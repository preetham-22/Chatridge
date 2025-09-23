import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/learn_more_bottom_sheet.dart';
import './widgets/permission_benefits_widget.dart';
import './widgets/permission_icon_widget.dart';

class BluetoothPermissions extends StatefulWidget {
  const BluetoothPermissions({super.key});

  @override
  State<BluetoothPermissions> createState() => _BluetoothPermissionsState();
}

class _BluetoothPermissionsState extends State<BluetoothPermissions> {
  bool _isLoading = false;
  bool _isCheckingPermissions = false;
  String _loadingMessage = '';

  @override
  void initState() {
    super.initState();
    _checkExistingPermissions();
  }

  Future<void> _checkExistingPermissions() async {
    setState(() {
      _isCheckingPermissions = true;
      _loadingMessage = 'Checking permissions...';
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (kIsWeb) {
        // Web doesn't require explicit Bluetooth permissions
        setState(() {
          _isCheckingPermissions = false;
        });
        return;
      }

      bool hasBluetoothPermission = false;
      bool hasLocationPermission = false;

      if (Platform.isAndroid) {
        // Check Android Bluetooth permissions
        final bluetoothStatus = await Permission.bluetooth.status;
        final bluetoothConnectStatus = await Permission.bluetoothConnect.status;
        final bluetoothScanStatus = await Permission.bluetoothScan.status;
        final locationStatus = await Permission.locationWhenInUse.status;

        hasBluetoothPermission = bluetoothStatus.isGranted &&
            bluetoothConnectStatus.isGranted &&
            bluetoothScanStatus.isGranted;
        hasLocationPermission = locationStatus.isGranted;
      } else if (Platform.isIOS) {
        // iOS handles Bluetooth permissions automatically
        // Check location permission which is required for BLE discovery
        final locationStatus = await Permission.locationWhenInUse.status;
        hasLocationPermission = locationStatus.isGranted;
        hasBluetoothPermission = true; // iOS handles this internally
      }

      if (hasBluetoothPermission && hasLocationPermission) {
        // All permissions granted, navigate to device discovery
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/device-discovery');
        }
      }
    } catch (e) {
      // Handle permission check errors silently
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingPermissions = false;
        });
      }
    }
  }

  Future<void> _requestBluetoothPermissions() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Requesting permissions...';
    });

    try {
      if (kIsWeb) {
        // Web implementation - show success and navigate
        await Future.delayed(const Duration(milliseconds: 1000));
        _showSuccessAndNavigate();
        return;
      }

      bool allPermissionsGranted = false;

      if (Platform.isAndroid) {
        // Request Android permissions
        Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetooth,
          Permission.bluetoothConnect,
          Permission.bluetoothScan,
          Permission.locationWhenInUse,
        ].request();

        allPermissionsGranted =
            statuses.values.every((status) => status.isGranted);

        if (!allPermissionsGranted) {
          // Check if any permission is permanently denied
          bool permanentlyDenied =
              statuses.values.any((status) => status.isPermanentlyDenied);
          if (permanentlyDenied) {
            _showSettingsDialog();
            return;
          } else {
            _showPermissionDeniedMessage();
            return;
          }
        }
      } else if (Platform.isIOS) {
        // iOS - request location permission first (required for BLE)
        setState(() {
          _loadingMessage = 'Requesting location access...';
        });

        final locationStatus = await Permission.locationWhenInUse.request();

        if (locationStatus.isGranted) {
          allPermissionsGranted = true;
        } else if (locationStatus.isPermanentlyDenied) {
          _showSettingsDialog();
          return;
        } else {
          _showPermissionDeniedMessage();
          return;
        }
      }

      if (allPermissionsGranted) {
        _showSuccessAndNavigate();
      }
    } catch (e) {
      _showErrorMessage('Failed to request permissions. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessAndNavigate() {
    // Haptic feedback for success
    HapticFeedback.lightImpact();

    setState(() {
      _loadingMessage = 'Permissions granted!';
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/device-discovery');
      }
    });
  }

  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Bluetooth permissions are required for offline communication'),
        backgroundColor: AppTheme.warningLight,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _requestBluetoothPermissions,
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'BlueBridge needs Bluetooth and Location permissions to discover and connect to nearby devices. Please enable these permissions in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Background blur effect
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
                    AppTheme.lightTheme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),

            // Main content
            Column(
              children: [
                // Header with back button
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, '/splash-screen'),
                        icon: CustomIconWidget(
                          iconName: 'arrow_back',
                          color: AppTheme.textPrimaryLight,
                          size: 6.w,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // Main content area
                Expanded(
                  child: _isCheckingPermissions
                      ? _buildLoadingState()
                      : _buildPermissionContent(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            _loadingMessage,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionContent() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 20.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Bluetooth icon
          const PermissionIconWidget(),

          SizedBox(height: 4.h),

          // Main heading
          Text(
            'Enable Bluetooth Communication',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryLight,
            ),
          ),

          SizedBox(height: 2.h),

          // Subtitle
          Text(
            'BlueBridge needs Bluetooth access to connect with ESP32/Arduino devices and enable offline messaging.',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryLight,
              height: 1.5,
            ),
          ),

          SizedBox(height: 4.h),

          // Benefits list
          const PermissionBenefitsWidget(),

          SizedBox(height: 4.h),

          // Primary action button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _requestBluetoothPermissions,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.w),
                ),
                elevation: 2.0,
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          _loadingMessage,
                          style: AppTheme.lightTheme.textTheme.labelLarge
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Allow Bluetooth Access',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          SizedBox(height: 2.h),

          // Secondary action button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: OutlinedButton(
              onPressed:
                  _isLoading ? null : () => LearnMoreBottomSheet.show(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.lightTheme.primaryColor,
                side: BorderSide(
                  color: AppTheme.lightTheme.primaryColor,
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
              child: Text(
                'Learn More',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
