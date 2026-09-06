import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';

Widget buildContactIconCircular({
  dynamic icon,
  String? imageUrl,
  required Color backgroundColor,
  required String label,
  required VoidCallback onTap,
  bool isFontAwesome = false,
  bool useImage = false,
  double size = 60,
  bool fullImage = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.3),
            gradient: LinearGradient(
              colors: [backgroundColor, backgroundColor.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 5),
                spreadRadius: 1,
              ),
            ],
          ),
          child: useImage && imageUrl != null
              ? fullImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(size * 0.3),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.link,
                              color: Colors.white,
                              size: size * 0.35,
                            );
                          },
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(size * 0.15),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.link,
                              color: Colors.white,
                              size: size * 0.35,
                            );
                          },
                        ),
                      )
              : Center(
                  child: isFontAwesome
                      ? Icon(icon, color: Colors.white, size: size * 0.42)
                      : Icon(icon, color: Colors.white, size: size * 0.45),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.four,
          ),
        ),
      ],
    ),
  );
}
