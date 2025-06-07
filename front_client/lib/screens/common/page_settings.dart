//front_client\lib\screens\common\page_settings.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../auth/login.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool emailNotifications = true;
  bool smsNotifications = false;
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
        title: Text('settings'.tr()),
      ),
      body: ListView(
        children: [
          SettingsSection(
            title: 'notifications'.tr(),
            children: [
              SwitchListTile(
                title: Text('enable_notifications'.tr()),
                subtitle: Text('push_notifications'.tr()),
                value: notificationsEnabled,
                onChanged: (value) => setState(() => notificationsEnabled = value),
              ),
              SwitchListTile(
                title: Text('email_notifications'.tr()),
                subtitle: Text('receive_email_notifications'.tr()),
                value: emailNotifications,
                onChanged: notificationsEnabled
                    ? (value) => setState(() => emailNotifications = value)
                    : null,
              ),
              SwitchListTile(
                title: Text('sms_notifications'.tr()),
                subtitle: Text('receive_sms_notifications'.tr()),
                value: smsNotifications,
                onChanged: notificationsEnabled
                    ? (value) => setState(() => smsNotifications = value)
                    : null,
              ),
            ],
          ),
          SettingsSection(
            title: 'application'.tr(),
            children: [
              ListTile(
                title: Text('theme'.tr()),
                trailing: DropdownButton<ThemeMode>(
                  value: currentTheme,
                  onChanged: (newValue) {
                    if (newValue != null) setState(() => currentTheme = newValue);
                  },
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('system'.tr()),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('light'.tr()),
                    ),
                    // DropdownMenuItem(
                    //   value: ThemeMode.dark,
                    //   child: Text('dark'.tr()),
                    // ),
                  ],
                ),
              ),
              ListTile(
                title: Text('about_app'.tr()),
                trailing: Icon(Icons.chevron_right),
                onTap: () { /* show about dialog */ },
              ),
            ],
          ),
          SettingsSection(
            title: 'account'.tr(),
            children: [
              ListTile(
                title: Text('logout'.tr()),
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
          child: Column(children: children),
        ),
        Divider(height: 1),
      ],
    );
  }
}
