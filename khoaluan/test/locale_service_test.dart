import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/l10n/generated/app_localizations.dart';
import 'package:khoaluan/services/locale_service.dart';
import 'package:khoaluan/widgets/language_switcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('khôi phục ngôn ngữ đã chọn từ trình duyệt', () async {
    SharedPreferences.setMockInitialValues({'app_language_code': 'en'});

    await LocaleService.initialize();

    expect(LocaleService.locale.value.languageCode, 'en');
  });

  testWidgets('đổi từ tiếng Việt sang tiếng Anh và lưu lựa chọn', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app_language_code': 'vi'});
    await LocaleService.initialize();

    await tester.pumpWidget(
      ValueListenableBuilder<Locale>(
        valueListenable: LocaleService.locale,
        builder: (context, locale, _) => MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Scaffold(body: LanguageSwitcher()),
        ),
      ),
    );

    expect(find.text('VI'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('EN'), findsOneWidget);
    expect(LocaleService.locale.value.languageCode, 'en');
    expect(
      (await SharedPreferences.getInstance()).getString('app_language_code'),
      'en',
    );
  });
}
