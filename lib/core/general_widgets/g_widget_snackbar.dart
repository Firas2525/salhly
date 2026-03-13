import 'package:flutter/material.dart';
import 'package:salhly/configs/app_font_style.dart';
import '../../generated/l10n.dart';

class GWidgetSnackBar {
  final String body;
  final bool isSucess;
  final BuildContext context;

  GWidgetSnackBar(
      {required this.body, required this.isSucess, required this.context});

  Future showSnackBar() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      padding: const EdgeInsets.all(10),
      elevation: 1,
      backgroundColor: isSucess ? const Color(0XFF197232) : Colors.red[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.down,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isSucess ? S.of(context).Success : S.of(context).Error,
              style: AppFontStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15)
                  .getFontStyle()),
          const Padding(padding: EdgeInsets.only(bottom: 8)),
          Text(body,
              style: AppFontStyle(
                color: Colors.white,
                fontSize: 12,
              ).getFontStyle())
        ],
      ),
    ));
  }
}
