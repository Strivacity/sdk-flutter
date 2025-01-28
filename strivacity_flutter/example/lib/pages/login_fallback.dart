import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

class LoginFallbackPage extends StatefulWidget {
  final StrivacitySDK sdk;

  const LoginFallbackPage({super.key, required this.sdk});

  @override
  State<LoginFallbackPage> createState() => _LoginFallbackPageState();
}

class _LoginFallbackPageState extends State<LoginFallbackPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _launchFallback();
  }

  _launchFallback() async {
    try {
      Map? arguments = ModalRoute.of(context)!.settings.arguments as Map?;

      if (arguments == null || arguments['url'] == null) {
        throw Exception('Missing fallback URL');
      }

      await launchUrl(
        Uri.parse(arguments['url'] as String),
        prefersDeepLink: true,
        customTabsOptions: CustomTabsOptions(
          shareState: CustomTabsShareState.off,
          urlBarHidingEnabled: false,
          showTitle: false,
        ),
        safariVCOptions: SafariViewControllerOptions(
          barCollapsingEnabled: false,
          entersReaderIfAvailable: false,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
