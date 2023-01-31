import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'BluetoothListener.dart';

class KeepOnBackground {
  Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'background_service',
      'Background Service',
      description: 'Service to keep the app running in the background',
      importance: Importance.high,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: false,
        notificationChannelId: 'background_service',
        initialNotificationTitle: 'Background Service',
        initialNotificationContent: 'Service is running',
        foregroundServiceNotificationId: 1,
      ),
      iosConfiguration: IosConfiguration(),
    );
  }

  static Future<void> onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      await BluetoothListener().checkBluetoothDevice();
    });
  }
}
