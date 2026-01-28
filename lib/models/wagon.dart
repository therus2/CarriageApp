import 'dart:convert';

class Wagon {
  final int? id;
  String wagonNumber;
  int wagonType;
  String? wagonTypeName; // Для отображения названия типа
  List<int> cargoTypes;
  String? cargoNames;    // Для отображения списка грузов строкой
  int firm;
  String? firmName;      // Для отображения названия владельца
  int pathNumber;
  int position;
  double length;
  double height;
  double width;
  double weightNetto;
  double maxLoadWeight;
  String conditionStatus;
  bool isOperational;
  DateTime arrivedAt;
  String? comment;

  Wagon({
    this.id,
    required this.wagonNumber,
    required this.wagonType,
    this.wagonTypeName,
    required this.cargoTypes,
    this.cargoNames,
    required this.firm,
    this.firmName,
    required this.pathNumber,
    required this.position,
    required this.length,
    required this.height,
    this.width = 3.2,       // Значение по умолчанию
    this.weightNetto = 24.0, // Значение по умолчанию
    required this.maxLoadWeight,
    required this.conditionStatus,
    required this.isOperational,
    required this.arrivedAt,
    this.comment,
  });

  // Преобразование из JSON (ответ от Django API)
  factory Wagon.fromJson(Map<String, dynamic> json) {
    return Wagon(
      id: json['id'],
      wagonNumber: json['wagon_number'] ?? '',
      wagonType: json['wagon_type'],
      wagonTypeName: json['wagon_type_name'],
      // Обработка списка ID грузов
      cargoTypes: List<int>.from(json['cargo_types'] ?? []),
      cargoNames: json['cargo_names'],
      firm: json['firm'],
      firmName: json['firm_name'],
      pathNumber: json['path_number'] ?? 1,
      position: json['position'] ?? 1,
      length: (json['length'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      width: (json['width'] as num?)?.toDouble() ?? 3.2,
      weightNetto: (json['weight_netto'] as num?)?.toDouble() ?? 24.0,
      maxLoadWeight: (json['max_load_weight'] as num).toDouble(),
      conditionStatus: json['condition_status'] ?? 'OK',
      isOperational: json['is_operational'] ?? true,
      arrivedAt: DateTime.parse(json['arrived_at']),
      comment: json['comment'],
    );
  }

  // Преобразование в JSON (для отправки на сервер при создании/редактировании)
  Map<String, dynamic> toJson() {
    return {
      'wagon_number': wagonNumber,
      'wagon_type': wagonType,
      'cargo_types': cargoTypes,
      'firm': firm,
      'path_number': pathNumber,
      'position': position,
      'length': length,
      'height': height,
      'width': width,
      'weight_netto': weightNetto,
      'max_load_weight': maxLoadWeight,
      'condition_status': conditionStatus,
      'is_operational': isOperational,
      'arrived_at': arrivedAt.toIso8601String(),
      'comment': comment,
    };
  }
}