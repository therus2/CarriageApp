import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wagon_provider.dart';
import '../models/wagon.dart';

class WagonListScreen extends StatefulWidget {
  const WagonListScreen({super.key});

  @override
  State<WagonListScreen> createState() => _WagonListScreenState();
}

class _WagonListScreenState extends State<WagonListScreen> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<WagonProvider>().fetchAllWagons());
  }

  @override
  Widget build(BuildContext context) {
    final wagonProv = context.watch<WagonProvider>();

    // Фильтрация списка по номеру вагона
    final filteredWagons = wagonProv.allWagons.where((w) {
      return w.wagonNumber.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Реестр вагонов"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Поиск по номеру...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),
      ),
      body: wagonProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: filteredWagons.length,
        itemBuilder: (context, index) {
          final w = filteredWagons[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(
                Icons.train,
                color: w.isOperational ? Colors.teal : Colors.red,
              ),
              title: Text("Вагон №${w.wagonNumber}"),
              subtitle: Text("Путь: ${w.pathNumber} | Поз: ${w.position} | ${w.wagonTypeName ?? 'Тип н/д'}"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${w.length} м", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(w.conditionStatus, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                ],
              ),
              onTap: () => _showWagonDetails(context, w),
            ),
          );
        },
      ),
    );
  }

  void _showWagonDetails(BuildContext context, Wagon w) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Детали вагона ${w.wagonNumber}"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow("Собственник:", w.firmName ?? "Не указан"),
              _detailRow("Груз:", w.cargoNames ?? "Порожний"),
              _detailRow("Длина/Высота:", "${w.length}м / ${w.height}м"),
              _detailRow("Г/П:", "${w.maxLoadWeight} т"),
              _detailRow("Прибыл:", w.arrivedAt.toString().substring(0, 16)),
              if (w.comment != null) _detailRow("Комментарий:", w.comment!),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ОК"))],
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(width: 8),
      Expanded(child: Text(value)),
    ]),
  );
}