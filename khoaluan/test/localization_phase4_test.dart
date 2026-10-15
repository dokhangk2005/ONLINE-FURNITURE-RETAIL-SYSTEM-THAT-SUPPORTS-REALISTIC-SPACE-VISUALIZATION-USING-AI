import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/l10n/generated/app_localizations.dart';
import 'package:khoaluan/page/loginpage/forgot_password_page.dart';
import 'package:khoaluan/page/loginpage/set_password_page.dart';
import 'package:khoaluan/widgets/confirm_delete_dialog.dart';
import 'package:khoaluan/widgets/currency_formatter.dart';

Widget _englishApp(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );
}

void main() {
  test('định dạng VND thay đổi theo ngôn ngữ', () {
    expect(formatVND(1234567, languageCode: 'vi'), '1.234.567 đ');
    expect(formatVND(1234567, languageCode: 'en'), '₫1,234,567');
  });

  testWidgets('màn khôi phục mật khẩu hiển thị tiếng Anh', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_englishApp(const ForgotPasswordPage()));
    await tester.pump();

    expect(find.text('Recover Password'), findsOneWidget);
    expect(find.text('SEND OTP'), findsOneWidget);
    expect(find.text('Khôi Phục Mật Khẩu'), findsNothing);
  });

  testWidgets('liên kết thiết lập mật khẩu lỗi hiển thị tiếng Anh', (
    tester,
  ) async {
    await tester.pumpWidget(_englishApp(const SetPasswordPage(token: '')));
    await tester.pump();

    expect(find.text('This link is no longer valid'), findsOneWidget);
    expect(find.text('REQUEST A NEW LINK'), findsOneWidget);
  });

  testWidgets('hộp thoại xóa dùng ngôn ngữ hiện tại', (tester) async {
    await tester.pumpWidget(
      _englishApp(
        Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showDialog<bool>(
                context: context,
                builder: (_) => const ConfirmDeleteDialog(
                  title: 'Delete item?',
                  content: 'This action cannot be undone.',
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Confirm deletion'), findsOneWidget);
  });
}
