import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import '../styles.dart';

class InputWidget extends StatefulWidget {
  final InputWidgetModel config;
  final String formId;
  final LoginContext loginContext;

  const InputWidget({
    super.key,
    required this.formId,
    required this.loginContext,
    required this.config,
  });

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool valueChanged = false;
  String? modifiedLabel;

  InputWidgetValidator? get validator {
    return widget.config.validator;
  }

  String? get errorMessage {
    return widget.loginContext.messageContexts[widget.formId]?[widget.config.id];
  }

  bool get disabled {
    return widget.loginContext.loading || widget.config.readonly;
  }

  @override
  void initState() {
    super.initState();

    if (widget.config.value != null) {
      controller.text = widget.config.value!;
    }

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        validate(controller.text);
        valueChanged = false;
      }
    });

    if(widget.config.validator!.required) {
      modifiedLabel = widget.config.label;
    } else {
      modifiedLabel = '${widget.config.label} (Optional)';
    }
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
    if (validator!.regex != null) {
      if (!RegExp(validator!.regex!).hasMatch(value)) {
        errorMessage = 'This field is invalid';
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
            labelText: modifiedLabel,
            hintText: widget.config.placeholder,
            errorText: errorMessage,
          ),
        ),
        keyboardType: widget.config.inputmode,
        autofillHints: [widget.config.autocomplete ?? ''],
      ),
    );
  }
}
