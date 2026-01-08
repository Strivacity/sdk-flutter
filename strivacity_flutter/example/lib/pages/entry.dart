// ignore_for_file: avoid_print

import 'package:example/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

class EntryPage extends StatefulWidget {
  final StrivacitySDK sdk;

  const EntryPage({super.key, required this.sdk});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final Map<String, String> _params = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _extractArguments();
      _handleEntry();
    });
  }

  void _extractArguments() {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      for (final entry in arguments.entries) {
        if (entry.value != null) {
          _params[entry.key] = entry.value.toString();
        }
      }
    }
  }

  Future<void> _handleEntry() async {
    try {
      final sessionId = await widget.sdk.entry(_params);

      if (!mounted) {
        return;
      }

      if (sessionId.isNotEmpty) {
        final LoginPageArguments args =
            (optionalOidcParams: null, sessionId: sessionId);
        Navigator.of(context)
            .pushReplacementNamed('/login', arguments: args);
      } else {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (error) {
      _showAlert(error.toString());
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
