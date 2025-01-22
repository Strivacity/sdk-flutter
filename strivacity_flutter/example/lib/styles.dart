import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class Styles {
  static const Color primaryColor = Color(0xFF5D21AB);
  static const Color successColor = Color(0xFF008060);
  static const Color infoColor = Color(0xFF0095E6);
  static const Color warningColor = Color(0xFFFFA600);
  static const Color errorColor = Color(0xFFE40C0C);
  static const Color textColor = Color(0xFF4b4158);
  static const Color backgroundColor = Color(0xFFF2F7FB);
  static const Color textColorSecondary = Color(0xFF98949E);
  static const Color inputColor = Styles.textColor;
  static const Color inputBorderColor = Color(0xFFE6E6E6);
  static const Color inputBorderColorDisabled = Color(0xFFE6E6E6);
  static const Color inputBackgroundColor = Color(0xFFFFFFFF);
  static const Color inputBackgroundColorDisabled = Color(0xFFFAFAFA);
  static const Color inputPlaceholderColor = Color(0xFFD9D9D9);
  static const Color inputButtonColor = Styles.textColor;
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color transparentColor = Color(0x00FFFFFF);

  static const double textSizeSmall = 14;
  static const double textSizeMedium = 16;
  static const double textSizeLarge = 18;

  static const double borderRadius = 4;
  static const double borderRadiusMedium = 6;
  static const double borderRadiusLarge = 10;

  static const double paddingSmall = 8;
  static const double paddingMedium = 10;
  static const double paddingLarge = 14;

  static const double marginSmall = 8;
  static const double marginMedium = 14;
  static const double marginLarge = 20;

  static const double buttonMedium = 20;
  static const double spaceBetweenButtons = 20;

  static final Style linkStyle = Style(color: Styles.primaryColor, textDecoration: TextDecoration.none, fontWeight: FontWeight.bold);

  static InputDecoration setInputDecoration([InputDecoration? inputDecoration]) {
    return InputDecoration(
      contentPadding: inputDecoration?.contentPadding ?? EdgeInsets.all(Styles.paddingMedium),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Styles.borderRadius),
        borderSide: BorderSide(color: Styles.inputBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Styles.borderRadius),
        borderSide: BorderSide(color: Styles.inputBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Styles.borderRadius),
        borderSide: BorderSide(color: Styles.primaryColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Styles.borderRadius),
        borderSide: BorderSide(color: Styles.inputBorderColorDisabled),
      ),
      hintStyle: TextStyle(color: Styles.textColor),
      fillColor: inputDecoration?.enabled == false ? Styles.inputBackgroundColorDisabled : Styles.inputBackgroundColor,
      filled: true,
      labelText: inputDecoration?.labelText,
      errorText: inputDecoration?.errorText,
      hintText: inputDecoration?.hintText,
      suffixIcon: inputDecoration?.suffixIcon,
      prefixIcon: inputDecoration?.prefixIcon,
      icon: inputDecoration?.icon,
      counter: inputDecoration?.counter,
      counterText: inputDecoration?.counterText,
      counterStyle: inputDecoration?.counterStyle,
      errorBorder: inputDecoration?.errorBorder,
      errorMaxLines: inputDecoration?.errorMaxLines,
      errorStyle: inputDecoration?.errorStyle,
      floatingLabelBehavior: inputDecoration?.floatingLabelBehavior,
      focusColor: inputDecoration?.focusColor,
      focusedErrorBorder: inputDecoration?.focusedErrorBorder,
      helperMaxLines: inputDecoration?.helperMaxLines,
      helperStyle: inputDecoration?.helperStyle,
      helperText: inputDecoration?.helperText,
      hintMaxLines: inputDecoration?.hintMaxLines,
      isCollapsed: inputDecoration?.isCollapsed,
      isDense: inputDecoration?.isDense,
      labelStyle: inputDecoration?.labelStyle,
      prefix: inputDecoration?.prefix,
      prefixIconConstraints: inputDecoration?.prefixIconConstraints,
      prefixStyle: inputDecoration?.prefixStyle,
      semanticCounterText: inputDecoration?.semanticCounterText,
      suffix: inputDecoration?.suffix,
      suffixIconConstraints: inputDecoration?.suffixIconConstraints,
      suffixStyle: inputDecoration?.suffixStyle,
    );
  }

  static TextStyle setInputTextStyle([TextStyle? textStyle]) {
    return TextStyle(
      color: Styles.inputColor,
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
    ).merge(textStyle);
  }
}
