import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

class ReportCard extends StatelessWidget {
  final String title;
  final String location;
  final String time;
  
  const ReportCard({
    super.key,
    required this.title,
    required this.location,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppStyles.headlineSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(location, style: AppStyles.bodyMedium),
                const Spacer(),
                Text(time, style: AppStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}