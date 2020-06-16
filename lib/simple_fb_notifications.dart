library simple_fb_notifications;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void showNotification(notification) {
  var and = AndroidNotificationDetails('chid_bin', 'chname_bin', 'chdesc_bin',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
  var ind = IOSNotificationDetails();

  flutterLocalNotificationsPlugin.show(0, notification["title"],
      notification["body"], NotificationDetails(and, ind));
}

void initializeNotification(topic) async {
  var initializationSettingsAndroid =
      AndroidInitializationSettings('notification_icon');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> data) async {
      if (data.containsKey('notification'))
        showNotification(data['notification']);
    },
  );
  var res = await _firebaseMessaging.requestNotificationPermissions();
  if (res == null || res) {
    await _firebaseMessaging.subscribeToTopic(topic);
    print(await _firebaseMessaging.getToken());
  }
}

class NotificationWrapper extends StatefulWidget {
  final Widget child;
  final String topic;
  final void Function(String) onToken;
  NotificationWrapper({this.child, @required this.topic, this.onToken});
  @override
  _NotificationWrapperState createState() => _NotificationWrapperState();
}

class _NotificationWrapperState extends State<NotificationWrapper> {
  _NotificationWrapperState();

  @override
  void initState() {
    super.initState();
    initializeNotification(widget.topic);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
