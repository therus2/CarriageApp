class Conductor {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  Conductor({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  factory Conductor.fromJson(Map<String, dynamic> json) {
    return Conductor(
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
      if (description != null) 'description': description,
      'is_active': isActive,
    };
  }
}
