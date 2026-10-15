import 'package:flutter/material.dart';
import '../../conf/responsive.dart';
import '../../widgets/main_layout.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../model/order.dart';
import '../../widgets/currency_formatter.dart';
import '../../widgets/address_editor_dialog.dart';
import '../../l10n/l10n.dart';
import 'my_vouchers_tab.dart';
import 'my_questions_tab.dart';
import 'order_review_dialog.dart';

class ProfilePage extends StatefulWidget {
  final String? initialTab;
  const ProfilePage({super.key, this.initialTab});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  String _activeTab = 'info'; // 'info' or 'address'
  String _selectedOrderFilter = 'All';
  bool _isLoading = false;

  // Controllers
  late TextEditingController _emailController;
  late TextEditingController _lastNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;

  String _gender = 'Nam';
  DateTime? _selectedDateOfBirth;
  String? _lastLocaleCode;
  List<Map<String, dynamic>> _addresses = [];
  bool _addressesLoading = false;
  String? _addressesError;
  final Set<int> _reviewedOrderDetailIds = <int>{};

  @override
  void initState() {
    super.initState();
    if (widget.initialTab == 'addresses') {
      _activeTab = 'address';
    } else if (widget.initialTab == 'orders') {
      _activeTab = 'orders';
    } else if (widget.initialTab == 'vouchers') {
      _activeTab = 'vouchers';
    } else if (widget.initialTab == 'questions') {
      _activeTab = 'questions';
    }

    final user = AuthService.currentUser.value ?? {};
    _emailController = TextEditingController(text: user['email'] ?? '');
    _phoneController = TextEditingController(
      text: user['phone'] ?? user['Phone'] ?? '',
    );

    // Parse FullName into firstName (last word) and lastName (the rest)
    final fullName = (user['fullName'] ?? '').toString().trim();
    final parts = fullName.split(' ');
    String firstName = '';
    String lastName = '';
    if (parts.isNotEmpty) {
      firstName = parts.last;
      if (parts.length > 1) {
        lastName = parts.sublist(0, parts.length - 1).join(' ');
      }
    }
    _lastNameController = TextEditingController(text: lastName);
    _firstNameController = TextEditingController(text: firstName);

    // Gender
    _gender = user['gender'] ?? 'Nam';
    if (_gender.isEmpty) _gender = 'Nam';

    // DOB
    final dobStr = user['dateOfBirth'];
    if (dobStr != null) {
      try {
        _selectedDateOfBirth = DateTime.parse(dobStr);
        _dobController = TextEditingController(
          text:
              '${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}/${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}/${_selectedDateOfBirth!.year}',
        );
      } catch (_) {
        _dobController = TextEditingController();
      }
    } else {
      _dobController = TextEditingController();
    }
    _loadAddresses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeCode = Localizations.localeOf(context).languageCode;
    if (_lastLocaleCode != localeCode) {
      _lastLocaleCode = localeCode;
      if (_selectedDateOfBirth != null) {
        _dobController.text = _formatDateOfBirth(_selectedDateOfBirth!);
      }
    }
  }

  String _formatDateOfBirth(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return _lastLocaleCode == 'en'
        ? '$month/$day/${value.year}'
        : '$day/$month/${value.year}';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dobController.text = _formatDateOfBirth(picked);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = AuthService.currentUser.value ?? {};
      final userId = user['userId'] ?? user['UserId'];
      if (userId == null) throw Exception(context.l10n.loginAgain);

      final joinedFullName =
          '${_lastNameController.text.trim()} ${_firstNameController.text.trim()}'
              .trim();
      final dobIso = _selectedDateOfBirth?.toIso8601String();

      final updatedUser = await _apiService.updateUserProfile(
        userId,
        joinedFullName,
        _gender,
        dobIso,
        _phoneController.text.trim(),
      );

      // Save to global auth state
      AuthService.login(updatedUser);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.profileUpdated),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAddresses() async {
    if (!AuthService.isLoggedIn) return;
    if (mounted) {
      setState(() {
        _addressesLoading = true;
        _addressesError = null;
      });
    }
    try {
      final addresses = await _apiService.fetchAddresses();
      if (!mounted) return;
      setState(() => _addresses = addresses);
    } catch (error) {
      if (!mounted) return;
      setState(() => _addressesError = error.toString());
    } finally {
      if (mounted) setState(() => _addressesLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final double horizontalPadding = isMobile ? 16.0 : 64.0;

    return MainLayout(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 48,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title "Tài khoản của bạn"
              Center(
                child: Column(
                  children: [
                    Text(
                      context.l10n.yourAccount,
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(width: 60, height: 3, color: Colors.black87),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Layout side-by-side or stacked
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSideMenu(),
                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 32),
                        _buildActiveTabContent(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Sidebar
                        SizedBox(width: 250, child: _buildSideMenu()),
                        const SizedBox(width: 48),
                        // Right Content Panel
                        Expanded(child: _buildActiveTabContent()),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case 'info':
        return _buildInfoForm();
      case 'address':
        return _buildAddressesView();
      case 'orders':
        return _buildOrdersView();
      case 'vouchers':
        return const MyVouchersTab();
      case 'questions':
        return const MyQuestionsTab();
      default:
        return _buildInfoForm();
    }
  }

  Widget _buildSideMenu() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileMenuTitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        _buildSideMenuItem(
          title: l10n.profileInformation,
          isActive: _activeTab == 'info',
          onTap: () => setState(() => _activeTab = 'info'),
        ),
        _buildSideMenuItem(
          title: l10n.addressList,
          isActive: _activeTab == 'address',
          onTap: () => setState(() => _activeTab = 'address'),
        ),
        _buildSideMenuItem(
          title: l10n.deliveryHistory,
          isActive: _activeTab == 'orders',
          onTap: () => setState(() => _activeTab = 'orders'),
        ),
        _buildSideMenuItem(
          title: l10n.myVouchers,
          isActive: _activeTab == 'vouchers',
          onTap: () => setState(() => _activeTab = 'vouchers'),
        ),
        _buildSideMenuItem(
          title: l10n.helpCenter,
          isActive: _activeTab == 'questions',
          onTap: () => setState(() => _activeTab = 'questions'),
        ),
        _buildSideMenuItem(
          title: l10n.logout,
          isActive: false,
          onTap: () {
            AuthService.logout();
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.loggedOut)));
          },
        ),
      ],
    );
  }

  Widget _buildSideMenuItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                isActive ? '• ' : '  ',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                  color: isActive ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoForm() {
    final l10n = context.l10n;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.accountDetails,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 24),

          // Email field
          _buildFormRow(
            label: 'Email',
            child: TextFormField(
              controller: _emailController,
              readOnly: true,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xfff1f3f5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Họ và tên đệm field
          _buildFormRow(
            label: l10n.lastName,
            child: TextFormField(
              controller: _lastNameController,
              style: const TextStyle(fontSize: 14),
              validator: (val) => val == null || val.trim().isEmpty
                  ? l10n.requiredField(l10n.lastName)
                  : null,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xfff1f3f5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tên field
          _buildFormRow(
            label: l10n.firstName,
            child: TextFormField(
              controller: _firstNameController,
              style: const TextStyle(fontSize: 14),
              validator: (val) => val == null || val.trim().isEmpty
                  ? l10n.requiredField(l10n.firstName)
                  : null,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xfff1f3f5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Số điện thoại field
          _buildFormRow(
            label: l10n.phoneNumber,
            child: TextFormField(
              controller: _phoneController,
              style: const TextStyle(fontSize: 14),
              keyboardType: TextInputType.phone,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return l10n.requiredField(l10n.phoneNumber);
                }
                return RegExp(r'^0\d{9}$').hasMatch(val.trim())
                    ? null
                    : l10n.invalidPhone;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xfff1f3f5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Giới tính field
          _buildFormRow(
            label: l10n.gender,
            child: Row(
              children: [
                Radio<String>(
                  value: 'Nữ',
                  groupValue: _gender,
                  activeColor: Colors.black,
                  onChanged: (val) {
                    if (val != null) setState(() => _gender = val);
                  },
                ),
                Text(l10n.female, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 24),
                Radio<String>(
                  value: 'Nam',
                  groupValue: _gender,
                  activeColor: Colors.black,
                  onChanged: (val) {
                    if (val != null) setState(() => _gender = val);
                  },
                ),
                Text(l10n.male, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ngày sinh field
          _buildFormRow(
            label: l10n.dateOfBirth,
            child: GestureDetector(
              onTap: _selectDateOfBirth,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xfff1f3f5),
                    hintText: _lastLocaleCode == 'en'
                        ? 'mm/dd/yyyy'
                        : 'dd/mm/yyyy',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // CẬP NHẬT button
          SizedBox(
            width: 140,
            height: 44,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff333333),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      l10n.update,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesView() {
    final l10n = context.l10n;
    if (_addressesLoading && _addresses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.addressBook,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddressDialog(),
              icon: const Icon(Icons.add),
              label: Text(l10n.addAddress),
            ),
            IconButton(
              tooltip: l10n.refresh,
              onPressed: _addressesLoading ? null : _loadAddresses,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_addressesError != null)
          Text(
            '${l10n.cannotLoadAddresses}\n$_addressesError',
            style: const TextStyle(color: Colors.red),
          ),
        if (_addressesError == null && _addresses.isEmpty)
          Text(l10n.noAddresses, style: const TextStyle(color: Colors.grey)),
        ..._addresses.map(
          (address) => Card(
            child: ListTile(
              leading: Icon(
                address['isDefault'] == true
                    ? Icons.home
                    : Icons.location_on_outlined,
              ),
              title: Text(
                '${address['recipientName'] ?? ''} · ${address['phone'] ?? ''}',
              ),
              subtitle: Text(
                '${_addressLabelText(address['label'])} · ${address['addressLine'] ?? ''}${address['isDefault'] == true ? '\n${l10n.defaultAddress}' : ''}',
              ),
              isThreeLine: address['isDefault'] == true,
              trailing: Wrap(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showAddressDialog(address: address),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(l10n.confirmDelete),
                          content: Text(l10n.confirmDeleteAddress),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: Text(l10n.cancel),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: Text(l10n.delete),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      try {
                        await _apiService.deleteAddress(
                          address['addressId'] as int,
                        );
                        await _loadAddresses();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.addressDeleted)),
                          );
                        }
                      } catch (error) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString())),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddressDialog({Map<String, dynamic>? address}) async {
    final l10n = context.l10n;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AddressEditorDialog(apiService: _apiService, address: address),
    );
    if (saved == true && mounted) {
      await _loadAddresses();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.addressSaved)));
      }
    }
  }

  String _addressLabelText(Object? value) {
    final label = value?.toString().trim().toLowerCase() ?? '';
    if (label == 'company' || label == 'công ty' || label == 'work') {
      return context.l10n.addressLabelCompany;
    }
    if (label == 'other' || label == 'khác') {
      return context.l10n.addressLabelOther;
    }
    return context.l10n.addressLabelHome;
  }

  Widget buildLegacyAddressesView() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.addressBook,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: Colors.grey.shade200),
        const SizedBox(height: 24),
        Text(
          l10n.noAddresses,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildOrdersView() {
    final l10n = context.l10n;
    final user = AuthService.currentUser.value ?? {};
    final int? userId = user['userId'] ?? user['UserId'];

    if (userId == null) {
      return Center(
        child: Text(
          l10n.loginToViewOrders,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    final List<Map<String, String>> filters = [
      {'key': 'All', 'label': l10n.all},
      {'key': 'Unpaid', 'label': l10n.awaitingPayment},
      {'key': 'Pending', 'label': l10n.awaitingConfirmation},
      {'key': 'Processing', 'label': l10n.awaitingDelivery},
      {'key': 'Delivered', 'label': l10n.delivered},
      {'key': 'Cancelled', 'label': l10n.cancelled},
      {'key': 'Returned', 'label': l10n.returnedRefunded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.deliveryHistoryTitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        // Horizontal Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((f) {
              final isSelected = _selectedOrderFilter == f['key'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedOrderFilter = f['key']!;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? const Color(0xffFF471A)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    f['label']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xffFF471A)
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: Colors.grey.shade200),
        const SizedBox(height: 24),
        FutureBuilder<List<OrderModel>>(
          future: _apiService.fetchMyOrders(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              );
            }
            if (snapshot.hasError) {
              return Text(
                l10n.loadOrdersError(snapshot.error!),
                style: const TextStyle(fontSize: 14, color: Colors.redAccent),
              );
            }
            var orders = snapshot.data ?? [];

            // Apply filtering locally
            if (_selectedOrderFilter == 'Unpaid') {
              orders = orders
                  .where(
                    (o) =>
                        o.paymentStatus.toLowerCase() == 'pending' &&
                        o.orderStatus.toLowerCase() != 'cancelled',
                  )
                  .toList();
            } else if (_selectedOrderFilter == 'Pending') {
              orders = orders
                  .where((o) => o.orderStatus.toLowerCase() == 'pending')
                  .toList();
            } else if (_selectedOrderFilter == 'Processing') {
              orders = orders
                  .where((o) => o.orderStatus.toLowerCase() == 'processing')
                  .toList();
            } else if (_selectedOrderFilter == 'Delivered') {
              orders = orders
                  .where((o) => o.orderStatus.toLowerCase() == 'delivered')
                  .toList();
            } else if (_selectedOrderFilter == 'Cancelled') {
              orders = orders
                  .where((o) => o.orderStatus.toLowerCase() == 'cancelled')
                  .toList();
            } else if (_selectedOrderFilter == 'Returned') {
              orders = orders
                  .where((o) => o.orderStatus.toLowerCase() == 'returned')
                  .toList();
            }

            if (orders.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    l10n.noOrdersForStatus,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final order = orders[index];

                // Color and text mapping for statuses
                String statusText = order.orderStatus;
                Color statusColor = Colors.orange;
                switch (order.orderStatus.toLowerCase()) {
                  case 'pending':
                    statusText = l10n.awaitingConfirmation;
                    statusColor = Colors.blue;
                    break;
                  case 'processing':
                    statusText = l10n.awaitingDelivery;
                    statusColor = Colors.orange;
                    break;
                  case 'shipping':
                    statusText = l10n.shipping;
                    statusColor = Colors.purple;
                    break;
                  case 'delivered':
                    statusText = l10n.delivered;
                    statusColor = Colors.green;
                    break;
                  case 'returned':
                    statusText = l10n.returned;
                    statusColor = Colors.brown;
                    break;
                  case 'cancelled':
                    statusText = l10n.cancelled;
                    statusColor = Colors.red;
                    break;
                }

                Color paymentColor = Colors.orange;
                final isPaid =
                    order.paymentStatus == 'Đã thanh toán' ||
                    order.paymentStatus == 'Paid' ||
                    order.paymentStatus == 'Success';
                if (isPaid) {
                  paymentColor = Colors.green;
                }
                final paymentText = isPaid
                    ? l10n.paid
                    : order.paymentStatus.toLowerCase() == 'pending'
                    ? l10n.awaitingPayment
                    : order.paymentStatus;

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xfff8f9fa),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.orderCode(order.orderCode),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.orderDate(order.orderDate.split('T')[0]),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: paymentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    paymentText,
                                    style: TextStyle(
                                      color: paymentColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Items list
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.orderDetails.length,
                        separatorBuilder: (context, idx) =>
                            Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, idx) {
                          final item = order.orderDetails[idx];
                          final hasReviewed =
                              item.hasReviewed ||
                              _reviewedOrderDetailIds.contains(
                                item.orderDetailId,
                              );
                          final canReview =
                              !hasReviewed &&
                              item.canReview &&
                              order.canReviewItems;
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Builder(
                                  builder: (context) {
                                    String displayImgUrl = item.imageUrl;
                                    if (displayImgUrl.isNotEmpty &&
                                        !displayImgUrl.startsWith('http')) {
                                      displayImgUrl =
                                          'http://localhost:5024$displayImgUrl';
                                    }
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        displayImgUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    size: 20,
                                                  ),
                                                ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.variantDetails(
                                          item.color.toUpperCase(),
                                          item.size.toUpperCase(),
                                        ),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatVND(item.price),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.quantity(item.quantity),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (hasReviewed) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          l10n.reviewed,
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ] else if (canReview) ...[
                                      const SizedBox(height: 8),
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          final message =
                                              await showOrderReviewDialog(
                                                context,
                                                item,
                                              );
                                          if (message == null ||
                                              !context.mounted) {
                                            return;
                                          }
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(message),
                                              backgroundColor:
                                                  Colors.green.shade700,
                                            ),
                                          );
                                          setState(() {
                                            _reviewedOrderDetailIds.add(
                                              item.orderDetailId,
                                            );
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.star_outline,
                                          size: 17,
                                        ),
                                        label: Text(l10n.review),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xffff6b35,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),

                      // Footer info
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.paymentLabel(order.paymentMethod),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${l10n.totalAmount} ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  formatVND(order.totalAmount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFormRow({required String label, required Widget child}) {
    final isMobile = context.isMobile;
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: child),
      ],
    );
  }
}
