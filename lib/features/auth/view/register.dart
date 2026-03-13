import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../configs/app_colors.dart';
import '../controller/login_controller.dart';
import 'login.dart';
import 'widgets/BuildTextFormField.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final controller = Get.put(AuthController());
  bool showPassword = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: GetBuilder<AuthController>(
          builder: (controller) {
            return controller.isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: AppColors.four,
                strokeWidth: 4,
              ),
            )
                : Form(
              key: _formKey,
              child: ListView(
                children: [
                  SizedBox(height: height * 0.12),

                  // ========= اختيار صورة =========
                  Center(
                    child: GestureDetector(
                      onTap: () => controller.pickImage(),
                      child: CircleAvatar(

                        radius: 76,
                        backgroundColor: AppColors.four,
                        child: CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: controller.imageFile != null
                              ? FileImage(controller.imageFile!)
                              : null,
                          child: controller.imageFile == null
                              ? Icon(Icons.camera_alt,
                              color: Colors.black54, size: 35)
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text("اختر صورة شخصية",
                        style: TextStyle(color: Colors.black54)),
                  ),

                  SizedBox(height: height * 0.06),

                  // ========= الحقول =========

                  BuildTextFormField(
                    hint: 'اسم المستخدم',
                    icon: Icons.person,
                    controller: controller.myName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال اسم المستخدم";
                      }
                      if (value.length < 3) {
                        return "الاسم يجب أن يكون 3 أحرف على الأقل";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: height * 0.016),

                  BuildTextFormField(
                    hint: 'رقم الهاتف',
                    icon: Icons.phone_android,
                    controller: controller.myPhone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال رقم الهاتف";
                      }
                      if (!value.startsWith("09")) {
                        return "رقم الهاتف يجب أن يبدأ بـ 09";
                      }
                      if (value.length != 10) {
                        return "رقم الهاتف يجب أن يكون 10 أرقام";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: height * 0.016),
/*
                  BuildTextFormField(
                    hint: 'البريد الالكتروني',
                    icon: Icons.email,
                    controller: controller.myEmail,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال البريد الإلكتروني";
                      }
                      if (!value.contains("@") ||
                          !value.contains(".")) {
                        return "الرجاء إدخال بريد صحيح";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: height * 0.016),*/

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

                  SizedBox(height: height * 0.04),

                  // ========= زر إنشاء الحساب =========
                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        controller.register();
                      }
                    },
                    child: Container(
                      height: height * 0.07,
                      margin: EdgeInsets.symmetric(
                        horizontal: width * 0.05,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.four, AppColors.four],
                        ),
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
                          "إنشاء الحساب",
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('لديك حساب بالفعل ؟',
                          style: TextStyle(color: Colors.black)),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => Login()),
                          );
                        },
                        child: Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            color: AppColors.four,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
