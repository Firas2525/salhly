import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/features/auth/view/register.dart';
import '../../../../core/general_widgets/g_widget_button.dart';
import '../../../../generated/l10n.dart';
import 'login.dart';

int currentPage = 0;

class OnboardScr extends StatefulWidget {
  const OnboardScr({super.key});

  static const route = '/OnboardScr';

  @override
  State<OnboardScr> createState() => _OnboardScrState();
}

class _OnboardScrState extends State<OnboardScr> {
  late Timer _imageTimer;

  @override
  void initState() {
    super.initState();
    _startImageTimer();
  }

  void _startImageTimer() {
    _imageTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        currentPage = (currentPage + 1) % 3;
      });
    });
  }

  @override
  void dispose() {
    _imageTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List _screens = [
      {
        'image': 'assets/images/8.jpg',
        'text': "كل تصليحاتك في مكان واحد",
        'desc':
        "اطلب فنيين محترفين لأي خدمة منزلية بسهولة، وبدون عناء البحث الطويل.",
      },
      {
        'image': 'assets/images/6.jpg',
        'text': "خدمات متنوعة وموثوقة",
        'desc':
        "اختر من تشكيلة واسعة من الخدمات المنزلية من قبل متخصصين معتمدين.",
      },
      {
        'image': 'assets/images/4.jpg',
        'text': "تجربة سهلة وآمنة",
        'desc':
        "احصل على خدمات عالية الجودة بأسعار عادلة مع ضمان رضاك التام.",
      },
    ];
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_screens[currentPage]['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: [0.4, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _screens[currentPage]['text'],
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      _screens[currentPage]['desc'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 25),
                    GWidgetButton(
                      backgroundColor: Colors.white,
                      width: double.infinity,
                      raduis: 15,
                      padding: 0,
                      fontSize: 19,
                      widget: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            S
                                .of(context)
                                .GetStarted,
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_outlined,
                            color: Colors.black,
                            size: 29,
                          ),
                        ],
                      ),
                      onPressed: () async {
                        if (currentPage < _screens.length + 1) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Register()),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
              // UserWidgetOnboard(
              //     text: _screens[currentPage]['text'],
              //     underText: _screens[currentPage]['desc'],
              //     onNext: () async {
              //       if (currentPage < 3) {
              //         setState(() {
              //           currentPage += 1;
              //         });
              //       } else {
              //         await Navigator.pushReplacementNamed(
              //             context, WelcomeScr.route);
              //       }
              //     },
              //     onPrev: () {
              //       if (currentPage > 0) {
              //         setState(() {
              //           currentPage -= 1;
              //         });
              //       }
              //     },
              //     currentPage: currentPage),
            ],
          ),
        ),
      ),
    );
  }
}
