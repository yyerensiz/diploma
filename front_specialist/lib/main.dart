import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_carenest/providers/user_provider.dart';
import 'auth/auth_wrapper.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/provider_specialist.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpecialistProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // ... any other providers
      ],
      child: AppEntry(),
    ),
  );
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
  static const Color primaryColor = Color(0xFF3366FF); // NEW for specialist
  static const Color secondaryColor = Color(0xFF003399); // NEW for specialist
  static const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);

  static const MaterialColor customPrimary = MaterialColor(0xFF3366FF, {
    50: Color(0xFFE3EFFF),
    100: Color(0xFFB3D4FF),
    200: Color(0xFF80B9FF),
    300: Color(0xFF4D9EFF),
    400: Color(0xFF2688FF),
    500: Color(0xFF3366FF),
    600: Color(0xFF004DE6),
    700: Color(0xFF003BB3),
    800: Color(0xFF002980),
    900: Color(0xFF00174D),
  });

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareNest Job',
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
        home: SpecialistAuthWrapper(),
        supportedLocales: const [
          Locale('en', ''),
          Locale('ru', ''),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
    );
  }
}
