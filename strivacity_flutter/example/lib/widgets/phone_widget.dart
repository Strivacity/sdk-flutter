import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import '../styles.dart';

class PhoneWidget extends StatefulWidget {
  final PhoneWidgetModel config;
  final String formId;
  final LoginContext loginContext;

  const PhoneWidget({
    super.key,
    required this.formId,
    required this.loginContext,
    required this.config,
  });

  @override
  State<PhoneWidget> createState() => _PhoneWidgetState();
}

class _PhoneWidgetState extends State<PhoneWidget> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool valueChanged = false;
  String? modifiedLabel;

  BaseWidgetValidator? get validator {
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
            errorText: errorMessage,
          ),
        ),
        autofillHints: [AutofillHints.telephoneNumber],
        keyboardType: TextInputType.phone,
      ),
    );
  }
}
