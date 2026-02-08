import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wagon_provider.dart';
import '../models/wagon.dart';
import 'dispatcher_input_screen.dart';

class DispatcherCountScreen extends StatefulWidget {
  const DispatcherCountScreen({super.key});

  @override
  State<DispatcherCountScreen> createState() => _DispatcherCountScreenState();
}

class _DispatcherCountScreenState extends State<DispatcherCountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _countController = TextEditingController();

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_formKey.currentState!.validate()) {
      final count = int.parse(_countController.text);
      if (count > 0) {
        final wagonProvider =
            Provider.of<WagonProvider>(context, listen: false);
        wagonProvider.clearWagons();

        // Создаём список пустых вагонов
        // В Django минимальные значения length/height = 0.1,
        // поэтому ставим безопасные значения по умолчанию
        final now = DateTime.now();
        for (int i = 0; i < count; i++) {
          wagonProvider.addWagon(
            Wagon(
              wagonNumber: '',
              pathNumber: 1,
              position: i + 1,
              length: 10.0,
              height: 4.0,
              arrivedAt: now,
              conditionStatus: 'OK',
              isOperational: true,
            ),
          );
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DispatcherInputScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ввод количества вагонов'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Введите количество вагонов',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _countController,
                  decoration: const InputDecoration(
                    labelText: 'Количество',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите количество';
                    }
                    final count = int.tryParse(value);
                    if (count == null || count <= 0) {
                      return 'Количество должно быть больше 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleConfirm,
                    child: const Text('Подтвердить'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
