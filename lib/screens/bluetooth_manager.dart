import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();
  factory BluetoothManager() => _instance;
  BluetoothManager._internal();

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? targetCharacteristic;

  final StreamController<String> _dataController =
      StreamController<String>.broadcast();

  Stream<String> get dataStream => _dataController.stream;

  bool get isConnected => connectedDevice != null;

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      if (connectedDevice != null) {
        await connectedDevice!.disconnect();
        connectedDevice = null;
      }

      await device.connect();
      connectedDevice = device;

      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var char in service.characteristics) {
          if (char.properties.notify) {
            targetCharacteristic = char;
            await char.setNotifyValue(true);
            char.value.listen((value) {
              final data = String.fromCharCodes(value);
              _dataController.add(data);
            });
            break;
          }
        }
      }
    } catch (e) {
      print("Bluetooth bağlantı hatası: $e");
    }
  }

  void disconnect() {
    connectedDevice?.disconnect();
    connectedDevice = null;
    targetCharacteristic = null;

    if (!_dataController.isClosed) {
      _dataController.close();
    }
  }
}
