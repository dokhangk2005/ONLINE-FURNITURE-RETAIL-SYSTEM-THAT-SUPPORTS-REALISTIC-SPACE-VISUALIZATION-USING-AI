import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/l10n/generated/app_localizations.dart';
import 'package:khoaluan/page/admin/questions/admin_questions_page.dart';

void main() {
  testWidgets('Admin nhìn thấy hộp thư hỗ trợ realtime và bộ lọc', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('vi'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: AdminQuestionsPage()),
      ),
    );

    expect(find.text('HỘP THƯ HỖ TRỢ REALTIME'), findsOneWidget);
    expect(find.textContaining('Cần phản hồi'), findsOneWidget);
    expect(find.textContaining('Chờ khách hàng'), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
  });
}
