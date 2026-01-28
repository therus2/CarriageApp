import 'package:flutter/foundation.dart';
import '../models/wagon.dart';
import '../services/api_service.dart';

class WagonProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Wagon> _wagons = [];
  bool _isLoading = false;
  String? _error;

  List<Wagon> get wagons => _wagons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWagons({bool? isOperational, int? path}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wagons = await _apiService.getWagons(
        isOperational: isOperational,
        path: path,
      );
    } catch (e) {
      _error = 'Ошибка загрузки вагонов: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addWagon(Wagon wagon) {
    _wagons.add(wagon);
    notifyListeners();
  }

  void updateWagon(int index, Wagon wagon) {
    if (index >= 0 && index < _wagons.length) {
      _wagons[index] = wagon;
      notifyListeners();
    }
  }

  void removeWagon(int index) {
    if (index >= 0 && index < _wagons.length) {
      _wagons.removeAt(index);
      notifyListeners();
    }
  }

  void clearWagons() {
    _wagons.clear();
    _error = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> saveWagons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.bulkCreateWagons(_wagons);
      if (result['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return result;
      } else {
        _error = result['error']?.toString() ?? 'Ошибка сохранения';
        _isLoading = false;
        notifyListeners();
        return result;
      }
    } catch (e) {
      _error = 'Ошибка соединения: $e';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': _error};
    }
  }
}
