import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salhly/features/user/controller/user_controller.dart';
import '../../../../configs/app_colors.dart';

import 'widgets/BuildTextFormField.dart';

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  final controller = Get.put(UserController());

  bool showCurrentPass = false;
  bool showNewPass = false;
  bool showConfirmPass = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    controller.getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: GetBuilder<UserController>(
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
                  SizedBox(height: height * 0.15),

                  Center(
                    child: SizedBox(
                      height: 180,
                      width: 180,
                      child: Image.asset(
                        'assets/images/logo2.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.03),

                  // ========= كلمة المرور الحالية =========

                  BuildTextFormField(
                    hint: 'كلمة المرور الحالية',
                    icon: Icons.lock_outline,
                    controller: controller.myCurrentPassword,
                    obscureText: !showCurrentPass,
                    suffixIcon: IconButton(
                      icon: Icon(
                        showCurrentPass ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => showCurrentPass = !showCurrentPass);
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال كلمة المرور الحالية";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: height * 0.02),

                  // ========= كلمة المرور الجديدة =========

                  BuildTextFormField(
                    hint: 'كلمة المرور الجديدة',
                    icon: Icons.lock_reset,
                    controller: controller.myNewPassword,
                    obscureText: !showNewPass,
                    suffixIcon: IconButton(
                      icon: Icon(
                        showNewPass ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => showNewPass = !showNewPass);
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال كلمة المرور الجديدة";
                      }
                      if (value.length < 6) {
                        return "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: height * 0.02),

                  // ========= تأكيد كلمة المرور =========

                  BuildTextFormField(
                    hint: 'تأكيد كلمة المرور الجديدة',
                    icon: Icons.lock,
                    controller: controller.myConfirmPassword,
                    obscureText: !showConfirmPass,
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPass ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => showConfirmPass = !showConfirmPass);
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء تأكيد كلمة المرور";
                      }
                      if (value != controller.myNewPassword.text) {
                        return "كلمة المرور غير متطابقة";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: height * 0.04),

                  // ========= زر حفظ =========
                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        controller.updatePassword();
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
                          "حفظ التغييرات",
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
