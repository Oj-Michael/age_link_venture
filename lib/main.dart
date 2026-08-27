import 'dart:ui';

import 'package:agelink_venture/router.dart' show appRouter, initializeAppNavigation;
import 'package:agelink_venture/utils/app_theme.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeAppNavigation();
  runApp(const AgeLinkApp());
}

class AgeLinkApp extends StatelessWidget {
  const AgeLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AgeLink Venture',
      theme: AppTheme.build(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: true,
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      builder: (context, child) {
        final textScaler = MediaQuery.of(
          context,
        ).textScaler.clamp(maxScaleFactor: 1.0);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        );
      },
      routerConfig: appRouter,
    );
  }
}
