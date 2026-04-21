import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginFallbackPage extends StatefulWidget {
  final StrivacitySDK sdk;

  const LoginFallbackPage({super.key, required this.sdk});

  @override
  State<LoginFallbackPage> createState() => _LoginFallbackPageState();
}

class _LoginFallbackPageState extends State<LoginFallbackPage> with WidgetsBindingObserver {
  bool _browserOpened = false;
  bool _launched = false;
  late StreamSubscription _appLinksSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // When a deep link redirect arrives (e.g. sty://callback?code=...),
    // onNewIntent fires before onResume on Android. Clearing the flag here
    // prevents the lifecycle observer from navigating to /init — main.dart
    // already handles the token exchange for this case.
    _appLinksSub = AppLinks().uriLinkStream.listen((_) {
      _appLinksSub.cancel();
      _browserOpened = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appLinksSub.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _browserOpened) {
      _browserOpened = false;

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/init');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_launched) {
      _launched = true;
      _launchFallback();
    }
  }

  Future<void> _launchFallback() async {
    try {
      Map? arguments = ModalRoute.of(context)!.settings.arguments as Map?;

      if (arguments == null || arguments['url'] == null) {
        throw Exception('Missing fallback URL');
      }

      final url = arguments['url'] as String;

      if (Platform.isIOS) {
        final redirectUri = Uri.parse(dotenv.env['STY_REDIRECT_URI']!);
        final callbackScheme = redirectUri.scheme;

        try {
          final callbackUrl = await FlutterWebAuth2.authenticate(
            url: url,
            callbackUrlScheme: callbackScheme,
            options: const FlutterWebAuth2Options(preferEphemeral: false),
          );

          await _handleCallbackUrl(Uri.parse(callbackUrl));
        } on Exception catch (e) {
          debugPrint(e.toString());
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/init');
          }
        }
      } else {
        if (await supportsLaunchMode(LaunchMode.inAppBrowserView)) {
          _browserOpened = true;
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.inAppBrowserView,
            browserConfiguration: const BrowserConfiguration(showTitle: false),
          );
        } else {
          debugPrint('In-app browser view is not supported on this platform');
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _handleCallbackUrl(Uri uri) async {
    if (!mounted) {
      return;
    }

    if (uri.queryParameters['session_id'] != null) {
      Navigator.of(context).pushReplacementNamed('/login', arguments: uri.queryParameters);
    } else if (uri.queryParameters['challenge'] != null) {
      Navigator.of(context).pushReplacementNamed('/entry', arguments: uri.queryParameters);
    } else {
      try {
        await widget.sdk.tokenExchange(uri.queryParameters);

        if (await widget.sdk.isAuthenticated) {
          if (mounted) Navigator.of(context).pushReplacementNamed('/profile');
        } else {
          if (mounted) Navigator.of(context).pushReplacementNamed('/init');
        }
      } on OIDCError catch (e) {
        debugPrint(e.toString());
        if (mounted) Navigator.of(context).pushReplacementNamed('/init');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(child: CircularProgressIndicator()),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/init');
          },
          child: Icon(Icons.close),
        ),
      ),
    );
  }
}
