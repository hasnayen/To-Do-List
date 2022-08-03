import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import 'main.dart';

class NotificationManager {
  setNotification(int diff, String title, String time) {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    Workmanager().registerOneOffTask('Task identifier', 'taskName',
        initialDelay: Duration(seconds: diff),
        inputData: <String, dynamic>{'title': title, 'time': time});
  }
}

callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    var title = inputData!['title'].toString();
    var time = inputData['time'].toString();
    _showNotification(title, time);
    return Future.value(true);
  });
}

Future<void> _showNotification(String title, String time) async {
  const AndroidNotificationDetails androidNotificationDetailsChannelSpecific =
      AndroidNotificationDetails('channelId', 'channelName',
          channelDescription: 'Channel description',
          importance: Importance.max,
          priority: Priority.max,
          ticker: 'ticker');

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidNotificationDetailsChannelSpecific);
  await flutterLocalNotificationsPlugin.show(
      0, 'Up next "$title"', 'At $time', platformChannelSpecifics,
      payload: 'item payload');
}
