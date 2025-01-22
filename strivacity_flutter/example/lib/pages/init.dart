import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

class InitPage extends StatelessWidget {
  final StrivacitySDK sdk;

  const InitPage({super.key, required this.sdk});

  Future<void> _navigate(BuildContext context) async {
    if (!context.mounted) return;

    if (await sdk.isAuthenticated) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/profile');
      }
    } else {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _navigate(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'My flutter app',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              SizedBox(height: 20.0),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
