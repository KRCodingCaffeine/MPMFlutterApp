import 'package:device_preview/device_preview.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/route/route_page.dart';

import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // if (Firebase.apps.isEmpty) {
  //   await Firebase.initializeApp(
  //    name: 'maheshvari',
  //    options: DefaultFirebaseOptions.currentPlatform,
  //   );
  //   await PushNotificationService().initialise();
  // }

  // GetServerKey getServerKey=GetServerKey();
  // String acc= await getServerKey.getServerKey();
  // print("aaa"+acc.toString());
  // runApp(MyApp());
  runApp(
      DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => MyApp(), // Wrap your app
      ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Ubuntu-Regular.ttf',
        colorScheme: ColorScheme.fromSeed(seedColor: ColorHelperClass.getColorFromHex(ColorResources.primary_color)),
        useMaterial3: true,
      ),
      onGenerateRoute: RoutePages.generateRoute,
      initialRoute: RouteNames.splash_screen,
    );
  }
}


