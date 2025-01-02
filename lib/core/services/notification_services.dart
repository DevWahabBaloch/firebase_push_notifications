import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
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
      log('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      log('User granted provisional permission');
    } else {
      AppSettings.openAppSettings();
      log('User denied permission');
    }
  }

  Future<String> getDeviveToken() async {
    String? token = await messaging.getToken();
    if (token != null) {
      log('FCM token: $token');
      return token;
    } else {
      log('Failed to get token');
      return 'Failed to get token';
    }
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      log('isTokenRefreshed: ${event.toString()}');
    });
  }
}
