import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:front_client/services/service_child.dart';
import 'package:http/http.dart' as http;
import 'page_children_add.dart'; 
import '../../models/model_child.dart';
import '../../models/model_user.dart';
import '../../services/auth_service.dart';
import 'edit_profile.dart';
import 'page_payments.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? userProfile;
  bool isLoading = true;
  
  

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    _loadChildren();
  }

  Future<void> fetchUserProfile() async {
    try {
      // Replace with your actual API endpoint
      final user = FirebaseAuth.instance.currentUser;
      final firebaseToken = await user?.getIdToken();
      print('Firebase Token: $firebaseToken');
      final response = await http.get(Uri.parse('http://192.168.0.230:5000/api/auth/me'), 
        headers: {
          'Authorization': 'Bearer $firebaseToken',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('User data response: ${response.body}');

        setState(() {
          userProfile = UserProfile.fromJson(data['user']); // fix is here
          isLoading = false;
        });

      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  List<Child> _children = [];
  bool _loading = true;

  Future<void> _loadChildren() async {
    
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    final firebaseUid = user?.uid;
    if (token == null) {
        print(
          'Token is null. Cannot fetch children.',
        );
      return;
    }  // fresh token every time
    // final userId = await AuthService.getUserId();  // or from provider
    // if (token == null || userId == null) {
    //     print(
    //       'User ID is null. Cannot fetch children.',
    //     );
    //   return;
    // }
    final children = await ChildService().fetchChildren(token);
    setState(() {
      _children = children;
      _loading = false;
    });
  }


  void _openChildDetail(Child child) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditChildPage(child: child),
      ),
    );
    if (updated == true) {
      _loadChildren();
    }
  }

  @override
Widget build(BuildContext context) {
  if (isLoading) {
    return Center(child: CircularProgressIndicator());
  }

  if (userProfile == null) {
    return Center(child: Text('Ошибка загрузки профиля'));
  }

  return SingleChildScrollView(
    padding: EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Профиль', style: Theme.of(context).textTheme.headlineMedium),
        SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userProfile!.profileImageUrl),
            ),
            SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userProfile!.fullName, style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 8),
                  Text('Email: ${userProfile!.email}'),
                  Text('Телефон: ${userProfile!.phone}'),
                  Text('Адрес: ${userProfile!.address ?? "Не указан"}'),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(user: userProfile!),
                        ),
                      );
                      if (updated == true) {
                        fetchUserProfile(); // перезагрузить данные
                      }
                    },
                    child: Text('Редактировать'),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PageChildrenAdd()),
                      );
                    },
                    child: Text('Добавить ребенка'),
                  ),
                  
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 32),
        Text('Мои дети', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 16),
        _loading
            ? CircularProgressIndicator()
            : Container(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _children.length,
                  separatorBuilder: (_, __) => SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final child = _children[index];
                    return GestureDetector(
                      onTap: () => _openChildDetail(child),
                      child: ChildCard(
                        name: child.name,
                        age: _calculateAge(child.dateOfBirth),
                        imageUrl: child.pfpUrl != null && child.pfpUrl!.isNotEmpty 
                          ? child.pfpUrl 
                          : 'https://via.placeholder.com/100',
                      ),
                    );
                  },
                ),
              ),
        SizedBox(height: 32),
        ProfileMenuButton(
          icon: Icons.history,
          title: 'История заказов',
          onTap: () {
            // TODO: Навигация к истории заказов
          },
        ),
        ProfileMenuButton(
          icon: Icons.payment,
          title: 'Платежные данные',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PaymentPage()),
            );
          },
        ),
        ProfileMenuButton(
          icon: Icons.security,
          title: 'Настройки безопасности',
          onTap: () {
            // TODO: Навигация к настройкам безопасности
          },
        ),
      ],
    ),
    
  );
  
}
String _calculateAge(DateTime dob) {
  final today = DateTime.now();
  int age = today.year - dob.year;
  if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
    age--;
  }
  return '$age лет';
}



}

class ChildCard extends StatelessWidget {
  final String name;
  final String age;
  final String? imageUrl;

  const ChildCard({
    required this.name,
    required this.age,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl!),
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            age,
            style: Theme.of(context).textTheme.bodySmall,
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

class EditChildPage extends StatefulWidget {
  final Child child;
  EditChildPage({required this.child});

  @override
  _EditChildPageState createState() => _EditChildPageState();
}
class _EditChildPageState extends State<EditChildPage> {
  late TextEditingController _nameController;
  late DateTime _dob;
  late TextEditingController _bioController;
  late TextEditingController _pfpUrlController;


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child.name);
    _dob = widget.child.dateOfBirth;
    _bioController = TextEditingController(text: widget.child.bio ?? '');
    _pfpUrlController = TextEditingController(text: widget.child.pfpUrl ?? '');

  }
  
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  Future<void> _updateChild() async {
  final user = FirebaseAuth.instance.currentUser;
  final token = await user?.getIdToken();
  if (token == null) {
    // handle error
    return;
  }

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Токен отсутствует. Пожалуйста, войдите снова.')));
    return;
  }
  try {
    final updatedChild = Child(
      id: widget.child.id,
      name: _nameController.text,
      dateOfBirth: _dob,
      bio: _bioController.text,
      pfpUrl: _pfpUrlController.text,
    );

    await ChildService().updateChild(token, widget.child.id, updatedChild);
    Navigator.pop(context, true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при обновлении ребенка: $e')));
  }
}

    @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Редактировать данные')),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600), // optional, for web/tablet
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Имя ребенка'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: 'Биография'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _pfpUrlController,
              decoration: InputDecoration(labelText: 'URL фотографии'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text('Дата рождения: ${_dob.toLocal().toIso8601String().substring(0, 10)}')),
                TextButton(
                  onPressed: _selectDate,
                  child: Text('Изменить'),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateChild,
              child: Text('Сохранить'),
            ),
            SizedBox(height: 16),
            
          ],
        ),
      ),
    ),
  );
}

}
