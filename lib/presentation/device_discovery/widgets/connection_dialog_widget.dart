import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectionDialogWidget extends StatefulWidget {
  final Map<String, dynamic> device;
  final VoidCallback onConnect;
  final VoidCallback onCancel;

  const ConnectionDialogWidget({
    Key? key,
    required this.device,
    required this.onConnect,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<ConnectionDialogWidget> createState() => _ConnectionDialogWidgetState();
}

class _ConnectionDialogWidgetState extends State<ConnectionDialogWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startConnection() {
    setState(() {
      _isConnecting = true;
    });
    _animationController.repeat();

    // Simulate connection attempt with timeout
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _animationController.stop();
        widget.onConnect();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Device Icon
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: _isConnecting
                  ? AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 2 * 3.14159,
                          child: CustomIconWidget(
                            iconName: 'bluetooth_searching',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 10.w,
                          ),
                        );
                      },
                    )
                  : CustomIconWidget(
                      iconName:
                          widget.device['type']?.toLowerCase() == 'arduino'
                              ? 'memory'
                              : 'developer_board',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 10.w,
                    ),
            ),
            SizedBox(height: 3.h),
            // Device Name
            Text(
              widget.device['name'] ?? 'Unknown Device',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            // MAC Address
            Text(
              widget.device['macAddress'] ?? 'XX:XX:XX:XX:XX:XX',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            // Connection Status
            if (_isConnecting) ...[
              Text(
                'Connecting to device...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              LinearProgressIndicator(
                backgroundColor:
                    AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.lightTheme.primaryColor,
                ),
              ),
            ] else ...[
              Text(
                'Ready to connect to this device?',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 4.h),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isConnecting ? null : widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isConnecting ? null : _startConnection,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _isConnecting ? 'Connecting...' : 'Connect',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
