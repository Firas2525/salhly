import 'package:flutter/material.dart';
import 'package:salhly/configs/app_font_style.dart';

class GWidgetButton extends StatelessWidget {
  const GWidgetButton(
      {super.key,
      required this.backgroundColor,
      this.colorText,
      this.fontSize,
      this.text,
      required this.onPressed,
      this.width,
      this.heigth,
      this.isEnable = true,
      this.isLoading = false,
      this.padding = 5,
      this.raduis = 10,
      this.border,
      this.widget,
      this.noEnablebackgroundColor});
  final Color backgroundColor;
  final Color? noEnablebackgroundColor;
  final Color? colorText;
  final double? fontSize;
  final String? text;
  final Widget? widget;
  final Function() onPressed;
  final double? width;
  final double? heigth;
  final bool isEnable;
  final bool isLoading;
  final double raduis;
  final double padding;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: heigth,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
            border: border,
            color: isEnable
                ? backgroundColor
                : noEnablebackgroundColor ??
                    Colors.grey.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(raduis)),
        child: TextButton(
            onPressed: isEnable ? onPressed : null,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (text?.isNotEmpty ?? false)
                        Text(text ?? '',
                            textAlign: TextAlign.center,
                            style: AppFontStyle(
                                    color: isEnable
                                        ? (colorText ?? Colors.white)
                                        : Colors.grey.withValues(alpha: 0.6),
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w700)
                                .getFontStyle()),
                      if (widget != null) widget!
                    ],
                  )));
  }
}
