// import 'dart:js';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../app.dart';
import '../../../core/utils/app_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart%20%20';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class NotificationServices {
  static NotificationServices instance = NotificationServices._();
  NotificationServices._();
  factory NotificationServices() {
    return instance;
  }
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('user granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('user granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        print('user denied permission');
      }
    }
  }

  Future<String?> getDeviceToken() async {
    String? token = await messaging.getToken();
    if (token == null || token.isEmpty) return token;

    final lastToken = App.prefs.getString('fcm_token_sent');
    if (lastToken == token) {
      print("FCM token already sent");
      return token;
    }

    await sendToken(token);
    return token;
  }

  void initLocalNotifications() async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
    );
  }

  void firebaseInit() {
    initLocalNotifications();
    FirebaseMessaging.onMessage.listen((message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (kDebugMode) {
        print("notifications title:${notification?.title}");
        print("notifications body:${notification?.body}");
        print('count:${android?.count}');
        print('data:${message.data.toString()}');
      }

      showNotification(message);
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    if (message.notification == null) {
      return;
    }
    print(
      " channel id:  ${message.notification?.android?.channelId.toString()}",
    );
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      "high_importance_channel",
      "high_importance_channel",
      importance: Importance.max,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "high_importance_channel",
      "high_importance_channel",
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      ticker: 'ticker',
    );

    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () async {
      await _flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title.toString() ?? '',
        message.notification?.body.toString() ?? '',
        notificationDetails,
      );
    });
  }

}



sendToken(String token) async {

  try {
    String? tokenn = App.prefs.getString('token');
    if(tokenn!=null){
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $tokenn',
    };

    var uri = Uri.parse("${AppApi.baseUrl}/fcm_token");

    var request = http.MultipartRequest('POST', uri);

    request.fields['fcm_token'] = token;


    request.headers.addAll(headers);
    var response = await request.send();
    var data = jsonDecode(await response.stream.bytesToString());
    print(response.statusCode);
    print(data);
    if (response.statusCode == 200 || response.statusCode == 201|| response.statusCode == 220) {
      print("okkkkkkkkkk");
      print("nooooooooooooooooootiiiiii");
      await App.prefs.setString('fcm_token_sent', token);
    } else {

    }}
  } catch (e) {
    print(e);
  }

}