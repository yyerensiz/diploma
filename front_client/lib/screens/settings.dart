import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person, color: theme.primaryColor),
            title: Text(
              'Profile Settings',
              style: theme.textTheme.titleMedium,
            ),
            onTap: () {
              // Navigate to profile settings
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: theme.primaryColor),
            title: Text(
              'Notification Settings',
              style: theme.textTheme.titleMedium,
            ),
            onTap: () {
              // Navigate to notification settings
            },
          ),
          ListTile(
            leading: Icon(Icons.language, color: theme.primaryColor),
            title: Text(
              'Language',
              style: theme.textTheme.titleMedium,
            ),
            onTap: () {
              // Navigate to language settings
            },
          ),
          ListTile(
            leading: Icon(Icons.payment, color: theme.primaryColor),
            title: Text(
              'Payment Methods',
              style: theme.textTheme.titleMedium,
            ),
            onTap: () {
              // Navigate to payment settings
            },
          ),
          ListTile(
            leading: Icon(Icons.security, color: theme.primaryColor),
            title: Text(
              'Privacy and Security',
              style: theme.textTheme.titleMedium,
            ),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: theme.primaryColor),
            title: Text(
              'Help and Support',
              style: theme.textTheme.titleMedium,
            ),
            onTap: () {
              // Navigate to help section
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: theme.primaryColor),
            title: Text(
              'About',
              style: theme.textTheme.titleMedium,
            ),
            onTap: () {
              // Navigate to about section
            },
          ),
        ],
      ),
    );
  }
} 