import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/configs/app_font_style.dart';
import 'package:salhly/core/general_widgets/g_widget_drop_down.dart';
import 'package:salhly/core/utils/assets_manager.dart';

import '../../generated/l10n.dart';

class GWidgetDates extends StatefulWidget {
  const GWidgetDates({
    super.key,
    required this.showStatus,
    required this.onPick,
    required this.datesClosed,
    this.dateTimePicked,
  });
  final bool showStatus;
  final List<DateTime> datesClosed;
  final Function(DateTime dateTimePicked) onPick;
  final DateTime? dateTimePicked;

  @override
  State<GWidgetDates> createState() => _GWidgetDatesState();
}

class _GWidgetDatesState extends State<GWidgetDates> {
  //(year, month) 5 months from now
  List<(int, int)> months = [];
  List<DateTime> dates = [];
  int monthPicked = 0;

  @override
  void initState() {
    months = getMonthsFromNow(5);
    dates = getAllDaysInMonth(months[monthPicked].$1, months[monthPicked].$2);
    super.initState();
  }

  List<DateTime> getAllDaysInMonth(int year, int month) {
    // أول يوم في الشهر
    // DateTime firstDay = DateTime(year, month, 1);

    // آخر يوم في الشهر
    DateTime lastDay = DateTime(year, month + 1, 0);

    List<DateTime> days = [];
    for (int i = 0; i < lastDay.day; i++) {
      days.add(DateTime(year, month, i + 1));
    }
    return days;
  }

  List<(int, int)> getMonthsFromNow(int count) {
    DateTime now = DateTime.now();
    List<(int, int)> months = [];

    for (int i = 0; i < count; i++) {
      DateTime nextMonth = DateTime(now.year, now.month + i, 1);
      months.add((nextMonth.year, nextMonth.month));
    }

    return months;
  }

  String getMonthName(
    int month,
  ) {
    DateTime date = DateTime(2000, month, 1); // أي سنة وأي يوم شغالين
    return DateFormat.MMMM().format(date);
  }

  @override
  Widget build(BuildContext context) {
    bool isLight = ThemeControllerProvider.of(context).isLight;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isLight ? Colors.grey.withValues(alpha: 0.1) : Colors.white12,
          border: Border.all(
              color: isLight
                  ? Colors.grey.withValues(alpha: 0.5)
                  : Colors.white24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showStatus)
            Column(
              children: [
                SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TopWidget(
                            text: S.of(context).ConsultationCost,
                            value: '\$20',
                            imgPath: ImgAsset.consCost),
                      ),
                      SizedBox(
                        height: 50,
                        child: VerticalDivider(
                          color: Colors.white24,
                          thickness: 1,
                        ),
                      ),
                      Expanded(
                        child: TopWidget(
                            text: S.of(context).YouWillEarn,
                            value: S.of(context).FiftyPoint,
                            imgPath: ImgAsset.earn),
                      ),
                      SizedBox(
                        height: 50,
                        child: VerticalDivider(
                          color: Colors.white24,
                          thickness: 1,
                        ),
                      ),
                      Expanded(
                        child: TopWidget(
                            text: S.of(context).WaitingTime,
                            value: S.of(context).FifteenMinute,
                            imgPath: ImgAsset.waitTime),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ],
            ),
          Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(S.of(context).ChooseYourAppointment,
                          style: AppFontStyle(fontSize: 12).getFontStyle()),
                      SizedBox(
                        width: 102,
                        child: GWidgetDropDown(
                            items:
                                months.map((e) => getMonthName(e.$2)).toList(),
                            selectedItem: getMonthName(months[monthPicked].$2),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  monthPicked = months
                                      .map((e) => getMonthName(e.$2))
                                      .toList()
                                      .indexOf(value);
                                  dates = getAllDaysInMonth(
                                      months[monthPicked].$1,
                                      months[monthPicked].$2);
                                });
                              }
                            },
                            searchBox: false,
                            showOnlyText: true,
                            hint: ''),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 69,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dates.length,
                      itemBuilder: (context, index) {
                        return MonthCard(
                          isChosen: widget.dateTimePicked == dates[index],
                          dateTime: dates[index],
                          isClosed: widget.datesClosed.contains(dates[index]),
                          onPressed: () {
                            widget.onPick(dates[index]);
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  // FiltWidgetOptions(
                  //     title: S.of(context).SelectTimeFromAvailableTimes,
                  //     texts: List.generate(9, (index) => '08:00 AM'),
                  //     pickedIndex: -1,
                  //     padding: 0,
                  //     showDivider: false,
                  //     onPress: (index) {})
                ],
              ))
        ],
      ),
    );
  }
}

class TopWidget extends StatelessWidget {
  const TopWidget(
      {super.key,
      required this.text,
      required this.imgPath,
      required this.value});
  final String text;
  final String value;
  final String imgPath;

  @override
  Widget build(BuildContext context) {
    bool isLight = ThemeControllerProvider.of(context).isLight;
    return Column(
      children: [
        Image.asset(imgPath,
            color: isLight ? Colors.black : Colors.white,
            width: 25,
            height: 25),
        SizedBox(height: 5),
        Text(text,
            style: AppFontStyle(fontSize: 10, fontWeight: FontWeight.w400)
                .getFontStyle()),
        Text(value,
            style: AppFontStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400)
                .getFontStyle()),
      ],
    );
  }
}

class MonthCard extends StatelessWidget {
  const MonthCard(
      {super.key,
      required this.isChosen,
      required this.dateTime,
      required this.onPressed,
      this.isClosed = false});
  final bool isChosen;
  final DateTime dateTime;
  final Function() onPressed;
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    bool isLight = ThemeControllerProvider.of(context).isLight;
    return InkWell(
      onTap: isClosed ? null : onPressed,
      child: Container(
        height: 69,
        width: 58,
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
            border: isChosen
                ? null
                : Border.all(
                    color: isLight
                        ? Colors.grey.withValues(alpha: 0.5)
                        : Colors.white24),
            color: isChosen
                ? AppColors.primary
                : isLight
                    ? Colors.grey.withValues(alpha: 0.1)
                    : Colors.white24,
            borderRadius: BorderRadius.circular(10)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat('E').format(dateTime),
                    style: AppFontStyle(
                            color: isLight & !isChosen
                                ? Colors.grey.withValues(alpha: 0.5)
                                : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)
                        .getFontStyle()),
                Text(DateFormat('dd').format(dateTime),
                    style: AppFontStyle(
                            color: isChosen ? Colors.white : AppColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)
                        .getFontStyle())
              ],
            ),
            if (isClosed)
              Container(
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(S.of(context).Booked,
                      style: AppFontStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)
                          .getFontStyle()),
                ),
              )
          ],
        ),
      ),
    );
  }
}
