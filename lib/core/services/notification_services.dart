import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // Local Notification Plugin to show the notification
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // For Taking Permission From the User
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: true,
      announcement: true,
      provisional: true,
      criticalAlert: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      dev.log('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      dev.log('User granted provisional permission');
    } else {
      AppSettings.openAppSettings();
      dev.log('User denied permission');
    }
  }

  void inItLocalNotifications(BuildContext context, RemoteMessage message) async {
    // Initilizing the plugin instance
    var androidInitializationSettings = const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInitializationSettings = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (payload) {});
  }

  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      // Logs to print the title and body of the message
      dev.log(message.notification!.title.toString());
      dev.log(message.notification!.body.toString());

      showNotification(message);
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(math.Random.secure().nextInt(1000000).toString(), 'High importance notifications');

    // Future.delayed(Duration.zero);
    // _flutterLocalNotificationsPlugin.show(0,
    //  message.notification!.title.toString(),
    //  message.notification!.body.toString(),
    //  notificationDetails)
  }

  Future<String> getDeviveToken() async {
    String? token = await messaging.getToken();
    if (token != null) {
      dev.log('FCM token: $token');
      return token;
    } else {
      dev.log('Failed to get token');
      return 'Failed to get token';
    }
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      dev.log('isTokenRefreshed: ${event.toString()}');
    });
  }
}
