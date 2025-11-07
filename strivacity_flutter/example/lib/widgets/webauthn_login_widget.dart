import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import '../styles.dart';

class WebauthnLoginWidget extends StatelessWidget {
  final WebauthnLoginWidgetModel config;
  final String formId;
  final LoginContext loginContext;

  const WebauthnLoginWidget({
    super.key,
    required this.formId,
    required this.loginContext,
    required this.config,
  });

  bool get loading {
    return loginContext.loading;
  }

  Future<void> onPressed() async {
    try {
      final result = await PasskeyService.authenticate(config.assertionOptions);

      loginContext.setFormState(formId, config.id, result);
      await loginContext.submitForm(formId);
    } on PasskeyException catch (e) {
      loginContext.setMessage('global', 'passkey', e.message);
    } catch (e) {
      loginContext.setMessage('global', 'passkey', 'Authentication failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (config.render.type == 'button') {
      return Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: Styles.marginLarge, bottom: Styles.marginMedium),
          child: ElevatedButton(
            onPressed: loading ? null : () => onPressed(),
            style: ElevatedButton.styleFrom(
              backgroundColor: config.render.hint?.variant == 'primary' ? Styles.primaryColor : Styles.whiteColor,
              foregroundColor: config.render.hint?.variant == 'primary' ? Styles.whiteColor : Styles.primaryColor,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: Styles.paddingMedium, horizontal: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Styles.borderRadiusMedium)),
            ),
            child: Text(
              config.label ?? '',
              style: TextStyle(
                fontSize: Styles.textSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ));
    } else {
      return GestureDetector(
        onTap: loading ? null : () => onPressed(),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: Styles.marginSmall, horizontal: Styles.marginSmall),
          color: Styles.transparentColor,
          child: Text(
            config.label ?? '',
            style: TextStyle(
              color: Styles.primaryColor,
              fontSize: Styles.textSizeMedium,
            ),
          ),
        ),
      );
    }
  }
}
