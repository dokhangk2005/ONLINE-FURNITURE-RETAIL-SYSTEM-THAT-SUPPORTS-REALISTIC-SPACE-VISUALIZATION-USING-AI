import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/l10n/generated/app_localizations.dart';
import 'package:khoaluan/page/loginpage/my_questions_tab.dart';

void main() {
  testWidgets('tab hỗ trợ hiển thị giao diện chat cho khách hàng', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('vi'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: Padding(padding: EdgeInsets.all(20), child: MyQuestionsTab()),
        ),
      ),
    );

    expect(find.text('TRÒ CHUYỆN HỖ TRỢ'), findsOneWidget);
    expect(find.text('Cuộc trò chuyện mới'), findsOneWidget);
    expect(find.byIcon(Icons.add_comment_outlined), findsOneWidget);
  });
}
