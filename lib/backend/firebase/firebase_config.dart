import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDoWIoP-utUlfmRnCIwbMTTzIta9diRruI",
            authDomain: "tangcal-batanes.firebaseapp.com",
            projectId: "tangcal-batanes",
            storageBucket: "tangcal-batanes.firebasestorage.app",
            messagingSenderId: "630075721339",
            appId: "1:630075721339:web:acb1e6d7c52dc19a6fc4de",
            measurementId: "G-C4VL50QWYL"));
  } else {
    await Firebase.initializeApp();
  }
}
