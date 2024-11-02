// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAtqp26TDrH0DOeGI532lHctXOwR1X-se8',
    appId: '1:341726152441:web:ffea3ef497b8f850004428',
    messagingSenderId: '341726152441',
    projectId: 'tasksystem-4d1dd',
    authDomain: 'tasksystem-4d1dd.firebaseapp.com',
    storageBucket: 'tasksystem-4d1dd.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5-yqAcJ6CDJpRUB6_viP2b2e25XgrSlc',
    appId: '1:341726152441:android:49aec8dbd2a75259004428',
    messagingSenderId: '341726152441',
    projectId: 'tasksystem-4d1dd',
    storageBucket: 'tasksystem-4d1dd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYuzZd1x6q2T6_sXJmBzb-hMXTKhhlUPs',
    appId: '1:341726152441:ios:340c7ca06b57edbf004428',
    messagingSenderId: '341726152441',
    projectId: 'tasksystem-4d1dd',
    storageBucket: 'tasksystem-4d1dd.firebasestorage.app',
    iosBundleId: 'com.example.taskmanagerr',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAYuzZd1x6q2T6_sXJmBzb-hMXTKhhlUPs',
    appId: '1:341726152441:ios:340c7ca06b57edbf004428',
    messagingSenderId: '341726152441',
    projectId: 'tasksystem-4d1dd',
    storageBucket: 'tasksystem-4d1dd.firebasestorage.app',
    iosBundleId: 'com.example.taskmanagerr',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAtqp26TDrH0DOeGI532lHctXOwR1X-se8',
    appId: '1:341726152441:web:f8634191ee08238a004428',
    messagingSenderId: '341726152441',
    projectId: 'tasksystem-4d1dd',
    authDomain: 'tasksystem-4d1dd.firebaseapp.com',
    storageBucket: 'tasksystem-4d1dd.firebasestorage.app',
  );

}