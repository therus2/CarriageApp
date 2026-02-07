import 'wagon_type.dart';
import 'firm.dart';
import 'cistern_type.dart';
import 'conductor.dart';
import 'user.dart';

class Wagon {
  final int? id;
  final String wagonNumber;
  final WagonType? wagonType;
  final Firm? firm;
  final int pathNumber;
  final int position;
  final double? length;
  final double? height;
  final double? loadCapacity; // Грузоподъёмность (т)
  final int? axleCount; // Количество осей
  final double? netWeight; // Масса нетто (кг)
  final double? wagonWeight; // Масса вагона (кг)
  final double? bodyVolume; // Объём кузова (м³)
  final double? fillHeight; // Высота налива (см) - только для цистерн
  final CisternType? cisternType; // Тип цистерны - только для цистерн
  final Conductor? conductors; // Проводники
  final bool canRollFromHill; // Можно ли вагон скатывать с горки
  final bool inConsist; // Находится в составе
  final DateTime? inConsistAt; // Дата включения в состав
  final DateTime arrivedAt;
  final User? createdBy;
  final String conditionStatus;
  final bool isOperational;
  final String? comment;
  final DateTime? createdAt;

  // Write-only поля для создания/обновления
  final int? wagonTypeId;
  final int? firmId;
  final int? cisternTypeId;
  final int? conductorsId;

  Wagon({
    this.id,
    required this.wagonNumber,
    this.wagonType,
    this.firm,
    required this.pathNumber,
    required this.position,
    this.length,
    this.height,
    this.loadCapacity,
    this.axleCount,
    this.netWeight,
    this.wagonWeight,
    this.bodyVolume,
    this.fillHeight,
    this.cisternType,
    this.conductors,
    required this.arrivedAt,
    this.createdBy,
    required this.conditionStatus,
    required this.isOperational,
      this.comment,
      this.createdAt,
      this.wagonTypeId,
      this.firmId,
      this.cisternTypeId,
      this.conductorsId,
      this.canRollFromHill = true,
      this.inConsist = false,
      this.inConsistAt,
    });

  factory Wagon.fromJson(Map<String, dynamic> json) {
    return Wagon(
      id: json['id'],
      wagonNumber: json['wagon_number'],
      wagonType: json['wagon_type'] != null
          ? WagonType.fromJson(json['wagon_type'])
          : null,
      firm: json['firm'] != null ? Firm.fromJson(json['firm']) : null,
      pathNumber: json['path_number'],
      position: json['position'],
      length: json['length'] != null ? (json['length'] as num).toDouble() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      loadCapacity: json['load_capacity'] != null
          ? (json['load_capacity'] as num).toDouble()
          : null,
      axleCount: json['axle_count'],
      netWeight: json['net_weight'] != null
          ? (json['net_weight'] as num).toDouble()
          : null,
      wagonWeight: json['wagon_weight'] != null
          ? (json['wagon_weight'] as num).toDouble()
          : null,
      bodyVolume: json['body_volume'] != null
          ? (json['body_volume'] as num).toDouble()
          : null,
      fillHeight: json['fill_height'] != null
          ? (json['fill_height'] as num).toDouble()
          : null,
      cisternType: json['cistern_type'] != null
          ? CisternType.fromJson(json['cistern_type'])
          : null,
      conductors: json['conductors'] != null
          ? Conductor.fromJson(json['conductors'])
          : null,
      canRollFromHill: json['can_roll_from_hill'] ?? true,
      inConsist: json['in_consist'] ?? false,
      inConsistAt: json['in_consist_at'] != null
          ? DateTime.parse(json['in_consist_at'])
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
      if (length != null) 'length': length,
      if (height != null) 'height': height,
      'arrived_at': arrivedAt.toIso8601String(),
      'condition_status': conditionStatus,
      'is_operational': isOperational,
    };

    if (id != null) json['id'] = id;
    if (wagonTypeId != null) json['wagon_type_id'] = wagonTypeId;
    if (firmId != null) json['firm_id'] = firmId;
    if (cisternTypeId != null) json['cistern_type_id'] = cisternTypeId;
    if (conductorsId != null) json['conductors_id'] = conductorsId;
    json['can_roll_from_hill'] = canRollFromHill;
    if (loadCapacity != null) json['load_capacity'] = loadCapacity;
    if (axleCount != null) json['axle_count'] = axleCount;
    if (netWeight != null) json['net_weight'] = netWeight;
    if (wagonWeight != null) json['wagon_weight'] = wagonWeight;
    if (bodyVolume != null) json['body_volume'] = bodyVolume;
    if (fillHeight != null) json['fill_height'] = fillHeight;
    if (comment != null) json['comment'] = comment;

    return json;
  }
}
