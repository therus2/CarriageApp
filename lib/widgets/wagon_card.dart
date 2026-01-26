import 'package:flutter/material.dart';
import '../models/wagon.dart';

class WagonCard extends StatelessWidget {
  final Wagon wagon;
  final VoidCallback? onTap;

  WagonCard({required this.wagon, this.onTap});

  Color getCategoryColor(String category) {
    switch (category) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.orange;
      case 'C':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: getCategoryColor(wagon.category),
        child: Container(
          padding: EdgeInsets.all(8),
          width: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('№${wagon.number}', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Тип: ${wagon.cargoType}'),
              Text('Категория: ${wagon.category}'),
              Text('Путь: ${wagon.path}'),
            ],
          ),
        ),
      ),
    );
  }
}
