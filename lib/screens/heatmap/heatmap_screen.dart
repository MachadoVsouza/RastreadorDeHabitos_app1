import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../../providers/habit_log_provider.dart';
import '../../core/utils/heatmap_calculator.dart';

class HeatmapScreen extends ConsumerWidget {
  const HeatmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(habitLogProvider);
    final heatmapData = HeatmapCalculator.generateHeatmapData(logs);
    final currentStreak = HeatmapCalculator.getCurrentStreak(heatmapData);
    final longestStreak = HeatmapCalculator.getLongestStreak(heatmapData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heatmap de Atividades'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.local_fire_department,
                    label: 'Sequência atual',
                    value: '$currentStreak dias',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.emoji_events,
                    label: 'Melhor sequência',
                    value: '$longestStreak dias',
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Heatmap
            Text(
              'Histórico de conclusões',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: HeatMap(
                  datasets: heatmapData,
                  colorMode: ColorMode.color,
                  defaultColor: Colors.grey[200]!,
                  textColor: Colors.black87,
                  showColorTip: false,
                  showText: true,
                  scrollable: true,
                  size: 32,
                  fontSize: 11,
                  colorsets: const {
                    1: Color(0xFFD4EDDA),
                    2: Color(0xFFA8D8B9),
                    3: Color(0xFF7BC96F),
                    4: Color(0xFF4CAF50),
                    5: Color(0xFF2E7D32),
                  },
                  onClick: (value) {
                    final count = heatmapData[value] ?? 0;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          count > 0
                              ? 'Você completou $count hábito${count > 1 ? 's' : ''} neste dia!'
                              : 'Nenhum hábito completado neste dia.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Legend
            Text(
              'Legenda',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _LegendItem(color: Colors.grey[200]!, label: 'Nenhum'),
                const _LegendItem(color: Color(0xFFD4EDDA), label: '1'),
                const _LegendItem(color: Color(0xFFA8D8B9), label: '2'),
                const _LegendItem(color: Color(0xFF7BC96F), label: '3'),
                const _LegendItem(color: Color(0xFF4CAF50), label: '4'),
                const _LegendItem(color: Color(0xFF2E7D32), label: '5+'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
