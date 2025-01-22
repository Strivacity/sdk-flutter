// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

class LoginFallbackPage extends StatefulWidget {
  final StrivacitySDK sdk;

  const LoginFallbackPage({super.key, required this.sdk});

  @override
  State<LoginFallbackPage> createState() => _LoginFallbackPageState();
}

class _LoginFallbackPageState extends State<LoginFallbackPage> {
  late WebViewController webViewController;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    webViewController = WebViewController();
  }

  @override
  void didChangeDependencies() {
    Map? arguments = ModalRoute.of(context)!.settings.arguments as Map?;

    if (arguments == null || arguments['url'] == null) {
      return _onError('Missing fallback URL');
    }

    webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    webViewController.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) async {
          if (_hasNavigated) {
            return NavigationDecision.prevent;
          } else if (request.url.startsWith(widget.sdk.tenantConfiguration.redirectUri.toString())) {
            try {
              _hasNavigated = true;

              _onLogin(Uri.parse(request.url).queryParameters);
            } catch (e, stackTrace) {
              _onError(e, stackTrace);
            }

            return NavigationDecision.prevent;
          } else {
            return NavigationDecision.navigate;
          }
        },
      ),
    );
    webViewController.loadRequest(Uri.parse(arguments['url'] as String));

    super.didChangeDependencies();
  }

  Future<void> _onLogin(Map<String, String> queryParameters) async {
    try {
      await widget.sdk.tokenExchange(queryParameters);

      if (await widget.sdk.isAuthenticated) {
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/profile');
        }
      } else {
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/init');
        }
      }
    } catch (e) {
      // Session timeout
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/init');
      }
    }
  }

  void _onError(dynamic e, [dynamic stackTrace]) {
    log(e);
    log(stackTrace);
    _showErrorToast(e.toString());
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: WebViewWidget(controller: webViewController),
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
