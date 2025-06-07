//front_client\lib\main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:front_client/theme.dart';
import 'package:shared_carenest/providers/user_provider.dart';
import 'providers/children_provider.dart';
import 'auth/auth_wrapper.dart';
import 'firebase_options.dart';

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
        ChangeNotifierProvider(create: (_) => ChildrenProvider()),
      ],
      child: MaterialApp(
        title: 'CareNest',
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
      ),
    );
  }
}
