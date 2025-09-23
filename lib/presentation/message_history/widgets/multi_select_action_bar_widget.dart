import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MultiSelectActionBarWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onClearSelection;
  final VoidCallback onDeleteSelected;
  final VoidCallback onArchiveSelected;
  final VoidCallback onExportSelected;

  const MultiSelectActionBarWidget({
    super.key,
    required this.selectedCount,
    required this.onClearSelection,
    required this.onDeleteSelected,
    required this.onArchiveSelected,
    required this.onExportSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              // Close button
              IconButton(
                onPressed: onClearSelection,
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: Colors.white,
                  size: 6.w,
                ),
              ),

              SizedBox(width: 2.w),

              // Selected count
              Text(
                '$selectedCount selected',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              // Action buttons
              Row(
                children: [
                  // Export button
                  IconButton(
                    onPressed: onExportSelected,
                    icon: CustomIconWidget(
                      iconName: 'download',
                      color: Colors.white,
                      size: 6.w,
                    ),
                    tooltip: 'Export',
                  ),

                  SizedBox(width: 1.w),

                  // Archive button
                  IconButton(
                    onPressed: onArchiveSelected,
                    icon: CustomIconWidget(
                      iconName: 'archive',
                      color: Colors.white,
                      size: 6.w,
                    ),
                    tooltip: 'Archive',
                  ),

                  SizedBox(width: 1.w),

                  // Delete button
                  IconButton(
                    onPressed: onDeleteSelected,
                    icon: CustomIconWidget(
                      iconName: 'delete',
                      color: Colors.white,
                      size: 6.w,
                    ),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
