import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _navigateToLogin(BuildContext context, [OidcParams? params]) {
    Navigator.of(context).pushReplacementNamed('/login', arguments: {'params': params?.toJson()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToLogin(context),
              child: Text('Login'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _navigateToLogin(context, OidcParams(prompt: 'create')),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
