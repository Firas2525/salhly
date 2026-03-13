import 'package:flutter/material.dart';

import '../../configs/app_colors.dart';
import '../../configs/app_font_style.dart';
import '../../generated/l10n.dart';
import '../utils/assets_manager.dart';

class GWidgetSearchTxtField extends StatelessWidget {
  const GWidgetSearchTxtField(
      {super.key,
      required this.openDrawer,
      this.showFilters = true,
      this.onPressed,
      this.controller,
      this.onSubmitted,
      this.onChanged,
      this.prefix,
      this.radius=50
      });
  final Function() openDrawer;
  final bool showFilters;
  final Widget? prefix;
  final Function()? onPressed;
  final Function(String value)? onSubmitted;
  final Function(String value)? onChanged;
  final TextEditingController? controller;
  final double radius;

  @override
  Widget build(BuildContext context) {
    bool isLight = ThemeControllerProvider.of(context).isLight;
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
          color: isLight
              ? Colors.white
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.5), width: 0.5)),
      child: Row(
        children: [
          // Image.asset(
          //   ImgAsset.searchIcon,
          //   color: isLight ? Colors.black.withValues(alpha: 0.5) : null,
          //   width: 29,
          //   height: 29,
          // ),
          // SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: onPressed,
              child: TextField(
                controller: controller,
                enabled: onPressed == null,
                onSubmitted: onSubmitted,
                onChanged: onChanged,
                cursorColor: isLight ? Colors.black : Colors.white,
                style: AppFontStyle(fontSize: 12.9, fontWeight: FontWeight.w400)
                    .getFontStyle(),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: S.of(context).FindWhatYouWant,
                    hintStyle: AppFontStyle(
                            color: isLight
                                ? Colors.black.withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.6),
                            fontSize: 12.9,
                            keepArabicFont: true,
                            fontWeight: FontWeight.w400)
                        .getFontStyle()),
              ),
            ),
          ),
          if (prefix != null) prefix!,
          if (showFilters)
            InkWell(
              onTap: openDrawer,
              child: Image.asset(
                ImgAsset.filterIcon,
                color: AppColors.primary,
                height: 20,
                width: 20,
              ),
            )
        ],
      ),
    );
  }
}
