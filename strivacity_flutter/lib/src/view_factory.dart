import 'package:flutter/material.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

abstract class ViewFactory {
  /// Returns a container widget with the specified [children].
  Widget getContainerWidget({required List<Widget> children});

  /// Returns a loading widget.
  Widget getLoadingWidget();

  /// Returns a checkbox widget with the specified parameters.
  Widget getCheckboxWidget({required Key key, required String formId, required CheckboxWidgetModel config, required LoginContext loginContext});

  /// Returns a date widget with the specified parameters.
  Widget getDateWidget({required Key key, required String formId, required DateWidgetModel config, required LoginContext loginContext});

  /// Returns an input widget with the specified parameters.
  Widget getInputWidget({required Key key, required String formId, required InputWidgetModel config, required LoginContext loginContext});

  /// Returns a layout widget with the specified [type] and [children].
  Widget getLayoutWidget({required Key key, required String type, required List<Widget> children});

  /// Returns a multi-select widget with the specified parameters.
  Widget getMultiSelectWidget({required Key key, required String formId, required MultiSelectWidgetModel config, required LoginContext loginContext});

  /// Returns a passcode widget with the specified parameters.
  Widget getPasscodeWidget({required Key key, required String formId, required PasscodeWidgetModel config, required LoginContext loginContext});

  /// Returns a password widget with the specified parameters.
  Widget getPasswordWidget({required Key key, required String formId, required PasswordWidgetModel config, required LoginContext loginContext});

  /// Returns a phone widget with the specified parameters.
  Widget getPhoneWidget({required Key key, required String formId, required PhoneWidgetModel config, required LoginContext loginContext});

  /// Returns a select widget with the specified parameters.
  Widget getSelectWidget({required Key key, required String formId, required SelectWidgetModel config, required LoginContext loginContext});

  /// Returns a static widget with the specified parameters.
  Widget getStaticWidget({required Key key, required StaticWidgetModel config});

  /// Returns a submit widget with the specified parameters.
  Widget getSubmitWidget({required Key key, required String formId, required SubmitWidgetModel config, required LoginContext loginContext});
}
