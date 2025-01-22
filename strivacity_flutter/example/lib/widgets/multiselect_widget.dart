import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import '../styles.dart';

class MultiSelectWidget extends StatefulWidget {
  final MultiSelectWidgetModel config;
  final String formId;
  final LoginContext loginContext;

  const MultiSelectWidget({
    super.key,
    required this.formId,
    required this.loginContext,
    required this.config,
  });

  @override
  State<MultiSelectWidget> createState() => _MultiSelectWidgetState();
}

class _MultiSelectWidgetState extends State<MultiSelectWidget> {
  final TextEditingController controller = TextEditingController();

  MultiSelectWidgetValidator? get validator {
    return widget.config.validator;
  }

  String? get errorMessage {
    return widget.loginContext.state.messages?[widget.formId]?[widget.config.id]?.text;
  }

  bool get disabled {
    return widget.loginContext.loading || widget.config.readonly;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void validate(List<String> values) {
    if (validator == null) {
      return;
    }

    String? errorMessage;

    if (validator!.minSelectable != null && values.length < validator!.minSelectable!) {
      if (values.isEmpty) {
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

    final currentValues = widget.loginContext.formContexts[widget.formId]?[widget.config.id] as List<String>? ?? [];
    final newValues = List<String>.from(currentValues);

    if (newValues.contains(value)) {
      newValues.remove(value);
    } else {
      newValues.add(value);
    }

    setState(() {
      widget.loginContext.setFormState(widget.formId, widget.config.id, newValues);
      validate(newValues);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: widget.config.label != null ? Styles.paddingLarge : 0, bottom: Styles.paddingMedium),
          child: Text(
            widget.config.label ?? '',
            style: TextStyle(fontSize: Styles.textSizeMedium, color: Styles.textColor),
          ),
        ),
        ...widget.config.options.map<Widget>((option) {
          if (option is SelectWidgetOptionGroup) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.label ?? '',
                  style: TextStyle(fontSize: Styles.textSizeMedium, color: Styles.textColor),
                ),
                ...option.options.map<Widget>((subOption) {
                  return CheckboxListTile(
                    value: (widget.loginContext.formContexts[widget.formId]?[widget.config.id] as List<String>?)?.contains(subOption.value) ?? false,
                    onChanged: (selected) => onChanged(subOption.value),
                    title: Text(
                      subOption.label ?? '',
                      style: TextStyle(color: Styles.textColor),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),
                    activeColor: Styles.primaryColor,
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  );
                }),
              ],
            );
          } else if (option is SelectWidgetOption) {
            return CheckboxListTile(
              value: (widget.loginContext.formContexts[widget.formId]?[widget.config.id] as List<String>?)?.contains(option.value) ?? false,
              onChanged: (selected) => onChanged(option.value),
              title: Text(
                option.label ?? '',
                style: TextStyle(fontSize: Styles.textSizeMedium, color: Styles.textColor),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity,
              ),
              activeColor: Styles.primaryColor,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            );
          }
          return Container();
        }),
      ],
    );
  }
}
