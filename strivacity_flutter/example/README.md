# Strivacity Flutter SDK: Example

Flutter app for Android, iOS, macOS, and the web that demonstrates how to use the Strivacity Flutter SDK.

## Configuration

### 1. Creating your first application

Go to this [documentation]() and configure your [application](https://docs.strivacity.com/docs/creating-your-first-application) with a [native client](https://docs.strivacity.com/docs/clients).

### 2. Configure the example app

Rename the `.env.example` file to `.env`. Then, open it and fill in the values:

- `STY_ISSUER`: your cluster domain
- `STY_CLIENT_ID`: the client ID of your application
- `STY_SCOPES`: the scopes you want to request
- `STY_REDIRECT_URI`: the redirect URI of your application, for example `native://myapp`
- `STY_POST_LOGOUT_URI`: the post-logout URI of your application, for example `native://myapp`

### 3. Configure deep links

Before using the example app, you'll need to setup each platform you target. For example, if your redirect URI is `native://myapp`, the scheme is `native` and you should use it in the configurations below.

#### Android

Open `android/app/src/main/AndroidManifest.xml` and update the following:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="sty" /> <!-- Replace 'sty' with your redirect uri scheme -->
</intent-filter>
```

#### iOS

Open `ios/Runner/Info.plist` and update the following:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.example.example</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>sty</string> <!-- Replace 'sty' with your redirect uri scheme -->
        </array>
    </dict>
</array>
```

### 4. Run the app

Use the [Flutter CLI's](https://docs.flutter.dev/reference/flutter-cli) `run` command.

```sh
flutter run
```
