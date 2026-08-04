// File generated manually based on Firebase JSON & PLIST configs for OzVisa Alert.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
        return ios;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBDyIAikheNo2kppTdJdW0un1ywicnlWA8',
    appId: '1:58600120257:web:ozvisa-alert-prod',
    messagingSenderId: '58600120257',
    projectId: 'ozvisa-alert-prod',
    storageBucket: 'ozvisa-alert-prod.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBDyIAikheNo2kppTdJdW0un1ywicnlWA8',
    appId: '1:58600120257:android:1dababefbda7ff921fd940',
    messagingSenderId: '58600120257',
    projectId: 'ozvisa-alert-prod',
    storageBucket: 'ozvisa-alert-prod.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDi6mCeAa6Kmh_kCvFVv5P32OLZcgH2tmA',
    appId: '1:58600120257:ios:f68c11657e8083c91fd940',
    messagingSenderId: '58600120257',
    projectId: 'ozvisa-alert-prod',
    storageBucket: 'ozvisa-alert-prod.firebasestorage.app',
    iosBundleId: 'com.ozvisa.alert',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBDyIAikheNo2kppTdJdW0un1ywicnlWA8',
    appId: '1:58600120257:web:ozvisa-alert-prod',
    messagingSenderId: '58600120257',
    projectId: 'ozvisa-alert-prod',
    storageBucket: 'ozvisa-alert-prod.firebasestorage.app',
  );
}
