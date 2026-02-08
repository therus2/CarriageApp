import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    checkAuth();
  }

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      if (token != null) {
        final user = await _apiService.getCurrentUser();
        if (user != null) {
          _currentUser = user;
          await _storageService.saveUser(user);
        } else {
          await _storageService.clearAll();
        }
      }
    } catch (e) {
      _error = 'Ошибка проверки авторизации: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);
      if (result['success'] == true) {
        final user = await _apiService.getCurrentUser();
        if (user != null) {
          _currentUser = user;
          await _storageService.saveUser(user);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } else {
        _error = result['error'] ?? 'Ошибка входа';
      }
    } catch (e) {
      _error = 'Ошибка соединения: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
    } catch (e) {
      print('Ошибка выхода: $e');
    } finally {
      _currentUser = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}
