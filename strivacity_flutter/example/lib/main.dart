import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final appLinks = AppLinks();

  final _nav = GlobalKey<NavigatorState>();
  late StreamSubscription sub;

  @override
  void initState() {
    super.initState();

    _watchLinkStream();
  }

  @override
  void dispose() {
    super.dispose();

    sub.cancel();
  }

  Future<void> _watchLinkStream() async {
    sub = appLinks.uriLinkStream.listen((uri) async {
      try {
        closeCustomTabs();

        // Clear the navigation stack
        _nav.currentState!.popUntil((r) => r.isFirst);

        if (uri.queryParameters['session_id'] != null) {
          _nav.currentState!.pushReplacementNamed('/login', arguments: {'session_id': uri.queryParameters['session_id']});
        } else {
          try {
            await sdk.tokenExchange(uri.queryParameters);
          } on OIDCError catch (e) {
            _showErrorToast(e.toString());
          }

          if (await sdk.isAuthenticated) {
            _nav.currentState!.pushReplacementNamed('/profile');
          } else {
            _nav.currentState!.pushReplacementNamed('/init');
          }
        }
      } catch (e) {
        // Session timeout
        _nav.currentState!.pushReplacementNamed('/init');
      }
    });
  }

  void _showErrorToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _nav,
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
