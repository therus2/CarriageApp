class WagonType {
  final int id;
  final String name;
  WagonType({required this.id, required this.name});
  factory WagonType.fromJson(Map<String, dynamic> json) =>
      WagonType(id: json['id'], name: json['name']);
}

class CargoType {
  final int id;
  final String name;
  final String? hazardClass;
  CargoType({required this.id, required this.name, this.hazardClass});
  factory CargoType.fromJson(Map<String, dynamic> json) =>
      CargoType(id: json['id'], name: json['name'], hazardClass: json['hazard_class']);
}

class Firm {
  final int id;
  final String name;
  Firm({required this.id, required this.name});
  factory Firm.fromJson(Map<String, dynamic> json) =>
      Firm(id: json['id'], name: json['name']);
}