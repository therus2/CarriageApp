import 'package:flutter/foundation.dart';
import '../models/wagon_type.dart';
import '../models/cargo_type.dart';
import '../models/cistern_type.dart';
import '../models/conductor.dart';
import '../models/firm.dart';
import '../models/station_config.dart';
import '../services/api_service.dart';

class ReferenceProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<WagonType> _wagonTypes = [];
  List<CargoType> _cargoTypes = [];
  List<CisternType> _cisternTypes = [];
  List<Conductor> _conductors = [];
  List<Firm> _firms = [];
  StationConfig? _stationConfig;

  bool _isLoading = false;
  String? _error;

  List<WagonType> get wagonTypes => _wagonTypes;
  List<CargoType> get cargoTypes => _cargoTypes;
  List<CisternType> get cisternTypes => _cisternTypes;
  List<Conductor> get conductors => _conductors;
  List<Firm> get firms => _firms;
  StationConfig? get stationConfig => _stationConfig;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllReferences() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wagonTypes = await _apiService.getWagonTypes();
      print('ReferenceProvider: загружено типов вагонов: ${_wagonTypes.length}');
      _cargoTypes = await _apiService.getCargoTypes();
      print('ReferenceProvider: загружено типов грузов: ${_cargoTypes.length}');
      _cisternTypes = await _apiService.getCisternTypes();
      print('ReferenceProvider: загружено типов цистерн: ${_cisternTypes.length}');
      _conductors = await _apiService.getConductors();
      print('ReferenceProvider: загружено проводников: ${_conductors.length}');
      _firms = await _apiService.getFirms();
      print('ReferenceProvider: загружено фирм: ${_firms.length}');
      _stationConfig = await _apiService.getStationConfig();
    } catch (e) {
      _error = 'Ошибка загрузки справочников: $e';
      print('ReferenceProvider: ошибка: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('ReferenceProvider: загрузка завершена, уведомлены слушатели');
    }
  }

  Future<bool> addWagonType(WagonType wagonType) async {
    try {
      final created = await _apiService.createWagonType(wagonType);
      if (created != null) {
        _wagonTypes.add(created);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Ошибка создания типа вагона: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addCargoType(CargoType cargoType) async {
    try {
      final created = await _apiService.createCargoType(cargoType);
      if (created != null) {
        _cargoTypes.add(created);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Ошибка создания типа груза: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addCisternType(CisternType cisternType) async {
    try {
      final created = await _apiService.createCisternType(cisternType);
      if (created != null) {
        _cisternTypes.add(created);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Ошибка создания типа цистерны: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addConductor(Conductor conductor) async {
    try {
      final created = await _apiService.createConductor(conductor);
      if (created != null) {
        _conductors.add(created);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Ошибка создания проводника: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addFirm(Firm firm) async {
    try {
      final created = await _apiService.createFirm(firm);
      if (created != null) {
        _firms.add(created);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Ошибка создания фирмы: $e';
      notifyListeners();
      return false;
    }
  }
}
