import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:salhly/configs/app_font_style.dart';

import '../../app.dart';
import '../../configs/app_colors.dart';
import '../../generated/l10n.dart';

class GWidgetDropDown extends StatelessWidget {
  const GWidgetDropDown(
      {super.key,
      required this.items,
      required this.onChanged,
      required this.hint,
      this.selectedItem,
      this.title,
      this.searchBox = true,
      this.showOnlyText = false});
  final List<String> items;
  final Function(String? value) onChanged;
  final String hint;
  final String? selectedItem;
  final bool searchBox;
  final bool showOnlyText;
  final String? title;

  @override
  Widget build(BuildContext context) {
    bool isLight = ThemeControllerProvider.of(context).isLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Column(
            children: [
              Text(title!,
                  style: AppFontStyle(color: Colors.white, fontSize: 16)
                      .getFontStyle()),
              SizedBox(height: 4),
            ],
          ),
        DropdownSearch<String>(
            items: items,
            selectedItem: selectedItem,
            popupProps: PopupProps.menu(
              showSearchBox: searchBox,
              searchFieldProps: TextFieldProps(
                cursorColor: Colors.black,
                decoration: InputDecoration(
                    hintText: S.of(context).Search,
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor:
                        Colors.white.withValues(alpha: isLight ? 1 : 0.28),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black, width: 2))),
              ),
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              baseStyle: AppFontStyle().getFontStyle(),
              dropdownSearchDecoration: InputDecoration(
                hintText: hint,
                hintStyle: AppFontStyle(
                        color: isLight ? Colors.black54 : Colors.white54)
                    .getFontStyle(),
                filled: true,
                fillColor: showOnlyText
                    ? Colors.transparent
                    : Colors.white.withValues(
                        alpha: ThemeControllerProvider.of(
                                    App.scaffoldMessengerKey.currentContext!)
                                .isLight
                            ? 1
                            : 0.28),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: showOnlyText
                    ? InputBorder.none
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white54)),
              ),
            ),
            dropdownButtonProps: DropdownButtonProps(
              icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
            ),
            onChanged: onChanged)
      ],
    );
  }
}
