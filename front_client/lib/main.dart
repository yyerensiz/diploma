import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/children_provider.dart';
import 'auth/auth_wrapper.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppEntry());
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  Future<FirebaseApp> _initializeFirebase() async {
    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: Text('Error initializing Firebase')),
            ),
          );
        }
        return const MyApp();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  static const Color primaryColor = Color(0xFFFC3C59);
  static const Color secondaryColor = Color(0xFFE61A39);
  static const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);

  static const MaterialColor customPrimary = MaterialColor(0xFFFC3C59, {
    50: Color(0xFFFFE0E0),
    100: Color(0xFFFFB3B3),
    200: Color(0xFFFF8080),
    300: Color(0xFFFF4D4D),
    400: Color(0xFFFF2626),
    500: Color(0xFFFC3C59),
    600: Color(0xFFE61A39),
    700: Color(0xFFCC0000),
    800: Color(0xFFB30000),
    900: Color(0xFF990000),
  });

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChildrenProvider()),
      ],
      child: MaterialApp(
        title: 'CareNest',
        theme: ThemeData(
          primarySwatch: customPrimary,
          scaffoldBackgroundColor: backgroundColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: primaryColor,
            unselectedItemColor: secondaryColor.withOpacity(0.5),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(color: secondaryColor),
            bodyLarge: TextStyle(color: secondaryColor),
            bodyMedium: TextStyle(color: secondaryColor),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}
