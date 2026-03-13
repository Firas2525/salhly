import 'package:flutter/material.dart';
import '../../../../../configs/app_colors.dart';

class BuildTextFormField extends StatelessWidget {
  const BuildTextFormField({
    Key? key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscureText = false,     // ✔ تغيير الاسم ليصبح مناسب
    this.suffixIcon,              // ✔ تغيير الاسم ليصبح مناسب
    this.validator,
  }) : super(key: key);

  final String hint;
  final IconData icon;
  final TextEditingController controller;

  final bool obscureText;         // ✔
  final Widget? suffixIcon;       // ✔

  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,   // ✔ أصبح متوافق مع الشاشة
      cursorColor: AppColors.four,
      style: const TextStyle(color: Colors.black),

      validator: validator,

      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45),
        prefixIcon: Icon(icon, color: Colors.black45),

        suffixIcon: suffixIcon,   // ✔

        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border2Color, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.second, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.third, width: 1),
        ),
      ),
    );
  }
}
