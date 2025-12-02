import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/habit_provider.dart';
import '../../providers/habit_log_provider.dart';
import '../../core/utils/stats_calculator.dart';
import '../../core/utils/date_utils.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  DateTimeRange _range = DateTimeRange(
    start: AppDateUtils.daysAgo(6),
    end: DateTime.now(),
  );

  Future<void> _pickRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _range,
    );
    if (result != null) setState(() => _range = result);
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitProvider);
    final logs = ref.watch(habitLogProvider);

    final rate = StatsCalculator.completionRate(habits, logs, _range.start, _range.end);
    final totalXP = StatsCalculator.totalXP(logs, _range.start, _range.end);
    final counts = StatsCalculator.completionCountsByHabit(logs, _range.start, _range.end);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickRange,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Período: ${AppDateUtils.formatDate(_range.start)} - ${AppDateUtils.formatDate(_range.end)}'),
            const SizedBox(height: 16),
            StatCard(
              icon: Icons.check_circle,
              title: 'Taxa de conclusão',
              value: '${(rate * 100).toStringAsFixed(0)}%'
            ),
            const SizedBox(height: 12),
            StatCard(
              icon: Icons.star,
              title: 'XP no período',
              value: totalXP.toString(),
            ),
            const SizedBox(height: 24),
            Text('Concluídos por hábito', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...counts.entries.map((e) {
              String name = 'Hábito ${e.key}';
              for (final h in habits) {
                if (h.id == e.key) {
                  name = h.title;
                  break;
                }
              }
              return ListTile(
                leading: const Icon(Icons.task_alt),
                title: Text(name),
                trailing: Text('${e.value}'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const StatCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
