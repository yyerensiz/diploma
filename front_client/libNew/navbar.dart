//front_client\lib\navbar.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'features/orders/page_search_screen.dart';
import 'features/home/page_home.dart';
import 'features/profile/page_profile.dart';
import 'features/settings/page_settings.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

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
      SearchScreen(),
      HomePage(),
      ProfilePage(),
    ];
    final titles = [
      'services'.tr(),
      'home'.tr(),
      'profile'.tr(),
    ];
    final items = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.list),
        label: 'services'.tr(),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.home),
        label: 'home'.tr(),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person),
        label: 'profile'.tr(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.translate),
          onPressed: _toggleLocale,
        ),
        title: Text(titles[_selectedIndex]),
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
          )
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}
