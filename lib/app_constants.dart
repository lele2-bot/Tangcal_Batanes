import 'package:flutter/material.dart';
import 'flutter_flow/flutter_flow_util.dart';

abstract class FFAppConstants {
  // Order statuses live in OrderStatus (lib/backend/order_service.dart).

  // Google Maps keys used by the in-app map/place picker. These ship inside
  // the app, so protect them with restrictions in Google Cloud Console
  // (APIs & Services > Credentials), not by hiding them. The same keys also
  // appear in android/app/src/main/AndroidManifest.xml,
  // ios/Runner/AppDelegate.swift and web/index.html; update all places when
  // rotating a key.
  static const String googleMapsIosKey =
      'AIzaSyDXVXphU0mHqHC3ycDoDSqh2hUTgDbpVO0';
  static const String googleMapsAndroidKey =
      'AIzaSyBGo5XeG-c8gkCiEO55kSw27oVZ6hKVOZw';
  static const String googleMapsWebKey =
      'AIzaSyDA_4syZdOKLDahugfk9jcA_nJQC4pVq6c';
}
