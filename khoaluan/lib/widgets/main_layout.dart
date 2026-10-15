import 'dart:async';

import 'package:flutter/material.dart';
import '../page/cartpage/cart_page.dart';
import '../services/auth_service.dart';
import '../services/delivery_realtime_service.dart';
import 'shared_navbar.dart';
import 'web_page_route.dart';
import 'shared_mobile_drawer.dart';
import 'shared_footer.dart';
import 'shared_overlays.dart';
import 'floating_ai_chatbot.dart';
import '../l10n/generated/app_localizations.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    required this.child,
    this.showNavbar = true,
    this.showFooter = true,
    this.isFooterSmall = false,
    this.isScrollable = true,
    this.transparentNavbarAtTop = false,
    this.transparentThreshold = 300.0,
  });

  final Widget child;
  final bool showNavbar;
  final bool showFooter;
  final bool isFooterSmall;
  final bool isScrollable;
  final bool transparentNavbarAtTop;
  final double transparentThreshold;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isSearchOpen = false;
  bool _isCartOpen = false;
  late final ScrollController? _scrollController;
  bool _isNavbarTransparent = false;
  final DeliveryRealtimeService _deliveryRealtime =
      DeliveryRealtimeService.instance;
  StreamSubscription<DeliveryRealtimeEvent>? _deliverySubscription;

  @override
  void initState() {
    super.initState();
    if (widget.transparentNavbarAtTop && widget.isScrollable) {
      _isNavbarTransparent = true;
      _scrollController = ScrollController();
      _scrollController!.addListener(_onScroll);
    } else {
      _scrollController = null;
    }
    if (AuthService.isLoggedIn) {
      _deliveryRealtime.initialize();
      _deliverySubscription = _deliveryRealtime.events.listen((event) {
        if (!mounted || event.message.isEmpty) return;
        final currentRoute = ModalRoute.of(context);
        if (currentRoute != null && !currentRoute.isCurrent) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(event.message),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      });
      unawaited(_deliveryRealtime.connect());
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _deliverySubscription?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController == null) return;
    final offset = _scrollController.offset;
    final shouldBeTransparent = offset < widget.transparentThreshold;
    if (shouldBeTransparent != _isNavbarTransparent) {
      setState(() {
        _isNavbarTransparent = shouldBeTransparent;
      });
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
      if (_isSearchOpen) {
        _isCartOpen = false;
      }
    });
  }

  void _closeSearch() {
    setState(() {
      _isSearchOpen = false;
    });
  }

  void _toggleCart() {
    if (!AuthService.isLoggedIn) {
      final l10n = Localizations.of<AppLocalizations>(
        context,
        AppLocalizations,
      );
      if (_isCartOpen) {
        setState(() => _isCartOpen = false);
      }
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      final controller = messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n?.loginToViewCart ?? 'Vui lòng đăng nhập để xem giỏ hàng.',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          persist: false,
        ),
      );
      Future<void>.delayed(const Duration(seconds: 2), controller.close);
      return;
    }

    setState(() {
      _isCartOpen = !_isCartOpen;
      if (_isCartOpen) {
        _isSearchOpen = false;
      }
    });
  }

  void _closeCart() {
    setState(() {
      _isCartOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 1100;
    final topPadding = widget.showNavbar
        ? (widget.transparentNavbarAtTop ? 0.0 : (isMobile ? 56.0 : 78.0))
        : 0.0;

    final Widget content;

    if (widget.isScrollable) {
      if (widget.showFooter) {
        content = CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: widget.child),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SharedFooter(isSmall: widget.isFooterSmall),
              ),
            ),
          ],
        );
      } else {
        content = SingleChildScrollView(
          controller: _scrollController,
          child: widget.child,
        );
      }
    } else {
      if (widget.showFooter) {
        content = Column(
          children: [
            Expanded(child: widget.child),
            SharedFooter(isSmall: widget.isFooterSmall),
          ],
        );
      } else {
        content = widget.child;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: (isMobile && widget.showNavbar)
          ? SharedMobileDrawer(
              onSearchTap: _toggleSearch,
              onCartTap: _toggleCart,
            )
          : null,
      body: Stack(
        children: [
          // Content layer
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: content,
            ),
          ),

          // Shared Navbar
          if (widget.showNavbar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SharedNavbar(
                onSearchTap: _toggleSearch,
                onCartTap: _toggleCart,
                isTransparent:
                    widget.transparentNavbarAtTop && _isNavbarTransparent,
              ),
            ),

          // Search overlay
          if (_isSearchOpen && widget.showNavbar)
            Positioned(
              top: isMobile ? 64.0 : 78.0,
              left: 0,
              right: 0,
              child: SearchBarOverlay(onClose: _closeSearch),
            ),

          // Cart popup overlay
          if (_isCartOpen && widget.showNavbar)
            Positioned.fill(
              child: CartPopupOverlay(
                isMobile: isMobile,
                onClose: _closeCart,
                onViewCart: () {
                  _closeCart();
                  Navigator.push(
                    context,
                    WebPageRoute(page: const CartPage(), animated: false),
                  );
                },
                onCheckout: () {
                  _closeCart();
                  Navigator.pushNamed(context, '/checkout');
                },
              ),
            ),

          // AI Chatbot Widget (Floating at Bottom Right)
          const FloatingAiChatbot(),
        ],
      ),
    );
  }
}
