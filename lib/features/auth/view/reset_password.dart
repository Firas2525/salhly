import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salhly/features/auth/view/login.dart';
import 'package:salhly/features/auth/view/register.dart';
import '../../../../configs/app_colors.dart';
import '../controller/login_controller.dart';
import 'widgets/BuildTextFormField.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final controller = Get.put(AuthController());

  final _formKey = GlobalKey<FormState>(); // ✅ مفتاح الفورم
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: GetBuilder<AuthController>(builder: (_) {
          return controller.isLoading
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
                  hint: 'البريد الالكتروني',
                  icon: Icons.email,
                  controller: controller.myEmail,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الرجاء إدخال البريد الالكتروني";
                    }
                    return null;
                  },
                ),



                SizedBox(height: height * 0.012),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Get.offAll(()=>Login());
                    },
                    child: Text(
                      'تذكرت كلمة المرور؟',
                      style: TextStyle(color: AppColors.four),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.02),

                // زر تسجيل الدخول
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      controller.resetPassword();
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
                        "إعادة تعيين  كلمة المرور",
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
