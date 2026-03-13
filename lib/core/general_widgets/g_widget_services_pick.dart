import 'package:flutter/material.dart';

import '../../configs/app_colors.dart';
import '../../configs/app_font_style.dart';

class GWidgetServicesPick extends StatelessWidget {
  const GWidgetServicesPick(
      {super.key,
        required this.texts,
        required this.onPress,
        required this.chosenIndex});
  final List<Map> texts;
  final Function(int index) onPress;
  final int chosenIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 69,
      margin: EdgeInsets.only(top: 25, bottom: 15, left: 5, right: 5),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: List.generate(
              texts.length,
                  (index) => InkWell(
                onTap: () {
                  onPress(index);
                },
                child: Container(
                  margin: EdgeInsets.only(right: 15),
                  width: 125,
                  decoration: BoxDecoration(
                      border: index == chosenIndex
                          ? null
                          : Border.all(color: Colors.white, width: 0.4),
                      color: index == chosenIndex
                          ? AppColors.primary
                          : Colors.grey[600]!.withValues(alpha: 0.69),
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(texts[index]['icon'],color: Colors.white, width: 25),
                      SizedBox(height: 5),
                      Text(texts[index]['text'],
                          style: AppFontStyle(
                              color: Colors.white,
                              fontSize: 12.9,
                              fontWeight: FontWeight.bold)
                              .getFontStyle()),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
