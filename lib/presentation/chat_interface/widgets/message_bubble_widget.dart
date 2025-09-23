import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isCurrentUser;
  final VoidCallback? onLongPress;
  final VoidCallback? onRetry;

  const MessageBubbleWidget({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.onLongPress,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageText = message['content'] as String? ?? '';
    final timestamp = message['timestamp'] as DateTime? ?? DateTime.now();
    final status = message['status'] as String? ?? 'sent';
    final isEncrypted = message['encrypted'] as bool? ?? false;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 4.w),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 2.5.w,
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              child: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.onSecondary,
                size: 3.w,
              ),
            ),
            SizedBox(width: 2.w),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPress,
              child: Container(
                constraints: BoxConstraints(maxWidth: 70.w),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.w),
                    topRight: Radius.circular(4.w),
                    bottomLeft: Radius.circular(isCurrentUser ? 4.w : 1.w),
                    bottomRight: Radius.circular(isCurrentUser ? 1.w : 4.w),
                  ),
                  border: !isCurrentUser
                      ? Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline,
                          width: 0.5,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEncrypted) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'lock',
                            color: isCurrentUser
                                ? AppTheme.lightTheme.colorScheme.onPrimary
                                    .withValues(alpha: 0.7)
                                : AppTheme.lightTheme.colorScheme.primary,
                            size: 3.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Encrypted',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                              color: isCurrentUser
                                  ? AppTheme.lightTheme.colorScheme.onPrimary
                                      .withValues(alpha: 0.7)
                                  : AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                    ],
                    Text(
                      messageText,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: isCurrentUser
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _formatTimestamp(timestamp),
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: isCurrentUser
                                ? AppTheme.lightTheme.colorScheme.onPrimary
                                    .withValues(alpha: 0.7)
                                : AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                          ),
                        ),
                        if (isCurrentUser) ...[
                          SizedBox(width: 1.w),
                          _buildStatusIcon(status),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isCurrentUser) ...[
            SizedBox(width: 2.w),
            CircleAvatar(
              radius: 2.5.w,
              backgroundColor: AppTheme.lightTheme.primaryColor,
              child: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 3.w,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData iconData;
    Color iconColor;

    switch (status.toLowerCase()) {
      case 'sending':
        iconData = Icons.access_time;
        iconColor =
            AppTheme.lightTheme.colorScheme.onPrimary.withValues(alpha: 0.7);
        break;
      case 'delivered':
        iconData = Icons.check;
        iconColor = AppTheme.lightTheme.colorScheme.onPrimary;
        break;
      case 'failed':
        iconData = Icons.error_outline;
        iconColor = AppTheme.errorLight;
        break;
      default:
        iconData = Icons.check;
        iconColor =
            AppTheme.lightTheme.colorScheme.onPrimary.withValues(alpha: 0.7);
    }

    return GestureDetector(
      onTap: status.toLowerCase() == 'failed' ? onRetry : null,
      child: CustomIconWidget(
        iconName: iconData.codePoint.toString(),
        color: iconColor,
        size: 3.w,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }
}