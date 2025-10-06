import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  final FlutterBluePlus _flutterBlue = FlutterBluePlus;

  // Stream to expose scan results
  Stream<List<ScanResult>> get scanResults => _flutterBlue.scanResults;

  // Stream to expose scanning state
  Stream<bool> get isScanning => _flutterBlue.isScanning;

  // Start scanning for devices
  Future<void> startScan(
      {Duration timeout = const Duration(seconds: 5)}) async {
    // `startScan` is non-blocking, so we can listen to the `isScanning` stream
    // to know when it has started and stopped.
    try {
      await _flutterBlue.startScan(timeout: timeout);
    } catch (e) {
      // Handle exceptions from starting the scan
      print("Error starting scan: $e");
    }
  }

  // Stop scanning for devices
  Future<void> stopScan() async {
    try {
      await _flutterBlue.stopScan();
    } catch (e) {
      print("Error stopping scan: $e");
    }
  }

  // Connect to a device
  Future<void> connect(BluetoothDevice device) async {
    try {
      // Listen for connection state changes
      device.connectionState.listen((BluetoothConnectionState state) async {
        if (state == BluetoothConnectionState.disconnected) {
          // Handle disconnection
          print("Device Disconnected: ${device.remoteId}");
        }
      });
      await device.connect(autoConnect: false);
      print("Connected to ${device.remoteId}");
    } catch (e) {
      print("Error connecting to device: $e");
      // Optionally re-throw or handle the error
    }
  }

  // Disconnect from a device
  Future<void> disconnect(BluetoothDevice device) async {
    try {
      await device.disconnect();
      print("Disconnected from ${device.remoteId}");
    } catch (e) {
      print("Error disconnecting from device: $e");
    }
  }
}
