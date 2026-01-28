class User {
  final int id;
  final String email;
  final String? username;
  final String? role;

  User({
    required this.id,
    required this.email,
    this.username,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] ?? '',
      username: json['username'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role,
    };
  }
}
