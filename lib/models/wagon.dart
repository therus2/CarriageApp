class Wagon {
  final int? id;
  final String number;
  final String cargoType;
  final String category;
  final String path;

  Wagon({
    this.id,
    required this.number,
    required this.cargoType,
    required this.category,
    required this.path,
  });

  factory Wagon.fromJson(Map<String, dynamic> json) {
    return Wagon(
      id: json['id'],
      number: json['number'],
      cargoType: json['cargo_type'] is Map
          ? json['cargo_type']['name']
          : json['cargo_type'].toString(),
      category: json['category'],
      path: json['path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'cargo_type': cargoType,
      'category': category,
      'path': path,
    };
  }
}
