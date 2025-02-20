import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );

      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }



  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0OAakQDm23j1-LJMHtWoJ63TD9Yb6bbA',
    appId: '1:976331994564:android:04a7a0418717324ec92091',
    messagingSenderId: '976331994564',
    projectId: 'maheshvari-2d787',
      storageBucket: "maheshvari-2d787.firebasestorage.app"
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
    storageBucket: '',
    androidClientId: '',
    iosClientId: '',
    iosBundleId: '',
  );

}
