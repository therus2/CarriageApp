class CargoType {
  final int id;
  final String name;
  final String? hazardClass;
  final bool isActive;

  CargoType({
    required this.id,
    required this.name,
    this.hazardClass,
    required this.isActive,
  });

  factory CargoType.fromJson(Map<String, dynamic> json) {
    return CargoType(
      id: json['id'],
      name: json['name'],
      hazardClass: json['hazard_class'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hazard_class': hazardClass,
      'is_active': isActive,
    };
  }
}
