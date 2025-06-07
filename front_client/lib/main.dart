<<<<<<< HEAD
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/children_provider.dart';
import 'screens/auth_wrapper.dart';
import 'screens/main_screen.dart';
=======
//front_client\lib\main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:front_client/theme.dart';
import 'package:shared_carenest/providers/user_provider.dart';
import 'providers/children_provider.dart';
import 'auth/auth_wrapper.dart';
>>>>>>> yrys1
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
<<<<<<< HEAD
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const primaryColor = Color(0xFFFC3C59);
  static const secondaryColor = Color(0xFFE61A39); // Более темный оттенок основного
  static const backgroundColor = Color(0xFFFFE0E0);

  final MaterialColor customPrimary = MaterialColor(0xFFFC3C59, {
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
=======
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'), 
        Locale('kk', 'KZ'), 
        Locale('ru', 'RU'), 
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      //assetLoader: const JsonAssetLoader(useOnlyLangCode: true),

      child: const AppEntry(),
    ),
  );
}

class AppEntry extends StatelessWidget {
  const AppEntry({Key? key}) : super(key: key);
>>>>>>> yrys1

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChildrenProvider()),
      ],
      child: MaterialApp(
        title: 'CareNest',
<<<<<<< HEAD
        theme: ThemeData(
          primarySwatch: customPrimary,
          scaffoldBackgroundColor: backgroundColor,
          appBarTheme: AppBarTheme(
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
          textTheme: TextTheme(
            titleLarge: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(color: secondaryColor),
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
=======
        theme: CareNestTheme.light(),

        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,

        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) return supportedLocales.first;
          for (var supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
          return supportedLocales.first;
        },

        home: const ClientAuthWrapper(),
>>>>>>> yrys1
      ),
    );
  }
}
