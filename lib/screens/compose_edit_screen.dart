import 'package:flutter/material.dart';
import '../models/wagon.dart';
import '../models/editable_wagon_data.dart';
import '../providers/reference_provider.dart';
import 'package:provider/provider.dart';

class ComposeEditScreen extends StatefulWidget {
  final List<Wagon> wagons;
  final int? conductorsId;

  const ComposeEditScreen({
    super.key,
    required this.wagons,
    this.conductorsId,
  });

  @override
  State<ComposeEditScreen> createState() => _ComposeEditScreenState();
}

class _WagonControllers {
  final TextEditingController pathNumber;
  final TextEditingController wagonPosition;
  final TextEditingController wagonNumber;
  final TextEditingController wagonType;
  final TextEditingController loadCapacity;
  final TextEditingController axleCount;
  final TextEditingController netWeight;
  final TextEditingController wagonWeight;
  final TextEditingController grossWeight;
  final TextEditingController conductors;
  final TextEditingController bodyVolume;
  final TextEditingController fillHeight;
  final TextEditingController cisternType;

  _WagonControllers({
    required this.pathNumber,
    required this.wagonPosition,
    required this.wagonNumber,
    required this.wagonType,
    required this.loadCapacity,
    required this.axleCount,
    required this.netWeight,
    required this.wagonWeight,
    required this.grossWeight,
    required this.conductors,
    required this.bodyVolume,
    required this.fillHeight,
    required this.cisternType,
  });

  void dispose() {
    pathNumber.dispose();
    wagonPosition.dispose();
    wagonNumber.dispose();
    wagonType.dispose();
    loadCapacity.dispose();
    axleCount.dispose();
    netWeight.dispose();
    wagonWeight.dispose();
    grossWeight.dispose();
    conductors.dispose();
    bodyVolume.dispose();
    fillHeight.dispose();
    cisternType.dispose();
  }
}

class _ComposeEditScreenState extends State<ComposeEditScreen> {
  late List<EditableWagonData> _editedWagons;
  int? _selectedWagonIndex;
  final Map<int, _WagonControllers> _controllers = {};

  @override
  void initState() {
    super.initState();
    _editedWagons = widget.wagons
        .asMap()
        .entries
        .map((e) => EditableWagonData.fromWagon(e.value, e.key + 1))
        .toList();
    _selectedWagonIndex = _editedWagons.isNotEmpty ? 0 : null;
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var i = 0; i < _editedWagons.length; i++) {
      final wagon = _editedWagons[i];
      _controllers[i] = _WagonControllers(
        pathNumber: TextEditingController(text: wagon.pathNumber.toString()),
        wagonPosition: TextEditingController(text: wagon.wagonPosition.toString()),
        wagonNumber: TextEditingController(text: wagon.wagonNumber),
        wagonType: TextEditingController(text: wagon.wagonType),
        loadCapacity: TextEditingController(text: wagon.loadCapacity?.toString() ?? ''),
        axleCount: TextEditingController(text: wagon.axleCount?.toString() ?? ''),
        netWeight: TextEditingController(text: wagon.netWeight?.toString() ?? ''),
        wagonWeight: TextEditingController(text: wagon.wagonWeight?.toString() ?? ''),
        grossWeight: TextEditingController(text: wagon.grossWeight?.toString() ?? ''),
        conductors: TextEditingController(text: wagon.conductors ?? ''),
        bodyVolume: TextEditingController(text: wagon.bodyVolume?.toString() ?? ''),
        fillHeight: TextEditingController(text: wagon.fillHeight?.toString() ?? ''),
        cisternType: TextEditingController(text: wagon.cisternType ?? ''),
      );
    }
  }

  @override
  void dispose() {
    for (var controllers in _controllers.values) {
      controllers.dispose();
    }
    super.dispose();
  }

  void _updateWagonFromControllers(int index) {
    final controllers = _controllers[index]!;
    final wagon = _editedWagons[index];
    
    setState(() {
      _editedWagons[index] = EditableWagonData(
        id: wagon.id,
        position: wagon.position,
        pathNumber: int.tryParse(controllers.pathNumber.text) ?? wagon.pathNumber,
        wagonPosition: int.tryParse(controllers.wagonPosition.text) ?? wagon.wagonPosition,
        wagonNumber: controllers.wagonNumber.text.isNotEmpty 
            ? controllers.wagonNumber.text 
            : wagon.wagonNumber,
        wagonType: controllers.wagonType.text.isNotEmpty 
            ? controllers.wagonType.text 
            : wagon.wagonType,
        loadCapacity: double.tryParse(controllers.loadCapacity.text),
        axleCount: int.tryParse(controllers.axleCount.text),
        netWeight: double.tryParse(controllers.netWeight.text),
        wagonWeight: double.tryParse(controllers.wagonWeight.text),
        grossWeight: double.tryParse(controllers.grossWeight.text),
        conductors: controllers.conductors.text.isNotEmpty 
            ? controllers.conductors.text 
            : null,
        bodyVolume: double.tryParse(controllers.bodyVolume.text),
        fillHeight: double.tryParse(controllers.fillHeight.text),
        cisternType: controllers.cisternType.text.isNotEmpty 
            ? controllers.cisternType.text 
            : null,
      );
    });
  }

  void _removeWagon(int index) {
    setState(() {
      // Удаляем контроллеры
      _controllers[index]!.dispose();
      _controllers.remove(index);
      _editedWagons.removeAt(index);
      
      // Перенумеровываем позиции и переиндексируем контроллеры
      final newControllers = <int, _WagonControllers>{};
      for (var i = 0; i < _editedWagons.length; i++) {
        final oldIndex = i >= index ? i + 1 : i;
        if (_controllers.containsKey(oldIndex)) {
          newControllers[i] = _controllers[oldIndex]!;
        }
        _editedWagons[i] = EditableWagonData(
          id: _editedWagons[i].id,
          position: i + 1,
          pathNumber: _editedWagons[i].pathNumber,
          wagonPosition: _editedWagons[i].wagonPosition,
          wagonNumber: _editedWagons[i].wagonNumber,
          wagonType: _editedWagons[i].wagonType,
          loadCapacity: _editedWagons[i].loadCapacity,
          axleCount: _editedWagons[i].axleCount,
          netWeight: _editedWagons[i].netWeight,
          wagonWeight: _editedWagons[i].wagonWeight,
          grossWeight: _editedWagons[i].grossWeight,
          conductors: _editedWagons[i].conductors,
          bodyVolume: _editedWagons[i].bodyVolume,
          fillHeight: _editedWagons[i].fillHeight,
          cisternType: _editedWagons[i].cisternType,
        );
      }
      _controllers.clear();
      _controllers.addAll(newControllers);
      
      if (_selectedWagonIndex != null && _selectedWagonIndex! >= _editedWagons.length) {
        _selectedWagonIndex = _editedWagons.length > 0 ? _editedWagons.length - 1 : null;
      }
    });
  }

  void _moveWagon(int fromIndex, int toIndex) {
    setState(() {
      if (fromIndex < toIndex) {
        toIndex -= 1;
      }
      final wagon = _editedWagons.removeAt(fromIndex);
      final controllers = _controllers.remove(fromIndex);
      
      _editedWagons.insert(toIndex, EditableWagonData(
        id: wagon.id,
        position: toIndex + 1,
        pathNumber: wagon.pathNumber,
        wagonPosition: wagon.wagonPosition,
        wagonNumber: wagon.wagonNumber,
        wagonType: wagon.wagonType,
        loadCapacity: wagon.loadCapacity,
        axleCount: wagon.axleCount,
        netWeight: wagon.netWeight,
        wagonWeight: wagon.wagonWeight,
        grossWeight: wagon.grossWeight,
        conductors: wagon.conductors,
        bodyVolume: wagon.bodyVolume,
        fillHeight: wagon.fillHeight,
        cisternType: wagon.cisternType,
      ));
      
      // Обновляем позиции всех вагонов
      for (var i = 0; i < _editedWagons.length; i++) {
        _editedWagons[i] = EditableWagonData(
          id: _editedWagons[i].id,
          position: i + 1,
          pathNumber: _editedWagons[i].pathNumber,
          wagonPosition: _editedWagons[i].wagonPosition,
          wagonNumber: _editedWagons[i].wagonNumber,
          wagonType: _editedWagons[i].wagonType,
          loadCapacity: _editedWagons[i].loadCapacity,
          axleCount: _editedWagons[i].axleCount,
          netWeight: _editedWagons[i].netWeight,
          wagonWeight: _editedWagons[i].wagonWeight,
          grossWeight: _editedWagons[i].grossWeight,
          conductors: _editedWagons[i].conductors,
          bodyVolume: _editedWagons[i].bodyVolume,
          fillHeight: _editedWagons[i].fillHeight,
          cisternType: _editedWagons[i].cisternType,
        );
      }
      
      // Перемещаем контроллеры
      final newControllers = <int, _WagonControllers>{};
      for (var i = 0; i < _editedWagons.length; i++) {
        if (i == toIndex) {
          newControllers[i] = controllers!;
        } else if (i < fromIndex && i < toIndex) {
          newControllers[i] = _controllers[i]!;
        } else if (i > fromIndex && i > toIndex) {
          newControllers[i] = _controllers[i]!;
        } else if (i < fromIndex && i >= toIndex) {
          newControllers[i] = _controllers[i + 1]!;
        } else if (i > fromIndex && i <= toIndex) {
          newControllers[i] = _controllers[i - 1]!;
        }
      }
      _controllers.clear();
      _controllers.addAll(newControllers);
      
      if (_selectedWagonIndex == fromIndex) {
        _selectedWagonIndex = toIndex;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final referenceProvider = Provider.of<ReferenceProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Редактирование состава для PDF',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade700, Colors.orange.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              // Сохраняем изменения из всех контроллеров
              for (var i = 0; i < _editedWagons.length; i++) {
                _updateWagonFromControllers(i);
              }
              Navigator.pop(context, _editedWagons);
            },
            icon: const Icon(Icons.save),
            label: const Text('Сохранить'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Левая панель со списком вагонов
          Container(
            width: 250,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border(bottom: BorderSide(color: Colors.orange.shade200)),
                  ),
                  child: Text(
                    'Вагонов: ${_editedWagons.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
                Expanded(
                  child: _editedWagons.isEmpty
                      ? const Center(
                          child: Text(
                            'Состав пуст',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _editedWagons.length,
                          onReorder: (oldIndex, newIndex) {
                            _moveWagon(oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final wagon = _editedWagons[index];
                            final isSelected = _selectedWagonIndex == index;
                            return Card(
                              key: ValueKey('wagon_${wagon.id}_$index'),
                              margin: const EdgeInsets.only(bottom: 8),
                              color: isSelected ? Colors.orange.shade100 : null,
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade700,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${wagon.position}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  wagon.wagonNumber,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  '${wagon.pathNumber}:${wagon.wagonPosition}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                  onPressed: () => _removeWagon(index),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedWagonIndex = index;
                                  });
                                },
                                dense: true,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          // Правая панель с формой редактирования
          Expanded(
            child: _selectedWagonIndex == null || _selectedWagonIndex! >= _editedWagons.length
                ? const Center(
                    child: Text(
                      'Выберите вагон для редактирования',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildEditForm(_selectedWagonIndex!),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(int index) {
    final wagon = _editedWagons[index];
    final controllers = _controllers[index]!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Text(
            'Редактирование вагона №${wagon.position}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade900,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Внимание: Изменения применяются только к PDF файлу и не сохраняются в базу данных!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Основная информация
        _buildSectionTitle('Основная информация'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controllers.pathNumber,
                decoration: const InputDecoration(
                  labelText: 'Номер пути',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateWagonFromControllers(index),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controllers.wagonPosition,
                decoration: const InputDecoration(
                  labelText: 'Позиция на пути',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateWagonFromControllers(index),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controllers.wagonNumber,
          decoration: const InputDecoration(
            labelText: '№ вагона',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _updateWagonFromControllers(index),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controllers.wagonType,
          decoration: const InputDecoration(
            labelText: 'Тип вагона',
            border: OutlineInputBorder(),
            helperText: 'Например: Полувагон, Цистерна и т.д.',
          ),
          onChanged: (_) => _updateWagonFromControllers(index),
        ),
        const SizedBox(height: 24),
        // Весовые характеристики
        _buildSectionTitle('Весовые характеристики'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controllers.loadCapacity,
                decoration: const InputDecoration(
                  labelText: 'Грузоподъёмность (т)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _updateWagonFromControllers(index),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controllers.axleCount,
                decoration: const InputDecoration(
                  labelText: 'Количество осей',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateWagonFromControllers(index),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controllers.netWeight,
                decoration: const InputDecoration(
                  labelText: 'Масса нетто (кг)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _updateWagonFromControllers(index),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controllers.wagonWeight,
                decoration: const InputDecoration(
                  labelText: 'Масса вагона (кг)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _updateWagonFromControllers(index),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controllers.grossWeight,
          decoration: const InputDecoration(
            labelText: 'Масса брутто (кг)',
            border: OutlineInputBorder(),
            helperText: 'Автоматически рассчитывается как масса нетто + масса вагона',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _updateWagonFromControllers(index),
        ),
        const SizedBox(height: 24),
        // Дополнительная информация
        _buildSectionTitle('Дополнительная информация'),
        const SizedBox(height: 8),
        TextFormField(
          controller: controllers.conductors,
          decoration: const InputDecoration(
            labelText: 'Проводники',
            border: OutlineInputBorder(),
            helperText: 'Например: Охранники, Полиция и т.д.',
          ),
          onChanged: (_) => _updateWagonFromControllers(index),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controllers.bodyVolume,
                decoration: const InputDecoration(
                  labelText: 'Объём кузова (м³)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _updateWagonFromControllers(index),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controllers.fillHeight,
                decoration: const InputDecoration(
                  labelText: 'Высота налива (см)',
                  border: OutlineInputBorder(),
                  helperText: 'Только для цистерн',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _updateWagonFromControllers(index),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controllers.cisternType,
          decoration: const InputDecoration(
            labelText: 'Тип цистерны',
            border: OutlineInputBorder(),
            helperText: 'Только для цистерн',
          ),
          onChanged: (_) => _updateWagonFromControllers(index),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.orange.shade700,
        ),
      ),
    );
  }
}
