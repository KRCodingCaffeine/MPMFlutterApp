import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show Random;
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mpm/model/notification/NotificationDataModel.dart';
import 'package:mpm/utils/NotificationDatabase.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../view_model/controller/notification/NotificationController.dart';

// ------------------ Constants ------------------
const kNotificationType = 'notification_type';
const String urlLaunchActionId = 'id_1';
const String navigationActionId = 'id_3';
const String darwinNotificationCategoryText = 'textCategory';
const String darwinNotificationCategoryPlain = 'plainCategory';

const AndroidInitializationSettings android =
AndroidInitializationSettings('@drawable/logo');

final DarwinInitializationSettings initializationSettingsDarwin =
DarwinInitializationSettings(
  requestAlertPermission: false,
  requestBadgePermission: false,
  requestSoundPermission: false,
  notificationCategories: [
    DarwinNotificationCategory(
      darwinNotificationCategoryText,
      actions: [
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
      options: {
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    ),
  ],
);

final InitializationSettings initializationSettings = InitializationSettings(
  android: android,
  iOS: initializationSettingsDarwin,
);

// ------------------ Streams ------------------
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
StreamController<String?>.broadcast();

// ------------------ Model ------------------
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

// ------------------ PushNotificationService ------------------
class PushNotificationService {
  bool alreadySent = false;
  static AudioPlayer player = AudioPlayer();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // ✅ Unified method: inserts into DB and refreshes controller
  static Future<void> checkNotification(RemoteMessage message) async {
    final notificationType = message.data[kNotificationType] as String?;
    final notification = message.notification;

    String title = notification?.title ?? "No Title";
    String body = notification?.body ?? "No Body";
    String? image = Platform.isAndroid
        ? notification?.android?.imageUrl
        : notification?.apple?.imageUrl;

    String timestamp = DateTime.now().toIso8601String();

    await NotificationDatabase.instance.insertNotification(
      NotificationDataModel(
        title: title,
        body: body,
        image: image ?? "",
        timestamp: timestamp,
        isRead: false,
      ),
    );

    // 🔹 Immediately refresh UI if controller is active
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().loadNotifications();
    }

    _goToScreen(notificationType, 0);
  }

  Future<void> initialise() async {
    try {
      _configureDidReceiveLocalNotificationSubject();
      _configureSelectNotificationSubject();
      generateToken();

      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (notificationResponse) async {
          // 🔹 Tap on notification
          if (notificationResponse.notificationResponseType ==
              NotificationResponseType.selectedNotification ||
              notificationResponse.actionId == navigationActionId) {
            selectNotificationStream.add(notificationResponse.payload);
          }

          // 🔹 Dismiss/swipe notification
          // if (notificationResponse.notificationResponseType ==
          //     NotificationResponseType.dismissed) {
          //   // Mark as read in DB
          //   await NotificationDatabase.instance.markAllNotificationsAsRead();
          //   // Refresh controller
          //   if (Get.isRegistered<NotificationController>()) {
          //     Get.find<NotificationController>().loadNotifications();
          //   }
          //   // Update badge
          //   //await updateAppBadge();
          // }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // 🔹 Request permissions
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
      } else if (Platform.isAndroid) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
            ?.requestPermission();
      }

      // 🔹 Foreground notification
      FirebaseMessaging.onMessage.listen((event) {
        if (Platform.isAndroid) playCustomNotificationSound();
        _showNotificationWithActions(event);
      });

      // 🔹 Background tap
      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        if (Platform.isAndroid) playCustomNotificationSound();
        if (!alreadySent) {
          alreadySent = true;
          await checkNotification(message);
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
    } catch (_) {}
  }

  Future<String?> generateToken() async {
    try {
      String? token;
      for (int i = 0; i < 3; i++) {
        token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) break;
        await Future.delayed(Duration(seconds: 2));
      }
      if (token != null && token.isNotEmpty) {
        print('✅ FCM Token: $token');
      } else {
        print('❌ Failed to retrieve FCM token.');
      }
      return token;
    } catch (e) {
      print('❌ Token generation failed: $e');
      return null;
    }
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream.listen((receivedNotification) {});
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((payload) async {
      final data = json.decode(payload ?? '') as Map<String, dynamic>;
      final notificationType = data[kNotificationType] as String?;
      _goToScreen(notificationType ?? '', 0);
    });
  }

  void playCustomNotificationSound() async {
    await player.play(AssetSource('audio/smileringtone.mp3'));
  }

  Future<void> _showNotificationWithActions(RemoteMessage event) async {
    final unreadCount =
    await NotificationDatabase.instance.getUnreadNotificationCount();

    const iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final androidNotificationDetails = AndroidNotificationDetails(
      "MPM",
      "MPM",
      channelDescription: "MPM",
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound("smileringtone"),
      icon: '@drawable/logo',
      enableLights: true,
      enableVibration: true,
      number: unreadCount, // 🔹 shows unread count
      styleInformation: MediaStyleInformation(
        htmlFormatContent: true,
        htmlFormatTitle: true,
      ),
      playSound: true,
    );

    var notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      //iOS: iosNotificationDetails.copyWith(badgeNumber: unreadCount),
    );

    final title = event.notification?.title ?? '';
    final body = event.notification?.body ?? '';
    final image = event.notification?.android?.imageUrl ?? "";
    String timestamp = DateTime.now().toIso8601String();

    await flutterLocalNotificationsPlugin.show(
      Random().nextInt(9999),
      title,
      body,
      notificationDetails,
      payload: json.encode(event.data),
    );

    // Save in DB
    await NotificationDatabase.instance.insertNotification(
      NotificationDataModel(
        title: title,
        body: body,
        image: image,
        timestamp: timestamp,
        isRead: false,
      ),
    );

    // Refresh UI + badge
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().loadNotifications();
    }
    await updateAppBadge();
  }


  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await checkNotification(message); // ✅ Background now also updates UI
  }

  Future<void> handleInitialNotification() async {
    final initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (!alreadySent) {
        alreadySent = true;
        await checkNotification(initialMessage); // ✅ Auto refresh
      }
    }
  }

  static Future<void> updateAppBadge() async {
    final count = await NotificationDatabase.instance.getUnreadNotificationCount();
    if (count > 0) {
      FlutterAppBadger.updateBadgeCount(count);
    } else {
      FlutterAppBadger.removeBadge();
    }
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('notification(${notificationResponse.id}) tapped: '
      '${notificationResponse.actionId} payload: ${notificationResponse.payload}');
}

extension on AndroidFlutterLocalNotificationsPlugin? {
  requestPermission() {}
}
