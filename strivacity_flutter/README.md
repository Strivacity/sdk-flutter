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

To manage the storage of authentication tokens and other data, create a custom storage class by extending the `SDKStorage` class. Here is an example using `flutter_secure_storage`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

class KeychainStorage extends SDKStorage {
  final storage = FlutterSecureStorage();

  @override
  Future<void> clear() {
    return storage.deleteAll();
  }

  @override
  Future<String?> get(String key) {
    return storage.read(key: key);
  }

  @override
  Future<void> put(String key, String value) {
    return storage.write(key: key, value: value);
  }

  @override
  Future<void> remove(String key) {
    return storage.delete(key: key);
  }
}
```

#### Create your view factory and widget classes

To customize the UI components used in the authentication flows, implement the `ViewFactory` interface. Example implementations for various widgets can be found in the [example app](https://github.com/Strivacity/sdk-flutter/blob/main/strivacity_flutter/example/README.md):

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
import 'widgets/close_widget.dart';
import 'widgets/passkey_login_widget.dart';
import 'widgets/passkey_enroll_widget.dart';
import 'widgets/webauthn_login_widget.dart';
import 'widgets/webauthn_enroll_widget.dart';
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
  Widget getCloseWidget({required Key key, required String formId, required CloseWidgetModel config, required LoginContext loginContext}) {
    return CloseWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getPasskeyLoginWidget({required Key key, required String formId, required PasskeyLoginWidgetModel config, required LoginContext loginContext}) {
    return PasskeyLoginWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getPasskeyEnrollWidget({required Key key, required String formId, required PasskeyEnrollWidgetModel config, required LoginContext loginContext}) {
    return PasskeyEnrollWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getWebauthnLoginWidget({required Key key, required String formId, required WebauthnLoginWidgetModel config, required LoginContext loginContext}) {
    return WebauthnLoginWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getWebauthnEnrollWidget({required Key key, required String formId, required WebauthnEnrollWidgetModel config, required LoginContext loginContext}) {
    return WebauthnEnrollWidget(key: key, formId: formId, config: config, loginContext: loginContext);
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

## Passkey Configuration

To enable passkey support in your Flutter application, you need to configure platform-specific settings for both iOS and Android.

### iOS Configuration

Add the associated domain to your `ios/Runner/Runner.entitlements` file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.developer.associated-domains</key>
	<array>
		<string>webcredentials:your-cluster-domain?mode=developer</string>
	</array>
</dict>
</plist>
```

Replace `your-cluster-domain` with your Strivacity cluster domain (e.g., `example.strivacity.com`).

**Note:** Remove the `?mode=developer` parameter when deploying to production.

### Android Configuration

Add the Digital Asset Links intent filter to your `android/app/src/main/AndroidManifest.xml` file inside the `<activity>` tag:

```xml
<!-- Digital Asset Links for Passkey support -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" />
    <data android:host="your-cluster-domain" />
</intent-filter>
```

Replace `your-cluster-domain` with your Strivacity cluster domain (e.g., `example.strivacity.com`).

## Contributing

Please see our [contributing guide](https://github.com/Strivacity/sdk-flutter/blob/main/strivacity_flutter/CONTRIBUTING.md).
