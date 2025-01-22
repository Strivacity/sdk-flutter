import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import 'styles.dart';
import 'storage.dart';
import 'pages/init.dart';
import 'pages/home.dart';
import 'pages/profile.dart';
import 'pages/login.dart';
import 'pages/login_fallback.dart';

Future<dynamic> main() async {
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final StrivacitySDK sdk = StrivacitySDK(
    tenantConfiguration: TenantConfiguration(
      issuer: dotenv.env['STY_ISSUER']!,
      clientId: dotenv.env['STY_CLIENT_ID']!,
      scopes: dotenv.env['STY_SCOPES']!.split(' '),
      redirectUri: dotenv.env['STY_REDIRECT_URI']!,
      postLogoutUri: dotenv.env['STY_POST_LOGOUT_URI']!,
    ),
    storage: KeychainStorage(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Styles.backgroundColor,
      ),
      home: InitPage(sdk: sdk),
      routes: {
        '/init': (context) => InitPage(sdk: sdk),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(sdk: sdk),
        '/login': (context) => LoginPage(sdk: sdk),
        '/login-fallback': (context) => LoginFallbackPage(sdk: sdk),
      },
    );
  }
}
