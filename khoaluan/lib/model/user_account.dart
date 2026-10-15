class UserAccount {
  final int userId;
  final String fullName;
  final String email;
  final String phone;
  final int roleId;
  final String roleName;
  final bool isDeleted;
  final String createdAt;

  UserAccount({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.roleId,
    required this.roleName,
    required this.isDeleted,
    required this.createdAt,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      roleId: json['roleId'] ?? 2,
      roleName: json['roleName'] ?? 'Customer',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
