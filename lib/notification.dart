import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

class NotificationService {
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    debugPrint('Handling a background message ${message.data}');

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification!.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          playSound: true,
          icon: 'launch_background',
        ),
      ),
    );
  }

  late AndroidNotificationChannel channel;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  init() async {
    // Set the background messaging handler early on, as a named top-level function
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    final notificationSettings =
        await FirebaseMessaging.instance.requestPermission(provisional: true);
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title

        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    FirebaseMessaging.instance
        .getToken()
        .then((value) => debugPrint("FCM TOKEN:$value"));
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      print("Notification received $message");
      AndroidNotification? android = message.notification?.android;
      if (message.notification?.android?.imageUrl == null) {
        if (notification != null && android != null && !kIsWeb) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                icon: 'launch_background',
              ),
            ),
          );
        }
      } else {
        if (notification != null && android != null && !kIsWeb) {
          var attachmentPicturePath = await _downloadAndSaveFile(
              message.notification!.android!.imageUrl!, "attachment_img.jpg");
          var bigPictureStyleInformation = BigPictureStyleInformation(
            FilePathAndroidBitmap(attachmentPicturePath),
            contentTitle: '<b>Attached Image</b>',
            htmlFormatContentTitle: true,
            summaryText: 'Test Image',
            htmlFormatSummaryText: true,
          );
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name,
                  icon: 'launch_background',
                  largeIcon: FilePathAndroidBitmap(attachmentPicturePath),
                  styleInformation: bigPictureStyleInformation),
            ),
          );
        }
      }
    });
  }

  _downloadAndSaveFile(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    await Dio().download(url, filePath);

    return filePath;
  }
}
