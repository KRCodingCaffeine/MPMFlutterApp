import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show Random;
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mpm/model/notification/NotificationModel.dart';
import 'package:mpm/utils/NotificationDatabase.dart';


const AndroidInitializationSettings android =

AndroidInitializationSettings('@drawable/logo');

class ReceivedNotification {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}

const kNotificationType = 'notification_type';

final InitializationSettings initializationSettings = InitializationSettings(
  android: android,
  iOS: initializationSettingsDarwin,
);
final List<DarwinNotificationCategory> darwinNotificationCategories =
<DarwinNotificationCategory>[
  DarwinNotificationCategory(
    darwinNotificationCategoryText,
    actions: <DarwinNotificationAction>[
      DarwinNotificationAction.text(
        'text_1',
        'Action 1',
        buttonTitle: 'Send',
        placeholder: 'Placeholder',
      ),
    ],
  ),
  const DarwinNotificationCategory(
    darwinNotificationCategoryPlain,
    options: <DarwinNotificationCategoryOption>{
      DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
    },
  ),
];

/// Note: permissions aren't requested here just to demonstrate that can be
/// done later
final DarwinInitializationSettings initializationSettingsDarwin =
DarwinInitializationSettings(
  requestAlertPermission: false,
  requestBadgePermission: false,
  requestSoundPermission: false,


  notificationCategories: darwinNotificationCategories,
);

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    // DebugUtils.showLog(
    //   'notification action tapped with input: ${notificationResponse.input}',
    // );
  }
}

/// A notification action which triggers a url launch event

const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';
const String darwinNotificationCategoryText = 'textCategory';
const String darwinNotificationCategoryPlain = 'plainCategory';

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream = StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
StreamController<String?>.broadcast();

class PushNotificationService {
  bool alreadySent = false;
  static AudioPlayer player = AudioPlayer();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  Map<String, dynamic>? msgOnLocal;

  static Future<void> checkNotification() async {
    /*  await Future<void>.delayed(
      const Duration(milliseconds: 1000),
    );*/
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      final notificationType = message.data[kNotificationType] as String?;
      String title = message.notification!.title ?? "No Title";
      String body = message.notification!.body ?? "No Body";
      String timestamp = DateTime.now().toIso8601String();

      NotificationDatabase.instance.insertNotification(
        NotificationModel(title: title, body: body, timestamp: timestamp),
      );
      _goToScreen(notificationType, 0);
    }
  }

  Future<void> initialise() async {
    // await Firebase.();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    String? token=await generateToken();
    print("token"+token.toString());

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,

      sound: true,
    );
  await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              selectNotificationStream.add(notificationResponse.payload);
            }
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,

        critical: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: true,
      );
    } else if (Platform.isAndroid) {
      final androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      /*final granted = */
      await androidImplementation?.requestPermission();
      // if (granted ?? false) {
      await generateToken();
      // }
    }

    FirebaseMessaging.onMessage.listen((event) {
      //var notificationType = event.data[kNotificationType];
      // DebugUtils.showLog(
      //   'getData > ${event.data} getMessage > ${event.notification?.toMap()}',
      // );
      if (Platform.isAndroid)
        {
          playCustomNotificationSound();
          _showNotificationWithActions(event);

        }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // DebugUtils.showLog(
      //   'notificationSelect >> ${message.data}  ${message.data[kNotificationType]}',
      // );
      final notificationType = message.data[kNotificationType] as String?;
      // DebugUtils.showLog(
      //   'notificationSelect ss>> $notificationType ${notificationType.runtimeType}',
      // );
      if (Platform.isAndroid)
      {
        playCustomNotificationSound();


      }
      if (!alreadySent) {
        alreadySent = true;
      }
      _goToScreen(notificationType, 0);
    });

    Future<void>.delayed(
      const Duration(milliseconds: 1000),
          () {
        if (!alreadySent) {
          unawaited(checkNotification());
        }
      },
    );
  }

  static void _goToScreen(String? notificationType, int? orderId) {
    try {

    } on Exception catch (e, s) {

    }
  }

  Future<String?> generateToken() async {
    final deviceToken = await FirebaseMessaging.instance.getToken();
    // Just for testing will remove in future
    //DebugUtils.showLog(deviceToken!, prefix: 'Device/FCM Token >> ');
    return deviceToken;
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((receivedNotification) async {

    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((payload) async {
      final data = json.decode(payload ?? '') as Map<String, dynamic>;
      //DebugUtils.showLog('notificationSelect ssTOP>> $data');
      final notificationType = data[kNotificationType] as String?;


        _goToScreen(notificationType ?? '',0);


    });
  }
  void playCustomNotificationSound() async {
    await player.play(AssetSource('audio/noficationaudio.mp3'));
  }

  Future<void> _showNotificationWithActions(RemoteMessage event) async {

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();



    const iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: darwinNotificationCategoryPlain,
    );
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
    "MPM",
      "MPM",
      channelDescription: "MPM",
      importance: Importance.max,
      priority: Priority.high,

      sound: RawResourceAndroidNotificationSound("noficationaudio"), // Use the channel sound
      icon: '@drawable/logo',
      enableLights: true,
      enableVibration: true,

      styleInformation: MediaStyleInformation(
        htmlFormatContent: true,
        htmlFormatTitle: true,
      ),
      playSound: true,
    );

    var notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
    final title = event.notification?.title ?? '';
    final body = event.notification?.body ?? '';
    String timestamp = DateTime.now().toIso8601String();
    await flutterLocalNotificationsPlugin.show(
      Random().nextInt(9999),
      title,
      body,
      notificationDetails,

      payload: json.encode(event.data),

    );
    NotificationDatabase.instance.insertNotification(
      NotificationModel(title: title, body: body, timestamp: timestamp),
    );
  }
}

extension on AndroidFlutterLocalNotificationsPlugin? {
  requestPermission() {}
}