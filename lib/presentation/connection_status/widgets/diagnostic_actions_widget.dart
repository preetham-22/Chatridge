import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DiagnosticActionsWidget extends StatefulWidget {
  final VoidCallback onRefresh;
  final VoidCallback onTroubleshoot;
  final VoidCallback onReconnect;
  final VoidCallback onExportDiagnostics;
  final bool isLoading;

  const DiagnosticActionsWidget({
    Key? key,
    required this.onRefresh,
    required this.onTroubleshoot,
    required this.onReconnect,
    required this.onExportDiagnostics,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<DiagnosticActionsWidget> createState() =>
      _DiagnosticActionsWidgetState();
}

class _DiagnosticActionsWidgetState extends State<DiagnosticActionsWidget> {
  bool _showAdvanced = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Diagnostic Actions",
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: "Refresh",
                  icon: CustomIconWidget(
                    iconName: 'refresh',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 18,
                  ),
                  onPressed: widget.isLoading ? null : widget.onRefresh,
                  isPrimary: false,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildActionButton(
                  label: "Troubleshoot",
                  icon: CustomIconWidget(
                    iconName: 'build',
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: widget.isLoading ? null : widget.onTroubleshoot,
                  isPrimary: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: "Reconnect",
                  icon: CustomIconWidget(
                    iconName: 'link',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 18,
                  ),
                  onPressed: widget.isLoading ? null : widget.onReconnect,
                  isPrimary: false,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildActionButton(
                  label: "Export",
                  icon: CustomIconWidget(
                    iconName: 'download',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 18,
                  ),
                  onPressed:
                      widget.isLoading ? null : widget.onExportDiagnostics,
                  isPrimary: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          GestureDetector(
            onTap: () {
              setState(() {
                _showAdvanced = !_showAdvanced;
              });
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Advanced Diagnostics",
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  AnimatedRotation(
                    turns: _showAdvanced ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: CustomIconWidget(
                      iconName: 'expand_more',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showAdvanced ? null : 0,
            child: _showAdvanced
                ? _buildAdvancedDiagnostics()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Widget icon,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      height: 6.h,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: icon,
              label: Text(label),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: icon,
              label: Text(label),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
    );
  }

  Widget _buildAdvancedDiagnostics() {
    return Container(
      margin: EdgeInsets.only(top: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Technical Information",
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildTechnicalRow("Buffer Status", "Normal (85% free)"),
          SizedBox(height: 1.h),
          _buildTechnicalRow("Protocol Version", "BlueBridge v2.1"),
          SizedBox(height: 1.h),
          _buildTechnicalRow("Connection Type", "Classic Bluetooth"),
          SizedBox(height: 1.h),
          _buildTechnicalRow("Encryption", "AES-256 Enabled"),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            height: 5.h,
            child: OutlinedButton.icon(
              onPressed: () {
                // Show raw data in a modal or navigate to detailed view
              },
              icon: CustomIconWidget(
                iconName: 'code',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 16,
              ),
              label: const Text("View Raw Data"),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 35.w,
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
