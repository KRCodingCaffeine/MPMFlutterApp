import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/route/route_page.dart';
import 'package:mpm/utils/DefaultFirebaseOptions.dart';
import 'package:mpm/view_model/controller/notification/NotificationApiController.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/notification_service.dart';
import 'package:mpm/utils/device_token_service.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Register background handler BEFORE Firebase initialization
//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//
//   await Firebase.initializeApp();
//   await NotificationService().init();
//   await DeviceTokenService().initialize();
//
//   // Register NotificationApiController globally
//   Get.put(NotificationApiController(), permanent: true);
//
//   // Lock screen orientation
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
//
//   runApp(
//     DevicePreview(
//       enabled: !kReleaseMode, // Only enable in debug / dev mode
//       builder: (context) => const MyApp(),
//     ),
//   );
// }


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🚀 STARTUP 1: Flutter initialized');

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  debugPrint('⏳ STARTUP 2: Initializing Firebase...');
  await Firebase.initializeApp();
  debugPrint('✅ STARTUP 2: Firebase initialized');

  debugPrint('⏳ STARTUP 3: Initializing notifications...');
  await NotificationService().init();
  debugPrint('✅ STARTUP 3: Notifications initialized');

  debugPrint('⏳ STARTUP 4: Initializing device token...');
  await DeviceTokenService().initialize();
  debugPrint('✅ STARTUP 4: Device token initialized');

  debugPrint('⏳ STARTUP 5: Registering notification controller...');
  Get.put(NotificationApiController(), permanent: true);
  debugPrint('✅ STARTUP 5: Controller registered');

  debugPrint('⏳ STARTUP 6: Setting screen orientation...');
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  debugPrint('✅ STARTUP 6: Orientation configured');

  debugPrint('🚀 STARTUP 7: Calling runApp()');

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}


// Background handler is now in notification_service.dart

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      useInheritedMediaQuery: true, // ✅ Needed for DevicePreview
      locale: DevicePreview.locale(context), // ✅ Sync locale with DevicePreview
      builder: DevicePreview.appBuilder, //
      debugShowCheckedModeBanner: false,
      // ✅ ADD THIS
      localizationsDelegates: const [
        MonthYearPickerLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('en'),
      ],


      theme: ThemeData(
        fontFamily: 'Ubuntu-Regular.ttf',
        colorScheme: ColorScheme.fromSeed(
          seedColor:
              ColorHelperClass.getColorFromHex(ColorResources.primary_color),
        ),
        useMaterial3: true,
      ),
      onGenerateRoute: RoutePages.generateRoute,
      initialRoute: RouteNames.splash_screen,
    );
  }
}
