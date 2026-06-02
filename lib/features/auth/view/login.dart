import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:salhly/features/auth/view/register.dart';
import 'package:salhly/features/auth/view/reset_password.dart';
import 'package:salhly/features/home/controller/home_controller.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../../configs/app_colors.dart';
import '../controller/login_controller.dart';
import 'widgets/BuildTextFormField.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final controller = Get.put(AuthController());
  late final HomeController _homeController = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());

  final _formKey = GlobalKey<FormState>(); // ✅ مفتاح الفورم
  bool showPassword = false;
  bool _isContactLoading = false;

  String _normalizeWhatsAppNumber(String raw) {
    var s = raw.replaceAll(RegExp(r'[\s\-\(\)+]'), '');
    if (s.startsWith('00')) s = s.substring(2);
    if (s.startsWith('0')) s = s.substring(1);
    if (!s.startsWith('963')) s = '963$s';
    return s;
  }

  Future<void> _handleForgotPassword() async {
    setState(() {
      _isContactLoading = true;
    });

    await _homeController.getContactUs();

    setState(() {
      _isContactLoading = false;
    });

    final rawWa = _homeController.contactUsModel?.phoneNumber ?? '';
    final wa = _normalizeWhatsAppNumber(rawWa);
    if (wa.isEmpty) {
      showAppSnackbar('خطأ', 'رقم الواتساب غير متوفر', isError: true);
      return;
    }

    showConfirmDialog(
      title: 'نسيت كلمة المرور؟',
      middleText: 'سوف يتم الانتقال لواتس اب للتواصل مع الدعم.',
      confirmText: 'موافق',
      cancelText: 'غير موافق',
      onConfirm: () async {
        await Future.delayed(const Duration(milliseconds: 300));

        final whatsappUri = Uri.parse('whatsapp://send?phone=$wa');
        final waMeUri = Uri.parse('https://wa.me/$wa');
        final apiUri = Uri.parse('https://api.whatsapp.com/send?phone=$wa');

        try {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
          return;
        } catch (e) {
          print('WhatsApp app launch error: $e');
        }

        try {
          await launchUrl(waMeUri, mode: LaunchMode.externalApplication);
          return;
        } catch (e) {
          print('WhatsApp wa.me launch error: $e');
        }

        try {
          await launchUrl(apiUri, mode: LaunchMode.externalApplication);
          return;
        } catch (e) {
          print('WhatsApp api launch error: $e');
        }

        showAppSnackbar('خطأ', 'تعذر فتح واتساب', isError: true);
      },
      onCancel: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: GetBuilder<AuthController>(builder: (_) {
          return controller.isLoading || _isContactLoading
              ? Center(
              child: CircularProgressIndicator(
                  color: AppColors.four, strokeWidth: 4))
              : Form( // ⭐ غلفنا الصفحة داخل Form
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(height: height * 0.18),
                SizedBox(
                  height: 140,
                  width: 140,
                  child: Image.asset(
                    'assets/images/logo2.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: height * 0.04),

                // رقم الهاتف
                BuildTextFormField(
                  hint: 'رقم الهاتف',
                  icon: Icons.phone_android,
                  controller: controller.myPhone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الرجاء إدخال رقم الهاتف";
                    }
                    return null;
                  },
                ),

                SizedBox(height: height * 0.016),

                // كلمة المرور
                BuildTextFormField(
                  hint: 'كلمة المرور',
                  icon: Icons.lock,
                  controller: controller.myPassword,
                  obscure: !showPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الرجاء إدخال كلمة المرور";
                    }
                    if (value.length < 6) {
                      return "كلمة المرور يجب أن تكون 6 محارف على الأقل";
                    }
                    return null;
                  },
                  suffix: IconButton(
                    icon: Icon(
                      showPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black45,
                    ),
                    onPressed: () =>
                        setState(() => showPassword = !showPassword),
                  ),
                ),

SizedBox(height: height * 0.012),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    child: Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(color: AppColors.four),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.02),

                // زر تسجيل الدخول
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      controller.login();
                    }
                  },
                  child: Container(
                    height: height * 0.07,
                    margin:
                    EdgeInsets.symmetric(horizontal: width * 0.05),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [AppColors.four, AppColors.four]),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.four.withOpacity(0.18),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "تسجيل الدخول",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.02),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.03),
                      child: Text(
                        'أو',
                        style:
                        TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ليس لديك حساب؟',
                        style: TextStyle(color: Colors.black)),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => Register()));
                      },
                      child: Text(
                        'إنشاء حساب',
                        style: TextStyle(
                          color: AppColors.four,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height * 0.04),
              ],
            ),
          );
        }),
      ),
    );
  }
}
