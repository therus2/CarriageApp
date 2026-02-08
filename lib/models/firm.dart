class Firm {
  final int id;
  final String name;
  final String country;
  final bool isActive;

  Firm({
    required this.id,
    required this.name,
    required this.country,
    required this.isActive,
  });

  factory Firm.fromJson(Map<String, dynamic> json) {
    return Firm(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'is_active': isActive,
    };
  }
}
