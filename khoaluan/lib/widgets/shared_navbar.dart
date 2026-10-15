import 'package:flutter/material.dart';
import '../conf/const.dart';
import '../conf/responsive.dart';
import '../l10n/l10n.dart';
import '../model/home_model.dart';
import '../page/loginpage/login_page.dart';
import '../services/auth_service.dart';
import 'web_page_route.dart';
import '../services/cart_service.dart';
import 'language_switcher.dart';
import 'products_dropdown.dart';

const List<NavItem> defaultMenuItems = [
  NavItem(title: 'PRODUCTS', route: '/products'),
  NavItem(title: 'ROOM DESIGN', route: '/room-visualizer'),
  NavItem(title: 'ABOUT', route: '/about'),
  NavItem(title: 'CONTACT', route: '/contact'),
];

String localizedMenuTitle(BuildContext context, NavItem item) {
  return switch (item.route) {
    '/products' => context.l10n.navProducts,
    '/room-visualizer' => context.l10n.navRoomDesign,
    '/about' => context.l10n.navAbout,
    '/contact' => context.l10n.navContact,
    _ => item.title,
  };
}

class SharedNavbar extends StatefulWidget {
  const SharedNavbar({
    super.key,
    required this.onSearchTap,
    required this.onCartTap,
    this.menuItems = defaultMenuItems,
    this.isTransparent = false,
  });

  final List<NavItem> menuItems;
  final VoidCallback onSearchTap;
  final VoidCallback onCartTap;
  final bool isTransparent;

  @override
  State<SharedNavbar> createState() => _SharedNavbarState();
}

class _SharedNavbarState extends State<SharedNavbar> {
  bool _isNavbarHovered = false;
  final GlobalKey<PopupMenuButtonState<String>> _menuKey =
      GlobalKey<PopupMenuButtonState<String>>();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 1100;
    final isTablet = context.isTablet;

    final isCurrentlyTransparent = widget.isTransparent && !_isNavbarHovered;
    final contentColor = isCurrentlyTransparent ? Colors.white : Colors.black;

    if (isMobile) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isNavbarHovered = true),
        onExit: (_) => setState(() => _isNavbarHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          color: isCurrentlyTransparent
              ? Colors.transparent
              : navbarBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else {
                      debugPrint('Already on home page');
                    }
                  },
                  child: Text(
                    'My Furniture Store',
                    style: TextStyle(
                      color: contentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.search, color: contentColor),
                onPressed: widget.onSearchTap,
              ),
              ValueListenableBuilder(
                valueListenable: CartService.cartItems,
                builder: (context, items, _) {
                  final qty = CartService.totalQuantity;
                  final child = IconButton(
                    icon: Icon(
                      Icons.shopping_bag_outlined,
                      color: contentColor,
                    ),
                    onPressed: widget.onCartTap,
                  );
                  if (qty == 0) return child;
                  return Badge(
                    label: Text('$qty'),
                    offset: const Offset(-8, 8),
                    child: child,
                  );
                },
              ),
              Builder(
                builder: (ctx) => IconButton(
                  icon: Icon(Icons.menu, color: contentColor),
                  onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isNavbarHovered = true),
      onExit: (_) => setState(() => _isNavbarHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 78,
        color: isCurrentlyTransparent
            ? Colors.transparent
            : navbarBackgroundColor,
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 64),
        child: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    debugPrint('Already on home page');
                  }
                },
                child: Text(
                  'My Furniture Store',
                  style: TextStyle(
                    color: contentColor,
                    fontSize: isTablet ? 22 : 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: widget.menuItems.map((item) {
                final title = localizedMenuTitle(context, item);
                if (item.route == '/products') {
                  return ProductsDropdown(
                    title: title,
                    onTap: () {
                      Navigator.pushNamed(context, item.route);
                    },
                    textColor: contentColor,
                  );
                }
                return SharedNavbarButton(
                  title: title,
                  onTap: () {
                    debugPrint('Click ${item.title}');
                    if (item.route.isNotEmpty) {
                      Navigator.pushNamed(context, item.route);
                    }
                  },
                  textColor: contentColor,
                );
              }).toList(),
            ),
            const Spacer(),
            ValueListenableBuilder<Map<String, dynamic>?>(
              valueListenable: AuthService.currentUser,
              builder: (context, user, child) {
                if (user != null) {
                  final dynamic roleIdValue = user['roleId'] ?? user['RoleId'];
                  final bool isAdmin =
                      roleIdValue != null &&
                      (roleIdValue.toString() == '1' || roleIdValue == 1);

                  return PopupMenuButton<String>(
                    key: _menuKey,
                    offset: const Offset(0, 78),
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    onSelected: (value) {
                      if (value == 'admin') {
                        Navigator.pushNamed(context, '/admin');
                      } else if (value == 'profile') {
                        Navigator.pushNamed(context, '/profile');
                      } else if (value == 'addresses') {
                        Navigator.pushNamed(
                          context,
                          '/profile',
                          arguments: 'addresses',
                        );
                      } else if (value == 'logout') {
                        AuthService.logout();
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.l10n.loggedOut)),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      // Header: THÔNG TIN TÀI KHOẢN
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.l10n.accountInfo,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(height: 1, color: Colors.grey.shade200),
                            const SizedBox(height: 12),
                            Text(
                              user['fullName'] ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'profile',
                        child: Text(
                          context.l10n.yourAccount,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xff5f6670),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'addresses',
                        child: Text(
                          context.l10n.addressList,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xff5f6670),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isAdmin)
                        PopupMenuItem<String>(
                          value: 'admin',
                          child: Text(
                            context.l10n.adminPage,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xff5f6670),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Text(
                          context.l10n.logout,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xff5f6670),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          _menuKey.currentState?.showButtonMenu();
                        },
                        child: Container(
                          height: 78,
                          padding: EdgeInsets.symmetric(
                            horizontal: context.isTablet ? 14 : 24,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 24,
                                color: contentColor,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.accountOf,
                                    style: TextStyle(
                                      color: contentColor.withOpacity(0.8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        user['fullName'] ?? '',
                                        style: TextStyle(
                                          color: contentColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 14,
                                        color: contentColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return SharedNavbarButton(
                  title: context.l10n.loginRegister,
                  onTap: () {
                    Navigator.push(
                      context,
                      WebPageRoute(page: const LoginPage(), animated: false),
                    );
                  },
                  textColor: contentColor,
                );
              },
            ),
            SharedNavbarIconButton(
              icon: Icons.search,
              onTap: widget.onSearchTap,
              iconColor: contentColor,
            ),
            ValueListenableBuilder(
              valueListenable: CartService.cartItems,
              builder: (context, items, _) {
                final qty = CartService.totalQuantity;
                final child = SharedNavbarIconButton(
                  icon: Icons.shopping_bag_outlined,
                  onTap: widget.onCartTap,
                  iconColor: contentColor,
                );
                if (qty == 0) return child;
                return Badge(
                  label: Text('$qty'),
                  offset: const Offset(-12, 12),
                  child: child,
                );
              },
            ),
            LanguageSwitcher(
              color: contentColor,
              height: 78,
              horizontalPadding: context.isTablet ? 12 : 18,
            ),
          ],
        ),
      ),
    );
  }
}

class SharedNavbarButton extends StatefulWidget {
  const SharedNavbarButton({
    super.key,
    required this.title,
    required this.onTap,
    this.textColor = Colors.black,
  });

  final String title;
  final VoidCallback onTap;
  final Color textColor;

  @override
  State<SharedNavbarButton> createState() => _SharedNavbarButtonState();
}

class _SharedNavbarButtonState extends State<SharedNavbarButton> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 78,
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 14 : 24),
          alignment: Alignment.center,
          color: isHover ? navbarItemHoverColor : Colors.transparent,
          child: Text(
            widget.title,
            style: TextStyle(
              color: widget.textColor,
              fontSize: isTablet ? 11 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class SharedNavbarIconButton extends StatefulWidget {
  const SharedNavbarIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.black,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  State<SharedNavbarIconButton> createState() => _SharedNavbarIconButtonState();
}

class _SharedNavbarIconButtonState extends State<SharedNavbarIconButton> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 78,
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 24),
          alignment: Alignment.center,
          color: isHover ? navbarItemHoverColor : Colors.transparent,
          child: Icon(widget.icon, color: widget.iconColor, size: 24),
        ),
      ),
    );
  }
}
