//front_client\lib\features\settings\page_settings.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/widgets/section_settings.dart';
import '../../core/widgets/profile_button.dart';
import 'widget_settings_section.dart';
import '../../features/auth/page_login.dart';

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
        MaterialPageRoute(builder: (_) => const LoginPage(appName: '', tagline: '')),
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
          SectionSettings(
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
          SectionSettings(
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
                  ],
                ),
              ),
              ListTile(
                title: Text('about_app'.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
          SectionSettings(
            title: 'account'.tr(),
            children: [
              ProfileButton(
                icon: Icons.logout,
                title: 'logout'.tr(),
                onTap: _logout,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
