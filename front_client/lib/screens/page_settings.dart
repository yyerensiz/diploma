import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool emailNotifications = true;
  bool smsNotifications = false;
  bool applySubsidies = true;
  ThemeMode currentTheme = ThemeMode.system;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: ListView(
        children: [
          SettingsSection(
            title: 'Уведомления',
            children: [
              SwitchListTile(
                title: Text('Включить уведомления'),
                subtitle: Text('Общие push-уведомления'),
                value: notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Email уведомления'),
                subtitle: Text('Получать уведомления на email'),
                value: emailNotifications,
                onChanged: notificationsEnabled
                    ? (bool value) {
                        setState(() {
                          emailNotifications = value;
                        });
                      }
                    : null,
              ),
              SwitchListTile(
                title: Text('SMS уведомления'),
                subtitle: Text('Получать уведомления по SMS'),
                value: smsNotifications,
                onChanged: notificationsEnabled
                    ? (bool value) {
                        setState(() {
                          smsNotifications = value;
                        });
                      }
                    : null,
              ),
            ],
          ),
          SettingsSection(
            title: 'Оплата',
            children: [
              SwitchListTile(
                title: Text('Применять субсидии'),
                subtitle: Text('Автоматически применять доступные государственные субсидии'),
                value: applySubsidies,
                onChanged: (bool value) {
                  setState(() {
                    applySubsidies = value;
                  });
                },
              ),
              ListTile(
                title: Text('Способы оплаты'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // Навигация к странице способов оплаты
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'Безопасность',
            children: [
              ListTile(
                title: Text('Изменить пароль'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // Навигация к странице изменения пароля
                },
              ),
              ListTile(
                title: Text('Двухфакторная аутентификация'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // Навигация к настройкам 2FA
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'Приложение',
            children: [
              ListTile(
                title: Text('Тема'),
                trailing: DropdownButton<ThemeMode>(
                  value: currentTheme,
                  onChanged: (ThemeMode? newValue) {
                    if (newValue != null) {
                      setState(() {
                        currentTheme = newValue;
                      });
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('Системная'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Светлая'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Темная'),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('Язык'),
                trailing: Text('Русский'),
                onTap: () {
                  // Навигация к выбору языка
                },
              ),
              ListTile(
                title: Text('О приложении'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // Показать информацию о приложении
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'Аккаунт',
            children: [
              ListTile(
                title: Text('Выйти'),
                leading: Icon(Icons.logout, color: Colors.red),
                titleTextStyle: TextStyle(color: Colors.red, fontSize: 16),
                onTap: _logout,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
        Material(
          color: Colors.white,
          child: Column(
            children: children,
          ),
        ),
        Divider(height: 1),
      ],
    );
  }
}
