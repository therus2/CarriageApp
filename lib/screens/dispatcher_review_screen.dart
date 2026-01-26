import 'package:flutter/material.dart';
import '../models/wagon.dart';
import '../services/api_service.dart';
import '../widgets/wagon_card.dart';

class DispatcherReviewScreen extends StatelessWidget {
  final ApiService api;
  final List<Wagon> wagons;

  DispatcherReviewScreen({required this.api, required this.wagons});

  Future<void> saveAll(BuildContext context) async {
    for (var wagon in wagons) {
      await api.createWagon(wagon);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Вагоны успешно сохранены')),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Проверка вагонов'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.6,
              ),
              itemCount: wagons.length,
              itemBuilder: (_, i) => WagonCard(wagon: wagons[i]),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => saveAll(context),
              child: Text('Сохранить'),
            ),
          )
        ],
      ),
    );
  }
}
