import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../providers/wagon_provider.dart';
import '../models/wagon.dart';

class DispatcherScreen extends StatefulWidget {
  const DispatcherScreen({super.key});

  @override
  State<DispatcherScreen> createState() => _DispatcherScreenState();
}

class _DispatcherScreenState extends State<DispatcherScreen> {
  final _formKey = GlobalKey<FormState>();

  // Исходные данные для нового вагона
  late String _wagonNumber;
  int? _selectedType;
  int? _selectedFirm;
  int _path = 1;
  int _pos = 1;
  double _len = 14.0;
  double _height = 3.8;
  double _maxLoad = 68.0;

  @override
  void initState() {
    super.initState();
    // Загружаем справочники, если они еще не загружены
    Future.microtask(() => context.read<DataProvider>().loadAllDictionaries());
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final newWagon = Wagon(
      wagonNumber: _wagonNumber,
      wagonType: _selectedType!,
      cargoTypes: [], // В данной форме без груза при прибытии
      firm: _selectedFirm!,
      pathNumber: _path,
      position: _pos,
      length: _len,
      height: _height,
      maxLoadWeight: _maxLoad,
      conditionStatus: 'OK',
      isOperational: true,
      arrivedAt: DateTime.now(),
    );

    final success = await context.read<WagonProvider>().createWagon(newWagon);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Вагон успешно зарегистрирован"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Регистрация прибытия")),
      body: data.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "Номер вагона", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v!.length < 8 ? "Минимум 8 знаков" : null,
              onSaved: (v) => _wagonNumber = v!,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: "Тип вагона", border: OutlineInputBorder()),
              items: data.wagonTypes.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
              onChanged: (v) => setState(() => _selectedType = v),
              validator: (v) => v == null ? "Выберите тип" : null,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: "Собственник", border: OutlineInputBorder()),
              items: data.firms.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
              onChanged: (v) => setState(() => _selectedFirm = v),
              validator: (v) => v == null ? "Выберите фирму" : null,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _numField("Путь", (v) => _path = int.parse(v))),
                const SizedBox(width: 10),
                Expanded(child: _numField("Позиция", (v) => _pos = int.parse(v))),
              ],
            ),
            const SizedBox(height: 15),
            _numField("Длина (м)", (v) => _len = double.parse(v), initial: "14.0"),
            const SizedBox(height: 15),
            _numField("Грузоподъемность (т)", (v) => _maxLoad = double.parse(v), initial: "68.0"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55)
              ),
              child: const Text("СОХРАНИТЬ В БАЗУ", style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }

  Widget _numField(String label, Function(String) onSave, {String initial = "1"}) {
    return TextFormField(
      initialValue: initial,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType: TextInputType.number,
      onSaved: (v) => onSave(v!),
    );
  }
}