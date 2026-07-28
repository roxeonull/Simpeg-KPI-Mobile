import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/api/token_storage.dart';
import '../../core/models/user.dart';
import '../../core/services/notification_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final TokenStorage _tokenStorage = TokenStorage();
  final ApiClient _api = ApiClient.instance;

  AuthStatus status = AuthStatus.unknown;
  AppUser? user;
  bool isLoading = false;
  String? errorMessage;

  bool get isAtasan => user?.isAtasan ?? false;

  Future<void> bootstrap() async {
    final token = await _tokenStorage.read();
    if (token == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final response = await _api.request('/me');
      user = AppUser.fromJson(response.data['user']);
      status = AuthStatus.authenticated;
      await NotificationService.instance.registerToken();
    } catch (_) {
      await _tokenStorage.clear();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.request(
        '/login',
        method: 'POST',
        data: {'email': email, 'password': password, 'device_name': 'flutter-app'},
      );

      await _tokenStorage.save(response.data['token']);
      user = AppUser.fromJson(response.data['user']);
      status = AuthStatus.authenticated;
      isLoading = false;
      await NotificationService.instance.registerToken();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.friendlyMessage;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> lupaPassword(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _api.request(
        '/lupa-password',
        method: 'POST',
        data: {'email': email},
      );
    } on ApiException {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _api.request('/logout', method: 'POST');
    } catch (_) {
      // Tetap logout secara lokal walau request gagal (mis. tidak ada koneksi).
    }
    await _tokenStorage.clear();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
