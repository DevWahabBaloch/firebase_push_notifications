import 'dart:developer';

import 'package:firebase_push_notification/core/services/notification_services.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NotificationServices notificationServices = NotificationServices();
  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.isTokenRefresh();
    notificationServices.getDeviveToken().then((value) {
      log('Device Token: $value');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
