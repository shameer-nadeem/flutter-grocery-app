// Temporary Firebase options placeholder.
// IMPORTANT: Replace this file by running:
// flutterfire configure --project=shelfsight-e4f1f --platforms=android,web
// The FlutterFire CLI will generate the real apiKey/appId values for your Firebase project.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('Firebase is not configured for iOS. Run flutterfire configure if needed.');
      case TargetPlatform.macOS:
        throw UnsupportedError('Firebase is not configured for macOS. Run flutterfire configure if needed.');
      case TargetPlatform.windows:
        throw UnsupportedError('Firebase is not configured for Windows. Use Android or Web for this project, or run flutterfire configure.');
      case TargetPlatform.linux:
        throw UnsupportedError('Firebase is not configured for Linux. Use Android or Web for this project, or run flutterfire configure.');
      default:
        throw UnsupportedError('Firebase is not configured for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBiPjQVRSzJRTvk-X-RS6USeBCe5FFNqX8',
    appId: '1:328220526922:web:0a533005525964cc2cd9b3',
    messagingSenderId: '328220526922',
    projectId: 'shelfsight-e4f1f',
    authDomain: 'shelfsight-e4f1f.firebaseapp.com',
    storageBucket: 'shelfsight-e4f1f.firebasestorage.app',
    measurementId: 'G-SS6HHC9K61',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC58ONT3fbn2yf074mQ8dhTLQykFueSH-0',
    appId: '1:328220526922:android:08ea8c1b6d4669472cd9b3',
    messagingSenderId: '328220526922',
    projectId: 'shelfsight-e4f1f',
    storageBucket: 'shelfsight-e4f1f.firebasestorage.app',
  );

}