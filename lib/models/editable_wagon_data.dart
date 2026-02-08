/// Модель для редактируемых данных вагона (только для PDF, не сохраняется в БД)
class EditableWagonData {
  final int? id; // ID вагона из БД (для связи)
  int position; // № п/п в составе
  int pathNumber; // Номер пути
  int wagonPosition; // Позиция на пути
  String wagonNumber; // № вагона
  String wagonType; // Тип вагона
  double? loadCapacity; // Грузоподъёмность (т)
  int? axleCount; // Количество осей
  double? netWeight; // Масса нетто (кг)
  double? wagonWeight; // Масса вагона (кг)
  double? grossWeight; // Масса брутто (кг)
  String? conductors; // Проводники
  double? bodyVolume; // Объём кузова (м³)
  double? fillHeight; // Высота налива (см)
  String? cisternType; // Тип цистерны

  EditableWagonData({
    this.id,
    required this.position,
    required this.pathNumber,
    required this.wagonPosition,
    required this.wagonNumber,
    required this.wagonType,
    this.loadCapacity,
    this.axleCount,
    this.netWeight,
    this.wagonWeight,
    this.grossWeight,
    this.conductors,
    this.bodyVolume,
    this.fillHeight,
    this.cisternType,
  });

  /// Создает из модели Wagon
  factory EditableWagonData.fromWagon(dynamic wagon, int position) {
    return EditableWagonData(
      id: wagon.id,
      position: position,
      pathNumber: wagon.pathNumber,
      wagonPosition: wagon.position,
      wagonNumber: wagon.wagonNumber,
      wagonType: wagon.wagonType?.name ?? '',
      loadCapacity: wagon.loadCapacity,
      axleCount: wagon.axleCount,
      netWeight: wagon.netWeight,
      wagonWeight: wagon.wagonWeight,
      grossWeight: wagon.netWeight != null && wagon.wagonWeight != null
          ? (wagon.netWeight! + wagon.wagonWeight!)
          : null,
      conductors: wagon.conductors?.name,
      bodyVolume: wagon.bodyVolume,
      fillHeight: wagon.fillHeight,
      cisternType: wagon.cisternType?.name,
    );
  }

  /// Преобразует в JSON для отправки на сервер
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'position': position,
      'path_number': pathNumber,
      'wagon_position': wagonPosition,
      'wagon_number': wagonNumber,
      'wagon_type': wagonType,
      if (loadCapacity != null) 'load_capacity': loadCapacity,
      if (axleCount != null) 'axle_count': axleCount,
      if (netWeight != null) 'net_weight': netWeight,
      if (wagonWeight != null) 'wagon_weight': wagonWeight,
      if (grossWeight != null) 'gross_weight': grossWeight,
      if (conductors != null && conductors!.isNotEmpty) 'conductors': conductors,
      if (bodyVolume != null) 'body_volume': bodyVolume,
      if (fillHeight != null) 'fill_height': fillHeight,
      if (cisternType != null && cisternType!.isNotEmpty) 'cistern_type': cisternType,
    };
  }
}
