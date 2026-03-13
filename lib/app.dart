import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/general_widgets/g_widget_snackbar.dart';

class App {
  static GlobalKey<NavigatorState> scaffoldMessengerKey =
      GlobalKey<NavigatorState>();

  static late SharedPreferences prefs;

  static Future snackBar(
          {required String body,
          required bool isSucess,
          BuildContext? context}) async =>
      await GWidgetSnackBar(
              body: body,
              context: context ?? scaffoldMessengerKey.currentState!.context,
              isSucess: isSucess)
          .showSnackBar();
  static Language lang = Language(id: 1);

  static int? cityID;

  static const int rowCountHttp = 6;
}

class Language {
  int id;

  Language({required this.id});

  setArID() => id = 1;
  setEnID() => id = 2;
}
