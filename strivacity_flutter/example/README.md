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

### 3. Run the app

Use the [Flutter CLI's](https://docs.flutter.dev/reference/flutter-cli) `run` command.

```sh
flutter run
```
