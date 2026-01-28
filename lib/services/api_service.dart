import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Сервис для работы с HTTP-запросами через Dio.
/// Реализует автоматическую подстановку JWT токена и его обновление при истечении.
class ApiService {
  final Dio dio = Dio(BaseOptions(
    // Укажи здесь IP своего сервера (10.0.2.2 для эмулятора Android или реальный IP)
    baseUrl: 'http://127.0.0.1:8000/api/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  final storage = const FlutterSecureStorage();

  ApiService() {
    dio.interceptors.add(InterceptorsWrapper(
      // 1. Перед каждым запросом добавляем Access Token в заголовок
      onRequest: (options, handler) async {
        String? token = await storage.read(key: 'access');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },

      // 2. Обработка ошибок, включая истечение срока действия токена (401)
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          String? refreshToken = await storage.read(key: 'refresh');

          if (refreshToken != null) {
            try {
              // Пытаемся получить новый Access Token используя Refresh Token
              final response = await dio.post('auth/refresh/', data: {
                'refresh': refreshToken,
              });

              final newAccessToken = response.data['access'];

              // Сохраняем новый токен
              await storage.write(key: 'access', value: newAccessToken);

              // Повторяем изначальный запрос с новым токеном
              e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

              final opts = Options(
                method: e.requestOptions.method,
                headers: e.requestOptions.headers,
              );

              final cloneReq = await dio.request(
                e.requestOptions.path,
                options: opts,
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
              );

              return handler.resolve(cloneReq);
            } catch (refreshError) {
              // Если Refresh Token тоже невалиден — принудительный логаут
              await storage.deleteAll();
              // Тут можно добавить логику перехода на экран логина через навигатор
            }
          }
        }
        return handler.next(e);
      },
    ));
  }
}