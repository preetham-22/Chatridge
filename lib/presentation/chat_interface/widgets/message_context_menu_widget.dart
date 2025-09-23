import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class MessageContextMenuWidget extends StatelessWidget {
  final Map<String, dynamic> message;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final VoidCallback? onRetry;
  final VoidCallback onDismiss;

  const MessageContextMenuWidget({
    Key? key,
    required this.message,
    required this.onCopy,
    required this.onDelete,
    this.onRetry,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = message['status'] as String? ?? 'sent';
    final canRetry = status.toLowerCase() == 'failed' && onRetry != null;

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            padding: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(3.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuItem(
                  icon: 'content_copy',
                  title: 'Copy',
                  onTap: () {
                    final content = message['content'] as String? ?? '';
                    Clipboard.setData(ClipboardData(text: content));
                    onDismiss();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Message copied to clipboard'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                if (canRetry) ...[
                  Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                  _buildMenuItem(
                    icon: 'refresh',
                    title: 'Retry Send',
                    onTap: () {
                      onRetry!();
                      onDismiss();
                    },
                    textColor: AppTheme.lightTheme.primaryColor,
                  ),
                ],
                Divider(
                  height: 1,
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
                _buildMenuItem(
                  icon: 'delete',
                  title: 'Delete',
                  onTap: () {
                    onDelete();
                    onDismiss();
                  },
                  textColor: AppTheme.errorLight,
                ),
                SizedBox(height: 1.h),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  child: TextButton(
                    onPressed: onDismiss,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: textColor ?? AppTheme.lightTheme.colorScheme.onSurface,
              size: 5.w,
            ),
            SizedBox(width: 4.w),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: textColor ?? AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}