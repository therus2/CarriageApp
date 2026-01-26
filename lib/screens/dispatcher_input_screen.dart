import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/wagon.dart';
import 'dispatcher_review_screen.dart';

class DispatcherInputScreen extends StatefulWidget {
  final ApiService api;

  DispatcherInputScreen({required this.api});

  @override
  State<DispatcherInputScreen> createState() => _DispatcherInputScreenState();
}

class _DispatcherInputScreenState extends State<DispatcherInputScreen> {
  int? totalCount;
  int currentIndex = 0;
  List<Wagon> wagons = [];

  final numberCtrl = TextEditingController();
  final cargoCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final pathCtrl = TextEditingController();

  void nextWagon() {
    wagons.add(Wagon(
      id: 0,
      number: numberCtrl.text,
      cargoType: cargoCtrl.text,
      category: categoryCtrl.text,
      path: pathCtrl.text,
    ));

    numberCtrl.clear();
    cargoCtrl.clear();
    categoryCtrl.clear();
    pathCtrl.clear();

    setState(() {
      currentIndex++;
    });

    if (currentIndex == totalCount) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DispatcherReviewScreen(
            api: widget.api,
            wagons: wagons,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (totalCount == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Количество вагонов')),
        body: Center(
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Количество'),
                  onChanged: (v) => totalCount = int.tryParse(v),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: Text('Подтвердить'),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Вагон ${currentIndex + 1} из $totalCount'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: numberCtrl, decoration: InputDecoration(labelText: 'Номер вагона')),
            TextField(controller: cargoCtrl, decoration: InputDecoration(labelText: 'Тип груза')),
            TextField(controller: categoryCtrl, decoration: InputDecoration(labelText: 'Категория')),
            TextField(controller: pathCtrl, decoration: InputDecoration(labelText: 'Путь')),
            Spacer(),
            ElevatedButton(
              onPressed: nextWagon,
              child: Text('Далее'),
            )
          ],
        ),
      ),
    );
  }
}
