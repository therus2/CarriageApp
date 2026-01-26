import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wagon.dart';
import '../models/user.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';
  String? token;

  void setToken(String t) {
    token = t;
  }

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // Авторизация
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      token = data['access'];
      final userResponse = await http.get(
        Uri.parse('$baseUrl/users/me/'),
        headers: headers,
      );
      final userData = jsonDecode(userResponse.body);
      return User.fromJson(userData, token!);
    } else {
      throw Exception('Ошибка авторизации');
    }
  }

  // Получить список вагонов
  Future<List<Wagon>> getWagons() async {
    final response = await http.get(Uri.parse('$baseUrl/wagons/'), headers: headers);
    if (response.statusCode == 200) {
      List jsonData = jsonDecode(response.body);
      return jsonData.map((w) => Wagon.fromJson(w)).toList();
    } else {
      throw Exception('Не удалось загрузить вагоны');
    }
  }

  // Создание вагона
  Future<Wagon> createWagon(Wagon wagon) async {
    final response = await http.post(
      Uri.parse('$baseUrl/wagons/'),
      headers: headers,
      body: jsonEncode(wagon.toJson()),
    );
    if (response.statusCode == 201) {
      return Wagon.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Не удалось создать вагон');
    }
  }

  // Оптимальный состав
  Future<List<Wagon>> getOptimalComposition(List<Wagon> wagons) async {
    final response = await http.post(
      Uri.parse('$baseUrl/composer/optimal/'),
      headers: headers,
      body: jsonEncode(wagons.map((w) => w.toJson()).toList()),
    );
    if (response.statusCode == 200) {
      List jsonData = jsonDecode(response.body);
      return jsonData.map((w) => Wagon.fromJson(w)).toList();
    } else {
      throw Exception('Ошибка при расчёте оптимального состава');
    }
  }
}
