import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wagon_provider.dart';
import '../providers/reference_provider.dart';
import '../widgets/wagon_card.dart';
import '../models/wagon.dart';
import '../services/api_service.dart';

class ComposerScreen extends StatefulWidget {
  const ComposerScreen({super.key});

  @override
  State<ComposerScreen> createState() => _ComposerScreenState();
}

class _ComposerScreenState extends State<ComposerScreen> {
  final List<Map<String, dynamic>> _composeItems = [];
  final _maxTotalLengthController = TextEditingController();
  final _totalWagonsCountController = TextEditingController();
  bool _isComposing = false;
  List<Wagon> _composedWagons = [];
  String? _composeError;
  double? _totalLength;

  // Форма для добавления нового требования
  int? _selectedWagonTypeId;
  int? _selectedCargoTypeId;
  int? _selectedFirmId;
  final _countController = TextEditingController(text: '1');
  final List<int> _selectedClimateConditionIds = [];
  final _maxLoadWeightController = TextEditingController();

  @override
  void dispose() {
    _maxTotalLengthController.dispose();
    _totalWagonsCountController.dispose();
    _countController.dispose();
    _maxLoadWeightController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final wagonProvider = Provider.of<WagonProvider>(context, listen: false);
    final referenceProvider =
        Provider.of<ReferenceProvider>(context, listen: false);
    wagonProvider.loadWagons(isOperational: true);
    referenceProvider.loadAllReferences();
  }

  void _addComposeItem() {
    if (_selectedWagonTypeId == null || _selectedCargoTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите тип вагона и тип груза'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final count = int.tryParse(_countController.text);
    if (count == null || count <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите корректное количество (больше 0)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _composeItems.add({
        'wagon_type': _selectedWagonTypeId,
        'cargo_type': _selectedCargoTypeId,
        'count': count,
        'climate_conditions': List<int>.from(_selectedClimateConditionIds),
        if (_selectedFirmId != null) 'firm': _selectedFirmId,
        if (_maxLoadWeightController.text.isNotEmpty)
          'max_load_weight': double.tryParse(_maxLoadWeightController.text),
      });

      // Сброс формы
      _selectedWagonTypeId = null;
      _selectedCargoTypeId = null;
      _selectedFirmId = null;
      _countController.text = '1';
      _selectedClimateConditionIds.clear();
      _maxLoadWeightController.clear();
    });
  }

  void _removeComposeItem(int index) {
    setState(() {
      _composeItems.removeAt(index);
    });
  }

  Future<void> _composeTrain() async {
    if (_composeItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Добавьте хотя бы одно требование к составу'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final totalWagonsCount = int.tryParse(_totalWagonsCountController.text);
    if (totalWagonsCount == null || totalWagonsCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Укажите общее количество вагонов в составе'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isComposing = true;
      _composeError = null;
      _composedWagons = [];
    });

    final apiService = ApiService();
    final maxTotalLength = _maxTotalLengthController.text.isNotEmpty
        ? double.tryParse(_maxTotalLengthController.text)
        : null;

    final result = await apiService.composeTrain(
      _composeItems,
      maxTotalLength: maxTotalLength,
      totalWagonsCount: totalWagonsCount,
    );

    if (!mounted) return;

    setState(() {
      _isComposing = false;
    });

    if (result['success'] == true) {
      final data = result['data'];
      final wagonsData = data['wagons'] as List<dynamic>? ?? [];
      setState(() {
        _composedWagons = wagonsData
            .map((w) => Wagon.fromJson(w as Map<String, dynamic>))
            .toList();
        _totalLength = data['total_length']?.toDouble();
        _composeError = null;
      });

      if (data['errors'] != null && (data['errors'] as List).isNotEmpty) {
        final errorMessages = (data['errors'] as List)
            .map((e) => e['message'] ?? e.toString())
            .join('\n');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Состав подобран с предупреждениями:\n$errorMessages',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 7),
          ),
        );
      } else {
        final requestedCount = data['requested_count'];
        final actualCount = _composedWagons.length;
        final message = requestedCount != null && requestedCount != actualCount
            ? 'Подобрано $actualCount из $requestedCount вагонов'
            : 'Состав успешно подобран! Вагонов: $actualCount';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      setState(() {
        _composeError = result['error']?.toString() ?? 'Ошибка подбора состава';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_composeError!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final referenceProvider = Provider.of<ReferenceProvider>(context);
    final wagonProvider = Provider.of<WagonProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание состава'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          // Левая панель параметров подбора
          Container(
            width: 350,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Параметры подбора',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // ГЛАВНЫЙ ПАРАМЕТР: Количество вагонов в составе
                  TextFormField(
                    controller: _totalWagonsCountController,
                    decoration: InputDecoration(
                      labelText: 'Количество вагонов в составе *',
                      hintText: 'Общее количество вагонов',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.blue.shade50,
                      prefixIcon: const Icon(Icons.numbers, color: Colors.blue),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Детальные требования к вагонам:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  // Тип вагона
                  DropdownButtonFormField<int>(
                    value: _selectedWagonTypeId,
                    decoration: const InputDecoration(
                      labelText: 'Тип вагона *',
                      border: OutlineInputBorder(),
                    ),
                    items: referenceProvider.wagonTypes
                        .map(
                          (type) => DropdownMenuItem<int>(
                            value: type.id,
                            child: Text(type.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWagonTypeId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Тип груза
                  DropdownButtonFormField<int>(
                    value: _selectedCargoTypeId,
                    decoration: const InputDecoration(
                      labelText: 'Тип груза *',
                      border: OutlineInputBorder(),
                    ),
                    items: referenceProvider.cargoTypes
                        .map(
                          (cargo) => DropdownMenuItem<int>(
                            value: cargo.id,
                            child: Text(cargo.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCargoTypeId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Фирма
                  DropdownButtonFormField<int>(
                    value: _selectedFirmId,
                    decoration: const InputDecoration(
                      labelText: 'Фирма (опционально)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('Любая фирма'),
                      ),
                      ...referenceProvider.firms
                          .map(
                            (firm) => DropdownMenuItem<int>(
                              value: firm.id,
                              child: Text('${firm.name} (${firm.country})'),
                            ),
                          )
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFirmId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Количество для этого требования
                  TextFormField(
                    controller: _countController,
                    decoration: const InputDecoration(
                      labelText: 'Количество вагонов этого типа *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Климатические условия
                  const Text(
                    'Климатические условия (опционально)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: referenceProvider.climateConditions.map((condition) {
                      final isSelected =
                          _selectedClimateConditionIds.contains(condition.id);
                      return FilterChip(
                        label: Text(condition.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedClimateConditionIds.add(condition.id);
                            } else {
                              _selectedClimateConditionIds.remove(condition.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Макс. вес груза
                  TextFormField(
                    controller: _maxLoadWeightController,
                    decoration: const InputDecoration(
                      labelText: 'Макс. вес груза (т, опционально)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  // Кнопка добавить требование
                  ElevatedButton.icon(
                    onPressed: _addComposeItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить требование'),
                  ),
                  const SizedBox(height: 24),
                  // Список добавленных требований
                  if (_composeItems.isNotEmpty) ...[
                    const Text(
                      'Требования к составу:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(_composeItems.length, (index) {
                      final item = _composeItems[index];
                      final wagonType = referenceProvider.wagonTypes
                          .firstWhere((t) => t.id == item['wagon_type']);
                      final cargoType = referenceProvider.cargoTypes
                          .firstWhere((c) => c.id == item['cargo_type']);
                      final firm = item['firm'] != null
                          ? referenceProvider.firms
                              .firstWhere((f) => f.id == item['firm'])
                          : null;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            '${wagonType.name} / ${cargoType.name}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Количество: ${item['count']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (firm != null)
                                Text(
                                  'Фирма: ${firm.name}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              if (item['max_load_weight'] != null)
                                Text(
                                  'Макс. вес: ${item['max_load_weight']} т',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () => _removeComposeItem(index),
                            color: Colors.red,
                          ),
                          dense: true,
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Ограничения состава:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  // Макс. общая длина
                  TextFormField(
                    controller: _maxTotalLengthController,
                    decoration: const InputDecoration(
                      labelText: 'Макс. общая длина (м, опционально)',
                      border: OutlineInputBorder(),
                      helperText: 'Максимальная общая длина всего состава',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 24),
                  // Кнопка подобрать состав
                  ElevatedButton(
                    onPressed: _isComposing ? null : _composeTrain,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isComposing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Подобрать состав',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          // Центральная область с оптимальным составом
          Expanded(
            child: Column(
              children: [
                // Заголовок
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Оптимальный состав',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (_composedWagons.isNotEmpty) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Вагонов: ${_composedWagons.length}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_totalLength != null)
                              Text(
                                'Длина: ${_totalLength!.toStringAsFixed(1)} м',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Список вагонов в составе
                Expanded(
                  child: _isComposing
                      ? const Center(child: CircularProgressIndicator())
                      : _composedWagons.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.train,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _composeError ??
                                        'Укажите параметры и нажмите "Подобрать состав"',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.2,
                              ),
                              itemCount: _composedWagons.length,
                              itemBuilder: (context, index) {
                                return WagonCard(
                                  wagon: _composedWagons[index],
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          // Правая панель с доступными вагонами
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
                  child: wagonProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : wagonProvider.wagons.isEmpty
                          ? const Center(
                              child: Text('Нет доступных вагонов'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: wagonProvider.wagons.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  child: WagonCard(
                                    wagon: wagonProvider.wagons[index],
                                  ),
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
