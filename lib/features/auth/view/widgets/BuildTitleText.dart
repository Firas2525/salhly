import 'package:flutter/material.dart';

class BuildTitleText extends StatelessWidget {
  const BuildTitleText(
      {Key? key,
      required this.text,
      required this.color,
      required this.fontSize,
      this.center = false})
      : super(key: key);
  final String text;
  final Color color;
  final double fontSize;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.left,
      style: TextStyle(
          color: color, fontWeight: FontWeight.bold, fontSize: fontSize),
    );
  }
}
