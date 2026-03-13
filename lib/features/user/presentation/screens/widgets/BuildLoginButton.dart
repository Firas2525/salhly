import 'package:flutter/material.dart';

import '../../../../../configs/app_colors.dart';

class BuildLoginButton extends StatefulWidget {
  const BuildLoginButton({
    Key? key,
    required this.height,
    required this.width,
    required this.function,
  }) : super(key: key);
  final double height;
  final double width;
  final Function function;

  @override
  State<BuildLoginButton> createState() => _BuildLoginButtonState();
}

class _BuildLoginButtonState extends State<BuildLoginButton> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _handleTapUp(TapUpDetails _) => setState(() => _pressed = false);
  void _handleTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: (d) {
        _handleTapUp(d);
        widget.function();
      },
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.985 : 1.0,
        child: Container(
          height: widget.height * 0.07,
          margin: EdgeInsets.symmetric(horizontal: widget.width * 0.05),
          decoration: BoxDecoration(
            // vibrant CTA gradient
            gradient: LinearGradient(colors: [AppColors.four, AppColors.four]),
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
                fontSize: widget.width * 0.05,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
