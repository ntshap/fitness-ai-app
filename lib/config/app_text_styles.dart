import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle headline1 = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle headline2 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  static TextStyle metricValue = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static TextStyle metricUnit = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle metricLabel = GoogleFonts.poppins(
    color: AppColors.secondaryText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyRegular = GoogleFonts.poppins(
    color: AppColors.secondaryText,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle chartLabels = GoogleFonts.poppins(
    color: AppColors.secondaryText,
    fontSize: 12,
  );
}