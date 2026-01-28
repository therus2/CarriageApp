import 'package:flutter/material.dart';
import '../models/wagon.dart';

class WagonCard extends StatelessWidget {
  final Wagon wagon;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const WagonCard({
    super.key,
    required this.wagon,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  Color _getStatusColor() {
    switch (wagon.conditionStatus) {
      case 'OK':
        return Colors.green;
      case 'MINOR':
        return Colors.yellow;
      case 'MAJOR':
        return Colors.orange;
      case 'OUT_OF_SERVICE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (wagon.conditionStatus) {
      case 'OK':
        return 'Исправен';
      case 'MINOR':
        return 'Незначительные неисправности';
      case 'MAJOR':
        return 'Значительные неисправности';
      case 'OUT_OF_SERVICE':
        return 'Не пригоден к эксплуатации';
      default:
        return wagon.conditionStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    wagon.wagonNumber.isNotEmpty
                        ? wagon.wagonNumber
                        : 'Вагон',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (wagon.wagonType != null)
                Text('Тип: ${wagon.wagonType!.name}'),
              if (wagon.cargoTypes != null && wagon.cargoTypes!.isNotEmpty)
                Text(
                  'Грузы: ${wagon.cargoTypes!.map((e) => e.name).join(", ")}',
                ),
              const SizedBox(height: 4),
              Text('Путь: ${wagon.pathNumber}, Позиция: ${wagon.position}'),
              Text('Длина: ${wagon.length}м, Высота: ${wagon.height}м'),
              if (wagon.maxLoadWeight != null)
                Text('Макс. вес: ${wagon.maxLoadWeight}т'),
              Row(
                children: [
                  Icon(
                    wagon.isOperational
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: wagon.isOperational ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    wagon.isOperational
                        ? 'Готов к эксплуатации'
                        : 'Не готов',
                    style: TextStyle(
                      color: wagon.isOperational ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (showActions && (onEdit != null || onDelete != null))
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: onEdit,
                        iconSize: 20,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: onDelete,
                        iconSize: 20,
                        color: Colors.red,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
