class WagonType {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  WagonType({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  factory WagonType.fromJson(Map<String, dynamic> json) {
    return WagonType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive,
    };
  }
}
