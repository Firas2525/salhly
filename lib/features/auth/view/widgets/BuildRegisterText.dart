import 'package:flutter/material.dart';

import '../../../../../configs/app_colors.dart';


class BuildRegisterText extends StatelessWidget {
  const BuildRegisterText({Key? key, required this.height}) : super(key: key);
  final double height;

  @override
  Widget build(BuildContext context) {
    return InkWell(

        child:  const Center(
          child: Text(
            "Don’t have an account? Click here",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
    );
  }
}
