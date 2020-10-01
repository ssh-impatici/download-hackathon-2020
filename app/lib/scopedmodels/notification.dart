import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hackathon/scopedmodels/connected.dart';

mixin NotificationModel on ConnectedModel {
  Future<void> initNotification() async {
    firebaseMessaging.configure(onLaunch: (Map<String, dynamic> msg) {
      return;
    }, onResume: (Map<String, dynamic> msg) {
      return;
    }, onMessage: (Map<String, dynamic> msg) {
      return;
    });

    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));

    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {});

    firebaseMessaging.getToken().then((token) {});
  }
}
