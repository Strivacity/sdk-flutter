import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import '../styles.dart';

class SelectWidget extends StatefulWidget {
  final SelectWidgetModel config;
  final String formId;
  final LoginContext loginContext;

  const SelectWidget({
    super.key,
    required this.formId,
    required this.loginContext,
    required this.config,
  });

  @override
  State<SelectWidget> createState() => _SelectWidgetState();
}

class _SelectWidgetState extends State<SelectWidget> {
  final TextEditingController controller = TextEditingController();
  String? dropdownSelectValue;

  @override
  void initState() {
    super.initState();

    if (widget.config.options.length == 1) {
      final option = widget.config.options.first;

      if (option is SelectWidgetOption) {
        widget.loginContext.setFormState(widget.formId, widget.config.id, option.value);
      } else if (option is SelectWidgetOptionGroup && option.options.length == 1) {
        widget.loginContext.setFormState(widget.formId, widget.config.id, option.options.first.value);
      }
    }

    widget.loginContext.setFormState(widget.formId, widget.config.id, widget.config.value);

    // if there is only 1 element, select it
    if (widget.config.options[0].type == 'item' && widget.config.options.length == 1) {
       widget.loginContext.setFormState(widget.formId, widget.config.id, widget.config.options[0].value);
    } else if(widget.config.options[0].type == 'group' && widget.config.options[0]?.options.length == 1) {
      widget.loginContext.setFormState(widget.formId, widget.config.id, widget.config.options[0].options[0].value);
    }

    dropdownSelectValue = widget.config.value;
  }

  BaseWidgetValidator? get validator {
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

  void validate(String value) {
    if (validator == null) {
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

  void onChanged(String? value) {
    if (disabled) {
      return;
    }

    setState(() {
      widget.loginContext.setFormState(widget.formId, widget.config.id, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config.render.type == 'radio') {
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
                    return RadioListTile<String>(
                      value: subOption.value,
                      groupValue: widget.loginContext.formContexts[widget.formId]?[widget.config.id],
                      onChanged: disabled ? null : (value) => onChanged(value),
                      title: Text(
                        subOption.label ?? '',
                        style: TextStyle(color: Styles.textColor),
                      ),
                      contentPadding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity,
                      ),
                      activeColor: Styles.primaryColor,
                    );
                  }),
                ],
              );
            } else if (option is SelectWidgetOption) {
              return RadioListTile<String>(
                value: option.value,
                groupValue: widget.loginContext.formContexts[widget.formId]?[widget.config.id],
                onChanged: disabled ? null : (value) => onChanged(value),
                title: Text(
                  option.label ?? '',
                  style: TextStyle(color: Styles.textColor),
                ),
                contentPadding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(
                  horizontal: VisualDensity.minimumDensity,
                  vertical: VisualDensity.minimumDensity,
                ),
                activeColor: Styles.primaryColor,
              );
            }
            return Container();
          }),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: Styles.paddingLarge),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: dropdownSelectValue,
                decoration: Styles.setInputDecoration(
                  InputDecoration(
                    labelText: widget.config.label,
                    hintText: widget.config.placeholder,
                    errorText: errorMessage,
                  ),
                ),
                items: widget.config.options
                    .expand<DropdownMenuItem<String>>((option) {
                  if (option is SelectWidgetOptionGroup) {
                    return [
                      DropdownMenuItem<String>(
                        enabled: false,
                        child: Text(
                          option.label ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...option.options
                          .map<DropdownMenuItem<String>>((subOption) {
                        return DropdownMenuItem<String>(
                          value: dropdownSelectValue = subOption.value,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(subOption.label ?? ''),
                          ),
                        );
                      }),
                    ];
                  } else if (option is SelectWidgetOption) {
                    return [
                      DropdownMenuItem<String>(
                        value: dropdownSelectValue = option.value,
                        child: Text(option.label ?? ''),
                      )
                    ];
                  }
                  return [];
                }).toList(),
                onChanged: disabled ? null : (value) => onChanged(value),
                onTap: disabled ? () {} : null,
              ),
            ),
            TextButton(
              onPressed: disabled
                  ? null
                  : () {
                      setState(() {
                        dropdownSelectValue = null;
                        FocusScope.of(context).unfocus();
                        onChanged(null);
                      });
                    },
              child: Text('Clear'),
            )
          ],
        ),
      );
    }
  }
}
