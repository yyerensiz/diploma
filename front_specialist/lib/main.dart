//front_specialist\lib\main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:front_specialist/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_carenest/providers/user_provider.dart';
import 'auth/auth_wrapper.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/provider_specialist.dart';
import 'package:easy_localization/easy_localization.dart';



//main of client
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SpecialistProvider()),
      ],
      child: MaterialApp(
        title: 'CareNest Job',
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

        home: const SpecialistAuthWrapper(),
      ),
    );
  }
}

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => SpecialistProvider()),
//         ChangeNotifierProvider(create: (_) => UserProvider()),
//         // ... any other providers
//       ],
//       child: AppEntry(),
//     ),
//   );
// }


// class AppEntry extends StatelessWidget {
//   const AppEntry({super.key});

//   Future<FirebaseApp> _initializeFirebase() async {
//     return await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _initializeFirebase(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const MaterialApp(
//             home: Scaffold(
//               backgroundColor: Colors.white,
//               body: Center(child: CircularProgressIndicator()),
//             ),
//           );
//         } else if (snapshot.hasError) {
//           return MaterialApp(
//             home: Scaffold(
//               backgroundColor: Colors.white,
//               body: Center(child: Text('Error initializing Firebase')),
//             ),
//           );
//         }
//         return const MyApp();
//       },
//     );
//   }
// }


