import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import 'widgets/checkbox_widget.dart';
import 'widgets/date_widget.dart';
import 'widgets/input_widget.dart';
import 'widgets/layout_widget.dart';
import 'widgets/multiselect_widget.dart';
import 'widgets/passcode_widget.dart';
import 'widgets/password_widget.dart';
import 'widgets/phone_widget.dart';
import 'widgets/select_widget.dart';
import 'widgets/static_widget.dart';
import 'widgets/submit_widget.dart';
import 'widgets/close_widget.dart';
import 'widgets/passkey_login_widget.dart';
import 'widgets/passkey_enroll_widget.dart';
import 'widgets/webauthn_login_widget.dart';
import 'widgets/webauthn_enroll_widget.dart';
import 'widgets/container_widget.dart';
import 'widgets/loading_widget.dart';

class CustomViewFactory implements ViewFactory {
  @override
  Widget getContainerWidget({required List<Widget> children}) {
    return ContainerWidget(children: children);
  }

  @override
  Widget getLoadingWidget() {
    return LoadingWidget();
  }

  @override
  Widget getCheckboxWidget({required Key key, required String formId, required CheckboxWidgetModel config, required LoginContext loginContext}) {
    return CheckboxWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getDateWidget({required Key key, required String formId, required DateWidgetModel config, required LoginContext loginContext}) {
    return DateWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getInputWidget({required Key key, required String formId, required InputWidgetModel config, required LoginContext loginContext}) {
    return InputWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getLayoutWidget({required Key key, required String type, required List<Widget> children}) {
    return LayoutWidget(key: key, type: type, children: children);
  }

  @override
  Widget getMultiSelectWidget({required Key key, required String formId, required MultiSelectWidgetModel config, required LoginContext loginContext}) {
    return MultiSelectWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getPasscodeWidget({required Key key, required String formId, required PasscodeWidgetModel config, required LoginContext loginContext}) {
    return PasscodeWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getPasswordWidget({required Key key, required String formId, required PasswordWidgetModel config, required LoginContext loginContext}) {
    return PasswordWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getPhoneWidget({required Key key, required String formId, required PhoneWidgetModel config, required LoginContext loginContext}) {
    return PhoneWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getSelectWidget({required Key key, required String formId, required SelectWidgetModel config, required LoginContext loginContext}) {
    return SelectWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getSubmitWidget({required Key key, required String formId, required SubmitWidgetModel config, required LoginContext loginContext}) {
    return SubmitWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getCloseWidget({required Key key, required String formId, required CloseWidgetModel config, required LoginContext loginContext}) {
    return CloseWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getPasskeyLoginWidget({required Key key, required String formId, required PasskeyLoginWidgetModel config, required LoginContext loginContext}) {
    return PasskeyLoginWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getPasskeyEnrollWidget({required Key key, required String formId, required PasskeyEnrollWidgetModel config, required LoginContext loginContext}) {
    return PasskeyEnrollWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getWebauthnLoginWidget({required Key key, required String formId, required WebauthnLoginWidgetModel config, required LoginContext loginContext}) {
    return WebauthnLoginWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getWebauthnEnrollWidget({required Key key, required String formId, required WebauthnEnrollWidgetModel config, required LoginContext loginContext}) {
    return WebauthnEnrollWidget(key: key, formId: formId, config: config, loginContext: loginContext);
  }

  @override
  Widget getStaticWidget({required Key key, required StaticWidgetModel config}) {
    return StaticWidget(key: key, config: config);
  }
}
