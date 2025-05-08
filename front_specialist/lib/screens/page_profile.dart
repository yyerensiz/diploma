import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpecialistProfilePage extends StatefulWidget {
  @override
  _SpecialistProfilePageState createState() => _SpecialistProfilePageState();
}

class _SpecialistProfilePageState extends State<SpecialistProfilePage> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final token = await user.getIdToken();
      final response = await http.get(
        Uri.parse('http://192.168.0.230:5000/api/specialists/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
          setState(() {
              profileData = json.decode(response.body);  // Обновление данных профиля
              isLoading = false;
          });
      } else {
          setState(() {
              isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось загрузить данные')));
      }

    } catch (e) {
      print('Error fetching profile: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось загрузить данные')));

    }
    
  }
  void _showEditDialog(BuildContext context, Map<String, dynamic> profile ) {
  final nameController = TextEditingController(text: profile['full_name']);
  final bioController = TextEditingController(text: profile['bio']);
  final pfpController = TextEditingController(text: profile['pfp_url']);
  

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Редактировать профиль'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Имя')),
            TextField(controller: bioController, decoration: InputDecoration(labelText: 'Описание')),
            TextField(controller: pfpController, decoration: InputDecoration(labelText: 'Фото URL')),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Сохранить'),
          onPressed: () async {
              final updatedProfile = {
                  'full_name': nameController.text,
                  'bio': bioController.text,
                  'pfp_url': pfpController.text.isEmpty ? null : pfpController.text, // Handle null value
              };

              final token = await FirebaseAuth.instance.currentUser?.getIdToken();
              print('Token: $token');



              final response = await http.put(
                  Uri.parse('http://192.168.0.230:5000/api/specialists/profile'),
                  headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                  },
                  body: json.encode(updatedProfile),
              );

              Navigator.pop(context);

              if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Профиль обновлён')));
                  await fetchProfile(); // Перезагружаем профиль после успешного обновления
              } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при обновлении')));
              }
          },
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : profileData == null
            ? Center(child: Text('Не удалось загрузить данные профиля.'))
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Профиль',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            profileData!['pfp_url'] ??
                                'https://i.pinimg.com/originals/c2/a0/82/c2a0829e2d070defdc51a5d81bb5988f.png',
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profileData!['full_name'] ?? '',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 8),
                              Text('Email: ${profileData!['email'] ?? ''}'),
                              Text('Телефон: ${profileData!['phone'] ?? ''}'),
                              if (profileData!['bio'] != null)
                                Text('О себе: ${profileData!['bio']}'),
                              if (profileData!['experience_years'] != null)
                                Text('Опыт: ${profileData!['experience_years']} лет'),
                              if (profileData!['rating'] != null)
                                Text('Рейтинг: ${profileData!['rating'].toStringAsFixed(1)} ★'),
                              if (profileData!['verified'] == true)
                                Text('Статус: Верифицирован'),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                if (profileData != null) {
                                  _showEditDialog(context, profileData!);
                                }
                              },
                                child: Text('Редактировать'),
                              )

                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    ProfileMenuButton(
                      icon: Icons.description,
                      title: 'Документы',
                      onTap: () {
                        // Навигация к документам
                      },
                    ),
                    ProfileMenuButton(
                      icon: Icons.history,
                      title: 'История заказов',
                      onTap: () {
                        // Навигация к истории заказов
                      },
                    ),
                    ProfileMenuButton(
                      icon: Icons.security,
                      title: 'Настройки безопасности',
                      onTap: () {
                        // Навигация к безопасности
                      },
                    ),
                  ],
                ),
              );
  }
}

class ProfileMenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
