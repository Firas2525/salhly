import 'package:flutter/material.dart';

import '../../../../../configs/app_colors.dart';

class ButtonWidget extends StatefulWidget {
  const ButtonWidget({
    super.key,
    required this.height,
    required this.width,
    required this.function, required this.text,
  });
  final double height;
  final double width;
  final Function function;
  final String text;

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  bool _pressed = false;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        widget.function();
      },
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
              widget.text,
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
