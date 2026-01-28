import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wagon_provider.dart';
import '../widgets/wagon_card.dart';
import 'main_menu_screen.dart';

class DispatcherReviewScreen extends StatelessWidget {
  const DispatcherReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<WagonProvider>(
          builder: (context, wagonProvider, _) {
            return Text('Обзор вагонов (${wagonProvider.wagons.length})');
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<WagonProvider>(
        builder: (context, wagonProvider, _) {
          if (wagonProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (wagonProvider.wagons.isEmpty) {
            return const Center(child: Text('Нет вагонов для обзора'));
          }

          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: wagonProvider.wagons.length,
                  itemBuilder: (context, index) {
                    return WagonCard(
                      wagon: wagonProvider.wagons[index],
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: wagonProvider.isLoading
                        ? null
                        : () async {
                            final result = await wagonProvider.saveWagons();
                            if (!context.mounted) return;

                            if (result['success'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Вагоны успешно сохранены'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              wagonProvider.clearWagons();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainMenuScreen(),
                                ),
                                (route) => false,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result['error']?.toString() ??
                                        'Ошибка сохранения',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    child: wagonProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Сохранить'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
