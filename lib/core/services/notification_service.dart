import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../api/token_storage.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/cuti/cuti_detail_screen.dart';
import '../../features/cuti/cuti_list_screen.dart';
import '../../features/cuti/cuti_provider.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling background FCM message: ${message.messageId}");
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final ApiClient _api = ApiClient.instance;

  bool _initialized = false;
  GlobalKey<NavigatorState>? navigatorKey;

  /// Initialize FCM listeners and permissions
  Future<void> initialize({GlobalKey<NavigatorState>? navKey}) async {
    if (_initialized) return;
    _initialized = true;
    if (navKey != null) {
      navigatorKey = navKey;
    }

    // 1. Request notification permission (especially Android 13+ & iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint("User notification permission status: ${settings.authorizationStatus}");

    // 2. Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 3. Listen to token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      registerToken(newToken);
    });

    // 4. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground FCM message received: ${message.notification?.title}");
      _showInAppBanner(message);
    });

    // 5. Handle Background App Opened (when user taps notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification clicked while app in background: ${message.data}");
      _handlePayloadNavigation(message.data);
    });

    // 6. Handle Terminated App Opened
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint("App launched from terminated notification click: ${initialMessage.data}");
      Future.delayed(const Duration(milliseconds: 600), () {
        _handlePayloadNavigation(initialMessage.data);
      });
    }
  }

  /// Get current device FCM token and send to backend API
  Future<void> registerToken([String? customToken]) async {
    try {
      if (customToken == null) {
        NotificationSettings settings = await _fcm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          debugPrint("FCM token registration skipped: Notification permission denied.");
          return;
        }
      }

      final token = customToken ?? await _fcm.getToken();
      if (token == null || token.isEmpty) {
        debugPrint("FCM token is null or empty.");
        return;
      }

      final authToken = await TokenStorage().read();
      if (authToken == null) {
        debugPrint("FCM token registration deferred: User is not logged in.");
        return;
      }

      final deviceInfo = Platform.isAndroid ? 'Android Device' : (Platform.isIOS ? 'iOS Device' : 'Mobile Device');

      await _api.request(
        '/fcm-token',
        method: 'POST',
        data: {
          'token': token,
          'device_info': deviceInfo,
        },
      );
      debugPrint("Successfully registered FCM token to backend.");
    } catch (e) {
      debugPrint("Failed to register FCM token: $e");
    }
  }

  /// Show subtle in-app notification banner when app is in foreground
  void _showInAppBanner(RemoteMessage message) {
    final context = navigatorKey?.currentContext;
    if (context == null) return;

    final title = message.notification?.title ?? 'Notifikasi';
    final body = message.notification?.body ?? '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(body, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ],
        ),
        backgroundColor: const Color(0xFF1C1712),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Buka',
          textColor: const Color(0xFFC1272D),
          onPressed: () => _handlePayloadNavigation(message.data),
        ),
      ),
    );
  }

  /// Handle navigation based on payload (type & id)
  void _handlePayloadNavigation(Map<String, dynamic> data) {
    final context = navigatorKey?.currentContext;
    if (context == null || data.isEmpty) return;

    final String? type = data['type']?.toString();
    final String? idStr = data['id']?.toString();

    if (type == null) return;

    debugPrint("Navigating for payload type: $type, id: $idStr");

    final isAtasan = context.read<AuthProvider>().isAtasan;

    switch (type) {
      case 'cuti':
        if (idStr != null && int.tryParse(idStr) != null) {
          final cutiId = int.parse(idStr);
          if (isAtasan) {
            // For atasan, open CutiListScreen tab 0 (Perlu Persetujuan) or open detail directly with CutiProvider
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => CutiProvider()..loadAll(isAtasan: true),
                  child: CutiDetailScreen(cutiId: cutiId),
                ),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => CutiProvider()..loadAll(isAtasan: false),
                  child: CutiDetailScreen(cutiId: cutiId),
                ),
              ),
            );
          }
        } else if (isAtasan) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CutiListScreen(initialTab: 0),
            ),
          );
        }
        break;
      case 'pelatihan':
      case 'perubahan_data':
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
    }
  }
}
