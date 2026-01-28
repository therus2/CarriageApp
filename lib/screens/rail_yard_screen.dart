import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wagon_provider.dart';

class RailYardScreen extends StatefulWidget {
  const RailYardScreen({super.key});

  @override
  State<RailYardScreen> createState() => _RailYardScreenState();
}

class _RailYardScreenState extends State<RailYardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<WagonProvider>().fetchAllWagons());
  }

  @override
  Widget build(BuildContext context) {
    final wagonProv = context.watch<WagonProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Схема путей")),
      body: wagonProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // 10 путей по ТЗ
        itemBuilder: (context, index) {
          int pathNum = index + 1;
          final wagonsOnPath = wagonProv.allWagons.where((w) => w.pathNumber == pathNum).toList();

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[800],
                    shape: BoxShape.circle,
                  ),
                  child: Text("$pathNum", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey[400]!, width: 2)),
                    ),
                    child: wagonsOnPath.isEmpty
                        ? const Center(child: Text("Путь свободен", style: TextStyle(color: Colors.grey, fontSize: 12)))
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: wagonsOnPath.length,
                      itemBuilder: (ctx, i) => Container(
                        width: 25,
                        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                        decoration: BoxDecoration(
                          color: wagonsOnPath[i].conditionStatus == 'OK' ? Colors.teal : Colors.redAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text("${wagonsOnPath.length} ваг.", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}