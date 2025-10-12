import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show Random;
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mpm/model/notification/NotificationDataModel.dart';
import 'package:mpm/utils/NotificationDatabase.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../view_model/controller/notification/NotificationApiController.dart';

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

  // Initialize audio player with proper settings
  static Future<void> _initializeAudioPlayer() async {
    try {
      await player.setAudioContext(AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: {
            AVAudioSessionOptions.allowBluetooth,
          },
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.notification,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      ));
      
      // Set volume to a reasonable level for notifications
      await player.setVolume(0.7);
      
      // Set release mode to prevent audio from continuing after app goes to background
      await player.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  // Dispose audio player properly
  static Future<void> disposeAudioPlayer() async {
    try {
      await player.stop();
      await player.dispose();
    } catch (e) {
      debugPrint('Error disposing audio player: $e');
    }
  }

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
    try {
      final controller = Get.find<NotificationApiController>();
        controller.loadLocalNotifications();
    } catch (e) {
      // Controller not found, ignore
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
    try {
      // Check if audio is enabled (you can add a setting for this)
      // For now, we'll always try to play, but with better error handling
      
      // Initialize audio player if not already done
      await _initializeAudioPlayer();
      
      // Stop any currently playing audio first
      await player.stop();
      
      // Play the notification sound
      await player.play(AssetSource('audio/smileringtone.mp3'));
    } catch (e) {
      debugPrint('Error playing notification sound: $e');
      // Silently fail - don't let audio errors break the app
      // This prevents the queuebuffer warnings from crashing the app
    }
  }

  // Method to disable audio completely if needed
  static bool _audioEnabled = true;
  
  static void setAudioEnabled(bool enabled) {
    _audioEnabled = enabled;
    if (!enabled) {
      disposeAudioPlayer();
    }
  }
  
  static bool get isAudioEnabled => _audioEnabled;

  Future<void> _showNotificationWithActions(RemoteMessage event) async {
    final unreadCount =
    await NotificationDatabase.instance.getUnreadNotificationCount();

    // iOS notification details (currently unused but kept for future use)
    // const iosNotificationDetails = DarwinNotificationDetails(
    //   presentAlert: true,
    //   presentBadge: true,
    //   presentSound: true,
    // );

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
    if (Get.isRegistered<NotificationApiController>()) {
      Get.find<NotificationApiController>().loadLocalNotifications();
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
