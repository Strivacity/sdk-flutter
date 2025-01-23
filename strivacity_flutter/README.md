![Flutter SDK](https://static.strivacity.com/images/flutter-sdk.png)

[![Package](https://img.shields.io/pub/v/strivacity_flutter.svg)](https://pub.dartlang.org/packages/strivacity_flutter)

This SDK allows you to integrate Strivacity’s policy-driven journeys into your brand’s Flutter application. The SDK uses the OAuth 2.0 PKCE flow to authenticate with Strivacity.

See our [Developer Portal](https://www.strivacity.com/learn-support/developer-hub) to get started with developing the Strivacity product.

## Example app

See our [example app](https://github.com/Strivacity/sdk-flutter/blob/main/strivacity_flutter/example/README.md) for a comprehensive demonstration of how to integrate and use the Strivacity Flutter SDK in your own projects.

## How to include in your project

### Install

Add `strivacity_flutter` to your project:

```sh
flutter pub add strivacity_flutter
```

### Usage

#### Create your storage class

To manage the storage of authentication tokens and other data, create a custom storage class by extending the `SDKStorage` class. Here is an example using `flutter_keychain`:

```dart
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

class KeychainStorage extends SDKStorage {
  @override
  Future<void> clear() {
    return FlutterKeychain.clear();
  }

  @override
  Future<String?> get(String key) {
    return FlutterKeychain.get(key: key);
  }

  @override
  Future<void> put(String key, String value) {
    return FlutterKeychain.put(key: key, value: value);
  }

  @override
  Future<void> remove(String key) {
    return FlutterKeychain.remove(key: key);
  }
}
```

#### Create your view factory and widget classes

To customize the UI components used in the authentication flows, implement the `ViewFactory` interface. Example implementations for various widgets can be found in the [example app](https://github.com/strivacity/strivacity-flutter-example):

```dart
import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import 'widgets/checkbox_widget.dart';
import 'widgets/date_widget.dart';
import 'widgets/input_widget.dart';
import 'widgets/layout_widget.dart';
import 'widgets/multiselect_widget.dart';
import 'widgets/passcode_widget.dart';
import 'widgets/password_widget.dart';
import 'widgets/phone_widget.dart';
import 'widgets/select_widget.dart';
import 'widgets/static_widget.dart';
import 'widgets/submit_widget.dart';
import 'widgets/container_widget.dart';
import 'widgets/loading_widget.dart';

class CustomViewFactory implements ViewFactory {
  @override
  Widget getContainerWidget({required List<Widget> children}) {
    return ContainerWidget(children: children);
  }

  @override
  Widget getLoadingWidget() {
    return LoadingWidget();
  }

  @override
  Widget getCheckboxWidget({required Key key, required String formId, required CheckboxWidgetModel config, required LoginContext loginContext}) {
    return CheckboxWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getDateWidget({required Key key, required String formId, required DateWidgetModel config, required LoginContext loginContext}) {
    return DateWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getInputWidget({required Key key, required String formId, required InputWidgetModel config, required LoginContext loginContext}) {
    return InputWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getLayoutWidget({required Key key, required String type, required List<Widget> children}) {
    return LayoutWidget(key: key, type: type, children: children);
  }

  @override
  Widget getMultiSelectWidget({required Key key, required String formId, required MultiSelectWidgetModel config, required LoginContext loginContext}) {
    return MultiSelectWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getPasscodeWidget({required Key key, required String formId, required PasscodeWidgetModel config, required LoginContext loginContext}) {
    return PasscodeWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getPasswordWidget({required Key key, required String formId, required PasswordWidgetModel config, required LoginContext loginContext}) {
    return PasswordWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getPhoneWidget({required Key key, required String formId, required PhoneWidgetModel config, required LoginContext loginContext}) {
    return PhoneWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getSelectWidget({required Key key, required String formId, required SelectWidgetModel config, required LoginContext loginContext}) {
    return SelectWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getSubmitWidget({required Key key, required String formId, required SubmitWidgetModel config, required LoginContext loginContext}) {
    return SubmitWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getStaticWidget({required Key key, required StaticWidgetModel config}) {
    return StaticWidget(key: key, config: config);
  }
}
```

#### Use StrivacitySDK in your application

Initialize the `StrivacitySDK` in the `main.dart` file and pass the `sdk` into your login screen widget:

```dart
import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import 'login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  _sdk = StrivacitySDK(
    issuer: 'https://<your-cluster-domain>',
    clientId: '<your-client-id>',
    redirectUri: '<your-redirect-uri>',
    postLogoutRedirectUri: '<your-post-logout-redirect-uri>',
    scopes: ['openid', 'profile', 'email'],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strivacity Flutter Demo',
      home: LoginScreen(sdk: _sdk),
    );
  }
}
```

Create a `LoginScreen` widget in the `login_screen.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';
import 'pages/login/login_renderer.dart';

import 'view_factory.dart';

class LoginPage extends StatefulWidget {
  final StrivacitySDK sdk;

  const LoginPage({super.key, required this.sdk});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _onLogin(BuildContext context, IdTokenClaims idTokenClaims) {
    // Handle login success state
    // Example: redirect to a profile page
  }

  void _onError(BuildContext context, dynamic e, dynamic stackTrace) {
    // Handle errors
  }

  void _onFallback(BuildContext context, Uri uri) {
    // Open the provided uri in a webview
  }

  _onGlobalMessage(String msg) {
    // Display Strivacity global messages
    // For example: Show in a toast message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginRenderer(
        sdk: widget.sdk,
        viewFactory: CustomViewFactory(),
        onLogin: (idTokenClaims) => _onLogin(context, idTokenClaims),
        onError: (e, stackTrace) => _onError(context, e, stackTrace),
        onFallback: (uri) => _onFallback(context, uri),
        onGlobalMessage: (message) => _onGlobalMessage(message),
      ),
    );
  }
}
```

The `LoginRenderer` widget is responsible for rendering the login UI using the provided `StrivacitySDK` and `CustomViewFactory`. It also handles various events such as login success, errors, fallback URLs, and global messages.

## Contributing

Please see our [contributing guide](https://github.com/Strivacity/sdk-flutter/blob/main/strivacity_flutter/CONTRIBUTING.md).
