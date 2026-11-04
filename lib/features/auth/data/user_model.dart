class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    this.avatar,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final String? avatar;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String?,
    role: json['role'] as String?,
    avatar: json['avatar'] as String?,
  );
}
