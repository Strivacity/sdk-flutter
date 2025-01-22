import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import '../styles.dart';

class PasscodeWidget extends StatefulWidget {
  final PasscodeWidgetModel config;
  final String formId;
  final LoginContext loginContext;

  const PasscodeWidget({
    super.key,
    required this.formId,
    required this.loginContext,
    required this.config,
  });

  @override
  State<PasscodeWidget> createState() => _PasscodeWidgetState();
}

class _PasscodeWidgetState extends State<PasscodeWidget> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool valueChanged = false;

  PasscodeWidgetValidator? get validator {
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

  void validate(String value) {
    if (validator == null || !valueChanged) {
      return;
    }

    String? errorMessage;

    if (validator!.length != null) {
      if (value.length != validator!.length) {
        errorMessage = 'This field must be exactly ${validator!.length} characters long';
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
          ),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
        ],
        autofillHints: [AutofillHints.oneTimeCode],
      ),
    );
  }
}
