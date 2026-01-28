import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wagon_provider.dart';
import '../providers/data_provider.dart';
import '../models/wagon.dart';
import 'wagon_selection_screen.dart';

class ComposerScreen extends StatefulWidget {
  const ComposerScreen({super.key});

  @override
  State<ComposerScreen> createState() => _ComposerScreenState();
}

class _ComposerScreenState extends State<ComposerScreen> {
  int _selectedTypeId = 1;
  int _count = 5;
  double _maxLen = 600.0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DataProvider>().loadAllDictionaries();
      context.read<WagonProvider>().fetchAllWagons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wagonProv = context.watch<WagonProvider>();
    final dataProv = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("АРМ Составителя"), elevation: 2),
      body: Row(
        children: [
          // Левая панель параметров
          _buildSidebar(wagonProv, dataProv),

          // Основная рабочая зона
          Expanded(
            child: Column(
              children: [
                _buildStatusHeader(wagonProv),
                const Divider(height: 1),
                Expanded(child: _buildTrainVisualizer(wagonProv)),
                _buildActionHint(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(WagonProvider wProv, DataProvider dProv) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Параметры состава", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          DropdownButtonFormField<int>(
            value: _selectedTypeId,
            decoration: const InputDecoration(labelText: "Тип вагона", border: OutlineInputBorder()),
            items: dProv.wagonTypes.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
            onChanged: (v) => setState(() => _selectedTypeId = v!),
          ),
          const SizedBox(height: 15),
          TextField(
            decoration: const InputDecoration(labelText: "Количество", border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            onChanged: (v) => _count = int.tryParse(v) ?? 0,
          ),
          const SizedBox(height: 15),
          TextField(
            decoration: const InputDecoration(labelText: "Лимит длины (м)", border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            onChanged: (v) => _maxLen = double.tryParse(v) ?? 600.0,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => wProv.composeTrain(typeId: _selectedTypeId, cargoId: 1, count: _count, maxLength: _maxLen),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF263238),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("ПОДОБРАТЬ СОСТАВ"),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WagonSelectionScreen())),
            icon: const Icon(Icons.add),
            label: const Text("Добавить вручную"),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(WagonProvider prov) {
    bool isOver = prov.totalLength > _maxLen;
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoBlock("Вагонов", "${prov.composedWagons.length}"),
          _infoBlock("Длина", "${prov.totalLength.toStringAsFixed(1)} / $_maxLen м",
              color: isOver ? Colors.red : Colors.green),
          Icon(isOver ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: isOver ? Colors.red : Colors.green, size: 30),
        ],
      ),
    );
  }

  Widget _buildTrainVisualizer(WagonProvider prov) {
    if (prov.isLoading) return const Center(child: CircularProgressIndicator());
    if (prov.composedWagons.isEmpty) return const Center(child: Text("Состав еще не сформирован"));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: prov.composedWagons.map((w) => _wagonBox(w)).toList(),
      ),
    );
  }

  Widget _wagonBox(Wagon wagon) {
    return GestureDetector(
      onTap: () => _showWagonMenu(wagon),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("#${wagon.wagonNumber}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          Container(
            width: wagon.length * 10, // Масштабирование
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.blueGrey[600],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: const Icon(Icons.settings_input_component, color: Colors.white24, size: 20),
          ),
          Text("${wagon.length}м", style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showWagonMenu(Wagon w) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text("Заменить вагон"),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => WagonSelectionScreen(replacingId: w.id)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text("Удалить из состава"),
            onTap: () {
              context.read<WagonProvider>().removeWagon(w.id!);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  Widget _infoBlock(String label, String value, {Color color = Colors.black}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildActionHint() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: const Text(
        "Нажмите на вагон для замены или удаления",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontStyle: FontStyle.italic, // Исправлено здесь
        ),
      ),
    );
  }
}