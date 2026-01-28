import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/wagon_provider.dart';
import '../providers/reference_provider.dart';
import '../models/wagon.dart';
import 'dispatcher_review_screen.dart';

class DispatcherInputScreen extends StatefulWidget {
  const DispatcherInputScreen({super.key});

  @override
  State<DispatcherInputScreen> createState() => _DispatcherInputScreenState();
}

class _DispatcherInputScreenState extends State<DispatcherInputScreen> {
  int _currentIndex = 0;
  final Map<int, Map<String, dynamic>> _formData = {};

  static const Map<String, String> _conditionStatusLabels = {
    'OK': 'Исправен',
    'MINOR': 'Незначительные неисправности',
    'MAJOR': 'Значительные неисправности',
    'OUT_OF_SERVICE': 'Не пригоден к эксплуатации',
  };

  @override
  void initState() {
    super.initState();
    final referenceProvider =
        Provider.of<ReferenceProvider>(context, listen: false);
    referenceProvider.loadAllReferences();
    // Загружаем данные первого вагона при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFormData(0);
    });
  }

  void _saveCurrentForm() {
    final wagonProvider = Provider.of<WagonProvider>(context, listen: false);
    final wagons = wagonProvider.wagons;
    if (_currentIndex < 0 || _currentIndex >= wagons.length) return;

    final currentWagon = wagons[_currentIndex];
    final data = _formData[_currentIndex] ?? {};

    final updatedWagon = Wagon(
      id: currentWagon.id,
      wagonNumber: (data['wagonNumber'] as String?) ?? currentWagon.wagonNumber,
      pathNumber: (data['pathNumber'] as int?) ?? currentWagon.pathNumber,
      position: (data['position'] as int?) ?? currentWagon.position,
      length: (data['length'] as double?) ?? currentWagon.length,
      height: (data['height'] as double?) ?? currentWagon.height,
      maxLoadWeight:
          (data['maxLoadWeight'] as double?) ?? currentWagon.maxLoadWeight,
      arrivedAt: (data['arrivedAt'] as DateTime?) ?? currentWagon.arrivedAt,
      conditionStatus:
          (data['conditionStatus'] as String?) ?? currentWagon.conditionStatus,
      isOperational:
          (data['isOperational'] as bool?) ?? currentWagon.isOperational,
      comment: (data['comment'] as String?) ?? currentWagon.comment,
      wagonTypeId: (data['wagonTypeId'] as int?) ?? currentWagon.wagonTypeId,
      cargoTypeIds: (data['cargoTypeIds'] as List<int>?) ??
          currentWagon.cargoTypeIds,
      firmId: (data['firmId'] as int?) ?? currentWagon.firmId,
      climateConditionIds:
          (data['climateConditionIds'] as List<int>?) ??
              currentWagon.climateConditionIds,
      // поля, которые читает backend, но здесь не редактируются напрямую
      wagonType: currentWagon.wagonType,
      cargoTypes: currentWagon.cargoTypes,
      firm: currentWagon.firm,
      climateConditions: currentWagon.climateConditions,
      createdBy: currentWagon.createdBy,
      createdAt: currentWagon.createdAt,
    );

    wagonProvider.updateWagon(_currentIndex, updatedWagon);
  }

  void _loadFormData(int index) {
    final wagonProvider = Provider.of<WagonProvider>(context, listen: false);
    if (index < wagonProvider.wagons.length) {
      final wagon = wagonProvider.wagons[index];
      _formData[index] = {
        'wagonNumber': wagon.wagonNumber,
        'wagonTypeId': wagon.wagonTypeId ?? wagon.wagonType?.id,
        'cargoTypeIds': wagon.cargoTypeIds ?? wagon.cargoTypes?.map((e) => e.id).toList() ?? [],
        'firmId': wagon.firmId ?? wagon.firm?.id,
        'pathNumber': wagon.pathNumber,
        'position': wagon.position,
        'length': wagon.length,
        'height': wagon.height,
        'maxLoadWeight': wagon.maxLoadWeight,
        'climateConditionIds': wagon.climateConditionIds ?? wagon.climateConditions?.map((e) => e.id).toList() ?? [],
        'arrivedAt': wagon.arrivedAt,
        'conditionStatus': wagon.conditionStatus,
        'isOperational': wagon.isOperational,
        'comment': wagon.comment,
      };
    }
  }

  void _nextWagon() {
    _saveCurrentForm();
    final wagonProvider = Provider.of<WagonProvider>(context, listen: false);
    if (_currentIndex < wagonProvider.wagons.length - 1) {
      setState(() {
        _currentIndex++;
        _loadFormData(_currentIndex);
      });
    } else {
      // Переход на экран обзора
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DispatcherReviewScreen(),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final wagonProvider = Provider.of<WagonProvider>(context);
    final referenceProvider = Provider.of<ReferenceProvider>(context);
    final wagons = wagonProvider.wagons;

    // Пока справочники не загрузились – показываем индикатор или ошибку
    if (referenceProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (referenceProvider.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ввод данных вагонов'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Ошибка загрузки справочников: ${referenceProvider.error}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (wagons.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Нет вагонов для ввода')),
      );
    }

    final formData = _formData[_currentIndex] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text('Вагон ${_currentIndex + 1} из ${wagons.length}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _nextWagon,
            child: Text(_currentIndex < wagons.length - 1 ? 'Далее' : 'Обзор'),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: ValueKey('wagonNumber_$_currentIndex'),
                    initialValue: formData['wagonNumber']?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Номер вагона',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _formData[_currentIndex] ??= {};
                        _formData[_currentIndex]!['wagonNumber'] = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: ValueKey('wagonTypeId_$_currentIndex'),
                    value: formData['wagonTypeId'] as int?,
                    decoration: InputDecoration(
                      labelText: 'Тип вагона',
                      border: const OutlineInputBorder(),
                      hintText: referenceProvider.wagonTypes.isEmpty
                          ? 'Загрузка... (${referenceProvider.wagonTypes.length})'
                          : 'Выберите тип вагона (${referenceProvider.wagonTypes.length} доступно)',
                    ),
                    items: referenceProvider.wagonTypes
                        .map(
                          (type) => DropdownMenuItem<int>(
                            value: type.id,
                            child: Text(type.name),
                          ),
                        )
                        .toList(),
                    onChanged: referenceProvider.wagonTypes.isEmpty
                        ? null
                        : (value) {
                            setState(() {
                              _formData[_currentIndex] ??= {};
                              _formData[_currentIndex]!['wagonTypeId'] = value;
                            });
                          },
                  ),
                  if (referenceProvider.wagonTypes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Типы вагонов загружаются... (0 элементов)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Типы грузов (множественный выбор)
                  Text(
                    'Типы грузов',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  referenceProvider.cargoTypes.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Типы грузов загружаются...',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          children: referenceProvider.cargoTypes.map((cargo) {
                            final selectedIds =
                                (formData['cargoTypeIds'] as List<int>?) ??
                                    <int>[];
                            final isSelected = selectedIds.contains(cargo.id);
                            return FilterChip(
                              label: Text(cargo.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _formData[_currentIndex] ??= {};
                                  final list = List<int>.from(
                                      selectedIds); // копия списка
                                  if (selected) {
                                    if (!list.contains(cargo.id)) {
                                      list.add(cargo.id);
                                    }
                                  } else {
                                    list.remove(cargo.id);
                                  }
                                  _formData[_currentIndex]!['cargoTypeIds'] =
                                      list;
                                });
                              },
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: ValueKey('firmId_$_currentIndex'),
                    value: formData['firmId'] as int?,
                    decoration: InputDecoration(
                      labelText: 'Фирма',
                      border: const OutlineInputBorder(),
                      hintText: referenceProvider.firms.isEmpty
                          ? 'Загрузка... (${referenceProvider.firms.length})'
                          : 'Выберите фирму (${referenceProvider.firms.length} доступно)',
                    ),
                    items: referenceProvider.firms
                        .map(
                          (firm) => DropdownMenuItem<int>(
                            value: firm.id,
                            child: Text('${firm.name} (${firm.country})'),
                          ),
                        )
                        .toList(),
                    onChanged: referenceProvider.firms.isEmpty
                        ? null
                        : (value) {
                            setState(() {
                              _formData[_currentIndex] ??= {};
                              _formData[_currentIndex]!['firmId'] = value;
                            });
                          },
                  ),
                  if (referenceProvider.firms.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Фирмы загружаются... (0 элементов)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: ValueKey('pathNumber_$_currentIndex'),
                          initialValue:
                              formData['pathNumber']?.toString() ?? '1',
                          decoration: const InputDecoration(
                            labelText: 'Номер пути',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _formData[_currentIndex] ??= {};
                              _formData[_currentIndex]!['pathNumber'] =
                                  int.tryParse(value) ?? 1;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          key: ValueKey('position_$_currentIndex'),
                          initialValue:
                              formData['position']?.toString() ??
                                  (_currentIndex + 1).toString(),
                          decoration: const InputDecoration(
                            labelText: 'Позиция',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _formData[_currentIndex] ??= {};
                              _formData[_currentIndex]!['position'] =
                                  int.tryParse(value) ?? (_currentIndex + 1);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: ValueKey('length_$_currentIndex'),
                          initialValue:
                              formData['length']?.toString() ?? '10',
                          decoration: const InputDecoration(
                            labelText: 'Длина (м)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          onChanged: (value) {
                            setState(() {
                              _formData[_currentIndex] ??= {};
                              _formData[_currentIndex]!['length'] =
                                  double.tryParse(value) ?? 10.0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          key: ValueKey('height_$_currentIndex'),
                          initialValue:
                              formData['height']?.toString() ?? '4',
                          decoration: const InputDecoration(
                            labelText: 'Высота (м)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          onChanged: (value) {
                            setState(() {
                              _formData[_currentIndex] ??= {};
                              _formData[_currentIndex]!['height'] =
                                  double.tryParse(value) ?? 4.0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: ValueKey('maxLoadWeight_$_currentIndex'),
                    initialValue:
                        formData['maxLoadWeight']?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Макс. вес груза (т)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      setState(() {
                        _formData[_currentIndex] ??= {};
                        _formData[_currentIndex]!['maxLoadWeight'] =
                            double.tryParse(value);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Климатические условия (множественный выбор)
                  Text(
                    'Климатические условия',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  referenceProvider.climateConditions.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Климатические условия загружаются...',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          children: referenceProvider.climateConditions
                              .map((condition) {
                            final selectedIds = (formData['climateConditionIds']
                                    as List<int>?) ??
                                <int>[];
                            final isSelected =
                                selectedIds.contains(condition.id);
                            return FilterChip(
                              label: Text(condition.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _formData[_currentIndex] ??= {};
                                  final list = List<int>.from(
                                      selectedIds); // копия списка
                                  if (selected) {
                                    if (!list.contains(condition.id)) {
                                      list.add(condition.id);
                                    }
                                  } else {
                                    list.remove(condition.id);
                                  }
                                  _formData[_currentIndex]![
                                      'climateConditionIds'] = list;
                                });
                              },
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 16),
                  // Дата и время прибытия
                  Builder(
                    builder: (context) {
                      final arrivedAt =
                          (formData['arrivedAt'] as DateTime?) ??
                              DateTime.now();
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Дата и время прибытия'),
                        subtitle: Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(arrivedAt),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: arrivedAt,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date == null) return;
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(arrivedAt),
                          );
                          if (time == null) return;
                          final combined = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                          setState(() {
                            _formData[_currentIndex] ??= {};
                            _formData[_currentIndex]!['arrivedAt'] = combined;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey('conditionStatus_$_currentIndex'),
                    value: (formData['conditionStatus'] as String?) ?? 'OK',
                    decoration: const InputDecoration(
                      labelText: 'Техническое состояние',
                      border: OutlineInputBorder(),
                    ),
                    items: _conditionStatusLabels.entries
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _formData[_currentIndex] ??= {};
                        _formData[_currentIndex]!['conditionStatus'] = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Готов к эксплуатации'),
                    value: (formData['isOperational'] as bool?) ?? true,
                    onChanged: (value) {
                      setState(() {
                        _formData[_currentIndex] ??= {};
                        _formData[_currentIndex]!['isOperational'] = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: ValueKey('comment_$_currentIndex'),
                    initialValue: formData['comment']?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Комментарий',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      setState(() {
                        _formData[_currentIndex] ??= {};
                        _formData[_currentIndex]!['comment'] = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Ходбар с карточками вагонов
          Container(
            width: 200,
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey.shade300)),
            ),
            child: ListView.builder(
              itemCount: wagons.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Сохраняем данные текущего вагона перед переключением
                    _saveCurrentForm();
                    setState(() {
                      _currentIndex = index;
                      _loadFormData(index);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: index == _currentIndex
                          ? Colors.blue.shade100
                          : Colors.grey.shade100,
                      border: Border.all(
                        color: index == _currentIndex
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Вагон ${index + 1}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
