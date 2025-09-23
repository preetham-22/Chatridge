import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PermissionIconWidget extends StatefulWidget {
  const PermissionIconWidget({super.key});

  @override
  State<PermissionIconWidget> createState() => _PermissionIconWidgetState();
}

class _PermissionIconWidgetState extends State<PermissionIconWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeOut,
    ));

    _pulseController.repeat(reverse: true);
    _waveController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25.w,
      height: 25.w,
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _waveAnimation]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer wave ring
              Transform.scale(
                scale: 1.0 + (_waveAnimation.value * 0.8),
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.lightTheme.primaryColor.withValues(
                        alpha: 0.3 * (1.0 - _waveAnimation.value),
                      ),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              // Middle wave ring
              Transform.scale(
                scale: 1.0 + (_waveAnimation.value * 0.5),
                child: Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.lightTheme.primaryColor.withValues(
                        alpha: 0.5 * (1.0 - _waveAnimation.value),
                      ),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              // Inner wave ring
              Transform.scale(
                scale: 1.0 + (_waveAnimation.value * 0.2),
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.lightTheme.primaryColor.withValues(
                        alpha: 0.7 * (1.0 - _waveAnimation.value),
                      ),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              // Central Bluetooth icon
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightTheme.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.3),
                        blurRadius: 8.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: CustomIconWidget(
                    iconName: 'bluetooth',
                    color: Colors.white,
                    size: 5.w,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
