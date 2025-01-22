import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import '../styles.dart';

class CheckboxWidget extends StatefulWidget {
  final CheckboxWidgetModel config;
  final String formId;
  final LoginContext loginContext;

  const CheckboxWidget({
    super.key,
    required this.formId,
    required this.loginContext,
    required this.config,
  });

  @override
  State<CheckboxWidget> createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  late bool checked;

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

    checked = widget.config.value ?? false;

    if (widget.config.render.type == 'checkboxHidden') {
      widget.loginContext.setFormState(widget.formId, widget.config.id, true);
    }
  }

  void validate(bool checked) {
    if (validator == null) {
      return;
    }

    String? errorMessage;

    if (validator!.required) {
      if (!checked) {
        errorMessage = 'This field is required';
      }
    }

    setState(() {
      widget.loginContext.setMessage(widget.formId, widget.config.id, errorMessage);
    });
  }

  void onChanged() {
    if (disabled) {
      return;
    }

    setState(() {
      checked = !checked;
      widget.loginContext.setFormState(widget.formId, widget.config.id, checked);
      validate(checked);
    });
  }

  Future<void> onLinkTap(String? url) async {
    if (url == null || !await launchUrl(Uri.parse(url))) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config.render.type == 'checkboxShown') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: checked,
            onChanged: disabled ? null : (_) => onChanged(),
            title: Html(
              data: widget.config.label,
              style: {'*': Style(fontSize: FontSize(Styles.textSizeMedium), margin: Margins.all(0)), 'a': Styles.linkStyle},
              onLinkTap: (url, attributes, element) => onLinkTap(url),
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
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                errorMessage!,
                style: TextStyle(color: Styles.errorColor),
              ),
            ),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: Styles.paddingSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Html(
              data: widget.config.label,
              style: {'*': Style(fontSize: FontSize(Styles.textSizeMedium), margin: Margins.all(0)), 'a': Styles.linkStyle},
              onLinkTap: (url, attributes, element) => onLinkTap(url),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Styles.errorColor),
                ),
              ),
          ],
        ),
      );
    }
  }
}
