import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
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
  Set<int> _selectedWagonIds = {}; // ID выбранных вагонов для визуального выделения
  String? _composeError;
  double? _totalLength;
  bool _isSaving = false;

  // Форма для добавления нового требования
  int? _selectedWagonTypeId;
  int? _selectedFirmId;
  final _countController = TextEditingController(text: '1');
  final _loadCapacityMinController = TextEditingController();
  final _loadCapacityMaxController = TextEditingController();
  final _axleCountController = TextEditingController();
  final _wagonWeightMinController = TextEditingController();
  final _wagonWeightMaxController = TextEditingController();
  final _netWeightMinController = TextEditingController();
  final _netWeightMaxController = TextEditingController();
  final _bodyVolumeMinController = TextEditingController();
  final _bodyVolumeMaxController = TextEditingController();
  bool? _canRollFromHill;
  String? _conditionStatus;
  int? _selectedCisternTypeId;
  final _fillHeightMinController = TextEditingController();
  final _fillHeightMaxController = TextEditingController();
  
  // Параметры сопровождения состава (не для фильтрации)
  int? _selectedCompositionConductorsId;
  
  // Состояние раскрывающихся секций
  bool _showAdditionalParams = false;
  bool _showCisternParams = false;
  bool _showCompositionParams = false;

  @override
  void dispose() {
    _maxTotalLengthController.dispose();
    _totalWagonsCountController.dispose();
    _countController.dispose();
    _loadCapacityMinController.dispose();
    _loadCapacityMaxController.dispose();
    _axleCountController.dispose();
    _wagonWeightMinController.dispose();
    _wagonWeightMaxController.dispose();
    _netWeightMinController.dispose();
    _netWeightMaxController.dispose();
    _bodyVolumeMinController.dispose();
    _bodyVolumeMaxController.dispose();
    _fillHeightMinController.dispose();
    _fillHeightMaxController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final wagonProvider = Provider.of<WagonProvider>(context, listen: false);
    final referenceProvider =
        Provider.of<ReferenceProvider>(context, listen: false);
    wagonProvider.loadWagons(isOperational: true, excludeInConsist: true);
    referenceProvider.loadAllReferences();
  }

  void _addComposeItem() {
    if (_selectedWagonTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите тип вагона'),
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
      // Только параметры фильтрации (без conductors_id)
      final item = {
        'wagon_type': _selectedWagonTypeId,
        'count': count,
        if (_selectedFirmId != null) 'firm': _selectedFirmId,
        if (_loadCapacityMinController.text.isNotEmpty)
          'load_capacity_min': double.tryParse(_loadCapacityMinController.text),
        if (_loadCapacityMaxController.text.isNotEmpty)
          'load_capacity_max': double.tryParse(_loadCapacityMaxController.text),
        if (_axleCountController.text.isNotEmpty)
          'axle_count': int.tryParse(_axleCountController.text),
        if (_wagonWeightMinController.text.isNotEmpty)
          'wagon_weight_min': double.tryParse(_wagonWeightMinController.text),
        if (_wagonWeightMaxController.text.isNotEmpty)
          'wagon_weight_max': double.tryParse(_wagonWeightMaxController.text),
        if (_netWeightMinController.text.isNotEmpty)
          'net_weight_min': double.tryParse(_netWeightMinController.text),
        if (_netWeightMaxController.text.isNotEmpty)
          'net_weight_max': double.tryParse(_netWeightMaxController.text),
        if (_bodyVolumeMinController.text.isNotEmpty)
          'body_volume_min': double.tryParse(_bodyVolumeMinController.text),
        if (_bodyVolumeMaxController.text.isNotEmpty)
          'body_volume_max': double.tryParse(_bodyVolumeMaxController.text),
        if (_canRollFromHill != null) 'can_roll_from_hill': _canRollFromHill,
        if (_conditionStatus != null) 'condition_status': _conditionStatus,
        if (_selectedCisternTypeId != null) 'cistern_type_id': _selectedCisternTypeId,
        if (_fillHeightMinController.text.isNotEmpty)
          'fill_height_min': double.tryParse(_fillHeightMinController.text),
        if (_fillHeightMaxController.text.isNotEmpty)
          'fill_height_max': double.tryParse(_fillHeightMaxController.text),
      };
      
      _composeItems.add(item);

      // Сброс формы (только параметры фильтрации)
      _selectedWagonTypeId = null;
      _selectedFirmId = null;
      _countController.text = '1';
      _loadCapacityMinController.clear();
      _loadCapacityMaxController.clear();
      _axleCountController.clear();
      _wagonWeightMinController.clear();
      _wagonWeightMaxController.clear();
      _netWeightMinController.clear();
      _netWeightMaxController.clear();
      _bodyVolumeMinController.clear();
      _bodyVolumeMaxController.clear();
      _canRollFromHill = null;
      _conditionStatus = null;
      _selectedCisternTypeId = null;
      _fillHeightMinController.clear();
      _fillHeightMaxController.clear();
      _showAdditionalParams = false;
      _showCisternParams = false;
      // Параметры сопровождения НЕ сбрасываются - они для всего состава
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
      conductorsId: _selectedCompositionConductorsId,
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
        final errors = data['errors'] as List;
        final errorMessages = errors
            .map((e) => e['message'] ?? e.toString())
            .join('\n');
        
        // Проверяем, есть ли предложения альтернативных вагонов
        bool hasAlternatives = false;
        for (var error in errors) {
          if (error['alternatives'] != null && (error['alternatives'] as List).isNotEmpty) {
            hasAlternatives = true;
            break;
          }
        }
        
        if (hasAlternatives) {
          // Показываем диалог с предложениями
          _showAlternativesDialog(errors);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Состав подобран с предупреждениями:\n$errorMessages',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 7),
            ),
          );
        }
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

  Future<void> _showAlternativesDialog(List<dynamic> errors) async {
    // Находим ошибки с предложениями
    final errorsWithAlternatives = errors.where((e) => 
      e['alternatives'] != null && (e['alternatives'] as List).isNotEmpty
    ).toList();
    
    if (errorsWithAlternatives.isEmpty) return;
    
    // Показываем диалог для каждого типа вагонов с предложениями
    for (var error in errorsWithAlternatives) {
      final alternatives = (error['alternatives'] as List)
          .map((w) => Wagon.fromJson(w as Map<String, dynamic>))
          .toList();
      final wagonTypeName = error['wagon_type_name'] ?? 'неизвестный тип';
      final message = error['message'] ?? '';
      
      if (alternatives.isEmpty) continue;
      
      await _showWagonSelectionDialog(alternatives, wagonTypeName, message);
    }
  }
  
  Future<void> _showWagonSelectionDialog(
    List<Wagon> alternatives, 
    String wagonTypeName,
    String message,
  ) async {
    final selectedWagons = <Wagon>[];
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Предложения для типа "$wagonTypeName"'),
          content: SizedBox(
            width: 600,
            height: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: Colors.orange),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Доступные альтернативные вагоны:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: alternatives.length,
                    itemBuilder: (context, index) {
                      final wagon = alternatives[index];
                      final isSelected = selectedWagons.contains(wagon);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: CheckboxListTile(
                          title: Text('Вагон ${wagon.wagonNumber}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Путь: ${wagon.pathNumber}, Поз: ${wagon.position}'),
                              if (wagon.loadCapacity != null)
                                Text('Грузоподъёмность: ${wagon.loadCapacity} т'),
                              if (wagon.axleCount != null)
                                Text('Оси: ${wagon.axleCount}'),
                              if (wagon.wagonWeight != null)
                                Text('Масса вагона: ${wagon.wagonWeight} кг'),
                            ],
                          ),
                          value: isSelected,
                          onChanged: (value) {
                            setDialogState(() {
                              if (value == true) {
                                selectedWagons.add(wagon);
                              } else {
                                selectedWagons.remove(wagon);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Пропустить'),
            ),
            ElevatedButton(
              onPressed: selectedWagons.isEmpty
                  ? null
                  : () {
                      // Добавляем выбранные вагоны в состав
                      setState(() {
                        _composedWagons.addAll(selectedWagons);
                        _totalLength = (_totalLength ?? 0) + 
                            selectedWagons.fold(0.0, (sum, w) => sum + (w.length ?? 0));
                        // Обновляем список доступных вагонов
                        final wagonProvider = Provider.of<WagonProvider>(context, listen: false);
                        wagonProvider.loadWagons(isOperational: true, excludeInConsist: true);
                      });
                      Navigator.of(context).pop();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Добавлено ${selectedWagons.length} вагонов в состав',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
              child: const Text('Добавить в состав'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCompose() async {
    if (_composedWagons.isEmpty || _isSaving) return;

    // Показываем диалог подтверждения
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Сохранить состав?'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Вы хотите сохранить и показать информацию о составе который получился?',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Состав:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._composedWagons.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final wagon = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${index + 1}. Вагон ${wagon.wagonNumber} (Путь ${wagon.pathNumber}, Позиция ${wagon.position})',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Да'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final apiService = ApiService();
      final wagonIds = _composedWagons
          .where((w) => w.id != null)
          .map((w) => w.id!)
          .toList();

      if (wagonIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Нет вагонов для сохранения'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await apiService.saveCompose(
        wagonIds,
        conductorsId: _selectedCompositionConductorsId,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Сохраняем PDF файл
        final bytes = response.bodyBytes;
        final directory = Platform.isAndroid
            ? await getExternalStorageDirectory()
            : await getDownloadsDirectory();
        
        if (directory != null) {
          final file = File('${directory.path}/Состав_${DateTime.now().millisecondsSinceEpoch}.pdf');
          await file.writeAsBytes(bytes);
          
          // Открываем файл
          await OpenFile.open(file.path);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF файл сохранён: ${file.path}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF файл успешно сформирован и скачан'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения состава: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения состава: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final referenceProvider = Provider.of<ReferenceProvider>(context);
    final wagonProvider = Provider.of<WagonProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Создание состава',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade500],
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
      ),
      body: Row(
        children: [
          // Левая панель параметров подбора
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(right: BorderSide(color: Colors.blue.shade200, width: 2)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade300,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Параметры подбора',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Тип вагона *',
                      labelStyle: TextStyle(color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black87),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
                    items: referenceProvider.wagonTypes
                        .map(
                          (type) => DropdownMenuItem<int>(
                            value: type.id,
                            child: Text(
                              type.name,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                  // Фирма
                  DropdownButtonFormField<int>(
                    value: _selectedFirmId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Фирма (опционально)',
                      labelStyle: TextStyle(color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black87),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('Любая фирма'),
                      ),
                      ...referenceProvider.firms
                          .map(
                            (firm) => DropdownMenuItem<int>(
                              value: firm.id,
                              child: Text(
                                '${firm.name} (${firm.country})',
                                overflow: TextOverflow.ellipsis,
                              ),
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
                  // Грузоподъёмность (диапазон)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _loadCapacityMinController,
                          decoration: InputDecoration(
                            labelText: 'Грузоподъёмность от (т)',
                            labelStyle: TextStyle(color: Colors.blue.shade700),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            helperText: 'Мин.',
                            helperStyle: TextStyle(color: Colors.blue.shade600),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _loadCapacityMaxController,
                          decoration: InputDecoration(
                            labelText: 'Грузоподъёмность до (т)',
                            labelStyle: TextStyle(color: Colors.blue.shade700),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            helperText: 'Макс.',
                            helperStyle: TextStyle(color: Colors.blue.shade600),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Раскрывающаяся секция "Дополнительные параметры"
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      title: Text(
                        'Дополнительные параметры',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      leading: Icon(Icons.tune, color: Colors.blue.shade600),
                      iconColor: Colors.blue.shade600,
                      collapsedIconColor: Colors.blue.shade400,
                      initiallyExpanded: _showAdditionalParams,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _showAdditionalParams = expanded;
                        });
                      },
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Количество осей
                            TextFormField(
                              controller: _axleCountController,
                              decoration: InputDecoration(
                                labelText: 'Количество осей',
                                labelStyle: TextStyle(color: Colors.blue.shade700),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.blue.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.blue.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                helperText: 'Опционально',
                                helperStyle: TextStyle(color: Colors.blue.shade600),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.black87),
                            ),
                            const SizedBox(height: 16),
                            // Масса вагона (диапазон)
                            const Text(
                              'Масса вагона (кг)',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _wagonWeightMinController,
                                    decoration: InputDecoration(
                                      labelText: 'От (кг)',
                                      labelStyle: TextStyle(color: Colors.blue.shade700),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.blue.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.blue.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true),
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _wagonWeightMaxController,
                                    decoration: InputDecoration(
                                      labelText: 'До (кг)',
                                      labelStyle: TextStyle(color: Colors.blue.shade700),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.blue.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.blue.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true),
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Масса нетто (диапазон)
                            const Text(
                              'Масса нетто (кг)',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _netWeightMinController,
                                    decoration: InputDecoration(
                                      labelText: 'От (кг)',
                                      labelStyle: TextStyle(color: Colors.blue.shade700),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.blue.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.blue.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true),
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _netWeightMaxController,
                                    decoration: InputDecoration(
                                      labelText: 'До (кг)',
                                      labelStyle: TextStyle(color: Colors.blue.shade700),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.blue.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.blue.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true),
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Объём кузова (диапазон)
                            const Text(
                              'Объём кузова (м³)',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _bodyVolumeMinController,
                                    decoration: const InputDecoration(
                                      labelText: 'От (м³)',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _bodyVolumeMaxController,
                                    decoration: const InputDecoration(
                                      labelText: 'До (м³)',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Можно скатывать с горки
                            DropdownButtonFormField<bool>(
                              value: _canRollFromHill,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Можно скатывать с горки',
                                labelStyle: TextStyle(color: Colors.blue.shade700),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.blue.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.blue.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                helperText: 'Опционально',
                                helperStyle: TextStyle(color: Colors.blue.shade600),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.black87),
                              icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
                              items: const [
                                DropdownMenuItem<bool>(
                                  value: null,
                                  child: Text('Не важно'),
                                ),
                                DropdownMenuItem<bool>(
                                  value: true,
                                  child: Text('Да'),
                                ),
                                DropdownMenuItem<bool>(
                                  value: false,
                                  child: Text('Нет'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _canRollFromHill = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            // Техническое состояние
                            DropdownButtonFormField<String>(
                              value: _conditionStatus,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Техническое состояние',
                                labelStyle: TextStyle(color: Colors.blue.shade700),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.blue.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.blue.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                helperText: 'Опционально',
                                helperStyle: TextStyle(color: Colors.blue.shade600),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.black87),
                              icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
                              items: const [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Любое'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'OK',
                                  child: Text('Исправен'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'MINOR',
                                  child: Text('Незначительные неисправности'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'MAJOR',
                                  child: Text('Значительные неисправности'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'OUT_OF_SERVICE',
                                  child: Text('Не пригоден к эксплуатации'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _conditionStatus = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Раскрывающаяся секция "Параметры для цистерн"
                  if (_selectedWagonTypeId != null &&
                      referenceProvider.wagonTypes.any((wt) =>
                          wt.id == _selectedWagonTypeId &&
                          wt.name.toLowerCase().contains('цистерн')))
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade100,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ExpansionTile(
                        title: Text(
                          'Параметры для цистерн',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        leading: Icon(Icons.local_gas_station, color: Colors.blue.shade600),
                        iconColor: Colors.blue.shade600,
                        collapsedIconColor: Colors.blue.shade400,
                        initiallyExpanded: _showCisternParams,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            _showCisternParams = expanded;
                          });
                        },
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // Тип цистерны
                                DropdownButtonFormField<int>(
                                  value: _selectedCisternTypeId,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: 'Тип цистерны',
                                    labelStyle: TextStyle(color: Colors.blue.shade700),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.blue.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.blue.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    helperText: 'Опционально',
                                    helperStyle: TextStyle(color: Colors.blue.shade600),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(color: Colors.black87),
                                  icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
                                  items: [
                                    const DropdownMenuItem<int>(
                                      value: null,
                                      child: Text('Не указано'),
                                    ),
                                    ...referenceProvider.cisternTypes
                                        .map(
                                          (cisternType) => DropdownMenuItem<int>(
                                            value: cisternType.id,
                                            child: Text(
                                              cisternType.name,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCisternTypeId = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Высота налива (диапазон)
                                const Text(
                                  'Высота налива (см)',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _fillHeightMinController,
                                        decoration: InputDecoration(
                                          labelText: 'От (см)',
                                          labelStyle: TextStyle(color: Colors.blue.shade700),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(color: Colors.blue.shade300),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(color: Colors.blue.shade300),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(
                                            decimal: true),
                                        style: const TextStyle(color: Colors.black87),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _fillHeightMaxController,
                                        decoration: InputDecoration(
                                          labelText: 'До (см)',
                                          labelStyle: TextStyle(color: Colors.blue.shade700),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(color: Colors.blue.shade300),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(color: Colors.blue.shade300),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(
                                            decimal: true),
                                        style: const TextStyle(color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Кнопка добавить требование
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade300,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _addComposeItem,
                      icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                      label: const Text(
                        'Добавить требование',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Раскрывающаяся секция "Параметры сопровождения состава"
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      title: Text(
                        'Параметры сопровождения состава',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      subtitle: _selectedCompositionConductorsId != null
                          ? Builder(
                              builder: (context) {
                                final referenceProvider = Provider.of<ReferenceProvider>(context, listen: false);
                                return Text(
                                  'Проводники: ${referenceProvider.conductors.firstWhere((c) => c.id == _selectedCompositionConductorsId).name}',
                                  style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                                );
                              },
                            )
                          : Text(
                              'Люди, сопровождающие состав во время движения',
                              style: TextStyle(fontSize: 12, color: Colors.blue.shade500),
                            ),
                      leading: Icon(Icons.people, color: Colors.blue.shade600),
                      iconColor: Colors.blue.shade600,
                      collapsedIconColor: Colors.blue.shade400,
                      initiallyExpanded: _showCompositionParams,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _showCompositionParams = expanded;
                        });
                      },
                      children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Проводники состава
                            DropdownButtonFormField<int>(
                              value: _selectedCompositionConductorsId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Проводники состава',
                                labelStyle: TextStyle(color: Colors.blue.shade700),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.blue.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.blue.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                helperText: 'Люди, сопровождающие состав во время движения',
                                helperStyle: TextStyle(color: Colors.blue.shade600, fontSize: 11),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.black87),
                              icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('Не указано'),
                                ),
                                ...referenceProvider.conductors
                                    .map(
                                      (conductor) => DropdownMenuItem<int>(
                                        value: conductor.id,
                                        child: Text(
                                          conductor.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCompositionConductorsId = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Список добавленных требований
                  ...(_composeItems.isNotEmpty ? [
                    const Text(
                      'Требования к составу:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(_composeItems.length, (index) {
                      final item = _composeItems[index];
                      final wagonType = referenceProvider.wagonTypes
                          .firstWhere((t) => t.id == item['wagon_type']);
                      final firm = item['firm'] != null
                          ? referenceProvider.firms
                              .firstWhere((f) => f.id == item['firm'])
                          : null;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            wagonType.name,
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
                              if (item['load_capacity_min'] != null || item['load_capacity_max'] != null)
                                Text(
                                  'Грузоподъёмность: ${item['load_capacity_min'] ?? '?'} - ${item['load_capacity_max'] ?? '?'} т',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              if (item['axle_count'] != null)
                                Text(
                                  'Оси: ${item['axle_count']}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              if (item['wagon_weight_min'] != null || item['wagon_weight_max'] != null)
                                Text(
                                  'Масса вагона: ${item['wagon_weight_min'] ?? '?'} - ${item['wagon_weight_max'] ?? '?'} кг',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              if (item['net_weight_min'] != null || item['net_weight_max'] != null)
                                Text(
                                  'Масса нетто: ${item['net_weight_min'] ?? '?'} - ${item['net_weight_max'] ?? '?'} кг',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              if (item['body_volume_min'] != null || item['body_volume_max'] != null)
                                Text(
                                  'Объём кузова: ${item['body_volume_min'] ?? '?'} - ${item['body_volume_max'] ?? '?'} м³',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              if (item['can_roll_from_hill'] != null)
                                Text(
                                  'Скатывание с горки: ${item['can_roll_from_hill'] ? 'Да' : 'Нет'}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              if (item['condition_status'] != null)
                                Text(
                                  'Состояние: ${item['condition_status']}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              if (item['cistern_type_id'] != null)
                                Text(
                                  'Тип цистерны: ${referenceProvider.cisternTypes.firstWhere((c) => c.id == item['cistern_type_id']).name}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              if (item['fill_height_min'] != null || item['fill_height_max'] != null)
                                Text(
                                  'Высота налива: ${item['fill_height_min'] ?? '?'} - ${item['fill_height_max'] ?? '?'} см',
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
                  ] : []),
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
                    decoration: InputDecoration(
                      labelText: 'Макс. общая длина (м, опционально)',
                      labelStyle: TextStyle(color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      helperText: 'Максимальная общая длина всего состава',
                      helperStyle: TextStyle(color: Colors.blue.shade600),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  // Кнопка подобрать состав
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isComposing 
                            ? [Colors.grey.shade400, Colors.grey.shade300]
                            : [Colors.blue.shade700, Colors.blue.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _isComposing ? null : [
                        BoxShadow(
                          color: Colors.blue.shade300,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
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
                        ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveCompose,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: const Text('Сохранить вагон'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Список вагонов в составе
                Expanded(
                  child: _isComposing
                      ? const Center(child: CircularProgressIndicator())
                      : DragTarget<Wagon>(
                          onAccept: (wagon) {
                            setState(() {
                              if (!_composedWagons.any((w) => w.id == wagon.id)) {
                                _composedWagons.add(wagon);
                                _selectedWagonIds.add(wagon.id ?? 0);
                                _totalLength = _composedWagons
                                    .fold<double>(0.0, (sum, w) => sum + (w.length ?? 0.0));
                              }
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              decoration: BoxDecoration(
                                color: candidateData.isNotEmpty
                                    ? Colors.blue.shade50
                                    : Colors.transparent,
                                border: candidateData.isNotEmpty
                                    ? Border.all(color: Colors.blue, width: 2)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _composedWagons.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.train,
                                            size: 64,
                                            color: candidateData.isNotEmpty
                                                ? Colors.blue
                                                : Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            candidateData.isNotEmpty
                                                ? 'Отпустите вагон здесь'
                                                : (_composeError ??
                                                    'Укажите параметры и нажмите "Подобрать состав"\nили перетащите вагоны из правой панели'),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: candidateData.isNotEmpty
                                                  ? Colors.blue
                                                  : Colors.grey.shade600,
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
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 0.85, // Уменьшено для компактности
                                      ),
                                      itemCount: _composedWagons.length,
                                      itemBuilder: (context, index) {
                                        final wagon = _composedWagons[index];
                                        return DragTarget<Wagon>(
                                          onAccept: (draggedWagon) {
                                            setState(() {
                                              final draggedIndex = _composedWagons
                                                  .indexWhere((w) => w.id == draggedWagon.id);
                                              if (draggedIndex != -1 && draggedIndex != index) {
                                                // Удаляем вагон из старой позиции
                                                _composedWagons.removeAt(draggedIndex);
                                                // Вставляем в новую позицию
                                                final newIndex = draggedIndex < index
                                                    ? index - 1
                                                    : index;
                                                _composedWagons.insert(newIndex, draggedWagon);
                                                // Пересчитываем длину
                                                _totalLength = _composedWagons
                                                    .fold<double>(0.0, (sum, w) => sum + (w.length ?? 0.0));
                                              }
                                            });
                                          },
                                          builder: (context, candidateData, rejectedData) {
                                            return Draggable<Wagon>(
                                              key: ValueKey('wagon_${wagon.id}_$index'),
                                              data: wagon,
                                              feedback: Material(
                                                elevation: 8,
                                                child: Container(
                                                  width: 200,
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade100,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(
                                                      color: Colors.blue,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        wagon.wagonNumber,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      if (wagon.wagonType != null)
                                                        Text(
                                                          wagon.wagonType!.name,
                                                          style: const TextStyle(fontSize: 12),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              childWhenDragging: Opacity(
                                                opacity: 0.3,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: candidateData.isNotEmpty
                                                        ? Border.all(
                                                            color: Colors.green,
                                                            width: 2,
                                                          )
                                                        : null,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: WagonCard(wagon: wagon),
                                                ),
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: candidateData.isNotEmpty
                                                      ? Border.all(
                                                          color: Colors.green,
                                                          width: 2,
                                                        )
                                                      : null,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    WagonCard(
                                                      wagon: wagon,
                                                      onTap: () {
                                                        setState(() {
                                                          _composedWagons.removeAt(index);
                                                          _selectedWagonIds.remove(wagon.id ?? 0);
                                                          _totalLength = _composedWagons
                                                              .fold<double>(
                                                                  0.0, (sum, w) => sum + (w.length ?? 0.0));
                                                        });
                                                      },
                                                    ),
                                                    Positioned(
                                                      top: 4,
                                                      left: 4,
                                                      child: Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: BoxDecoration(
                                                          color: Colors.blue.shade700,
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Text(
                                                          '${index + 1}',
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 4,
                                                      right: 4,
                                                      child: Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: const BoxDecoration(
                                                          color: Colors.blue,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.drag_handle,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
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
                      : wagonProvider.availableWagons.isEmpty
                          ? const Center(
                              child: Text('Нет доступных вагонов'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: wagonProvider.availableWagons.length,
                              itemBuilder: (context, index) {
                                final wagon = wagonProvider.availableWagons[index];
                                final isSelected = _selectedWagonIds.contains(wagon.id);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  child: Draggable<Wagon>(
                                    data: wagon,
                                    feedback: Material(
                                      elevation: 8,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 250,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 2,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              wagon.wagonNumber,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            if (wagon.wagonType != null)
                                              Text(
                                                wagon.wagonType!.name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.3,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: WagonCard(wagon: wagon),
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Stack(
                                        children: [
                                          WagonCard(wagon: wagon),
                                          if (isSelected)
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.blue,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          Positioned(
                                            bottom: 4,
                                            right: 4,
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade700,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Icon(
                                                Icons.drag_handle,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
