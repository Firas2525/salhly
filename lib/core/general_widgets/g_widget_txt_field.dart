import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/configs/app_font_style.dart';

class GWidgetTxtField extends StatefulWidget {
  const GWidgetTxtField(
      {super.key,
      required this.hintTxt,
      this.isPassword = false,
      this.height,
      this.maxLines = 1,
      this.textInputType,
      this.controller,
      this.isDigitsOnly = false,
      this.isDicimal = false,
      this.maxLength,
      this.style,
      this.onChanged,
      this.focusNode,
      this.title,
      this.widget,
      this.enabled});
  final String hintTxt;
  final String? title;
  final bool isPassword;
  final double? height;
  final int? maxLines;
  final TextInputType? textInputType;
  final TextEditingController? controller;
  final bool isDigitsOnly;
  final bool isDicimal;
  final int? maxLength;
  final TextStyle? style;
  final FocusNode? focusNode;
  final Widget? widget;
  final bool? enabled;
  final Function(String value)? onChanged;

  @override
  State<GWidgetTxtField> createState() => _GWidgetTxtFieldState();
}

class _GWidgetTxtFieldState extends State<GWidgetTxtField> {
  bool isVisible = false;

  @override
  void initState() {
    if (widget.isPassword) {
      isVisible = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isLight = ThemeControllerProvider.of(context).isLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Column(
            children: [
              Text(widget.title!,
                  style: AppFontStyle(fontSize: 16).getFontStyle()),
              SizedBox(height: 4),
            ],
          ),
        Container(
            height: widget.height,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withValues(alpha: isLight ? 1 : 0.28),
                border: Border.all(color: Colors.white54)),
            child: Row(
              children: [
                if (widget.widget != null) widget.widget!,
                Expanded(
                    child: TextField(
                  enabled: widget.enabled,
                  controller: widget.controller,
                  obscureText: isVisible,
                  maxLength: widget.maxLength,
                  enableSuggestions: !widget.isPassword,
                  autocorrect: !widget.isPassword,
                  cursorColor: isLight ? Colors.black : Colors.white,
                  maxLines: widget.maxLines,
                  onChanged: widget.onChanged,
                  focusNode: widget.focusNode,
                  keyboardType: widget.isDigitsOnly
                      ? TextInputType.number
                      : widget.isDicimal
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : widget.textInputType,
                  inputFormatters: widget.isDigitsOnly
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : null,
                  decoration: InputDecoration(
                      hintText: widget.hintTxt,
                      counterText: '',
                      hintStyle: AppFontStyle(
                              color: isLight ? Colors.black54 : Colors.white54)
                          .getFontStyle(),
                      suffixIcon: widget.isPassword
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              child: Icon(
                                  isVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: isLight
                                      ? Colors.black.withValues(alpha: 0.8)
                                      : Colors.white.withValues(alpha: 0.8)),
                            )
                          : null,
                      border: InputBorder.none),
                  style: widget.style ?? AppFontStyle().getFontStyle(),
                ))
              ],
            ))
      ],
    );
  }
}
