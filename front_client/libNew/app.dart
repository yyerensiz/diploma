//front_client\lib\app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/provider_children.dart';
import 'core/providers/provider_info.dart';
import 'core/providers/provider_order.dart';
import 'core/providers/provider_payment.dart';
import 'core/providers/provider_review.dart';
import 'core/providers/provider_specialist.dart';
import 'features/auth/auth_wrapper.dart';
import 'navbar.dart';
import 'theme.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChildrenProvider()),
        ChangeNotifierProvider(create: (_) => InfoProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => SpecialistProvider()),
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
        home: ClientAuthWrapper(),
      ),
    );
  }
}
