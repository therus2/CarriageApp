import 'wagon_type.dart';
import 'cargo_type.dart';
import 'firm.dart';
import 'climate_condition.dart';
import 'user.dart';

class Wagon {
  final int? id;
  final String wagonNumber;
  final WagonType? wagonType;
  final List<CargoType>? cargoTypes;
  final Firm? firm;
  final int pathNumber;
  final int position;
  final double length;
  final double height;
  final double? maxLoadWeight;
  final List<ClimateCondition>? climateConditions;
  final DateTime arrivedAt;
  final User? createdBy;
  final String conditionStatus;
  final bool isOperational;
  final String? comment;
  final DateTime? createdAt;

  // Write-only поля для создания/обновления
  final int? wagonTypeId;
  final List<int>? cargoTypeIds;
  final int? firmId;
  final List<int>? climateConditionIds;

  Wagon({
    this.id,
    required this.wagonNumber,
    this.wagonType,
    this.cargoTypes,
    this.firm,
    required this.pathNumber,
    required this.position,
    required this.length,
    required this.height,
    this.maxLoadWeight,
    this.climateConditions,
    required this.arrivedAt,
    this.createdBy,
    required this.conditionStatus,
    required this.isOperational,
    this.comment,
    this.createdAt,
    this.wagonTypeId,
    this.cargoTypeIds,
    this.firmId,
    this.climateConditionIds,
  });

  factory Wagon.fromJson(Map<String, dynamic> json) {
    return Wagon(
      id: json['id'],
      wagonNumber: json['wagon_number'],
      wagonType: json['wagon_type'] != null
          ? WagonType.fromJson(json['wagon_type'])
          : null,
      cargoTypes: json['cargo_types'] != null
          ? (json['cargo_types'] as List)
              .map((e) => CargoType.fromJson(e))
              .toList()
          : null,
      firm: json['firm'] != null ? Firm.fromJson(json['firm']) : null,
      pathNumber: json['path_number'],
      position: json['position'],
      length: (json['length'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      maxLoadWeight: json['max_load_weight'] != null
          ? (json['max_load_weight'] as num).toDouble()
          : null,
      climateConditions: json['climate_conditions'] != null
          ? (json['climate_conditions'] as List)
              .map((e) => ClimateCondition.fromJson(e))
              .toList()
          : null,
      arrivedAt: DateTime.parse(json['arrived_at']),
      createdBy:
          json['created_by'] != null ? User.fromJson(json['created_by']) : null,
      conditionStatus: json['condition_status'] ?? 'OK',
      isOperational: json['is_operational'] ?? true,
      comment: json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'wagon_number': wagonNumber,
      'path_number': pathNumber,
      'position': position,
      'length': length,
      'height': height,
      'arrived_at': arrivedAt.toIso8601String(),
      'condition_status': conditionStatus,
      'is_operational': isOperational,
    };

    if (id != null) json['id'] = id;
    if (wagonTypeId != null) json['wagon_type_id'] = wagonTypeId;
    if (cargoTypeIds != null) json['cargo_type_ids'] = cargoTypeIds;
    if (firmId != null) json['firm_id'] = firmId;
    if (climateConditionIds != null) {
      json['climate_condition_ids'] = climateConditionIds;
    }
    if (maxLoadWeight != null) json['max_load_weight'] = maxLoadWeight;
    if (comment != null) json['comment'] = comment;

    return json;
  }
}
