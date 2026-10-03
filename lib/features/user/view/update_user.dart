import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/core/utils/assets_manager.dart';
import 'package:salhly/features/home/controller/home_controller.dart';
import 'package:salhly/features/home/view/about_contact_view.dart';
import 'package:salhly/features/home/widgets/animated_logo.dart';
import 'package:salhly/features/notifications/view/notifications_page.dart';
import 'package:salhly/features/user/controller/user_controller.dart';
import 'package:salhly/models/user_model.dart';
import '../../../../configs/app_colors.dart';
import 'widgets/BuildTextFormField.dart';

class UpdateUser extends StatefulWidget {
  final UserModel? userData;

  const UpdateUser({super.key, this.userData});

  @override
  State<UpdateUser> createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  final controller = Get.put(UserController());
  bool showPassword = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.userData != null) {
      controller.populateUserData(widget.userData!);
    } else {
      controller.getUser();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.blue.withOpacity(0.25),
        backgroundColor: Colors.blue,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        centerTitle: true,
        title: Text(
          'حسابي',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        leadingWidth: 70,
        leading: canPop
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () => Get.to(() => const AboutContactView()),
                  child: Center(
                    child: SizedBox(
                      height: 38,
                      width: 38,
                      child: AnimatedLogo(assetPath: ImgAsset.whiteLogo),
                    ),
                  ),
                ),
              ),
        actions: const [],
      ),
      body: GetBuilder<UserController>(
        builder: (controller) {
          if (controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.four,
                strokeWidth: 4,
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: MediaQuery.sizeOf(context).height*0.15,),
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              'assets/images/logo2.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 32),

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

                          const SizedBox(height: 16),

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

                          const SizedBox(height: 32),

                          // ========= زر حفظ التغييرات =========
                          GestureDetector(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                controller.updateUser();
                              }
                            },
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.four, AppColors.four],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.four.withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "حفظ التغييرات",
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
