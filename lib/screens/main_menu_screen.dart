import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'composer_screen.dart';
import 'dispatcher_input_screen.dart';

class MainMenuScreen extends StatelessWidget {
  final User user;
  final ApiService api;

  MainMenuScreen({required this.user, required this.api});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Главное меню'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user.role == 'Составитель')
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ComposerScreen(api: api)),
                ),
                child: Text('Создать состав'),
              ),
            if (user.role == 'Диспетчер')
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DispatcherInputScreen(api: api)),
                ),
                child: Text('Ввести вагоны'),
              ),
          ],
        ),
      ),
    );
  }
}
