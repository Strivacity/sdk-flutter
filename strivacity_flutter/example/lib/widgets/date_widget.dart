import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import '../styles.dart';

class DateWidget extends StatefulWidget {
  final DateWidgetModel config;
  final String formId;
  final LoginContext loginContext;

  const DateWidget({
    super.key,
    required this.formId,
    required this.loginContext,
    required this.config,
  });

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool valueChanged = false;
  String? modifiedLabel;

  final TextEditingController yearController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController dayController = TextEditingController();

  DateWidgetValidator? get validator {
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

    if (widget.config.validator!.required) {
      modifiedLabel = widget.config.label;
    } else {
      modifiedLabel = '${widget.config.label} (Optional)';
    }
  }

  @override
  void dispose() {
    yearController.dispose();
    monthController.dispose();
    dayController.dispose();
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
    if (validator!.notBefore != null) {
      final notBefore = DateTime.parse(validator!.notBefore!);

      if (DateTime.parse(value).isBefore(notBefore)) {
        errorMessage = 'This field must be after ${notBefore.toLocal()}';
      }
    }
    if (validator!.notAfter != null) {
      final notAfter = DateTime.parse(validator!.notAfter!);

      if (DateTime.parse(value).isAfter(notAfter)) {
        errorMessage = 'This field must be before ${notAfter.toLocal()}';
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

  void onDatePartChanged() {
    String year = yearController.text.padLeft(4, '0');
    String month = monthController.text.padLeft(2, '0');
    String day = dayController.text.padLeft(2, '0');
    String formattedDate = '$year-$month-$day';
    onChanged(formattedDate);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config.render.type == 'native') {
      return Container(
        margin: EdgeInsets.only(top: Styles.paddingLarge),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            GestureDetector(
              onTap: () async {
                if (disabled) return;
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  String formattedDate =
                      pickedDate.toLocal().toString().split(' ')[0];
                  controller.text = formattedDate;
                  onChanged(formattedDate);
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: !disabled,
                  onChanged: (value)  => onChanged(value),
                  onFieldSubmitted: (value) => onSubmitted(value),
                  style: Styles.setInputTextStyle(),
                  decoration: Styles.setInputDecoration(
                    InputDecoration(
                      enabled: !disabled,
                      labelText: modifiedLabel,
                      hintText: widget.config.placeholder,
                      errorText: errorMessage,
                      contentPadding: EdgeInsets.only(left: 12, right: 50),
                    ),
                  ),
                ),
              ),
            ),

            if (controller.text.isNotEmpty)
              Positioned(
                right: 40, 
                child: GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged(""); 
                  },
                  child: Icon(Icons.clear, color: Colors.grey),
                ),
              ),

            Positioned(
              right: 8,
              child: GestureDetector(
                onTap: () async {
                  if (disabled) return;
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    String formattedDate =
                        pickedDate.toLocal().toString().split(' ')[0];
                    controller.text = formattedDate;
                    onChanged(formattedDate);
                  }
                },
                child: Icon(Icons.calendar_today),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(top: Styles.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.config.label ?? '', style: Styles.setInputTextStyle()),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    decoration: Styles.setInputDecoration(
                      InputDecoration(
                        labelText: 'Year',
                        hintText: 'YYYY',
                      ),
                    ),
                    onChanged: (value) => onDatePartChanged(),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: monthController,
                    keyboardType: TextInputType.number,
                    decoration: Styles.setInputDecoration(
                      InputDecoration(
                        labelText: 'Month',
                        hintText: 'MM',
                      ),
                    ),
                    onChanged: (value) => onDatePartChanged(),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: dayController,
                    keyboardType: TextInputType.number,
                    decoration: Styles.setInputDecoration(
                      InputDecoration(
                        labelText: 'Day',
                        hintText: 'DD',
                      ),
                    ),
                    onChanged: (value) => onDatePartChanged(),
                  ),
                ),
              ],
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      );
    }
  }
}
