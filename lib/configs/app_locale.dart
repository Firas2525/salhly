import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:salhly/app.dart';
import '../generated/l10n.dart';

class LocaleController extends ChangeNotifier {
  LocaleController(this._locale);
  Locale _locale;
  Locale get locale => _locale;

  Future<void> toggleLanguage() async {
    if (_locale.languageCode == 'en') {
      _locale = const Locale('ar');
      App.lang.setArID(); // تحديث لغة API
    } else {
      _locale = const Locale('en');
      App.lang.setEnID(); // تحديث لغة API
    }
    notifyListeners();
    await App.prefs.setString('locale', _locale.languageCode);
  }

  Future<void> switchTo(Locale locale) async {
    _locale = locale;
    if (locale.languageCode == 'ar') {
      App.lang.setArID();
    } else {
      App.lang.setEnID();
    }
    notifyListeners();
    await App.prefs.setString('locale', _locale.languageCode);
  }

  static Future<LocaleController> load() async {
    final saved = App.prefs.getString('locale');
    final locale = switch (saved) {
      'ar' => const Locale('ar'),
      'en' => const Locale('en'),
      _ => const Locale('ar'),
    };

    // تحديث App.lang حسب القيمة المحفوظة
    if (locale.languageCode == 'ar') {
      App.lang.setArID();
    } else {
      App.lang.setEnID();
    }

    return LocaleController(locale);
  }
}

class LocaleControllerProvider extends InheritedNotifier<LocaleController> {
  const LocaleControllerProvider({
    super.key,
    required LocaleController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static LocaleController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<LocaleControllerProvider>()!
      .notifier!;
}

class LocaleSwitch extends StatelessWidget {
  const LocaleSwitch({super.key, required this.center});
  final bool center;

  @override
  Widget build(BuildContext context) {
    final localeController = LocaleControllerProvider.of(context);
    final isArabic = localeController.locale.languageCode == 'ar';

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(30),
      color: Theme.of(context).cardColor,
      surfaceTintColor: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: localeController.toggleLanguage,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: center ? 8 : 20,
          ),
          child: Row(
            mainAxisAlignment:
                center ? MainAxisAlignment.center : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Language pill toggle
              Container(
                height: 40,
                width: 120,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.shade200
                      : Colors.white12,
                ),
                child: Stack(
                  children: [
                    // Sliding thumb
                    AnimatedAlign(
                      alignment: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: Container(
                        width: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _LangText(
                          text: "EN",
                          active: !isArabic,
                        ),
                        _LangText(
                          text: "AR",
                          active: isArabic,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                S.of(context).languageSwitch,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangText extends StatelessWidget {
  const _LangText({required this.text, required this.active});
  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: active ? Theme.of(context).colorScheme.primary : Colors.grey,
          ),
        ),
      ),
    );
  }
}

// ===================== S Helpers =====================
extension SHelpers on S {
  static List<Locale> get supportedLocales => const [
        Locale('en'),
        Locale('ar'),
      ];

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];
}
