import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final bool isConnected;
  final String deviceName;
  final int signalStrength;
  final bool isReconnecting;

  const ConnectionStatusWidget({
    Key? key,
    required this.isConnected,
    required this.deviceName,
    required this.signalStrength,
    this.isReconnecting = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _buildStatusIcon(),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getStatusText(),
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(),
                    ),
                  ),
                  if (deviceName.isNotEmpty) ...[
                    SizedBox(height: 0.2.h),
                    Text(
                      deviceName,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: _getTextColor().withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isConnected && !isReconnecting) ...[
              _buildSignalStrengthIndicator(),
              SizedBox(width: 2.w),
            ],
            if (isReconnecting) ...[
              SizedBox(
                width: 4.w,
                height: 4.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                ),
              ),
              SizedBox(width: 2.w),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    String iconName;
    if (isReconnecting) {
      iconName = 'sync';
    } else if (isConnected) {
      iconName = 'bluetooth_connected';
    } else {
      iconName = 'bluetooth_disabled';
    }

    return CustomIconWidget(
      iconName: iconName,
      color: _getTextColor(),
      size: 4.w,
    );
  }

  Widget _buildSignalStrengthIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isActive = index < _getSignalBars();
        return Container(
          width: 0.8.w,
          height: (index + 1) * 0.8.h,
          margin: EdgeInsets.only(right: 0.5.w),
          decoration: BoxDecoration(
            color: isActive
                ? _getTextColor()
                : _getTextColor().withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(0.2.w),
          ),
        );
      }),
    );
  }

  Color _getStatusColor() {
    if (isReconnecting) {
      return AppTheme.warningLight.withValues(alpha: 0.1);
    } else if (isConnected) {
      return AppTheme.successLight.withValues(alpha: 0.1);
    } else {
      return AppTheme.errorLight.withValues(alpha: 0.1);
    }
  }

  Color _getTextColor() {
    if (isReconnecting) {
      return AppTheme.warningLight;
    } else if (isConnected) {
      return AppTheme.successLight;
    } else {
      return AppTheme.errorLight;
    }
  }

  String _getStatusText() {
    if (isReconnecting) {
      return 'Reconnecting...';
    } else if (isConnected) {
      return 'Connected';
    } else {
      return 'Disconnected';
    }
  }

  int _getSignalBars() {
    if (signalStrength >= -50) return 4;
    if (signalStrength >= -60) return 3;
    if (signalStrength >= -70) return 2;
    if (signalStrength >= -80) return 1;
    return 0;
  }
}