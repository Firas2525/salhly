import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                                    : (controller.currentUserImage != null &&
                                                  controller
                                                      .currentUserImage!
                                                      .isNotEmpty
                                              ? NetworkImage(
                                    'https://www.salhly.lareenmedco.com/${controller.currentUserImage}'.toString().
                                  contains("storage")?
                                  'https://www.salhly.lareenmedco.com/${controller.currentUserImage}':
                                  'https://www.salhly.lareenmedco.com/storage/${controller.currentUserImage}',
                                                )
                                              : null)
                                          as ImageProvider?,
                                child:
                                    (controller.imageFile == null &&
                                        (controller.currentUserImage == null ||
                                            controller
                                                .currentUserImage!
                                                .isEmpty))
                                    ? Icon(
                                        Icons.camera_alt,
                                        color: Colors.black54,
                                        size: 35,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Text(
                            "اختر صورة شخصية",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),

                        SizedBox(height: height * 0.08),

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

                        SizedBox(height: height * 0.04),

                        // ========= زر إنشاء الحساب =========
                        GestureDetector(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              controller.updateUser();
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
