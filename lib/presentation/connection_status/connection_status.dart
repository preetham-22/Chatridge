import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/communication_log_widget.dart';
import './widgets/device_info_card_widget.dart';
import './widgets/diagnostic_actions_widget.dart';
import './widgets/signal_quality_chart_widget.dart';
import './widgets/signal_strength_widget.dart';

class ConnectionStatus extends StatefulWidget {
  const ConnectionStatus({Key? key}) : super(key: key);

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus> {
  bool _isLoading = false;
  bool _autoRefresh = true;
  Timer? _refreshTimer;

  // Mock data for demonstration
  final Map<String, dynamic> _deviceInfo = {
    "name": "ESP32-BlueBridge-01",
    "macAddress": "AA:BB:CC:DD:EE:FF",
    "firmwareVersion": "v2.1.3",
    "lastCommunication": "2 minutes ago",
    "dataSent": "1.2",
    "dataReceived": "0.8",
    "isConnected": true,
  };

  final List<Map<String, dynamic>> _signalData = [
    {"strength": 85, "timestamp": "09:10"},
    {"strength": 82, "timestamp": "09:11"},
    {"strength": 78, "timestamp": "09:12"},
    {"strength": 80, "timestamp": "09:13"},
    {"strength": 88, "timestamp": "09:14"},
    {"strength": 85, "timestamp": "09:15"},
  ];

  final List<Map<String, dynamic>> _communicationLogs = [
    {
      "status": "success",
      "message": "Message sent successfully",
      "timestamp": "09:15:23",
    },
    {
      "status": "success",
      "message": "Heartbeat received",
      "timestamp": "09:15:18",
    },
    {
      "status": "failed",
      "message": "Connection timeout",
      "timestamp": "09:14:45",
      "errorCode": "BT_TIMEOUT_001",
    },
    {
      "status": "success",
      "message": "Device paired successfully",
      "timestamp": "09:14:32",
    },
    {
      "status": "success",
      "message": "Encryption handshake complete",
      "timestamp": "09:14:28",
    },
  ];

  int _currentSignalStrength = 85;
  double _packetLoss = 1.2;
  int _latency = 85;
  Duration _connectionDuration = const Duration(hours: 2, minutes: 34);

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    if (_autoRefresh) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted) {
          _refreshData();
        }
      });
    }
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  void _refreshData() {
    if (!mounted) return;

    setState(() {
      // Simulate real-time data updates
      _currentSignalStrength = 75 + (DateTime.now().millisecond % 25);
      _packetLoss = (DateTime.now().millisecond % 50) / 10.0;
      _latency = 50 + (DateTime.now().millisecond % 200);
      _connectionDuration = _connectionDuration + const Duration(seconds: 5);

      // Add new signal data point
      _signalData.add({
        "strength": _currentSignalStrength,
        "timestamp":
            "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      });

      // Keep only last 10 data points
      if (_signalData.length > 10) {
        _signalData.removeAt(0);
      }
    });
  }

  void _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate refresh operation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      _refreshData();
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connection status refreshed"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleTroubleshoot() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate troubleshooting sequence
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      _showTroubleshootResults();
    }
  }

  void _showTroubleshootResults() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              const Text("Diagnostic Complete"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDiagnosticResult("Ping Test", "Passed", true),
              SizedBox(height: 1.h),
              _buildDiagnosticResult("Signal Quality", "Good", true),
              SizedBox(height: 1.h),
              _buildDiagnosticResult("Buffer Status", "Normal", true),
              SizedBox(height: 1.h),
              _buildDiagnosticResult("Encryption", "Active", true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDiagnosticResult(String test, String result, bool passed) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: passed ? 'check' : 'close',
          color: passed
              ? AppTheme.lightTheme.colorScheme.tertiary
              : AppTheme.lightTheme.colorScheme.error,
          size: 16,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            test,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ),
        Text(
          result,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: passed
                ? AppTheme.lightTheme.colorScheme.tertiary
                : AppTheme.lightTheme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  void _handleReconnect() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate reconnection process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _deviceInfo["isConnected"] = true;
        _connectionDuration = Duration.zero;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reconnection successful"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleExportDiagnostics() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate export process
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Diagnostic report exported successfully"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Connection Status"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _autoRefresh = !_autoRefresh;
              });

              if (_autoRefresh) {
                _startAutoRefresh();
              } else {
                _stopAutoRefresh();
              }
            },
            icon: CustomIconWidget(
              iconName: _autoRefresh ? 'pause' : 'play_arrow',
              color: _autoRefresh
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading && !_autoRefresh
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 2.h),
                    Text(
                      "Updating connection status...",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with signal strength and connection duration
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.lightTheme.colorScheme.primary,
                            AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Primary Device",
                                    style: AppTheme
                                        .lightTheme.textTheme.labelMedium
                                        ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    _deviceInfo["name"] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.titleLarge
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SignalStrengthWidget(
                                signalStrength: _currentSignalStrength,
                                isConnected: _deviceInfo["isConnected"] as bool,
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'timer',
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 16,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                "Connected for ${_formatDuration(_connectionDuration)}",
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Device Information Card
                    DeviceInfoCardWidget(deviceInfo: _deviceInfo),

                    SizedBox(height: 3.h),

                    // Signal Quality Chart
                    SignalQualityChartWidget(
                      signalData: _signalData,
                      packetLoss: _packetLoss,
                      latency: _latency,
                    ),

                    SizedBox(height: 3.h),

                    // Communication Log
                    CommunicationLogWidget(
                        communicationLogs: _communicationLogs),

                    SizedBox(height: 3.h),

                    // Diagnostic Actions
                    DiagnosticActionsWidget(
                      onRefresh: _handleRefresh,
                      onTroubleshoot: _handleTroubleshoot,
                      onReconnect: _handleReconnect,
                      onExportDiagnostics: _handleExportDiagnostics,
                      isLoading: _isLoading,
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
      ),
    );
  }
}
