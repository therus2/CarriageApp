import 'package:flutter/material.dart';

class WagonStatsWidget extends StatelessWidget {
  final int count;
  final double currentLength;
  final double maxLength;

  const WagonStatsWidget({
    super.key,
    required this.count,
    required this.currentLength,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    bool isOver = currentLength > maxLength;
    double progress = (currentLength / maxLength).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Вагонов: $count", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "${currentLength.toStringAsFixed(1)} / $maxLength м",
                style: TextStyle(
                  color: isOver ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: isOver ? Colors.red : Colors.green,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          if (isOver)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text("ВНИМАНИЕ: Превышена допустимая длина!",
                  style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}