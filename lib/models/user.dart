class User {
  final String email;
  final String role;
  final String token;

  User({required this.email, required this.role, required this.token});

  factory User.fromJson(Map<String, dynamic> json, String token) {
    return User(
      email: json['email'],
      role: json['role'], // из Django
      token: token,
    );
  }
}
