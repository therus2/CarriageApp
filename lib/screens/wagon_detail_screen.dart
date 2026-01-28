import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wagon.dart';

class WagonDetailScreen extends StatelessWidget {
  final Wagon wagon;

  const WagonDetailScreen({super.key, required this.wagon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Детали вагона ${wagon.wagonNumber}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 20),
            _buildInfoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    Color statusColor = wagon.conditionStatus == 'OK' ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: statusColor),
          const SizedBox(width: 10),
          Text(
            "Состояние: ${wagon.conditionStatus}",
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Spacer(),
          if (wagon.isOperational)
            const Chip(label: Text("В эксплуатации"), backgroundColor: Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _row("Номер вагона", wagon.wagonNumber),
            _row("Тип вагона", wagon.wagonTypeName ?? "ID: ${wagon.wagonType}"),
            _row("Собственник", wagon.firmName ?? "ID: ${wagon.firm}"),
            const Divider(),
            _row("Путь", wagon.pathNumber.toString()),
            _row("Позиция", wagon.position.toString()),
            const Divider(),
            _row("Длина", "${wagon.length} м"),
            _row("Высота", "${wagon.height} м"),
            _row("Грузоподъемность", "${wagon.maxLoadWeight} т"),
            const Divider(),
            _row("Прибыл", DateFormat('dd.MM.yyyy HH:mm').format(wagon.arrivedAt)),
            if (wagon.comment != null && wagon.comment!.isNotEmpty)
              _row("Комментарий", wagon.comment!),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}