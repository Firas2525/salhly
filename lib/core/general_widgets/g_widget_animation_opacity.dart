import 'package:flutter/material.dart';

class GWidgetAnimationOpacity extends StatelessWidget {
  const GWidgetAnimationOpacity(
      {super.key,
      required this.widgetOpacity,
      required this.seconds,
      this.isRevers = false,
      this.onEnd});
  final Widget widgetOpacity;
  final int seconds;
  final bool isRevers;
  final Function()? onEnd;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
        onEnd: onEnd,
        tween: isRevers
            ? Tween<double>(begin: 1, end: 0)
            : Tween<double>(begin: 0, end: 1),
        duration: Duration(seconds: seconds),
        builder: (ctx, value, widget) {
          return Opacity(opacity: value, child: widgetOpacity);
        });
  }
}
