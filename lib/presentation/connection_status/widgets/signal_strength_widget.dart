import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SignalStrengthWidget extends StatefulWidget {
  final int signalStrength;
  final bool isConnected;

  const SignalStrengthWidget({
    Key? key,
    required this.signalStrength,
    required this.isConnected,
  }) : super(key: key);

  @override
  State<SignalStrengthWidget> createState() => _SignalStrengthWidgetState();
}

class _SignalStrengthWidgetState extends State<SignalStrengthWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isConnected) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SignalStrengthWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isConnected != oldWidget.isConnected) {
      if (widget.isConnected) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getSignalColor() {
    if (!widget.isConnected) return AppTheme.lightTheme.colorScheme.outline;

    if (widget.signalStrength >= 80) {
      return AppTheme.lightTheme.colorScheme.tertiary;
    } else if (widget.signalStrength >= 50) {
      return AppTheme.warningLight;
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25.w,
      height: 12.h,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(4, (index) {
                  final barHeight = (index + 1) * 0.8.h;
                  final isActive = widget.isConnected &&
                      (widget.signalStrength / 25) > index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 1.5.w,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: isActive
                          ? _getSignalColor().withValues(
                              alpha: widget.isConnected
                                  ? 0.7 + (0.3 * _animation.value)
                                  : 0.3)
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              );
            },
          ),
          SizedBox(height: 1.h),
          Text(
            widget.isConnected ? '${widget.signalStrength}%' : '--',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: _getSignalColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
