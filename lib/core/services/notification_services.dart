import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_push_notification/features/message_page/presentation/pages/message_page.dart';
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
    var androidInitializationSettings = const AndroidInitializationSettings('ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (payload) {
      handleMessage(context, message);
    });
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      // Logs to print the title and body of the message
      dev.log(message.notification!.title.toString());
      dev.log(message.notification!.body.toString());
      dev.log(message.data.toString());
      dev.log(message.data['type']);
      dev.log(message.data['id']);

      //  For Redirecting to the screen when the message is received and clicked
      inItLocalNotifications(context, message);
      showNotification(message);
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        math.Random.secure().nextInt(100000).toString(), 'High Importance Notifications',
        importance: Importance.max);
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(), channel.name.toString(),
        channelDescription: 'Your channel description',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
        icon: 'ic_launcher');

    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero);
    _flutterLocalNotificationsPlugin.show(
        0, message.notification!.title.toString(), message.notification!.body.toString(), notificationDetails);
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

  // When the popup is clicked
  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'message') {
      dev.log('Message type is ${message.data['type']}. Navigating to MessagePage...');
      // Navigate to the message page when the message is clicked
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return const MessagePage();
        },
      ));
    }
  }
}
