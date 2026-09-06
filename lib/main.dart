import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salhly/app.dart';
import 'package:salhly/configs/app_colors.dart';
import 'configs/app_locale.dart';
import 'core/general_widgets/g_widget_restart.dart';
import 'features/auth/view/login.dart';
import 'features/auth/view/onboard_scr.dart';
import 'features/auth/view/splash_screen.dart';
import 'features/auth/view/update_required_screen.dart';
import 'features/home/view/home_navigation_view.dart';
import 'features/home/view/new_home_page_view.dart';
import 'features/home_worker/view/home_worker_view.dart';
import 'firebase_options.dart';
import 'notifiction_services.dart';

Future<void> fierbaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  App.prefs = await SharedPreferences.getInstance();

  final themeController = await ThemeController.load();
  final localeController = await LocaleController.load();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  NotificationServices().getDeviceToken();
  NotificationServices().requestNotificationPermission();
  NotificationServices().firebaseInit();
  FirebaseMessaging.onBackgroundMessage(fierbaseMessagingBackgroundHandler);

  runApp(
    ThemeControllerProvider(
      controller: themeController,
      child: LocaleControllerProvider(
        controller: localeController,
        child: RestartWidget(
          child: ThemeControllerProvider(
            controller: themeController,
            child: LocaleControllerProvider(
              controller: localeController,
              child: SuperApp(
                controller: themeController,
                localeController: localeController,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class SuperApp extends StatelessWidget {
  const SuperApp({
    super.key,
    required this.controller,
    required this.localeController,
  });

  final ThemeController controller;
  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    print(App.prefs.getString("type"));
    print(App.prefs.getString("token"));
    return AnimatedBuilder(
      animation: Listenable.merge([
        controller,
        localeController,
      ]), // <-- هنا تم التعديل
      builder: (_, __) {
        return GetMaterialApp(
          locale: const Locale("ar"),
          supportedLocales: SHelpers.supportedLocales,
          localizationsDelegates: SHelpers.localizationsDelegates,
          themeMode: controller.mode,
          title: 'Salhly',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFeb5632),
            ),
            scaffoldBackgroundColor: const Color(0xFFF3F3F3),
          ),
          initialRoute: '/splash',
          navigatorKey: App.scaffoldMessengerKey,
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/': (context) => const OnboardScr(),
            "/login": (context) => const Login(),
            "/home": (context) => const HomeNavigationView(),
            "/homeworker": (context) => const HomeWorkerView(),
            "/update": (context) => const UpdateRequiredScreen(),
          },
        );
      },
    );
  }
}
