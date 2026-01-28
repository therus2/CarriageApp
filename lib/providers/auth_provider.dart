import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Провайдер для управления состоянием авторизации и данными пользователя.
class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  String? _role;
  String? _username;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  // Геттеры для доступа к данным из виджетов
  String? get role => _role;
  String? get username => _username;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  /// Метод для входа в систему
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Отправляем запрос на получение токенов
      final response = await _api.dio.post('auth/login/', data: {
        'username': username,
        'password': password,
      });

      final access = response.data['access'];
      final refresh = response.data['refresh'];

      // Сохраняем токены в защищенное хранилище
      await _api.storage.write(key: 'access', value: access);
      await _api.storage.write(key: 'refresh', value: refresh);

      // Сразу загружаем профиль, чтобы узнать роль (ADMIN, DISPATCHER, COMPOSER)
      await fetchProfile();

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Ошибка авторизации: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Получение данных текущего пользователя (включая роль из ТЗ)
  Future<void> fetchProfile() async {
    try {
      final response = await _api.dio.get('auth/me/');
      _role = response.data['role'];
      _username = response.data['username'];
      notifyListeners();
    } catch (e) {
      debugPrint("Ошибка получения профи its профиля: $e");
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  /// Проверка наличия токена при запуске приложения
  Future<void> checkAuth() async {
    String? token = await _api.storage.read(key: 'access');
    if (token != null) {
      _isAuthenticated = true;
      await fetchProfile();
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  /// Выход из системы
  Future<void> logout() async {
    await _api.storage.deleteAll();
    _isAuthenticated = false;
    _role = null;
    _username = null;
    notifyListeners();
  }
}