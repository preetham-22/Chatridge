import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CommunicationLogWidget extends StatelessWidget {
  final List<Map<String, dynamic>> communicationLogs;

  const CommunicationLogWidget({
    Key? key,
    required this.communicationLogs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Communication Log",
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              CustomIconWidget(
                iconName: 'history',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          communicationLogs.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: communicationLogs.length > 5 ? 5 : communicationLogs.length,
                  separatorBuilder: (context, index) => SizedBox(height: 1.h),
                  itemBuilder: (context, index) {
                    final log = communicationLogs[index];
                    return _buildLogItem(log);
                  },
                ),
          if (communicationLogs.length > 5) ...[
            SizedBox(height: 2.h),
            Center(
              child: TextButton(
                onPressed: () {
                  // Show all logs in a modal or navigate to detailed log screen
                },
                child: Text(
                  "View All Logs (${communicationLogs.length})",
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'inbox',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            size: 32,
          ),
          SizedBox(height: 1.h),
          Text(
            "No communication logs available",
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    final bool isSuccess = (log["status"] as String?) == "success";
    final String timestamp = log["timestamp"] as String? ?? "";
    final String message = log["message"] as String? ?? "";
    final String? errorCode = log["errorCode"] as String?;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isSuccess
            ? AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.05)
            : AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess
              ? AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.2)
              : AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: isSuccess ? 'check_circle' : 'error',
                color: isSuccess
                    ? AppTheme.lightTheme.colorScheme.tertiary
                    : AppTheme.lightTheme.colorScheme.error,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  message,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                timestamp,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (errorCode != null) ...[
            SizedBox(height: 0.5.h),
            Text(
              "Error Code: $errorCode",
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }
}