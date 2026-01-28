import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/user.dart';
import '../models/wagon.dart';
import '../models/wagon_type.dart';
import '../models/cargo_type.dart';
import '../models/climate_condition.dart';
import '../models/firm.dart';
import '../models/station_config.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final token = await _storageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Auth methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
        headers: await _getHeaders(includeAuth: false),
        body: jsonEncode({
          // Django SimpleJWT TokenObtainPairView ожидает поле `username`
          // по умолчанию. Используем введённое значение как имя пользователя.
          'username': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storageService.saveToken(data['access']);
        if (data['refresh'] != null) {
          await _storageService.saveRefreshToken(data['refresh']);
        }
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['detail'] ?? 'Ошибка входа'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Ошибка соединения: $e'};
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken != null) {
        await http.post(
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logoutEndpoint}'),
          headers: await _getHeaders(),
          body: jsonEncode({'refresh': refreshToken}),
        );
      }
    } catch (e) {
      print('Ошибка выхода: $e');
    } finally {
      await _storageService.clearAll();
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.meEndpoint}'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Ошибка получения пользователя: $e');
      return null;
    }
  }

  // Reference methods
  Future<List<WagonType>> getWagonTypes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.wagonTypesEndpoint}'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Проверяем, если это пагинация
        final List<dynamic> data = decoded is List
            ? decoded
            : (decoded['results'] as List<dynamic>? ?? []);
        print('Получено типов вагонов: ${data.length}');
        return data.map((e) => WagonType.fromJson(e)).toList();
      }
      print('Ошибка получения типов вагонов: статус ${response.statusCode}');
      return [];
    } catch (e, stackTrace) {
      print('Ошибка получения типов вагонов: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<WagonType?> createWagonType(WagonType wagonType) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.wagonTypesEndpoint}'),
        headers: await _getHeaders(),
        body: jsonEncode(wagonType.toJson()),
      );

      if (response.statusCode == 201) {
        return WagonType.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Ошибка создания типа вагона: $e');
      return null;
    }
  }

  Future<List<CargoType>> getCargoTypes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cargoTypesEndpoint}'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded is List
            ? decoded
            : (decoded['results'] as List<dynamic>? ?? []);
        print('Получено типов грузов: ${data.length}');
        return data.map((e) => CargoType.fromJson(e)).toList();
      }
      print('Ошибка получения типов грузов: статус ${response.statusCode}');
      return [];
    } catch (e) {
      print('Ошибка получения типов грузов: $e');
      return [];
    }
  }

  Future<CargoType?> createCargoType(CargoType cargoType) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cargoTypesEndpoint}'),
        headers: await _getHeaders(),
        body: jsonEncode(cargoType.toJson()),
      );

      if (response.statusCode == 201) {
        return CargoType.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Ошибка создания типа груза: $e');
      return null;
    }
  }

  Future<List<ClimateCondition>> getClimateConditions() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.climateConditionsEndpoint}'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded is List
            ? decoded
            : (decoded['results'] as List<dynamic>? ?? []);
        print('Получено климатических условий: ${data.length}');
        return data.map((e) => ClimateCondition.fromJson(e)).toList();
      }
      print(
          'Ошибка получения климатических условий: статус ${response.statusCode}');
      return [];
    } catch (e) {
      print('Ошибка получения климатических условий: $e');
      return [];
    }
  }

  Future<ClimateCondition?> createClimateCondition(
      ClimateCondition condition) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.climateConditionsEndpoint}'),
        headers: await _getHeaders(),
        body: jsonEncode(condition.toJson()),
      );

      if (response.statusCode == 201) {
        return ClimateCondition.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Ошибка создания климатического условия: $e');
      return null;
    }
  }

  Future<List<Firm>> getFirms() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.firmsEndpoint}'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded is List
            ? decoded
            : (decoded['results'] as List<dynamic>? ?? []);
        print('Получено фирм: ${data.length}');
        return data.map((e) => Firm.fromJson(e)).toList();
      }
      print('Ошибка получения фирм: статус ${response.statusCode}');
      return [];
    } catch (e) {
      print('Ошибка получения фирм: $e');
      return [];
    }
  }

  Future<Firm?> createFirm(Firm firm) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.firmsEndpoint}'),
        headers: await _getHeaders(),
        body: jsonEncode(firm.toJson()),
      );

      if (response.statusCode == 201) {
        return Firm.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Ошибка создания фирмы: $e');
      return null;
    }
  }

  Future<StationConfig?> getStationConfig() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.stationConfigEndpoint}'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return StationConfig.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Ошибка получения конфигурации станции: $e');
      return null;
    }
  }

  // Wagon methods
  Future<List<Wagon>> getWagons({bool? isOperational, int? path}) async {
    try {
      String url = '${ApiConstants.baseUrl}${ApiConstants.wagonsEndpoint}';
      final params = <String, String>{};
      if (isOperational != null) {
        params['is_operational'] = isOperational.toString();
      }
      if (path != null) {
        params['path'] = path.toString();
      }
      if (params.isNotEmpty) {
        url += '?${Uri(queryParameters: params).query}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            jsonDecode(response.body)['results'] ?? jsonDecode(response.body);
        return data.map((e) => Wagon.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Ошибка получения вагонов: $e');
      return [];
    }
  }

  Future<Wagon?> createWagon(Wagon wagon) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.wagonsEndpoint}'),
        headers: await _getHeaders(),
        body: jsonEncode(wagon.toJson()),
      );

      if (response.statusCode == 201) {
        return Wagon.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Ошибка создания вагона: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> bulkCreateWagons(List<Wagon> wagons) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bulkWagonsEndpoint}'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'wagons': wagons.map((w) => w.toJson()).toList(),
        }),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Ошибка соединения: $e',
      };
    }
  }

  // Compose method
  Future<Map<String, dynamic>> composeTrain(List<Map<String, dynamic>> items,
      {double? maxTotalLength, int? totalWagonsCount}) async {
    try {
      final body = <String, dynamic>{
        'items': items,
      };
      if (maxTotalLength != null) {
        body['max_total_length'] = maxTotalLength;
      }
      if (totalWagonsCount != null) {
        body['total_wagons_count'] = totalWagonsCount;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.composeEndpoint}'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 207) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Ошибка соединения: $e',
      };
    }
  }
}
