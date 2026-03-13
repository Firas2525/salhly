import 'package:flutter/material.dart';
import 'package:salhly/app.dart';

import '../generated/l10n.dart';

class AppColors {
  // static bool isLight = true;
  static Color primary = const Color(0xFFF6F4EB);
  static Color second = const Color(0xFF91C8E4);
  static Color third = const Color(0xFF749BC2);
  static Color four = const Color(0xFF4682A9);
  // Accent color chosen to complement the existing blue palette and the
  // warm primary background. A teal/greenish-teal works well as an accent
  // to add vibrancy and contrast for CTAs and highlights.
  static const Color accent = Color(0xFF2A9D8F);
  static const Color borderColor = Color(0XFFE6E6E6);
  static const Color textColor = Color(0XFF838383);
  static const Color greenColor = Color(0XFF008D38);
  static const Color redColor = Color(0XFFEF3B24);
  static const Color border2Color = Color(0XFFE6E6E6);
  static const Color availableColor = Color(0XFF69A2BD);
  static const Color available2Color = Color(0XFF69A2BD);

  // New vibrant gradient colors for redesigned login screen
  static const Color gradientStart = Color(0xFF6A11CB);
  static const Color gradientEnd = Color(0xFF2575FC);

  static List<String> carsColors = [];
  // static const Color background = //Color(0XFF1A1B20);
  //     Color(0XFFF3F3F3);
}

/// 1) Controller: holds ThemeMode and notifies listeners
class ThemeController extends ChangeNotifier {
  ThemeController(this._mode);
  ThemeMode _mode;
  ThemeMode get mode => _mode;
  bool get isLight => _mode == ThemeMode.light;

  Future<void> toggle() async {
    _mode = isLight ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    // persist choice (optional)

    await App.prefs.setString('theme_mode', _mode.name);
  }

  static Future<ThemeController> load() async {
    final saved = App.prefs.getString('theme_mode');
    final mode = switch (saved) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.dark,
    };
    return ThemeController(mode);
  }
}

/// 2) Inherited wrapper to access the controller anywhere without extra packages
class ThemeControllerProvider extends InheritedNotifier<ThemeController> {
  const ThemeControllerProvider({
    super.key,
    required ThemeController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static ThemeController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ThemeControllerProvider>()!
      .notifier!;
}

/// 3) The switch widget you asked for (only the widget, nice UI)
class ThemeModeSwitch extends StatelessWidget {
  const ThemeModeSwitch({super.key, required this.center});
  final bool center;
  @override
  Widget build(BuildContext context) {
    final controller = ThemeControllerProvider.of(context);
    final isLight = controller.isLight;

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: controller.toggle,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: center ? 0 : 20,
          ),
          child: Row(
            mainAxisAlignment: center
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (c, anim) =>
                    ScaleTransition(scale: anim, child: c),
                child: Icon(
                  isLight ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  key: ValueKey(isLight),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isLight ? S.of(context).Light : S.of(context).Dark,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 12),
              Switch.adaptive(
                value: isLight,
                onChanged: (_) {
                  controller.toggle();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
