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
        return 'Незначит.';
      case 'MAJOR':
        return 'Значит.';
      case 'OUT_OF_SERVICE':
        return 'Не пригоден';
      default:
        return wagon.conditionStatus.length > 10
            ? wagon.conditionStatus.substring(0, 10)
            : wagon.conditionStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок с номером и статусом
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      wagon.wagonNumber.isNotEmpty
                          ? wagon.wagonNumber
                          : 'Вагон',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Компактная информация
              if (wagon.wagonType != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    'Тип: ${wagon.wagonType!.name}',
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              if (wagon.cargoTypes != null && wagon.cargoTypes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    'Грузы: ${wagon.cargoTypes!.map((e) => e.name).join(", ")}',
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  'Путь: ${wagon.pathNumber}, Поз: ${wagon.position}',
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  'Д: ${wagon.length.toStringAsFixed(1)}м, В: ${wagon.height.toStringAsFixed(1)}м',
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (wagon.maxLoadWeight != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    'Вес: ${wagon.maxLoadWeight!.toStringAsFixed(1)}т',
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              const SizedBox(height: 4),
              // Статус готовности
              Row(
                children: [
                  Icon(
                    wagon.isOperational
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: wagon.isOperational ? Colors.green : Colors.red,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      wagon.isOperational
                          ? 'Готов'
                          : 'Не готов',
                      style: TextStyle(
                        color: wagon.isOperational ? Colors.green : Colors.red,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              if (showActions && (onEdit != null || onDelete != null))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: onEdit,
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: onDelete,
                          iconSize: 18,
                          color: Colors.red,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
