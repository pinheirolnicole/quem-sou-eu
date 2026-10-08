
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
        throw UnsupportedError('Firebase não configurado para Android.');

      case TargetPlatform.iOS:
        throw UnsupportedError('Firebase não configurado para iOS.');

      case TargetPlatform.macOS:
        throw UnsupportedError('Firebase não configurado para macOS.');

      case TargetPlatform.windows:
        throw UnsupportedError('Firebase não configurado para Windows.');

      case TargetPlatform.linux:
        throw UnsupportedError('Firebase não configurado para Linux.');

      default:
        throw UnsupportedError('Plataforma não suportada.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCIOaesQErX46tk_tHGTYRolXi0omhQwkY',
    appId: '1:698896623309:web:8fdd24662b098a73b72b84',
    messagingSenderId: '698896623309',
    projectId: 'quem-sou-eu-e30ca',
    authDomain: 'quem-sou-eu-e30ca.firebaseapp.com',
    storageBucket: 'quem-sou-eu-e30ca.firebasestorage.app',
  );
}
