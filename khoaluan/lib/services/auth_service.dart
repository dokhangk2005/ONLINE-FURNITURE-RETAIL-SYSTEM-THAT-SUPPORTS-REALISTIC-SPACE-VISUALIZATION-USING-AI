import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _storageKey = 'auth_session';
  static final ValueNotifier<Map<String, dynamic>?> currentUser = ValueNotifier(
    null,
  );

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw != null) {
      try {
        final restored = Map<String, dynamic>.from(jsonDecode(raw));
        if (_isTokenUsable(restored['_token']?.toString())) {
          currentUser.value = restored;
        } else {
          currentUser.value = null;
          await preferences.remove(_storageKey);
        }
      } catch (_) {
        currentUser.value = null;
        await preferences.remove(_storageKey);
      }
    }
  }

  static void login(Map<String, dynamic> user) {
    final merged = Map<String, dynamic>.from(user);
    merged['_token'] ??= currentUser.value?['_token'];
    currentUser.value = merged;
    SharedPreferences.getInstance().then(
      (p) => p.setString(_storageKey, jsonEncode(merged)),
    );
  }

  static void logout() {
    currentUser.value = null;
    SharedPreferences.getInstance().then((p) => p.remove(_storageKey));
  }

  static bool get isLoggedIn => currentUser.value != null;

  static bool get hasValidSession =>
      _isTokenUsable(currentUser.value?['_token']?.toString());

  static String? get token {
    final value = currentUser.value?['_token']?.toString();
    if (_isTokenUsable(value)) return value;
    if (currentUser.value != null) logout();
    return null;
  }

  static bool _isTokenUsable(String? token) {
    if (token == null || token.isEmpty) return false;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final normalized = base64Url.normalize(parts[1]);
      final payload = Map<String, dynamic>.from(
        jsonDecode(utf8.decode(base64Url.decode(normalized))),
      );
      final expValue = payload['exp'];
      final expiresAt = expValue is num
          ? expValue.toInt()
          : int.tryParse(expValue?.toString() ?? '');
      if (expiresAt == null) return false;
      final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      return expiresAt > now + 15;
    } catch (_) {
      return false;
    }
  }
}
