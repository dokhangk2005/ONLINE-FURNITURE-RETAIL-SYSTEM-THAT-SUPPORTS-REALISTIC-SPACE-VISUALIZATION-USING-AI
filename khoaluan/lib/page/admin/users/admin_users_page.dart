import 'package:flutter/material.dart';
import '../../../model/user_account.dart';
import '../../../services/api_service.dart';
import '../../../l10n/l10n.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final ApiService _apiService = ApiService();
  List<UserAccount> _allUsers = [];
  List<UserAccount> _filteredUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _apiService.fetchAdminUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(context.l10n.loadAccountsError(e));
    }
  }

  void _applyFilterAndSearch() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = _allUsers;
      });
      return;
    }

    setState(() {
      _filteredUsers = _allUsers.where((u) {
        return u.fullName.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query) ||
            u.phone.contains(query) ||
            u.userId.toString() == query;
      }).toList();
    });
  }

  Future<void> _toggleUserStatus(UserAccount user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          const Center(child: CircularProgressIndicator(color: Colors.black)),
    );

    try {
      await _apiService.toggleUserStatusAdmin(user.userId);
      Navigator.pop(context); // Close loading dialog
      _showSnackBar(
        user.isDeleted
            ? context.l10n.accountUnlocked
            : context.l10n.accountLocked,
      );
      _loadUsers();
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar(context.l10n.changeStatusError(e));
    }
  }

  Future<void> _changeUserRole(UserAccount user, int newRoleId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          const Center(child: CircularProgressIndicator(color: Colors.black)),
    );

    try {
      await _apiService.updateUserRoleAdmin(user.userId, newRoleId);
      Navigator.pop(context);
      _showSnackBar(context.l10n.roleUpdated);
      _loadUsers();
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar(context.l10n.updateRoleError(e));
    }
  }

  Future<void> _showResetPasswordDialog(UserAccount user) async {
    final controller = TextEditingController(text: '123456');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(
            context.l10n.resetPasswordFor(user.fullName),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.newPasswordLabel,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                context.l10n.cancel,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E73DF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () async {
                final newPass = controller.text.trim();
                if (newPass.isEmpty) return;
                Navigator.pop(ctx);

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (c) => const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                );

                try {
                  await _apiService.resetUserPasswordAdmin(
                    user.userId,
                    newPass,
                  );
                  Navigator.pop(context);
                  _showSnackBar(context.l10n.passwordResetSuccess(newPass));
                } catch (e) {
                  Navigator.pop(context);
                  _showSnackBar(context.l10n.resetPasswordError(e));
                }
              },
              child: Text(context.l10n.confirm),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.accountManagementTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5A5C69),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4E73DF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(
                  context.l10n.refresh,
                  style: const TextStyle(fontSize: 12),
                ),
                onPressed: _loadUsers,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.systemAccountList,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4E73DF),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        height: 38,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: context.l10n.searchAccountsHint,
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 18,
                              color: Colors.grey,
                            ),
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 8,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 13),
                          onChanged: (_) => _applyFilterAndSearch(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _filteredUsers.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(40.0),
                          child: Center(
                            child: Text(
                              context.l10n.noAccountsFound,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              const Color(0xFFF8F9FC),
                            ),
                            columns: [
                              DataColumn(
                                label: Text(
                                  context.l10n.customerId,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  context.l10n.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Email',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  context.l10n.phoneNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  context.l10n.role,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  context.l10n.status,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  context.l10n.operations,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            rows: _filteredUsers.map((u) {
                              return DataRow(
                                cells: [
                                  DataCell(Text('#${u.userId}')),
                                  DataCell(
                                    Text(
                                      u.fullName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(u.email)),
                                  DataCell(
                                    Text(u.phone.isEmpty ? '-' : u.phone),
                                  ),
                                  DataCell(
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: [1, 2, 3].contains(u.roleId)
                                            ? u.roleId
                                            : 2,
                                        menuMaxHeight: 200,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                        items: [
                                          const DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                              'Admin',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.indigo,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 2,
                                            child: Text(
                                              context.l10n.customerRole,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          const DropdownMenuItem(
                                            value: 3,
                                            child: Text(
                                              'Shipper',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ],
                                        onChanged: (val) {
                                          if (val != null && val != u.roleId) {
                                            _changeUserRole(u, val);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: u.isDeleted
                                            ? Colors.red.shade50
                                            : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        u.isDeleted
                                            ? context.l10n.locked
                                            : context.l10n.active,
                                        style: TextStyle(
                                          color: u.isDeleted
                                              ? Colors.red.shade700
                                              : Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          icon: Icon(
                                            u.isDeleted
                                                ? Icons.lock_open
                                                : Icons.lock,
                                            size: 14,
                                            color: u.isDeleted
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          label: Text(
                                            u.isDeleted
                                                ? context.l10n.unlock
                                                : context.l10n.lock,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: u.isDeleted
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                          onPressed: () => _toggleUserStatus(u),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          icon: const Icon(
                                            Icons.vpn_key,
                                            size: 14,
                                            color: Colors.amber,
                                          ),
                                          label: Text(
                                            context.l10n.resetPassword,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.amber,
                                            ),
                                          ),
                                          onPressed: () =>
                                              _showResetPasswordDialog(u),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
