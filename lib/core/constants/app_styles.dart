import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  static const double borderRadius = 16.0;

  // Headings
  static final TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static final TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static final TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // Body text
  static final TextStyle body = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  static final TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  static final TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    color: AppColors.textPrimary,
  );

  // NewsScreen specific
  static final TextStyle caption = TextStyle(
    fontSize: 12.0,
    color: AppColors.textSecondary,
  );

  static final TextStyle headlineSmall = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final TextStyle breakingBadge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static final TextStyle severityBadge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: AppColors.error, // overridden dynamically
  );

  // Buttons
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
  );
}
