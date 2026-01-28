import 'package:flutter/material.dart';
import '../models/wagon.dart';
import '../services/api_service.dart';

/// Провайдер для управления данными вагонов и логикой формирования составов.
class WagonProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Wagon> _allWagons = [];      // Все вагоны на станции
  List<Wagon> _composedWagons = []; // Текущий сформированный состав
  double _totalLength = 0.0;        // Общая длина текущего состава
  bool _isLoading = false;

  // Геттеры
  List<Wagon> get allWagons => _allWagons;
  List<Wagon> get composedWagons => _composedWagons;
  double get totalLength => _totalLength;
  bool get isLoading => _isLoading;

  /// Загрузка всех вагонов с сервера
  Future<void> fetchAllWagons() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.dio.get('wagons/');
      _allWagons = (response.data as List)
          .map((w) => Wagon.fromJson(w))
          .toList();
    } catch (e) {
      debugPrint("Ошибка загрузки вагонов: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Алгоритм автоматического подбора состава (Запрос к Backend)
  Future<void> composeTrain({
    required int typeId,
    required int cargoId,
    required int count,
    required double maxLength,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Отправляем требования к составу на сервер
      final response = await _api.dio.post('compose/', data: {
        "requirements": [
          {"type_id": typeId, "cargo_id": cargoId, "count": count}
        ],
        "max_total_length": maxLength
      });

      // Получаем подобранные вагоны и общую длину из ответа
      _composedWagons = (response.data['wagons'] as List)
          .map((w) => Wagon.fromJson(w))
          .toList();
      _totalLength = (response.data['total_length'] as num).toDouble();
    } catch (e) {
      debugPrint("Ошибка подбора состава: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Создание нового вагона (для Диспетчера)
  Future<bool> createWagon(Wagon wagon) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _api.dio.post('wagons/', data: wagon.toJson());
      await fetchAllWagons(); // Обновляем локальный список
      return true;
    } catch (e) {
      debugPrint("Ошибка при создании вагона: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Функция ручной замены вагона в составе (Пункт 8.1 ТЗ)
  void replaceWagon(int oldWagonId, Wagon newWagon) {
    int index = _composedWagons.indexWhere((w) => w.id == oldWagonId);
    if (index != -1) {
      _composedWagons[index] = newWagon;
      _calculateTotalLength();
      notifyListeners();
    }
  }

  /// Ручное добавление вагона в состав
  void addWagonToComposition(Wagon wagon) {
    // Проверка, чтобы не добавить один и тот же вагон дважды
    if (!_composedWagons.any((w) => w.id == wagon.id)) {
      _composedWagons.add(wagon);
      _calculateTotalLength();
      notifyListeners();
    }
  }

  /// Удаление вагона из текущего состава
  void removeWagon(int id) {
    _composedWagons.removeWhere((w) => w.id == id);
    _calculateTotalLength();
    notifyListeners();
  }

  /// Вспомогательный метод пересчета длины при ручных изменениях
  void _calculateTotalLength() {
    _totalLength = _composedWagons.fold(0.0, (sum, item) => sum + item.length);
  }

  /// Очистка текущего состава
  void clearComposition() {
    _composedWagons = [];
    _totalLength = 0.0;
    notifyListeners();
  }
}