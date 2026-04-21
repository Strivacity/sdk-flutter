import 'package:example/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final _controller = TextEditingController();

  void _navigateToLogin(BuildContext context, [OidcParams? params]) {
    final LoginPageArguments args = (optionalOidcParams: params, sessionId: null);
    Navigator.of(context).pushReplacementNamed('/login', arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Custom Audience",
                  helperText: "Optional audiences, separated by space",
                  suffixIcon: IconButton(
                    onPressed: () {
                      launchUrl(
                        Uri.parse(
                            'https://docs.strivacity.com/docs/oauth2-oidc-properties-setup#allowed-custom-audiences'),
                      ).ignore();
                    },
                    icon: Icon(Icons.help),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => _navigateToLogin(context, OidcParams(audiences: _controller.text.split(' '))),
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
      ),
    );
  }
}
