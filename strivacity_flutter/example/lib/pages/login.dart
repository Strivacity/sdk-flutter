// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import '../view_factory.dart';

class LoginPage extends StatefulWidget {
  final StrivacitySDK sdk;

  const LoginPage({super.key, required this.sdk});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  OidcParams? _params;
  String? _sessionId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null && arguments['params'] != null) {
      final params = arguments['params'] as Map<String, dynamic>;
      _params = OidcParams(
        prompt: params['prompt'],
        loginHint: params['login_hint'],
        acrValues: params['acr_values']?.cast<String>(),
        scopes: params['scopes']?.cast<String>(),
      );
    }

    if (arguments != null && arguments['session_id'] != null) {
      _sessionId = arguments['session_id'] as String;
    }
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

  void _onLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/profile');
  }

  void _onError(BuildContext context, dynamic e, dynamic stackTrace) {
    debugPrint(e.toString());
    debugPrint(stackTrace.toString());
    _showErrorToast(e.toString());
  }

  void _onFallback(BuildContext context, Uri uri, String? errorMessage) {
    debugPrint('Fallback error: ${errorMessage ?? 'Unknown'}');
    Navigator.of(context).pushReplacementNamed('/login-fallback', arguments: {'url': uri.toString()});
  }

  _onGlobalMessage(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
      webShowClose: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 64.0, bottom: 16.0),
          child: LoginRenderer(
            sdk: widget.sdk,
            viewFactory: CustomViewFactory(),
            params: _params,
            sessionId: _sessionId,
            onLogin: (_) => _onLogin(context),
            onError: (e, stackTrace) => _onError(context, e, stackTrace),
            onFallback: (uri, errorMessage) => _onFallback(context, uri, errorMessage),
            onGlobalMessage: _onGlobalMessage,
          ),
        ),
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
