import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SkeletonDeviceCardWidget extends StatefulWidget {
  const SkeletonDeviceCardWidget({Key? key}) : super(key: key);

  @override
  State<SkeletonDeviceCardWidget> createState() =>
      _SkeletonDeviceCardWidgetState();
}

class _SkeletonDeviceCardWidgetState extends State<SkeletonDeviceCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Device Icon Skeleton
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: AppTheme.textDisabledLight
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        // Device Info Skeleton
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40.w,
                                height: 2.h,
                                decoration: BoxDecoration(
                                  color: AppTheme.textDisabledLight
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Container(
                                width: 30.w,
                                height: 1.5.h,
                                decoration: BoxDecoration(
                                  color: AppTheme.textDisabledLight
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Signal Strength Skeleton
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(4, (index) {
                            return Container(
                              margin: EdgeInsets.only(left: 0.5.w),
                              width: 1.w,
                              height: (index + 1) * 1.h,
                              decoration: BoxDecoration(
                                color: AppTheme.textDisabledLight
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        // Status Badge Skeleton
                        Container(
                          width: 25.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppTheme.textDisabledLight
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const Spacer(),
                        // Button Skeleton
                        Container(
                          width: 20.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: AppTheme.textDisabledLight
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
