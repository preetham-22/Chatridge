import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/connected_device_card_widget.dart';
import './widgets/empty_connected_devices_widget.dart';

class ConnectedDevicesScreen extends StatefulWidget {
  const ConnectedDevicesScreen({Key? key}) : super(key: key);

  @override
  State<ConnectedDevicesScreen> createState() => _ConnectedDevicesScreenState();
}

class _ConnectedDevicesScreenState extends State<ConnectedDevicesScreen> {
  Map<String, dynamic>? _parentDevice;
  List<Map<String, dynamic>> _connectedDevices = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  // Mock connected devices data
  final Map<String, List<Map<String, dynamic>>> _mockConnectedDevices = {
    "1": [
      // ESP32-BlueBridge-01
      {
        "id": "conn_1",
        "name": "Smart Temperature Sensor",
        "macAddress": "12:34:56:78:90:AB",
        "type": "Sensor",
        "connectionType": "Mesh",
        "signalStrength": 3,
        "isOnline": true,
        "lastSeen": DateTime.now().subtract(const Duration(minutes: 1)),
        "batteryLevel": 85,
        "dataTransferRate": "2.4 KB/s",
        "deviceInfo": {
          "firmware": "v1.5.2",
          "capabilities": ["Temperature", "Humidity", "Pressure"]
        }
      },
      {
        "id": "conn_2",
        "name": "Motion Detector Pro",
        "macAddress": "AB:CD:EF:12:34:56",
        "type": "Sensor",
        "connectionType": "Direct",
        "signalStrength": 4,
        "isOnline": true,
        "lastSeen": DateTime.now().subtract(const Duration(seconds: 15)),
        "batteryLevel": 92,
        "dataTransferRate": "1.8 KB/s",
        "deviceInfo": {
          "firmware": "v2.1.1",
          "capabilities": ["Motion Detection", "PIR Sensor", "Night Vision"]
        }
      },
      {
        "id": "conn_3",
        "name": "LED Strip Controller",
        "macAddress": "56:78:90:AB:CD:EF",
        "type": "Controller",
        "connectionType": "Mesh",
        "signalStrength": 2,
        "isOnline": false,
        "lastSeen": DateTime.now().subtract(const Duration(hours: 2)),
        "batteryLevel": null, // Powered device
        "dataTransferRate": "0 KB/s",
        "deviceInfo": {
          "firmware": "v1.3.4",
          "capabilities": ["RGB Control", "Effects", "Timer"]
        }
      }
    ],
    "4": [
      // BlueBridge-Hub-Main
      {
        "id": "conn_4",
        "name": "Security Camera Node",
        "macAddress": "98:76:54:32:10:FE",
        "type": "Camera",
        "connectionType": "WiFi Bridge",
        "signalStrength": 4,
        "isOnline": true,
        "lastSeen": DateTime.now().subtract(const Duration(minutes: 3)),
        "batteryLevel": null,
        "dataTransferRate": "45.2 KB/s",
        "deviceInfo": {
          "firmware": "v3.2.1",
          "capabilities": ["HD Video", "Night Vision", "Motion Alert"]
        }
      },
      {
        "id": "conn_5",
        "name": "Smart Door Lock",
        "macAddress": "FE:DC:BA:98:76:54",
        "type": "Lock",
        "connectionType": "Secure Link",
        "signalStrength": 3,
        "isOnline": true,
        "lastSeen": DateTime.now().subtract(const Duration(seconds: 45)),
        "batteryLevel": 68,
        "dataTransferRate": "0.5 KB/s",
        "deviceInfo": {
          "firmware": "v2.8.3",
          "capabilities": ["Keypad", "RFID", "Remote Unlock"]
        }
      },
      {
        "id": "conn_6",
        "name": "Weather Station",
        "macAddress": "32:10:FE:DC:BA:98",
        "type": "Sensor",
        "connectionType": "Long Range",
        "signalStrength": 1,
        "isOnline": true,
        "lastSeen": DateTime.now().subtract(const Duration(minutes: 8)),
        "batteryLevel": 45,
        "dataTransferRate": "3.1 KB/s",
        "deviceInfo": {
          "firmware": "v1.9.2",
          "capabilities": [
            "Temperature",
            "Wind Speed",
            "Rain Gauge",
            "UV Index"
          ]
        }
      },
      {
        "id": "conn_7",
        "name": "Garage Door Opener",
        "macAddress": "BA:98:76:54:32:10",
        "type": "Controller",
        "connectionType": "Mesh",
        "signalStrength": 2,
        "isOnline": false,
        "lastSeen":
            DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
        "batteryLevel": null,
        "dataTransferRate": "0 KB/s",
        "deviceInfo": {
          "firmware": "v1.4.7",
          "capabilities": ["Remote Control", "Status Monitor", "Security"]
        }
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConnectedDevices();
    });
  }

  void _loadConnectedDevices() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    setState(() {
      _parentDevice = args?['device'];
      _isLoading = true;
    });

    // Simulate loading delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final deviceId = _parentDevice?['id'] as String? ?? '';
        final connectedDevices = _mockConnectedDevices[deviceId] ?? [];

        setState(() {
          _connectedDevices = connectedDevices;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _refreshConnectedDevices() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.lightImpact();

    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      // Simulate some status changes
      for (var device in _connectedDevices) {
        device['lastSeen'] = DateTime.now();
        // Random battery level changes for battery-powered devices
        if (device['batteryLevel'] != null) {
          final currentLevel = device['batteryLevel'] as int;
          device['batteryLevel'] =
              (currentLevel + (-2 + (DateTime.now().millisecond % 5)))
                  .clamp(0, 100);
        }
      }

      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _showDeviceDetails(Map<String, dynamic> device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildDeviceDetailsSheet(device),
    );
  }

  void _disconnectDevice(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Disconnect Device'),
        content: Text('Are you sure you want to disconnect ${device['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _connectedDevices.removeWhere((d) => d['id'] == device['id']);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${device['name']} disconnected'),
                  backgroundColor: AppTheme.warningLight,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            child: Text('Disconnect',
                style: TextStyle(color: AppTheme.errorLight)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Connected Devices'),
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        actions: [
          IconButton(
            onPressed: _refreshConnectedDevices,
            icon: _isRefreshing
                ? SizedBox(
                    width: 6.w,
                    height: 6.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'refresh',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 6.w,
                  ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshConnectedDevices,
        color: AppTheme.lightTheme.primaryColor,
        child: Column(
          children: [
            // Parent Device Header
            if (_parentDevice != null) _buildParentDeviceHeader(),
            // Connected Devices List
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _connectedDevices.isEmpty
                      ? EmptyConnectedDevicesWidget(
                          parentDeviceName: _parentDevice?['name'] ?? 'Device',
                          onRefresh: _refreshConnectedDevices,
                        )
                      : _buildConnectedDevicesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentDeviceHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'hub',
              color: AppTheme.lightTheme.primaryColor,
              size: 8.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _parentDevice?['name'] ?? 'Unknown Device',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_connectedDevices.length} connected device${_connectedDevices.length != 1 ? 's' : ''}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.successLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.successLight, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.successLight,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Hub Active',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.successLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          SizedBox(height: 2.h),
          Text(
            'Loading connected devices...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedDevicesList() {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 10.h),
      itemCount: _connectedDevices.length,
      itemBuilder: (context, index) {
        final device = _connectedDevices[index];
        return ConnectedDeviceCardWidget(
          device: device,
          onTap: () => _showDeviceDetails(device),
          onDisconnect: () => _disconnectDevice(device),
        );
      },
    );
  }

  Widget _buildDeviceDetailsSheet(Map<String, dynamic> device) {
    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.textDisabledLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          // Device Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: _getDeviceIcon(device['type']),
                  color: AppTheme.lightTheme.primaryColor,
                  size: 8.w,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device['name'] ?? 'Unknown Device',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      device['macAddress'] ?? 'XX:XX:XX:XX:XX:XX',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          // Device Info
          _buildInfoRow('Type', device['type'] ?? 'Unknown'),
          _buildInfoRow('Connection', device['connectionType'] ?? 'Unknown'),
          _buildInfoRow(
              'Signal Strength', '${device['signalStrength']}/4 bars'),
          _buildInfoRow('Status', device['isOnline'] ? 'Online' : 'Offline'),
          _buildInfoRow('Data Transfer', device['dataTransferRate'] ?? 'N/A'),
          if (device['batteryLevel'] != null)
            _buildInfoRow('Battery', '${device['batteryLevel']}%'),
          _buildInfoRow('Last Seen', _formatLastSeen(device['lastSeen'])),
          if (device['deviceInfo'] != null) ...[
            _buildInfoRow(
                'Firmware', device['deviceInfo']['firmware'] ?? 'Unknown'),
            SizedBox(height: 2.h),
            Text(
              'Capabilities',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children:
                  (device['deviceInfo']['capabilities'] as List<String>? ?? [])
                      .map((capability) => Chip(
                            label: Text(
                              capability,
                              style: AppTheme.lightTheme.textTheme.labelSmall,
                            ),
                            backgroundColor: AppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.1),
                          ))
                      .toList(),
            ),
          ],
          SizedBox(height: 4.h),
          // Action Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: device['isOnline']
                  ? () {
                      Navigator.pop(context);
                      // Navigate to device control or settings
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: device['isOnline']
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.textDisabledLight,
              ),
              child: Text(
                device['isOnline'] ? 'Device Settings' : 'Device Offline',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDeviceIcon(String? type) {
    switch (type?.toLowerCase()) {
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

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
