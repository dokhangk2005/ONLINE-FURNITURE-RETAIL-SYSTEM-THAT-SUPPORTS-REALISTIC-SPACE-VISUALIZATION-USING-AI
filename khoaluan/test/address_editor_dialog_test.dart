import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/l10n/generated/app_localizations.dart';
import 'package:khoaluan/services/api_service.dart';
import 'package:khoaluan/widgets/address_editor_dialog.dart';

class _FakeApiService extends ApiService {
  Map<String, dynamic>? savedAddress;

  @override
  Future<List<Map<String, dynamic>>> suggestAddresses(
    String query,
    String sessionToken,
  ) async {
    return [
      {
        'name': '123 Đường Lê Lợi',
        'full_address': '123 Đường Lê Lợi, Quận 1, TP. Hồ Chí Minh',
        'mapbox_id': 'test-address',
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> retrieveAddress(
    String mapboxId,
    String sessionToken,
  ) async {
    return {
      'features': [
        {
          'properties': {
            'full_address': '123 Đường Lê Lợi, Quận 1, TP. Hồ Chí Minh',
          },
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> saveAddress(
    Map<String, dynamic> address, {
    int? id,
  }) async {
    savedAddress = Map<String, dynamic>.from(address);
    return {'addressId': id ?? 1, ...address};
  }
}

void main() {
  testWidgets('gợi ý địa chỉ và chọn nhãn từ danh sách', (tester) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = _FakeApiService();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: AddressEditorDialog(apiService: api)),
      ),
    );

    expect(find.text('Nhà'), findsOneWidget);
    expect(find.text('Công ty'), findsOneWidget);
    expect(find.text('Khác'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Nguyễn Văn An');
    await tester.enterText(find.byType(TextField).at(1), '0981234567');
    await tester.enterText(find.byType(TextField).at(2), '123 Lê');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump();

    expect(find.text('123 Đường Lê Lợi'), findsOneWidget);
    await tester.tap(find.text('123 Đường Lê Lợi'));
    await tester.pumpAndSettle();

    expect(
      find.text('123 Đường Lê Lợi, Quận 1, TP. Hồ Chí Minh'),
      findsOneWidget,
    );
    await tester.tap(find.text('Công ty'));
    await tester.pump();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(api.savedAddress, isNotNull);
    expect(api.savedAddress!['label'], 'Company');
    expect(
      api.savedAddress!['addressLine'],
      '123 Đường Lê Lợi, Quận 1, TP. Hồ Chí Minh',
    );
  });
}
