import 'package:flutter/material.dart';
import 'l10n/generated/app_localizations.dart';
import 'page/homepage/home_page.dart';
import 'page/admin/admin_page.dart';
import 'page/product/product_detail_page.dart';
import 'page/product/products_page.dart';
import 'page/cartpage/checkout_page.dart';
import 'page/loginpage/profile_page.dart';
import 'page/loginpage/set_password_page.dart';
import 'page/shipper/shipper_home_page.dart';
import 'widgets/web_page_route.dart';
import 'conf/theme.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/locale_service.dart';
import 'services/support_realtime_service.dart';
import 'page/loginpage/login_page.dart';
import 'page/static_info_page.dart';
import 'page/visualizer/room_visualizer_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initialize();
  await CartService.initialize();
  await LocaleService.initialize();
  SupportRealtimeService.instance.initialize();
  runApp(const MyFurnitureApp());
}

class MyFurnitureApp extends StatelessWidget {
  const MyFurnitureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleService.locale,
      builder: (context, locale, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final uri = Uri.parse(settings.name ?? '/');
          final path = uri.path;
          Widget page;
          switch (path) {
            case '/':
              page = const HomePage();
              break;
            case '/admin':
              page = AuthService.currentUser.value?['roleId'] == 1
                  ? const AdminPage()
                  : const LoginPage();
              break;
            case '/shipper':
              page = AuthService.currentUser.value?['roleId'] == 3
                  ? const ShipperHomePage()
                  : const LoginPage();
              break;
            case '/product-detail':
              page = ProductDetailPage(
                productId: int.tryParse(uri.queryParameters['id'] ?? ''),
              );
              break;
            case '/products':
              final args = settings.arguments;
              final int? categoryId = args is int ? args : null;
              page = ProductsPage(initialCategoryId: categoryId);
              break;
            case '/room-visualizer':
              page = const RoomVisualizerPage();
              break;
            case '/checkout':
              page = CheckoutPage(
                paymentStatus: uri.queryParameters['status'],
                orderId: int.tryParse(uri.queryParameters['orderId'] ?? ''),
              );
              break;
            case '/profile':
              final String? tab = settings.arguments as String?;
              page = ProfilePage(initialTab: tab);
              break;
            case '/login':
              page = const LoginPage();
              break;
            case '/about':
              page = const StaticInfoPage(type: 'about');
              break;
            case '/contact':
              page = const StaticInfoPage(type: 'contact');
              break;
            case '/set-password':
              page = SetPasswordPage(token: uri.queryParameters['token'] ?? '');
              break;
            default:
              return null;
          }
          return WebPageRoute(settings: settings, page: page, animated: false);
        },
        theme: appTheme,
      ),
    );
  }
}
