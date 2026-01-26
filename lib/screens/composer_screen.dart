import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/wagon.dart';
import '../widgets/wagon_card.dart';

class ComposerScreen extends StatefulWidget {
  final ApiService api;

  ComposerScreen({required this.api});

  @override
  State<ComposerScreen> createState() => _ComposerScreenState();
}

class _ComposerScreenState extends State<ComposerScreen> {
  List<Wagon> allWagons = [];
  List<Wagon> optimalWagons = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadWagons();
  }

  Future<void> loadWagons() async {
    final wagons = await widget.api.getWagons();
    final optimal = await widget.api.getOptimalComposition(wagons);

    setState(() {
      allWagons = wagons;
      optimalWagons = optimal;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Составитель')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          /// 🔹 Оптимальный состав
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Оптимальный состав',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: optimalWagons.length,
                      itemBuilder: (_, i) =>
                          WagonCard(wagon: optimalWagons[i]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Divider(),

          /// 🔹 Все вагоны
          Expanded(
            flex: 1,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: allWagons
                  .map((w) => Container(
                width: 160,
                child: WagonCard(wagon: w),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
