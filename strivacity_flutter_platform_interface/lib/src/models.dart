import 'package:flutter/material.dart';

class BrandingData {
  final String? logoUrl;
  final String? brandName;
  final String? copyright;
  final String? privacyPolicyUrl;
  final String? siteTermsUrl;

  BrandingData({
    this.logoUrl,
    this.brandName,
    this.copyright,
    this.privacyPolicyUrl,
    this.siteTermsUrl,
  });

  factory BrandingData.fromJson(Map<String, dynamic> json) {
    return BrandingData(
      logoUrl: json['logoUrl'],
      brandName: json['brandName'],
      copyright: json['copyright'],
      privacyPolicyUrl: json['privacyPolicyUrl'],
      siteTermsUrl: json['siteTermsUrl'],
    );
  }
}

class BaseWidgetModel {
  final String id;
  final String type;

  BaseWidgetModel({
    required this.id,
    required this.type,
  });
}

class CheckboxWidgetModel extends BaseWidgetModel {
  final String? label;
  final bool readonly;
  final bool? value;
  final CheckboxWidgetRender render;
  final BaseWidgetValidator? validator;

  CheckboxWidgetModel({
    required super.id,
    required this.label,
    required this.readonly,
    this.value,
    required this.render,
    this.validator,
  }) : super(type: 'checkbox');

  factory CheckboxWidgetModel.fromJson(Map<String, dynamic> json) {
    return CheckboxWidgetModel(
      id: json['id'],
      label: json['label'],
      readonly: json['readonly'],
      value: json['value'],
      render: CheckboxWidgetRender.fromJson(json['render']),
      validator: json['validator'] != null ? BaseWidgetValidator.fromJson(json['validator']) : null,
    );
  }
}

class DateWidgetModel extends BaseWidgetModel {
  final String? label;
  final String? placeholder;
  final bool readonly;
  final String? value;
  final BaseWidgetRender render;
  final DateWidgetValidator? validator;

  DateWidgetModel({
    required super.id,
    required this.label,
    this.placeholder,
    required this.readonly,
    this.value,
    required this.render,
    this.validator,
  }) : super(type: 'date');

  factory DateWidgetModel.fromJson(Map<String, dynamic> json) {
    return DateWidgetModel(
      id: json['id'],
      label: json['label'],
      placeholder: json['placeholder'],
      readonly: json['readonly'],
      value: json['value'],
      render: BaseWidgetRender.fromJson(json['render']),
      validator: json['validator'] != null ? DateWidgetValidator.fromJson(json['validator']) : null,
    );
  }
}

class InputWidgetModel extends BaseWidgetModel {
  final String? label;
  final String? value;
  final String? placeholder;
  final bool readonly;
  final String? autocomplete;
  final TextInputType inputmode;
  final InputWidgetValidator? validator;

  InputWidgetModel({
    required super.id,
    required this.label,
    this.value,
    this.placeholder,
    required this.readonly,
    this.autocomplete,
    required this.inputmode,
    this.validator,
  }) : super(type: 'input');

  factory InputWidgetModel.fromJson(Map<String, dynamic> json) {
    return InputWidgetModel(
      id: json['id'],
      label: json['label'],
      value: json['value'],
      placeholder: json['placeholder'],
      readonly: json['readonly'],
      autocomplete: InputWidgetModel.getAutofillHints(json['autocomplete']),
      inputmode: InputWidgetModel.getTextInputType(json['inputmode']),
      validator: json['validator'] != null ? InputWidgetValidator.fromJson(json['validator']) : null,
    );
  }

  static TextInputType getTextInputType(String? inputMode) {
    switch (inputMode) {
      case 'text':
        return TextInputType.text;
      case 'email':
        return TextInputType.emailAddress;
      case 'number':
        return TextInputType.number;
      case 'phone':
        return TextInputType.phone;
      case 'url':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }

  static String getAutofillHints(String? autocomplete) {
    switch (autocomplete) {
      case 'username':
        return AutofillHints.username;
      case 'password':
        return AutofillHints.password;
      case 'email':
        return AutofillHints.email;
      case 'name':
        return AutofillHints.name;
      case 'tel':
        return AutofillHints.telephoneNumber;
      case 'address':
        return AutofillHints.fullStreetAddress;
      default:
        return '';
    }
  }
}

class PasscodeWidgetModel extends BaseWidgetModel {
  final String? label;
  final PasscodeWidgetValidator? validator;

  PasscodeWidgetModel({
    required super.id,
    required this.label,
    this.validator,
  }) : super(type: 'passcode');

  factory PasscodeWidgetModel.fromJson(Map<String, dynamic> json) {
    return PasscodeWidgetModel(
      id: json['id'],
      label: json['label'],
      validator: json['validator'] != null ? PasscodeWidgetValidator.fromJson(json['validator']) : null,
    );
  }
}

class PasswordWidgetModel extends BaseWidgetModel {
  final String? label;
  final bool qualityIndicator;
  final PasswordWidgetValidator? validator;

  PasswordWidgetModel({
    required super.id,
    required this.label,
    required this.qualityIndicator,
    this.validator,
  }) : super(type: 'password');

  factory PasswordWidgetModel.fromJson(Map<String, dynamic> json) {
    return PasswordWidgetModel(
      id: json['id'],
      label: json['label'],
      qualityIndicator: json['qualityIndicator'],
      validator: json['validator'] != null ? PasswordWidgetValidator.fromJson(json['validator']) : null,
    );
  }
}

class PhoneWidgetModel extends BaseWidgetModel {
  final String? label;
  final bool readonly;
  final String? value;
  final BaseWidgetValidator? validator;

  PhoneWidgetModel({
    required super.id,
    required this.label,
    required this.readonly,
    this.value,
    this.validator,
  }) : super(type: 'phone');

  factory PhoneWidgetModel.fromJson(Map<String, dynamic> json) {
    return PhoneWidgetModel(
      id: json['id'],
      label: json['label'],
      readonly: json['readonly'],
      value: json['value'],
      validator: json['validator'] != null ? BaseWidgetValidator.fromJson(json['validator']) : null,
    );
  }
}

class SelectWidgetOption {
  final String type = 'item';
  final String? label;
  final String value;

  SelectWidgetOption({
    required this.label,
    required this.value,
  });

  factory SelectWidgetOption.fromJson(Map<String, dynamic> json) {
    return SelectWidgetOption(
      label: json['label'],
      value: json['value'],
    );
  }
}

class SelectWidgetOptionGroup {
  final String type = 'group';
  final String? label;
  final List<SelectWidgetOption> options;

  SelectWidgetOptionGroup({
    required this.label,
    required this.options,
  });

  factory SelectWidgetOptionGroup.fromJson(Map<String, dynamic> json) {
    return SelectWidgetOptionGroup(
      label: json['label'],
      options: (json['options'] as List).map((e) => SelectWidgetOption.fromJson(e)).toList(),
    );
  }
}

class SelectWidgetModel extends BaseWidgetModel {
  final String? label;
  final bool readonly;
  final String? value;
  final String? placeholder;
  final BaseWidgetRender render;
  final List<dynamic> options;
  final BaseWidgetValidator? validator;

  SelectWidgetModel({
    required super.id,
    required this.label,
    required this.readonly,
    this.value,
    this.placeholder,
    required this.render,
    required this.options,
    this.validator,
  }) : super(type: 'select');

  factory SelectWidgetModel.fromJson(Map<String, dynamic> json) {
    return SelectWidgetModel(
      id: json['id'],
      label: json['label'],
      readonly: json['readonly'],
      value: json['value'],
      placeholder: json['placeholder'],
      render: BaseWidgetRender.fromJson(json['render']),
      options: (json['options'] as List).map((e) => e['type'] == 'group' ? SelectWidgetOptionGroup.fromJson(e) : SelectWidgetOption.fromJson(e)).toList(),
      validator: json['validator'] != null ? BaseWidgetValidator.fromJson(json['validator']) : null,
    );
  }
}

class MultiSelectWidgetModel extends BaseWidgetModel {
  final String? label;
  final bool readonly;
  final List<String>? values;
  final String? placeholder;
  final BaseWidgetRender render;
  final List<dynamic> options;
  final MultiSelectWidgetValidator? validator;

  MultiSelectWidgetModel({
    required super.id,
    required this.label,
    required this.readonly,
    this.values,
    this.placeholder,
    required this.render,
    required this.options,
    this.validator,
  }) : super(type: 'multiSelect');

  factory MultiSelectWidgetModel.fromJson(Map<String, dynamic> json) {
    return MultiSelectWidgetModel(
      id: json['id'],
      label: json['label'],
      readonly: json['readonly'],
      values: (json['values'] as List?)?.map((e) => e as String).toList(),
      placeholder: json['placeholder'],
      render: BaseWidgetRender(type: 'checkbox'),
      options: (json['options'] as List).map((e) => e['type'] == 'group' ? SelectWidgetOptionGroup.fromJson(e) : SelectWidgetOption.fromJson(e)).toList(),
      validator: json['validator'] != null ? MultiSelectWidgetValidator.fromJson(json['validator']) : null,
    );
  }
}

class StaticWidgetModel extends BaseWidgetModel {
  final String value;
  final BaseWidgetRender render;

  StaticWidgetModel({
    required super.id,
    required this.value,
    required this.render,
  }) : super(type: 'static');

  factory StaticWidgetModel.fromJson(Map<String, dynamic> json) {
    return StaticWidgetModel(
      id: json['id'],
      value: json['value'],
      render: BaseWidgetRender.fromJson(json['render']),
    );
  }
}

class SubmitWidgetModel extends BaseWidgetModel {
  final String? label;
  final SubmitWidgetRender render;

  SubmitWidgetModel({
    required super.id,
    required this.label,
    required this.render,
  }) : super(type: 'submit');

  factory SubmitWidgetModel.fromJson(Map<String, dynamic> json) {
    return SubmitWidgetModel(
      id: json['id'],
      label: json['label'],
      render: SubmitWidgetRender.fromJson(json['render']),
    );
  }
}

class FormWidgetModel extends BaseWidgetModel {
  final List<dynamic> widgets;

  FormWidgetModel({
    required super.id,
    required this.widgets,
  }) : super(type: 'form');

  factory FormWidgetModel.fromJson(Map<String, dynamic> json) {
    return FormWidgetModel(
      id: json['id'],
      widgets: (json['widgets'] as List).map((e) => _fromJsonWidget(e)).toList(),
    );
  }

  static dynamic _fromJsonWidget(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'checkbox':
        return CheckboxWidgetModel.fromJson(json);
      case 'date':
        return DateWidgetModel.fromJson(json);
      case 'input':
        return InputWidgetModel.fromJson(json);
      case 'passcode':
        return PasscodeWidgetModel.fromJson(json);
      case 'password':
        return PasswordWidgetModel.fromJson(json);
      case 'phone':
        return PhoneWidgetModel.fromJson(json);
      case 'multiSelect':
        return MultiSelectWidgetModel.fromJson(json);
      case 'select':
        return SelectWidgetModel.fromJson(json);
      case 'static':
        return StaticWidgetModel.fromJson(json);
      case 'submit':
        return SubmitWidgetModel.fromJson(json);
      default:
        throw Exception('Unknown widget type: ${json['type']}');
    }
  }
}

class BaseWidgetRender {
  final String type;

  BaseWidgetRender({required this.type});

  factory BaseWidgetRender.fromJson(Map<String, dynamic> json) {
    return BaseWidgetRender(type: json['type']);
  }
}

class SubmitWidgetRender {
  final String type;
  final Color? textColor;
  final Color? bgColor;
  final SubmitWidgetHint? hint;

  SubmitWidgetRender({required this.type, required this.textColor, required this.bgColor, required this.hint});

  factory SubmitWidgetRender.fromJson(Map<String, dynamic> json) {
    return SubmitWidgetRender(
        type: json['type'],
        textColor: json['textColor'] != null ? Color(_hexToColor(json['textColor'])) : null,
        bgColor: json['bgColor'] != null ? Color(_hexToColor(json['bgColor'])) : null,
        hint: json['hint'] != null ? SubmitWidgetHint.fromJson(json['hint']) : null);
  }

  static int _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return int.parse(hex, radix: 16);
  }
}

class SubmitWidgetHint {
  final String? icon;
  final String? variant;

  SubmitWidgetHint({required this.icon, required this.variant});

  factory SubmitWidgetHint.fromJson(Map<String, dynamic> json) {
    return SubmitWidgetHint(icon: json['icon'], variant: json['variant']);
  }
}

class CheckboxWidgetRender {
  final String type;
  final String labelType;

  CheckboxWidgetRender({required this.type, required this.labelType});

  factory CheckboxWidgetRender.fromJson(Map<String, dynamic> json) {
    return CheckboxWidgetRender(type: json['type'], labelType: json['labelType']);
  }
}

class BaseWidgetValidator {
  final bool required;

  BaseWidgetValidator({required this.required});

  factory BaseWidgetValidator.fromJson(Map<String, dynamic> json) {
    return BaseWidgetValidator(required: json['required'] ?? false);
  }
}

class DateWidgetValidator extends BaseWidgetValidator {
  final String? notBefore;
  final String? notAfter;

  DateWidgetValidator({
    required super.required,
    this.notBefore,
    this.notAfter,
  });

  factory DateWidgetValidator.fromJson(Map<String, dynamic> json) {
    return DateWidgetValidator(
      required: json['required'] ?? false,
      notBefore: json['notBefore'],
      notAfter: json['notAfter'],
    );
  }
}

class InputWidgetValidator extends BaseWidgetValidator {
  final int? minLength;
  final int? maxLength;
  final String? regex;

  InputWidgetValidator({
    required super.required,
    this.minLength,
    this.maxLength,
    this.regex,
  });

  factory InputWidgetValidator.fromJson(Map<String, dynamic> json) {
    return InputWidgetValidator(
      required: json['required'] ?? false,
      minLength: json['minLength'],
      maxLength: json['maxLength'],
      regex: json['regex'],
    );
  }
}

class PasscodeWidgetValidator {
  final int? length;

  PasscodeWidgetValidator({this.length});

  factory PasscodeWidgetValidator.fromJson(Map<String, dynamic> json) {
    return PasscodeWidgetValidator(length: json['length']);
  }
}

class PasswordWidgetValidator extends BaseWidgetValidator {
  final int? minLength;
  final int? maxLength;
  final int? maxNumericCharacterSequences;
  final int? maxRepeatedCharacters;
  final List<String>? mustContain;

  PasswordWidgetValidator({
    required super.required,
    this.minLength,
    this.maxLength,
    this.maxNumericCharacterSequences,
    this.maxRepeatedCharacters,
    this.mustContain,
  });

  factory PasswordWidgetValidator.fromJson(Map<String, dynamic> json) {
    return PasswordWidgetValidator(
      required: json['required'] ?? false,
      minLength: json['minLength'],
      maxLength: json['maxLength'],
      maxNumericCharacterSequences: json['maxNumericCharacterSequences'],
      maxRepeatedCharacters: json['maxRepeatedCharacters'],
      mustContain: (json['mustContain'] as List?)?.map((e) => e as String).toList(),
    );
  }
}

class MultiSelectWidgetValidator {
  final int? minSelectable;
  final int? maxSelectable;

  MultiSelectWidgetValidator({
    this.minSelectable,
    this.maxSelectable,
  });

  factory MultiSelectWidgetValidator.fromJson(Map<String, dynamic> json) {
    return MultiSelectWidgetValidator(
      minSelectable: json['minSelectable'],
      maxSelectable: json['maxSelectable'],
    );
  }
}

class LayoutWidgetModel {
  final String type;
  final List<dynamic> items;

  LayoutWidgetModel({required this.type, required this.items});

  factory LayoutWidgetModel.fromJson(Map<String, dynamic> json) {
    return LayoutWidgetModel(
      type: json['type'],
      items: (json['items'] as List).map((e) => e).toList(),
    );
  }
}

class LoginFlowMessage {
  final String type;
  final String text;

  LoginFlowMessage({required this.type, required this.text});

  factory LoginFlowMessage.fromJson(Map<String, dynamic> json) {
    return LoginFlowMessage(
      type: json['type'],
      text: json['text'],
    );
  }
}

class LoginFlowState {
  String? hostedUrl;
  String? finalizeUrl;
  String? screen;
  BrandingData? branding;
  List<FormWidgetModel>? forms;
  LayoutWidgetModel? layout;
  dynamic messages;

  LoginFlowState({
    this.hostedUrl,
    this.finalizeUrl,
    this.screen,
    this.branding,
    this.forms,
    this.layout,
    this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'hostedUrl': hostedUrl,
      'finalizeUrl': finalizeUrl,
      'screen': screen,
      'branding': branding,
      'forms': forms,
      'layout': layout,
      'messages': messages,
    };
  }

  factory LoginFlowState.fromJson(Map<String, dynamic> json) {
    return LoginFlowState(
      hostedUrl: json['hostedUrl'],
      finalizeUrl: json['finalizeUrl'],
      screen: json['screen'],
      branding: json['branding'] != null ? BrandingData.fromJson(json['branding']) : null,
      forms: json['forms'] != null ? (json['forms'] as List).map((e) => FormWidgetModel.fromJson(e)).toList() : null,
      layout: json['layout'] != null ? LayoutWidgetModel.fromJson(json['layout']) : null,
      messages: json['messages'] != null
          ? (json['messages'] as Map<String, dynamic>).map((key, value) {
              if (key == 'global') {
                return MapEntry(key, {'global': LoginFlowMessage.fromJson(value)});
              } else {
                return MapEntry(
                  key,
                  (value as Map<String, dynamic>).map((k, v) => MapEntry(k, LoginFlowMessage.fromJson(v))),
                );
              }
            })
          : null,
    );
  }

  LoginFlowState update(LoginFlowState other) {
    return LoginFlowState(
      hostedUrl: other.hostedUrl ?? hostedUrl,
      finalizeUrl: other.finalizeUrl ?? finalizeUrl,
      screen: other.screen ?? screen,
      branding: other.branding ?? branding,
      forms: other.forms ?? forms,
      layout: other.layout ?? layout,
      messages: other.messages ?? {},
    );
  }
}
