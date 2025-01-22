import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import '../styles.dart';

class PasswordWidget extends StatefulWidget {
  final PasswordWidgetModel config;
  final String formId;
  final LoginContext loginContext;

  const PasswordWidget({
    super.key,
    required this.formId,
    required this.loginContext,
    required this.config,
  });

  @override
  State<PasswordWidget> createState() => _PasswordWidgetState();
}

class _PasswordWidgetState extends State<PasswordWidget> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool valueChanged = false;
  bool obscureText = true;

  PasswordWidgetValidator? get validator {
    return widget.config.validator;
  }

  String? get errorMessage {
    return widget.loginContext.messageContexts[widget.formId]?[widget.config.id];
  }

  bool get disabled {
    return widget.loginContext.loading;
  }

  @override
  void initState() {
    super.initState();

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        validate(controller.text);
        valueChanged = false;
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  void validate(String value) {
    if (validator == null || !valueChanged) {
      return;
    }

    String? errorMessage;

    if (validator!.required) {
      if (value.isEmpty) {
        errorMessage = 'This field is required';
      }
    }
    if (validator!.minLength != null) {
      if (value.length < validator!.minLength!) {
        errorMessage = 'This field must be at least ${validator!.minLength} characters long';
      }
    }
    if (validator!.maxLength != null) {
      if (value.length > validator!.maxLength!) {
        errorMessage = 'This field must be at most ${validator!.maxLength} characters long';
      }
    }
    if (validator!.maxRepeatedCharacters != null) {
      final maxRepeatedCharacters = validator!.maxRepeatedCharacters!;
      final minNotAllowedSequenceLength = maxRepeatedCharacters + 1;

      if (minNotAllowedSequenceLength <= value.length) {
        final characters = value.split('');
        var repeatedCharsSequenceLength = 1;

        for (var i = 1; i < value.length; ++i) {
          repeatedCharsSequenceLength = characters[i - 1] == characters[i] ? repeatedCharsSequenceLength + 1 : 1;

          if (repeatedCharsSequenceLength == minNotAllowedSequenceLength) {
            errorMessage = 'This field must not have more than $maxRepeatedCharacters repeated characters';
          }
        }
      }
    }
    if (validator!.maxNumericCharacterSequences != null) {
      final maxNumericCharacterSequences = validator!.maxNumericCharacterSequences!;
      final minNotAllowedSequenceLength = maxNumericCharacterSequences + 1;

      if (minNotAllowedSequenceLength <= value.length) {
        for (var i = 0; i < value.length - maxNumericCharacterSequences; ++i) {
          final substring = value.substring(i, i + minNotAllowedSequenceLength);

          if ('01234567890'.contains(substring) || '09876543210'.contains(substring)) {
            errorMessage = 'This field must not contain more than $maxNumericCharacterSequences numeric character sequences';
          }
        }
      }
    }

    setState(() {
      widget.loginContext.setMessage(widget.formId, widget.config.id, errorMessage);
    });
  }

  void onChanged(String value) {
    if (disabled) {
      return;
    }

    setState(() {
      widget.loginContext.setFormState(widget.formId, widget.config.id, value);
      valueChanged = true;
    });
  }

  void onSubmitted(String value) {
    if (disabled) {
      return;
    }

    widget.loginContext.submitForm(widget.formId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: Styles.paddingLarge),
      child: TextFormField(
        obscureText: obscureText,
        controller: controller,
        focusNode: focusNode,
        enabled: !disabled,
        onChanged: (value) => onChanged(value),
        onFieldSubmitted: (value) => onSubmitted(value),
        style: Styles.setInputTextStyle(),
        decoration: Styles.setInputDecoration(
          InputDecoration(
            enabled: !disabled,
            labelText: widget.config.label,
            errorText: errorMessage,
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: Styles.inputButtonColor,
              ),
              onPressed: togglePasswordVisibility,
            ),
          ),
        ),
      ),
    );
  }
}
