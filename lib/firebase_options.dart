import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCz9bbSiUaCu2-nJ9Tp5TdUrf31aPo0PKo',
    appId: '1:1048533340884:android:87e6a05bd53b98db74a141',
    messagingSenderId: '1048533340884',
    projectId: 'exhibitspace-e0a06',
    storageBucket: 'exhibitspace-e0a06.firebasestorage.app',
  );
}