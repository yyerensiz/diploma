//front_specialist\lib\screens\navbar.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'page_home.dart';
import 'page_settings.dart';
import 'page_profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onTap(int index) => setState(() => _selectedIndex = index);

  void _toggleLocale() {
    final locales = context.supportedLocales;
    final current = context.locale;
    final next = locales[(locales.indexOf(current) + 1) % locales.length];
    context.setLocale(next);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(),
      SpecialistProfilePage(),
    ];

    final labels = [
      'current_orders'.tr(),
      'profile'.tr(),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.translate),
          onPressed: _toggleLocale,
        ),
        title: Text(labels[_selectedIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: labels[0],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: labels[1],
          ),
        ],
      ),
    );
  }
}
