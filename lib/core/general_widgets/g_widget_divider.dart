import 'package:flutter/material.dart';
import 'package:salhly/configs/app_colors.dart';

class GWidgetDivider extends StatelessWidget {
  const GWidgetDivider({super.key, this.height});
  final double? height;

  @override
  Widget build(BuildContext context) {
    bool isLight = ThemeControllerProvider.of(context).isLight;
    return Divider(
      height: height,
      color: isLight
          ? Colors.black.withValues(alpha: 0.25)
          : Colors.white.withValues(alpha: 0.25),
    );
  }
}
