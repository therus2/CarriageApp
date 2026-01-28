import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wagon_provider.dart';
import '../providers/reference_provider.dart';
import '../widgets/wagon_card.dart';

class ComposerScreen extends StatefulWidget {
  const ComposerScreen({super.key});

  @override
  State<ComposerScreen> createState() => _ComposerScreenState();
}

class _ComposerScreenState extends State<ComposerScreen> {
  List<Map<String, dynamic>> _selectedWagons = [];

  @override
  void initState() {
    super.initState();
    final wagonProvider = Provider.of<WagonProvider>(context, listen: false);
    final referenceProvider =
        Provider.of<ReferenceProvider>(context, listen: false);
    wagonProvider.loadWagons(isOperational: true);
    referenceProvider.loadAllReferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание состава'),
      ),
      body: Row(
        children: [
          // Левая панель параметров
          Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Параметры подбора',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  // Здесь будут поля для параметров подбора
                  Text('Форма параметров подбора'),
                ],
              ),
            ),
          ),
          // Центральная область
          Expanded(
            child: Column(
              children: [
                // Верхнее меню с карточками состава
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: _selectedWagons.isEmpty
                      ? const Center(child: Text('Состав не подобран'))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          itemCount: _selectedWagons.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Вагон ${index + 1}'),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedWagons.removeAt(index);
                                          });
                                        },
                                        child: const Text('Заменить'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Основная область
                Expanded(
                  child: _selectedWagons.isEmpty
                      ? const Center(
                          child: Text('Укажите параметры и нажмите "Подобрать состав"'),
                        )
                      : const Center(
                          child: Text('Визуализация состава'),
                        ),
                ),
              ],
            ),
          ),
          // Нижняя область с доступными вагонами
          Container(
            width: 400,
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Доступные вагоны',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Consumer<WagonProvider>(
                    builder: (context, wagonProvider, _) {
                      if (wagonProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                        itemCount: wagonProvider.wagons.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: WagonCard(
                              wagon: wagonProvider.wagons[index],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
