import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wagon_provider.dart';
import '../models/wagon.dart';

class WagonSelectionScreen extends StatelessWidget {
  final int? replacingId; // ID вагона, который мы хотим заменить

  const WagonSelectionScreen({super.key, this.replacingId});

  @override
  Widget build(BuildContext context) {
    final wagonProv = context.watch<WagonProvider>();

    // Фильтруем: только исправные и только те, которых НЕТ в текущем составе
    final available = wagonProv.allWagons.where((w) {
      bool alreadyInComposition = wagonProv.composedWagons.any((cw) => cw.id == w.id);
      return w.isOperational && !alreadyInComposition;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(replacingId != null ? "Замена вагона" : "Добавить в состав")),
      body: available.isEmpty
          ? const Center(child: Text("Нет доступных свободных вагонов"))
          : ListView.separated(
        itemCount: available.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final w = available[index];
          return ListTile(
            title: Text("Вагон №${w.wagonNumber}"),
            subtitle: Text("${w.wagonTypeName} | Путь ${w.pathNumber} | ${w.length}м"),
            trailing: ElevatedButton(
              onPressed: () {
                if (replacingId != null) {
                  wagonProv.replaceWagon(replacingId!, w);
                } else {
                  wagonProv.addWagonToComposition(w);
                }
                Navigator.pop(context);
              },
              child: const Text("ВЫБРАТЬ"),
            ),
          );
        },
      ),
    );
  }
}