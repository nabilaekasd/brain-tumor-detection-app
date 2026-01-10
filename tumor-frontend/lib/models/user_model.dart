class UserModel {
  final int id;
  final String username;
  final String fullName;
  final String role;
  final bool isActive;
  final String? avatar;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'dokter',
      isActive: json['is_active'] ?? true,
      avatar: json['avatar'],
    );
  }
}
