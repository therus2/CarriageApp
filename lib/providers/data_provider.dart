import 'package:flutter/material.dart';
import '../models/dictionary_item.dart';
import '../services/api_service.dart';

/// Провайдер для загрузки и хранения справочных данных станции.
class DataProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<DictionaryItem> _wagonTypes = [];
  List<DictionaryItem> _cargoTypes = [];
  List<DictionaryItem> _firms = [];
  bool _isLoading = false;

  List<DictionaryItem> get wagonTypes => _wagonTypes;
  List<DictionaryItem> get cargoTypes => _cargoTypes;
  List<DictionaryItem> get firms => _firms;
  bool get isLoading => _isLoading;

  /// Загрузка всех справочников параллельно
  Future<void> loadAllDictionaries() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Выполняем запросы к API
      final results = await Future.wait([
        _api.dio.get('wagon-types/'),
        _api.dio.get('cargo-types/'),
        _api.dio.get('firms/'),
      ]);

      _wagonTypes = (results[0].data as List)
          .map((item) => DictionaryItem.fromJson(item))
          .toList();

      _cargoTypes = (results[1].data as List)
          .map((item) => DictionaryItem.fromJson(item))
          .toList();

      _firms = (results[2].data as List)
          .map((item) => DictionaryItem.fromJson(item))
          .toList();

    } catch (e) {
      debugPrint("Ошибка загрузки справочников: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Вспомогательные методы для поиска названия по ID
  String getWagonTypeName(int id) =>
      _wagonTypes.firstWhere((element) => element.id == id,
          orElse: () => DictionaryItem(id: 0, name: 'Неизвестно')).name;

  String getCargoTypeName(int id) =>
      _cargoTypes.firstWhere((element) => element.id == id,
          orElse: () => DictionaryItem(id: 0, name: 'Неизвестно')).name;

  String getFirmName(int id) =>
      _firms.firstWhere((element) => element.id == id,
          orElse: () => DictionaryItem(id: 0, name: 'Неизвестно')).name;
}