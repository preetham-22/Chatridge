import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import './widgets/animated_logo_widget.dart';
import './widgets/background_gradient_widget.dart';
import './widgets/error_modal_widget.dart';
import './widgets/loading_indicator_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _loadingText = 'Initializing BlueBridge...';
  bool _showError = false;
  Timer? _timeoutTimer;
  Timer? _navigationTimer;

  // Mock initialization states
  final List<Map<String, dynamic>> _initializationSteps = [
    {
      'text': 'Initializing BlueBridge...',
      'duration': 800,
    },
    {
      'text': 'Checking Bluetooth permissions...',
      'duration': 600,
    },
    {
      'text': 'Scanning for paired devices...',
      'duration': 900,
    },
    {
      'text': 'Loading message history...',
      'duration': 500,
    },
    {
      'text': 'Preparing encryption keys...',
      'duration': 700,
    },
  ];

  @override
  void initState() {
    super.initState();
    _hideSystemUI();
    _startInitialization();
    _setTimeoutTimer();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _hideSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }

  void _setTimeoutTimer() {
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_showError) {
        setState(() {
          _showError = true;
        });
      }
    });
  }

  void _startInitialization() async {
    try {
      for (int i = 0; i < _initializationSteps.length; i++) {
        if (!mounted) return;

        final step = _initializationSteps[i];
        setState(() {
          _loadingText = step['text'] as String;
        });

        await Future.delayed(Duration(milliseconds: step['duration'] as int));
      }

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _showError = true;
        });
      }
    }
  }

  void _navigateToNextScreen() {
    _restoreSystemUI();

    // Mock navigation logic based on app state
    final bool hasBluetoothPermissions = _mockCheckBluetoothPermissions();
    final bool hasPairedDevices = _mockCheckPairedDevices();
    final bool isFirstTime = _mockCheckFirstTimeUser();

    String nextRoute;
    if (isFirstTime) {
      nextRoute = '/bluetooth-permissions';
    } else if (!hasBluetoothPermissions) {
      nextRoute = '/bluetooth-permissions';
    } else if (hasPairedDevices) {
      nextRoute = '/device-discovery';
    } else {
      nextRoute = '/device-discovery';
    }

    _navigationTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, nextRoute);
      }
    });
  }

  bool _mockCheckBluetoothPermissions() {
    // Mock permission check - in real app, this would check actual permissions
    return DateTime.now().millisecond % 2 == 0;
  }

  bool _mockCheckPairedDevices() {
    // Mock paired device check - in real app, this would scan for paired ESP32/Arduino devices
    return DateTime.now().millisecond % 3 == 0;
  }

  bool _mockCheckFirstTimeUser() {
    // Mock first time user check - in real app, this would check SharedPreferences
    return DateTime.now().millisecond % 4 == 0;
  }

  void _handleRetry() {
    setState(() {
      _showError = false;
      _loadingText = 'Retrying initialization...';
    });

    _timeoutTimer?.cancel();
    _setTimeoutTimer();
    _startInitialization();
  }

  void _handleOpenSettings() {
    // In real app, this would open device Bluetooth settings
    Navigator.pushReplacementNamed(context, '/bluetooth-permissions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGradientWidget(
        child: SafeArea(
          child: Stack(
            children: [
              // Main splash content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Animated logo
                    const AnimatedLogoWidget(),

                    SizedBox(height: 4.h),

                    // App name
                    Text(
                      'BlueBridge',
                      style: GoogleFonts.inter(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // Tagline
                    Text(
                      'Offline Communication Network',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Loading indicator
                    LoadingIndicatorWidget(
                      loadingText: _loadingText,
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              ),

              // Error modal overlay
              if (_showError)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: ErrorModalWidget(
                        title: 'Bluetooth Unavailable',
                        message:
                            'BlueBridge requires Bluetooth to function. Please enable Bluetooth and try again.',
                        onRetry: _handleRetry,
                        onSettings: _handleOpenSettings,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}