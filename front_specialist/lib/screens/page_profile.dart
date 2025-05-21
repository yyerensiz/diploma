import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'page_payments.dart';
import '../models/model_specialist.dart';
import '../providers/provider_specialist.dart';

class SpecialistProfilePage extends StatefulWidget {
  @override
  State<SpecialistProfilePage> createState() => _SpecialistProfilePageState();
}

class _SpecialistProfilePageState extends State<SpecialistProfilePage> {
  @override
  void initState() {
    super.initState();
    // Kick off loading once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpecialistProvider>().loadProfile();
    });
  }

  void _showEditDialog(SpecialistProfile profile) {
    final nameController    = TextEditingController(text: profile.fullName ?? "");
    final bioController     = TextEditingController(text: profile.bio ?? "");
    final pfpController     = TextEditingController(text: profile.pfpUrl ?? "");
    final hourlyRateController = TextEditingController(text: profile.hourlyRate?.toString() ?? "");
    final availableTimesController = TextEditingController(text: profile.availableTimes ?? "");
    final phoneController   = TextEditingController(text: profile.phone ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Редактировать профиль'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Имя')),
              TextField(controller: bioController, decoration: InputDecoration(labelText: 'Описание')),
              TextField(controller: pfpController, decoration: InputDecoration(labelText: 'Фото URL')),
              TextField(
                controller: hourlyRateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Часовая ставка'),
              ),
              TextField(controller: availableTimesController, decoration: InputDecoration(labelText: 'Доступное время')),
              TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Телефон')),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Сохранить'),
            onPressed: () async {
              final updated = SpecialistProfile(
                id:            profile.id,
                fullName:      nameController.text,
                bio:           bioController.text,
                pfpUrl:        pfpController.text.isEmpty ? null : pfpController.text,
                hourlyRate:    hourlyRateController.text.isEmpty
                    ? null
                    : double.tryParse(hourlyRateController.text),
                availableTimes: availableTimesController.text,
                phone:         phoneController.text,
                rating:        profile.rating,
                verified:      profile.verified,
                email:         profile.email,
              );
              await context.read<SpecialistProvider>().updateProfile(updated);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Профиль обновлён')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showVerificationDialog() {
    XFile? idDoc, certDoc;
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          title: Text('Загрузка документов'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() => idDoc = picked);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ID загружен')));
                  }
                },
                child: Text(idDoc != null ? 'ID загружен' : 'Загрузить удостоверение'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() => certDoc = picked);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Сертификат загружен')));
                  }
                },
                child: Text(certDoc != null ? 'Сертификат загружен' : 'Загрузить сертификат'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (idDoc == null || certDoc == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Загрузите оба документа')));
                  return;
                }
                await context.read<SpecialistProvider>().uploadVerificationDocs(idDoc!, certDoc!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Документы отправлены')));
              },
              child: Text('Отправить'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpecialistProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (provider.lastError != null) {
          return Center(child: Text('Ошибка: ${provider.lastError}'));
        }
        final profile = provider.profile;
        if (profile == null) {
          return Center(child: Text('Не удалось загрузить данные профиля.'));
        }

        // **Exact same padding and spacing as your old version**
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
                    backgroundImage: NetworkImage(
                      profile.pfpUrl ??
                          'https://i.pinimg.com/originals/c2/a0/82/c2a0829e2d070defdc51a5d81bb5988f.png',
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.fullName ?? '', style: Theme.of(context).textTheme.titleLarge),
                        SizedBox(height: 8),
                        Text('Email: ${profile.email ?? ''}'),
                        Text('Телефон: ${profile.phone ?? ''}'),
                        if ((profile.bio ?? '').isNotEmpty) Text('О себе: ${profile.bio}'),
                        if (profile.hourlyRate != null) Text('Часовая ставка: ${profile.hourlyRate}'),
                        if ((profile.availableTimes ?? '').isNotEmpty)
                          Text('Доступное время: ${profile.availableTimes}'),
                        if (profile.rating != null)
                          Text('Рейтинг: ${profile.rating!.toStringAsFixed(1)} ★'),
                        if (profile.verified == true)
                          Text('Статус: Верифицирован'),
                        if (profile.verified != true)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Статус: Не верифицирован'),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _showVerificationDialog,
                                child: Text('Пройти верификацию'),
                              ),
                            ],
                          ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _showEditDialog(profile),
                          child: Text('Редактировать'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              ProfileMenuButton(icon: Icons.history, title: 'История заказов', onTap: () {}),
              ProfileMenuButton(icon: Icons.payment,     title: 'Платежные данные', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PaymentPage()),
                );
              },),
              ProfileMenuButton(icon: Icons.security,    title: 'Настройки безопасности', onTap: () {}),
            ],
          ),
        );
      },
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
