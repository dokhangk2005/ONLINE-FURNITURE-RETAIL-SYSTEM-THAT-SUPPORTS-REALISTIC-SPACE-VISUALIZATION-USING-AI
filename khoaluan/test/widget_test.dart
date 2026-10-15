import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:khoaluan/main.dart';
import 'package:khoaluan/services/auth_service.dart';
import 'package:khoaluan/widgets/main_layout.dart';
import 'package:khoaluan/widgets/shared_navbar.dart';
import 'package:khoaluan/l10n/generated/app_localizations.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('ứng dụng mở được trang chủ', (tester) async {
    await tester.pumpWidget(const MyFurnitureApp());
    await tester.pump();
    expect(find.text('My Furniture Store'), findsWidgets);
  });

  testWidgets('navbar dùng bố cục gọn ở chiều rộng tablet', (tester) async {
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          endDrawer: const Drawer(),
          body: SharedNavbar(onSearchTap: () {}, onCartTap: () {}),
        ),
      ),
    );

    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('yêu cầu đăng nhập khi khách bấm vào giỏ hàng', (tester) async {
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    AuthService.currentUser.value = null;

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MainLayout(
          showFooter: false,
          isScrollable: false,
          child: SizedBox.expand(),
        ),
      ),
    );

    tester.state<ScaffoldState>(find.byType(Scaffold)).openEndDrawer();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.shopping_bag_outlined).hitTestable());
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Vui lòng đăng nhập để xem giỏ hàng.'), findsOneWidget);
    expect(find.text('GIỎ HÀNG'), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng đăng nhập để xem giỏ hàng.'), findsNothing);
  });
}
