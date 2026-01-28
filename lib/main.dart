import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/wagon_provider.dart';
import 'providers/data_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  // Гарантируем инициализацию связей Flutter перед запуском
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WagonProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: const TrainStationApp(),
    ),
  );
}

class TrainStationApp extends StatelessWidget {
  const TrainStationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Система учёта вагонов',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          primary: const Color(0xFF263238),
        ),
        useMaterial3: true,
      ),
      // Consumer следит за состоянием авторизации
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}