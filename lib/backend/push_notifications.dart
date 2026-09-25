// Push notifications (Firebase Cloud Messaging).
//
// The app only registers the device: it asks for permission and stores the
// FCM token at users/{uid}/fcm_tokens/{token}. The notifications themselves
// are sent by the Cloud Functions in firebase/functions/index.js whenever an
// order is created or changes status.
//
// Supported on Android and iOS. Web is skipped (it needs a VAPID key and a
// service worker); iOS also needs an APNs key uploaded in the Firebase console.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Push notifications need the Cloud Functions in firebase/functions, which
/// require the Blaze plan. Set to true once those functions are deployed.
const bool kPushNotificationsEnabled = false;

/// Lets foreground notifications show a SnackBar from anywhere in the app.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

String? _registeredUid;
StreamSubscription<String>? _tokenRefreshSub;
StreamSubscription<RemoteMessage>? _foregroundSub;

bool get _supported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

DocumentReference _tokenDoc(String uid, String token) => FirebaseFirestore
    .instance
    .collection('users')
    .doc(uid)
    .collection('fcm_tokens')
    .doc(token);

Future<void> _saveToken(String uid, String token) =>
    _tokenDoc(uid, token).set({
      'fcm_token': token,
      'device_type': defaultTargetPlatform.name,
      'created_at': FieldValue.serverTimestamp(),
    });

/// Call when a user signs in. Safe to call repeatedly.
Future<void> registerForPushNotifications(String uid) async {
  if (!kPushNotificationsEnabled ||
      !_supported ||
      uid.isEmpty ||
      _registeredUid == uid) {
    return;
  }
  _registeredUid = uid;
  try {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }
    // Show notifications as banners on iOS even while the app is open.
    await messaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    final token = await messaging.getToken();
    if (token != null) {
      await _saveToken(uid, token);
    }
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = messaging.onTokenRefresh.listen((t) => _saveToken(uid, t));

    // Android doesn't show a system notification while the app is in the
    // foreground, so show it in-app instead.
    await _foregroundSub?.cancel();
    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      final n = message.notification;
      if (n == null || defaultTargetPlatform == TargetPlatform.iOS) {
        return;
      }
      rootScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text([n.title, n.body].whereType<String>().join('\n')),
        duration: const Duration(seconds: 5),
      ));
    });
  } catch (e) {
    // Notifications are a convenience; never block the app on them.
    debugPrint('Push registration failed: $e');
    _registeredUid = null;
  }
}

/// Call before signing out so this device stops receiving the user's alerts.
Future<void> unregisterPushNotifications() async {
  final uid = _registeredUid;
  _registeredUid = null;
  await _tokenRefreshSub?.cancel();
  await _foregroundSub?.cancel();
  if (!_supported || uid == null) {
    return;
  }
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _tokenDoc(uid, token).delete();
    }
  } catch (e) {
    debugPrint('Push unregister failed: $e');
  }
}
