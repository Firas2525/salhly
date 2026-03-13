import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/app.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/configs/app_locale.dart';

class AppFontStyle {
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextDecoration? textDecoration;
  final bool keepArabicFont;

  AppFontStyle(
      {this.fontSize,
      this.fontWeight,
      this.keepArabicFont = true,
      this.color,
      this.textDecoration});

  TextStyle getFontStyle() {
    bool isLight =
        ThemeControllerProvider.of(App.scaffoldMessengerKey.currentContext!)
            .isLight;
    final localeController =
        LocaleControllerProvider.of(App.scaffoldMessengerKey.currentContext!);
    final langCode = localeController.locale.languageCode;

    return langCode == 'ar'
        ? GoogleFonts.cairo(
            fontSize: (fontSize != null
                ? fontSize! - (keepArabicFont ? 0 : 5)
                : fontSize),
            fontWeight: fontWeight,
            decoration: textDecoration,
            decorationColor: color ?? (isLight ? Colors.black : Colors.white),
            color: color ?? (isLight ? Colors.black : Colors.white),
          )
        : GoogleFonts.roboto(
            fontSize: fontSize,
            fontWeight: fontWeight,
            decoration: textDecoration,
            decorationColor: color ?? (isLight ? Colors.black : Colors.white),
            color: color ?? (isLight ? Colors.black : Colors.white),
          );
  }
}
