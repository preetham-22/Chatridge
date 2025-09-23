import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PermissionBenefitsWidget extends StatelessWidget {
  const PermissionBenefitsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> benefits = [
      {
        'icon': 'developer_board',
        'title': 'Connect to ESP32/Arduino devices',
        'description': 'Pair with microcontroller-powered communication hubs',
      },
      {
        'icon': 'wifi_off',
        'title': 'Send messages without internet',
        'description': 'Communicate in areas with no cellular or WiFi coverage',
      },
      {
        'icon': 'radar',
        'title': 'Discover nearby communication hubs',
        'description':
            'Find and connect to available Bluetooth devices automatically',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: benefits
          .map((benefit) => _buildBenefitItem(
                iconName: benefit['icon'] as String,
                title: benefit['title'] as String,
                description: benefit['description'] as String,
              ))
          .toList(),
    );
  }

  Widget _buildBenefitItem({
    required String iconName,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.primaryColor,
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
