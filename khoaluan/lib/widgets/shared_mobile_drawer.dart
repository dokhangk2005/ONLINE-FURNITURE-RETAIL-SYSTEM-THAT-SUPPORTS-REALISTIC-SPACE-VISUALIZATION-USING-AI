import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../model/home_model.dart';
import '../page/loginpage/login_page.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import 'web_page_route.dart';
import 'shared_navbar.dart';

class SharedMobileDrawer extends StatelessWidget {
  const SharedMobileDrawer({
    super.key,
    required this.onSearchTap,
    required this.onCartTap,
    this.menuItems = defaultMenuItems,
  });

  final List<NavItem> menuItems;
  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'My Furniture Store',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            ...menuItems.map(
              (item) => ListTile(
                title: Text(
                  localizedMenuTitle(context, item),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, item.route);
                },
              ),
            ),
            const Divider(),
            ValueListenableBuilder<Map<String, dynamic>?>(
              valueListenable: AuthService.currentUser,
              builder: (context, user, child) {
                if (user != null) {
                  final dynamic roleIdValue = user['roleId'] ?? user['RoleId'];
                  final bool isAdmin =
                      roleIdValue != null &&
                      (roleIdValue.toString() == '1' || roleIdValue == 1);

                  return ExpansionTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(
                      context.l10n.helloUser(
                        user['fullName']?.toString() ?? '',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.manage_accounts_outlined),
                        title: Text(context.l10n.yourAccount),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(context.l10n.addressList),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            '/profile',
                            arguments: 'addresses',
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.history_outlined),
                        title: Text(context.l10n.deliveryHistory),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            '/profile',
                            arguments: 'orders',
                          );
                        },
                      ),
                      if (isAdmin)
                        ListTile(
                          leading: const Icon(
                            Icons.admin_panel_settings_outlined,
                          ),
                          title: Text(context.l10n.adminPage),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/admin');
                          },
                        ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: Text(context.l10n.logout),
                        onTap: () {
                          Navigator.pop(context);
                          AuthService.logout();
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.l10n.loggedOut)),
                          );
                        },
                      ),
                    ],
                  );
                }
                return ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(
                    context.l10n.loginRegister,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      WebPageRoute(page: const LoginPage(), animated: false),
                    );
                  },
                );
              },
            ),
            if (onSearchTap != null)
              ListTile(
                leading: const Icon(Icons.search),
                title: Text(
                  context.l10n.search,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSearchTap!();
                },
              ),
            if (onCartTap != null)
              ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: Text(
                  context.l10n.cart,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onCartTap!();
                  });
                },
              ),
            const Divider(),
            ExpansionTile(
              leading: const Icon(Icons.language),
              title: Text(
                context.l10n.language,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                LocaleService.locale.value.languageCode.toUpperCase(),
              ),
              children: [
                ListTile(
                  leading: LocaleService.locale.value.languageCode == 'vi'
                      ? const Icon(Icons.check)
                      : const SizedBox(width: 24),
                  title: Text(context.l10n.vietnamese),
                  onTap: () => LocaleService.setLanguage('vi'),
                ),
                ListTile(
                  leading: LocaleService.locale.value.languageCode == 'en'
                      ? const Icon(Icons.check)
                      : const SizedBox(width: 24),
                  title: Text(context.l10n.english),
                  onTap: () => LocaleService.setLanguage('en'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
