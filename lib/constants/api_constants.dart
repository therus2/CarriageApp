class ApiConstants {
  // Базовый URL API (измените на ваш адрес сервера)
  static const String baseUrl = 'http://10.0.2.2:8000';

  // Auth endpoints
  static const String loginEndpoint = '/api/auth/login/';
  static const String logoutEndpoint = '/api/auth/logout/';
  static const String refreshEndpoint = '/api/auth/refresh/';
  static const String meEndpoint = '/api/auth/me/';

  // Reference endpoints
  static const String wagonTypesEndpoint = '/api/wagon-types/';
  static const String cargoTypesEndpoint = '/api/cargo-types/';
  static const String climateConditionsEndpoint = '/api/climate-conditions/';
  static const String firmsEndpoint = '/api/firms/';
  static const String stationConfigEndpoint = '/api/station-config/';

  // Wagon endpoints
  static const String wagonsEndpoint = '/api/wagons/';
  static const String bulkWagonsEndpoint = '/api/wagons/bulk/';

  // Compose endpoint
  static const String composeEndpoint = '/api/compose/';
}
