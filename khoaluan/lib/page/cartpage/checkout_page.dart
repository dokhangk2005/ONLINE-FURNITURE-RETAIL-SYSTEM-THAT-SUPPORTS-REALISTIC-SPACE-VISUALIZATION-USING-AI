import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import '../../conf/responsive.dart';
import '../../l10n/l10n.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/currency_formatter.dart';
import '../../services/cart_service.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../model/cart_item.dart';
import '../../widgets/web_page_route.dart';
import '../loginpage/login_page.dart';
import 'voucher_wallet_modal.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, this.paymentStatus, this.orderId});

  final String? paymentStatus;
  final int? orderId;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoadingSubmit = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController =
      TextEditingController(); // Administrative picker field
  final _noteController = TextEditingController();
  final _promoController = TextEditingController();
  List<Map<String, dynamic>> _savedAddresses = [];
  int? _selectedSavedAddressId;
  bool _loadingSavedAddresses = false;
  bool _usingSavedAddress = false;
  bool _applyingSavedAddress = false;

  String _selectedPaymentMethod =
      'bank'; // 'bank', 'pos', 'vnpay', 'momo', 'qr'
  bool _promoApplied = false;
  // Mapbox API Configuration & Session state
  late String _mapboxSessionToken;
  bool _showMapboxSuggestions = false;
  List<Map<String, dynamic>> _mapboxSuggestions = [];
  Timer? _mapboxDebounce;

  String _generateSessionToken() {
    final random = Random();
    final millis = DateTime.now().millisecondsSinceEpoch;
    final randNum = random.nextInt(1000000);
    return '$millis-$randNum';
  }

  double _discountAmount = 0.0;
  // --- Level 2 Shipping & Delivery Options ---
  bool _includesAssembly = false;
  String _selectedTimeSlot = 'Sáng (08:00 - 12:00)';
  final List<String> _timeSlots = [
    'Sáng (08:00 - 12:00)',
    'Chiều (13:00 - 17:00)',
    'Tối (18:00 - 20:00)',
  ];
  double _shippingFee = 50000.0; // Phí ship cơ bản nội thành
  double _assemblyFee = 0.0;
  double _distanceKm = 5.0;

  String _timeSlotLabel(String slot) {
    if (slot.startsWith('Sáng')) return context.l10n.morningSlot;
    if (slot.startsWith('Chiều')) return context.l10n.afternoonSlot;
    return context.l10n.eveningSlot;
  }

  String? _validateRequired(String? value, String field, {int minLength = 1}) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return context.l10n.requiredField(field);
    if (input.length < minLength) {
      return context.l10n.minLengthField(field, minLength);
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = (value ?? '').replaceAll(' ', '').replaceAll('-', '');
    if (phone.isEmpty) {
      return context.l10n.requiredField(context.l10n.phoneNumber);
    }
    return RegExp(r'^0\d{9}$').hasMatch(phone)
        ? null
        : context.l10n.invalidPhone;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return context.l10n.requiredField(context.l10n.emailField);
    }
    return RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(email)
        ? null
        : context.l10n.invalidEmail;
  }

  @override
  void initState() {
    super.initState();
    _mapboxSessionToken = _generateSessionToken();
    // Autofill with logged in user details if available
    final user = AuthService.currentUser.value;
    if (user != null) {
      _nameController.text = user['fullName'] ?? '';
      _phoneController.text = user['phone'] ?? '';
      _emailController.text = user['email'] ?? '';
    }
    _addressController.addListener(_onAddressChanged);
    if (user != null) {
      _loadSavedAddresses();
    }

    if (widget.paymentStatus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showVnPayResultDialog();
      });
    }
  }

  void _onAddressChanged() {
    if (_applyingSavedAddress) return;
    if (!_applyingSavedAddress && _usingSavedAddress) {
      setState(() {
        _usingSavedAddress = false;
        _selectedSavedAddressId = null;
      });
    }
    final query = _addressController.text.trim();
    if (query.length < 3) {
      setState(() {
        _mapboxSuggestions = [];
        _showMapboxSuggestions = false;
      });
      return;
    }

    if (_mapboxDebounce?.isActive ?? false) _mapboxDebounce!.cancel();
    _mapboxDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final suggestions = await _apiService.suggestAddresses(
          query,
          _mapboxSessionToken,
        );
        if (mounted && query == _addressController.text.trim()) {
          setState(() {
            _mapboxSuggestions = suggestions;
            _showMapboxSuggestions = suggestions.isNotEmpty;
          });
        }
      } catch (e) {
        debugPrint("Error fetching Mapbox suggestions: $e");
      }
    });
  }

  Future<void> _loadSavedAddresses() async {
    if (!AuthService.isLoggedIn || _loadingSavedAddresses) return;
    setState(() => _loadingSavedAddresses = true);
    try {
      final addresses = await _apiService.fetchAddresses();
      if (!mounted) return;
      setState(() => _savedAddresses = addresses);
      if (addresses.isNotEmpty && _addressController.text.trim().isEmpty) {
        final defaultAddress = addresses
            .cast<Map<String, dynamic>>()
            .firstWhere(
              (item) => item['isDefault'] == true,
              orElse: () => addresses.first,
            );
        _applySavedAddress(defaultAddress);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _loadingSavedAddresses = false);
    }
  }

  void _applySavedAddress(Map<String, dynamic> address) {
    _applyingSavedAddress = true;
    setState(() {
      _selectedSavedAddressId = address['addressId'] as int?;
      _usingSavedAddress = true;
      _nameController.text = (address['recipientName'] ?? '').toString();
      _phoneController.text = (address['phone'] ?? '').toString();
      _addressController.text = (address['addressLine'] ?? '').toString();
      _cityController.clear();
      _showMapboxSuggestions = false;
      _mapboxSuggestions = [];
    });
    _applyingSavedAddress = false;
  }

  Future<void> _selectMapboxPlace(String mapboxId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          const Center(child: CircularProgressIndicator(color: Colors.black)),
    );

    try {
      final data = await _apiService.retrieveAddress(
        mapboxId,
        _mapboxSessionToken,
      );
      if (mounted) Navigator.pop(context); // pop loading

      final features = data['features'] as List? ?? [];
      if (features.isNotEmpty) {
        final feature = features.first;
        final properties = feature['properties'] as Map<String, dynamic>? ?? {};
        final contextObj = properties['context'] as Map<String, dynamic>? ?? {};

        final region = contextObj['region']?['name'] ?? ''; // Province / City
        final district =
            contextObj['district']?['name'] ??
            contextObj['locality']?['name'] ??
            ''; // District
        final place = contextObj['place']?['name'] ?? ''; // Ward

        final name = properties['name'] ?? '';

        _mapboxSessionToken = _generateSessionToken();

        setState(() {
          _addressController.removeListener(_onAddressChanged);
          _addressController.text = name;
          _cityController.text = [
            region,
            district,
            place,
          ].where((s) => s.isNotEmpty).join(', ');
          _showMapboxSuggestions = false;
          _mapboxSuggestions = [];
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _addressController.addListener(_onAddressChanged);
        });
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // pop loading
      debugPrint("Error retrieving Mapbox place details: $e");
    }
  }

  @override
  void dispose() {
    _mapboxDebounce?.cancel();
    _addressController.removeListener(_onAddressChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _noteController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _applyPromo([String? codeToApply]) async {
    final code = codeToApply ?? _promoController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.enterOrSelectVoucher)),
      );
      return;
    }
    try {
      final subtotal = CartService.totalAmount;
      final res = await _apiService.validateVoucher(code, subtotal);
      setState(() {
        _promoController.text = res.voucherCode;
        _promoApplied = true;
        _discountAmount = res.discountAmount;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _promoApplied = false;
          _discountAmount = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openVoucherWallet() {
    showDialog(
      context: context,
      builder: (ctx) => VoucherWalletModal(
        currentSubtotal: CartService.totalAmount,
        onSelectVoucher: (v) {
          _promoController.text = v.voucherCode;
          _applyPromo(v.voucherCode);
        },
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (!AuthService.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.loginBeforeOrdering)));
      return;
    }
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.checkCheckoutInformation),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    if (CartService.cartItems.value.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.cartIsEmpty)));
      return;
    }

    // Maintenance logic for unsupported gateways
    if (_selectedPaymentMethod != 'bank' &&
        _selectedPaymentMethod != 'pos' &&
        _selectedPaymentMethod != 'vnpay') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.paymentMaintenance),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoadingSubmit = true);

    try {
      final user = AuthService.currentUser.value;
      final int userId = user != null ? (user['userId'] ?? 0) : 0;

      // Concatenate full address
      final String fullAddress = _usingSavedAddress
          ? _addressController.text.trim()
          : '${_addressController.text.trim()}, ${_cityController.text.trim()}';

      // Map cart items
      final List<Map<String, dynamic>> items = CartService.cartItems.value.map((
        item,
      ) {
        return {
          'productVariantId': item.variant?.variantId ?? 0,
          'quantity': item.quantity,
        };
      }).toList();

      // Call API
      final response = await _apiService.createOrder(
        userId,
        fullAddress,
        items,
        paymentMethod: _selectedPaymentMethod.toUpperCase(),
        shippingFee: _shippingFee,
        assemblyFee: _assemblyFee,
        includesAssembly: _includesAssembly,
        deliveryDistanceKm: _distanceKm,
        deliveryTimeSlot: _selectedTimeSlot,
        voucherCode: _promoApplied ? _promoController.text.trim() : null,
        discountAmount: _promoApplied ? _discountAmount : 0.0,
        recipientName: _nameController.text.trim(),
        recipientPhone: _phoneController.text.trim(),
        recipientEmail: _emailController.text.trim(),
        customerNote: _noteController.text.trim(),
      );

      final String paymentUrl = (response['paymentUrl'] ?? '').toString();

      if (!mounted) return;

      // Clean submit state
      setState(() => _isLoadingSubmit = false);

      if (_selectedPaymentMethod == 'vnpay') {
        if (paymentUrl.isEmpty) {
          throw Exception(context.l10n.missingVnPayUrl);
        }

        final launched = await launchUrl(
          Uri.parse(paymentUrl),
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: '_self',
        );
        if (!launched) {
          throw Exception(context.l10n.cannotOpenVnPay);
        }
      } else if (_selectedPaymentMethod == 'pos') {
        // Immediate POS successful layout
        _showOrderSuccessDialog();
      } else {
        // Demo Bank transfer info popup
        _showOrderSuccessDialog(isBankTransfer: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSubmit = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.createOrderError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showVnPayResultDialog() async {
    bool isSuccess = false;
    try {
      if (widget.orderId != null) {
        final result = await _apiService.fetchPaymentStatus(widget.orderId!);
        isSuccess = result['paymentStatus'] == 'Success';
      }
    } catch (_) {
      isSuccess = false;
    }
    if (!mounted) return;
    if (isSuccess) {
      CartService.clearCart();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.cancel,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isSuccess
                    ? context.l10n.vnPaySuccess
                    : context.l10n.vnPayFailed,
              ),
            ),
          ],
        ),
        content: Text(
          isSuccess
              ? context.l10n.paidOrderMessage((widget.orderId ?? '').toString())
              : context.l10n.failedOrderMessage(
                  (widget.orderId ?? '').toString(),
                ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false),
            child: Text(context.l10n.backHome),
          ),
        ],
      ),
    );
  }

  void _showOrderSuccessDialog({bool isBankTransfer = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            Text(
              isBankTransfer
                  ? context.l10n.orderRecorded
                  : context.l10n.orderSuccess,
            ),
          ],
        ),
        content: Text(
          isBankTransfer
              ? context.l10n.bankTransferInstructions
              : context.l10n.orderThankYou(_nameController.text.trim()),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () {
              CartService.clearCart();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(context.l10n.backHome),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;
    final hPad = isMobile ? 16.0 : (isTablet ? 32.0 : 64.0);

    return MainLayout(
      isScrollable: true,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Branding Header
                Row(
                  children: [
                    const Text(
                      'my furniture',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Responsive content layout
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLeftColumn(),
                      const SizedBox(height: 32),
                      _buildRightColumn(),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: _buildLeftColumn()),
                      const SizedBox(width: 32),
                      Expanded(flex: 5, child: _buildRightColumn()),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Login reminder if not logged in
        ValueListenableBuilder<Map<String, dynamic>?>(
          valueListenable: AuthService.currentUser,
          builder: (context, user, _) {
            if (user != null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.loginBenefit,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black87),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        WebPageRoute(page: const LoginPage(), animated: false),
                      ).then((_) {
                        // Refresh info on login return
                        final loggedUser = AuthService.currentUser.value;
                        if (loggedUser != null) {
                          setState(() {
                            _nameController.text = loggedUser['fullName'] ?? '';
                            _phoneController.text = loggedUser['phone'] ?? '';
                            _emailController.text = loggedUser['email'] ?? '';
                          });
                          _loadSavedAddresses();
                        }
                      });
                    },
                    child: Text(context.l10n.loginAction),
                  ),
                ],
              ),
            );
          },
        ),

        // Shipping Information
        _buildSectionCard(
          title: context.l10n.shippingInformation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.enterFullName,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (val) =>
                    _validateRequired(val, context.l10n.fullName, minLength: 2),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: context.l10n.enterPhone,
                  suffixIcon: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      '★',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: context.l10n.enterOrderEmail,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),
              if (AuthService.isLoggedIn) ...[
                DropdownButtonFormField<int>(
                  key: ValueKey(_selectedSavedAddressId),
                  initialValue: _selectedSavedAddressId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.chooseSavedAddress,
                    prefixIcon: const Icon(Icons.bookmark_outline),
                    suffixIcon: _loadingSavedAddresses
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  items: _savedAddresses.map((address) {
                    final label = (address['label'] ?? '').toString().trim();
                    final line = (address['addressLine'] ?? '').toString();
                    return DropdownMenuItem<int>(
                      value: address['addressId'] as int?,
                      child: Text(
                        label.isEmpty ? line : '$label · $line',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _loadingSavedAddresses
                      ? null
                      : (id) {
                          if (id == null) return;
                          final address = _savedAddresses.firstWhere(
                            (item) => item['addressId'] == id,
                          );
                          _applySavedAddress(address);
                        },
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<String>(
                value: 'Vietnam',
                decoration: InputDecoration(
                  labelText: context.l10n.country,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'Vietnam',
                    child: Text(context.l10n.vietnam),
                  ),
                ],
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),

              // Address Field with Mapbox suggestions
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: context.l10n.streetAddress,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    validator: (val) =>
                        _validateRequired(val, context.l10n.address),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  if (_showMapboxSuggestions && _mapboxSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          children: _mapboxSuggestions.map((suggestion) {
                            return ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: Colors.blueAccent,
                              ),
                              title: Text(suggestion['name'] ?? ''),
                              subtitle: Text(suggestion['full_address'] ?? ''),
                              onTap: () {
                                final mapboxId = suggestion['mapbox_id'] ?? '';
                                if (mapboxId.isNotEmpty) {
                                  _selectMapboxPlace(mapboxId);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Administrative subdivision field (Autofilled by Mapbox suggestions)
              TextFormField(
                controller: _cityController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: context.l10n.regionAutoFill,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? (_usingSavedAddress
                          ? null
                          : context.l10n.selectDeliveryArea)
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Level 2 Delivery & Assembly Options
        _buildSectionCard(
          title: context.l10n.deliveryAssemblyService,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.l10n.deliveryEstimate(
                          _distanceKm.toStringAsFixed(1),
                          formatVND(_shippingFee),
                        ),
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.selectDeliveryTime,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTimeSlot,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  prefixIcon: Icon(Icons.access_time),
                ),
                items: _timeSlots
                    .map(
                      (slot) => DropdownMenuItem(
                        value: slot,
                        child: Text(_timeSlotLabel(slot)),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTimeSlot = val);
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.brown[700],
                title: Text(
                  context.l10n.assemblySupport,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  context.l10n.fixedAssemblyFee(formatVND(100000.0)),
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                value: _includesAssembly,
                onChanged: (val) {
                  setState(() {
                    _includesAssembly = val ?? false;
                    _assemblyFee = _includesAssembly ? 100000 : 0.0;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Payment Methods
        _buildSectionCard(
          title: context.l10n.paymentMethod,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPaymentOption(
                  value: 'bank',
                  title: context.l10n.bankTransferPayment,
                  icon: const Icon(
                    Icons.account_balance,
                    size: 20,
                    color: Colors.black54,
                  ),
                  expandedContent: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.accountName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(context.l10n.accountNumber),
                        Text(context.l10n.bankName),
                        Text(context.l10n.transferContent),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                _buildPaymentOption(
                  value: 'pos',
                  title: context.l10n.posPayment,
                  icon: const Icon(
                    Icons.credit_card,
                    size: 20,
                    color: Colors.black54,
                  ),
                ),
                const Divider(height: 1),
                _buildPaymentOption(
                  value: 'vnpay',
                  title: context.l10n.vnPayPayment,
                  icon: const Icon(Icons.payment, size: 20, color: Colors.blue),
                  subtitle: _buildCardBadges(),
                ),
                const Divider(height: 1),
                _buildPaymentOption(
                  value: 'momo',
                  title: context.l10n.momoPayment,
                  icon: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA50064),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'mo\nmo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                          height: 0.9,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _buildPaymentOption(
                  value: 'qr',
                  title: context.l10n.qrTransfer,
                  icon: const Icon(
                    Icons.qr_code,
                    size: 20,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Order Note
        _buildSectionCard(
          title: context.l10n.orderNote,
          child: TextFormField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: context.l10n.orderNoteHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cart Review Panel
        _buildSectionCard(
          title: context.l10n.cart,
          child: ValueListenableBuilder<List<CartItem>>(
            valueListenable: CartService.cartItems,
            builder: (context, items, _) {
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      context.l10n.emptyCartShort,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 20),
                    itemBuilder: (context, idx) {
                      final item = items[idx];
                      String imgUrl = 'assets/images/products/product-.jpg';

                      // Resolve product image fallback cleanly
                      if (item.variant != null &&
                          item.variant!.productImages.isNotEmpty) {
                        imgUrl = item.variant!.productImages.first.imageUrl;
                      } else {
                        for (var variant in item.product.productVariants) {
                          if (variant.productImages.isNotEmpty) {
                            imgUrl = variant.productImages.first.imageUrl;
                            break;
                          }
                        }
                      }

                      if (imgUrl.startsWith('/') &&
                          !imgUrl.startsWith('/assets')) {
                        imgUrl = 'http://localhost:5024$imgUrl';
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.shade200),
                              image: DecorationImage(
                                image:
                                    (imgUrl.startsWith('http')
                                            ? NetworkImage(imgUrl)
                                            : AssetImage(imgUrl))
                                        as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (item.variant != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.variant!.color} - ${item.variant!.size}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Quantity Selector
                                    Row(
                                      children: [
                                        _buildQtyButton(
                                          icon: Icons.remove,
                                          onTap: () {
                                            if (item.quantity > 1) {
                                              CartService.updateQuantity(
                                                item,
                                                item.quantity - 1,
                                              );
                                            }
                                          },
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        _buildQtyButton(
                                          icon: Icons.add,
                                          onTap: () {
                                            CartService.updateQuantity(
                                              item,
                                              item.quantity + 1,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (item.product.hasActiveDiscount)
                                          Text(
                                            formatVND(
                                              item.originalUnitPrice *
                                                  item.quantity,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                        Text(
                                          formatVND(item.totalPrice),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: () => CartService.removeItem(item),
                          ),
                        ],
                      );
                    },
                  ),
                  if (_promoApplied) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.promotionApplied,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '-${formatVND(_discountAmount)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Coupon / Promo Code Panel
        _buildSectionCard(
          title: context.l10n.promotionCode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6B6B),
                  side: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: _openVoucherWallet,
                icon: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                ),
                label: Text(
                  context.l10n.openVoucherWallet,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoController,
                      decoration: InputDecoration(
                        hintText: context.l10n.enterPromotionCode,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: _applyPromo,
                    child: Text(context.l10n.apply),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Order Summary Block
        _buildSectionCard(
          title: context.l10n.orderSummary,
          child: ValueListenableBuilder<List<CartItem>>(
            valueListenable: CartService.cartItems,
            builder: (context, items, _) {
              final subtotal = CartService.totalAmount;
              final shipping = subtotal > 0 ? _shippingFee : 0.0;
              final assembly = _includesAssembly ? subtotal * 0.05 : 0.0;
              final total = subtotal - _discountAmount + shipping + assembly;

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.subtotal,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text(
                        formatVND(subtotal),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.shippingFeeDistance(
                          _distanceKm.toStringAsFixed(1),
                        ),
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text(
                        shipping == 0 ? '-' : formatVND(shipping),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  if (_includesAssembly) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.assemblyServiceFee,
                          style: const TextStyle(color: Colors.blue),
                        ),
                        Text(
                          '+${formatVND(assembly)}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_promoApplied) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.discount,
                          style: const TextStyle(color: Colors.green),
                        ),
                        Text(
                          '-${formatVND(_discountAmount)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.totalPayment,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatVND(total),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: _isLoadingSubmit ? null : _submitOrder,
                      child: _isLoadingSubmit
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Text(
                              context.l10n.placeOrder,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required Widget icon,
    Widget? subtitle,
    Widget? expandedContent,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFAF9F9) : Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: isSelected ? 1.5 : 0,
              ),
              borderRadius: isSelected
                  ? BorderRadius.circular(4)
                  : BorderRadius.zero,
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Radio<String>(
                      value: value,
                      groupValue: _selectedPaymentMethod,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedPaymentMethod = val;
                          });
                        }
                      },
                      activeColor: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: icon,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 6),
                            subtitle,
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isSelected && expandedContent != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 8, 16, 14),
              child: expandedContent,
            ),
        ],
      ),
    );
  }

  Widget _buildCardBadges() {
    return Row(
      children: [
        _buildBadgeText('ATM'),
        const SizedBox(width: 4),
        _buildBadgeText('VISA', color: Colors.blue.shade900),
        const SizedBox(width: 4),
        _buildBadgeText('MasterCard', color: Colors.orange.shade800),
        const SizedBox(width: 4),
        _buildBadgeText('JCB', color: Colors.red.shade800),
      ],
    );
  }

  Widget _buildBadgeText(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(2),
        color: Colors.white,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color ?? Colors.black54,
        ),
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: Colors.black87),
      ),
    );
  }
}
