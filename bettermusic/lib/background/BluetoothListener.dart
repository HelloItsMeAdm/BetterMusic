import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../utils/Constants.dart';
import '../utils/DownloadManager.dart';
import '../utils/SharedPrefs.dart';
import 'Player.dart';

class BluetoothListener {
  String deviceAddress = "74:65:0C:3B:01:5A";

  Future<void> checkBluetoothDevice() async {
    FlutterBluetoothSerial flutterBluetoothSerial = FlutterBluetoothSerial.instance;
    List<BluetoothDevice> devices = await flutterBluetoothSerial.getBondedDevices();
    for (BluetoothDevice device in devices) {
      if (device.address == deviceAddress) {
        if (device.isConnected) {
          if (Player().pauseType() == 2) {
            DownloadManager().getDownloadedFiles().then((files) {
              Constants().getAppSpecificFilesDir().then((path) async => {
                SharedPrefs()
                    .getMapData()
                    .then((data) => {Player().play(data, path, 0)})
              });
            });
          }
        } else {
          Player().stop();
        }
      }
    }
  }
}
