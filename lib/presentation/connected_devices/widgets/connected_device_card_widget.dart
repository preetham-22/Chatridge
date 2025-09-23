import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectedDeviceCardWidget extends StatelessWidget {
  final Map<String, dynamic> device;
  final VoidCallback onTap;
  final VoidCallback onDisconnect;

  const ConnectedDeviceCardWidget({
    Key? key,
    required this.device,
    required this.onTap,
    required this.onDisconnect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isOnline = device['isOnline'] ?? false;
    final int signalStrength = device['signalStrength'] ?? 0;
    final String deviceType = device['type'] ?? 'Unknown';
    final int? batteryLevel = device['batteryLevel'] as int?;
    final String connectionType = device['connectionType'] ?? 'Unknown';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Device Type Icon
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: _getDeviceIcon(deviceType),
                        color: AppTheme.lightTheme.primaryColor,
                        size: 6.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    // Device Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device['name'] ?? 'Unknown Device',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              Text(
                                connectionType,
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Container(
                                width: 1.w,
                                height: 1.w,
                                decoration: BoxDecoration(
                                  color: AppTheme.textSecondaryLight,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                device['dataTransferRate'] ?? '0 KB/s',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Signal Strength Indicator
                    Column(
                      children: [
                        _buildSignalStrengthIndicator(signalStrength),
                        if (batteryLevel != null) ...[
                          SizedBox(height: 1.h),
                          _buildBatteryIndicator(batteryLevel),
                        ],
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    // Connection Status Badge
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? AppTheme.successLight.withValues(alpha: 0.1)
                            : AppTheme.errorLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isOnline
                              ? AppTheme.successLight
                              : AppTheme.errorLight,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: isOnline ? 'check_circle' : 'cancel',
                            color: isOnline
                                ? AppTheme.successLight
                                : AppTheme.errorLight,
                            size: 4.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            isOnline ? 'Online' : 'Offline',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: isOnline
                                  ? AppTheme.successLight
                                  : AppTheme.errorLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Device Type Badge
                    SizedBox(width: 2.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        deviceType,
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.lightTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Disconnect Button
                    SizedBox(
                      height: 4.h,
                      child: TextButton.icon(
                        onPressed: onDisconnect,
                        icon: CustomIconWidget(
                          iconName: 'link_off',
                          color: AppTheme.errorLight,
                          size: 4.w,
                        ),
                        label: Text(
                          'Disconnect',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.errorLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignalStrengthIndicator(int strength) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final bool isActive = index < strength;
        return Container(
          margin: EdgeInsets.only(left: 0.5.w),
          width: 1.w,
          height: (index + 1) * 0.8.h,
          decoration: BoxDecoration(
            color: isActive
                ? _getSignalColor(strength)
                : AppTheme.textDisabledLight,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  Widget _buildBatteryIndicator(int batteryLevel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: _getBatteryIcon(batteryLevel),
          color: _getBatteryColor(batteryLevel),
          size: 4.w,
        ),
        SizedBox(width: 1.w),
        Text(
          '${batteryLevel}%',
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: _getBatteryColor(batteryLevel),
            fontWeight: FontWeight.w600,
            fontSize: 8.sp,
          ),
        ),
      ],
    );
  }

  String _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'sensor':
        return 'sensors';
      case 'camera':
        return 'camera_alt';
      case 'lock':
        return 'lock';
      case 'controller':
        return 'settings_remote';
      default:
        return 'device_hub';
    }
  }

  String _getBatteryIcon(int level) {
    if (level <= 20) return 'battery_1_bar';
    if (level <= 40) return 'battery_2_bar';
    if (level <= 60) return 'battery_3_bar';
    if (level <= 80) return 'battery_4_bar';
    return 'battery_full';
  }

  Color _getSignalColor(int strength) {
    if (strength >= 3) return AppTheme.successLight;
    if (strength >= 2) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }

  Color _getBatteryColor(int level) {
    if (level <= 20) return AppTheme.errorLight;
    if (level <= 40) return AppTheme.warningLight;
    return AppTheme.successLight;
  }
}
