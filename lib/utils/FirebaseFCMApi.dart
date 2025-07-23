import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show Random;
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mpm/model/notification/NotificationModel.dart';
import 'package:mpm/utils/NotificationDatabase.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../view_model/controller/notification/NotificationController.dart';


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

final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();

class PushNotificationService {
  bool alreadySent = false;
  static AudioPlayer player = AudioPlayer();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  Map<String, dynamic>? msgOnLocal;

  static Future<void> checkNotification(RemoteMessage message) async {
    /*  await Future<void>.delayed(
      const Duration(milliseconds: 1000),
    );*/

    if (message != null) {
      final notificationType = message.data[kNotificationType] as String?;
      String title = message.notification!.title ?? "No Title";
      String body = message.notification!.body ?? "No Body";
      String image = message.notification!.android!.imageUrl ?? "";
      String timestamp = DateTime.now().toIso8601String();

      NotificationDatabase.instance.insertNotification(
        NotificationModel(title: title, body: body, image: image, timestamp: timestamp, isRead: false),
      );
      // final controller = Get.find<NotificationController>();
      // controller.loadNotifications();
      _goToScreen(notificationType, 0);
    }
  }

  Future<void> initialise() async {
    try {
      _configureDidReceiveLocalNotificationSubject();
      _configureSelectNotificationSubject();

      // Log Firebase token (non-critical)
      generateToken();

      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (notificationResponse) {
          if (notificationResponse.notificationResponseType ==
              NotificationResponseType.selectedNotification ||
              notificationResponse.actionId == navigationActionId) {
            selectNotificationStream.add(notificationResponse.payload);
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Request permissions on iOS/Mac
      if (Platform.isIOS || Platform.isMacOS) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true,
        );
      } else if (Platform.isAndroid) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestPermission();
      }

      // Setup listeners
      FirebaseMessaging.onMessage.listen((event) {
        print('Message data: ${event.data}');
        if (Platform.isAndroid) {
          playCustomNotificationSound();
          _showNotificationWithActions(event);
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final notificationType = message.data[kNotificationType] as String?;
        if (Platform.isAndroid) playCustomNotificationSound();
        if (!alreadySent) {
          alreadySent = true;
          Future<void>.delayed(
            const Duration(milliseconds: 1000),
                () => checkNotification(message),
          );
          _goToScreen(notificationType, 3);
        }
      });
    } catch (e) {
      print("❌ PushNotificationService.init failed: $e");
    }
  }


  static void _goToScreen(String? notificationType, int? orderId) {

    try {
      final navController = Get.find<UdateProfileController>();

        navController.changeTab(3);

    } on Exception catch (e, s) {

    }
  }

  Future<String?> generateToken() async {
    try {
      String? token;
      for (int i = 0; i < 3; i++) {
        token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) break;
        await Future.delayed(Duration(seconds: 2));
      }
      if (token == null || token.isEmpty) {
        print('❌ Failed to retrieve FCM token.');
      } else {
        print('✅ FCM Token: $token');
      }
      return token;
    } catch (e) {
      print('❌ Token generation failed: $e');
      return null;
    }
  }


  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream.listen((receivedNotification) async {

    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((payload) async {
      final data = json.decode(payload ?? '') as Map<String, dynamic>;
      print('notificationSelect ssTOP>> $data');
      final notificationType = data[kNotificationType] as String?;
     // await NotificationDatabase.instance.markNotificationAsRead(data);

      _goToScreen(notificationType ?? '',0);


    });
  }
  void playCustomNotificationSound() async {
    await player.play(AssetSource('audio/smileringtone.mp3'));
  }




  Future<void> _showNotificationWithActions(RemoteMessage event) async {
    final imageUrl = event.data['image'];

    if (imageUrl != null && imageUrl.isNotEmpty) {
      final response = await http.get(Uri.parse(imageUrl));
      final documentDirectory = await getApplicationDocumentsDirectory();
      final filePath = '${documentDirectory.path}/notif_image.jpg';
      final imageFile = File(filePath);
      await imageFile.writeAsBytes(response.bodyBytes);

      final bigPictureStyle = BigPictureStyleInformation(
        FilePathAndroidBitmap(filePath),
        contentTitle: event.notification?.title,
        summaryText: event.notification?.body,
      );

      final androidDetails = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        styleInformation: bigPictureStyle,
        importance: Importance.max,
        priority: Priority.high,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
        0,
        event.notification?.title,
        event.notification?.body,

        notificationDetails,
      );
    } else {
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

        sound: RawResourceAndroidNotificationSound("smileringtone"), // Use the channel sound
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
      final image= event.notification!.android!.imageUrl??"";
      print("dataevent"+image.toString());
      String timestamp = DateTime.now().toIso8601String();
      await flutterLocalNotificationsPlugin.show(
        Random().nextInt(9999),
        title,
        body,
        notificationDetails,

        payload: json.encode(event.data),

      );
      await NotificationDatabase.instance.insertNotification(
        NotificationModel(title: title, body: body,image: image, timestamp: timestamp,isRead: false),
      );
      final controller = Get.put<NotificationController>(NotificationController());
      controller.loadNotifications();
    }
  }



  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {


    String title = message.notification!.title ?? "No Title";
    String body = message.notification!.body ?? "No Body";
    String image = message.notification!.android!.imageUrl ??"";

    String timestamp = DateTime.now().toIso8601String();

   if(title!="No Title")
     {
       await NotificationDatabase.instance.insertNotification(
         NotificationModel(title: title, body: body, image:image,timestamp: timestamp,isRead: false),
       );
      // await NotificationDatabase.instance.markAllNotificationsAsRead();
       NotificationController controller;
       if (Get.isRegistered<NotificationController>()) {
         controller = Get.find<NotificationController>();
         controller.loadNotifications();
       }
     }
  }
}

extension on AndroidFlutterLocalNotificationsPlugin? {
  requestPermission() {}
}