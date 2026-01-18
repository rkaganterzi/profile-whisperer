import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_RsfFDMMTE6Al1b8_SWVO4dD03di2RFo',
    appId: '1:412732474388:android:0861936537b5f9d6181301',
    messagingSenderId: '412732474388',
    projectId: 'profile-whisperer',
    storageBucket: 'profile-whisperer.firebasestorage.app',
  );

  // iOS - Firebase Console'dan iOS app ekleyince güncelle
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD_RsfFDMMTE6Al1b8_SWVO4dD03di2RFo',
    appId: '1:412732474388:android:0861936537b5f9d6181301',
    messagingSenderId: '412732474388',
    projectId: 'profile-whisperer',
    storageBucket: 'profile-whisperer.firebasestorage.app',
    iosBundleId: 'com.example.profileWhisperer',
  );

  // Web - Firebase Console'dan Web app ekleyince güncelle
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD_RsfFDMMTE6Al1b8_SWVO4dD03di2RFo',
    appId: '1:412732474388:android:0861936537b5f9d6181301',
    messagingSenderId: '412732474388',
    projectId: 'profile-whisperer',
    storageBucket: 'profile-whisperer.firebasestorage.app',
  );

  // Desktop platforms
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD_RsfFDMMTE6Al1b8_SWVO4dD03di2RFo',
    appId: '1:412732474388:android:0861936537b5f9d6181301',
    messagingSenderId: '412732474388',
    projectId: 'profile-whisperer',
    storageBucket: 'profile-whisperer.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD_RsfFDMMTE6Al1b8_SWVO4dD03di2RFo',
    appId: '1:412732474388:android:0861936537b5f9d6181301',
    messagingSenderId: '412732474388',
    projectId: 'profile-whisperer',
    storageBucket: 'profile-whisperer.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyD_RsfFDMMTE6Al1b8_SWVO4dD03di2RFo',
    appId: '1:412732474388:android:0861936537b5f9d6181301',
    messagingSenderId: '412732474388',
    projectId: 'profile-whisperer',
    storageBucket: 'profile-whisperer.firebasestorage.app',
  );
}
