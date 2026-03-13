import 'package:flutter/material.dart';
import '../../../../../configs/app_colors.dart';

class BuildTextFormField extends StatelessWidget {
  const BuildTextFormField({
    Key? key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.suffix,
    this.validator,  // ✅ إضافة الفاليديتور
  }) : super(key: key);

  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final Widget? suffix;

  final String? Function(String?)? validator;  // ⭐ هنا

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      cursorColor: AppColors.four,
      style: const TextStyle(color: Colors.black),

      validator: validator,   // ⭐ تفعيل الفاليديتور

      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45),
        prefixIcon: Icon(icon, color: Colors.black45),
        suffixIcon: suffix,
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
