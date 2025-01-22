import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import '../styles.dart';

class ProfilePage extends StatelessWidget {
  final StrivacitySDK sdk;

  const ProfilePage({super.key, required this.sdk});

  Future<void> _handleRefresh(BuildContext context) async {
    await sdk.refresh();

    if (!await sdk.isAuthenticated) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/init');
      }
    } else {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/profile');
      }
    }
  }

  Future<void> _handleRevoke(BuildContext context) async {
    await sdk.revoke();

    if (!await sdk.isAuthenticated) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/init');
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    await sdk.logout();

    if (!await sdk.isAuthenticated) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/init');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Welcome ${sdk.idTokenClaims?.data['given_name']} ${sdk.idTokenClaims?.data['family_name']}!'),
          automaticallyImplyLeading: false,
          backgroundColor: Styles.backgroundColor,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 64.0, bottom: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'accessToken',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(sdk.accessToken ?? 'null'),
              const SizedBox(height: 16),
              if (sdk.refreshToken != null) ...[
                Text(
                  'refreshToken',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(sdk.refreshToken ?? 'null'),
                const SizedBox(height: 16),
              ],
              Text(
                'accessTokenExpiration',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(sdk.idTokenClaims?.expirationTime.toString() ?? 'null'),
              const SizedBox(height: 16),
              Text(
                'claims',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var entry in sdk.idTokenClaims?.data.entries ?? <MapEntry<String, dynamic>>[]) ...[
                      Text(
                        '${entry.key}:',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(entry.value is List ? entry.value.join(', ') : entry.value.toString()),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (sdk.refreshToken != null)
                      ListTile(
                        leading: const Icon(Icons.refresh),
                        title: const Text('Refresh token'),
                        onTap: () => _handleRefresh(context),
                      ),
                    ListTile(
                      leading: const Icon(Icons.block),
                      title: const Text('Revoke token'),
                      onTap: () => _handleRevoke(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () => _handleLogout(context),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.menu),
        ),
      ),
    );
  }
}
