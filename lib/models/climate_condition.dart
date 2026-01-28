class ClimateCondition {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  ClimateCondition({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  factory ClimateCondition.fromJson(Map<String, dynamic> json) {
    return ClimateCondition(
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
