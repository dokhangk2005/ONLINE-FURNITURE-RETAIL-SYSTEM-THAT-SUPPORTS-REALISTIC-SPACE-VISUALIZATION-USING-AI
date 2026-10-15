import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khoaluan/services/auth_service.dart';

String _testToken(int expiresAt) {
  String encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${encode({'exp': expiresAt})}.test-signature';
}

void main() {
  setUp(() {
    AuthService.currentUser.value = null;
  });

  test('xóa phiên đã hết hạn khi khởi động ứng dụng', () async {
    final expiredAt =
        DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000 - 60;
    SharedPreferences.setMockInitialValues({
      'auth_session': jsonEncode({
        'userId': 1,
        'roleId': 1,
        '_token': _testToken(expiredAt),
      }),
    });

    await AuthService.initialize();

    expect(AuthService.currentUser.value, isNull);
    expect(
      (await SharedPreferences.getInstance()).getString('auth_session'),
      isNull,
    );
  });

  test('khôi phục phiên Admin khi token vẫn còn hạn', () async {
    final expiresAt =
        DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000 + 600;
    SharedPreferences.setMockInitialValues({
      'auth_session': jsonEncode({
        'userId': 1,
        'roleId': 1,
        '_token': _testToken(expiresAt),
      }),
    });

    await AuthService.initialize();

    expect(AuthService.currentUser.value?['roleId'], 1);
    expect(AuthService.hasValidSession, isTrue);
  });
}
