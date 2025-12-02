import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../providers/habit_log_provider.dart';
import '../core/utils/xp_calculator.dart';
import '../core/utils/dialog_utils.dart';

class HabitTile extends ConsumerWidget {
  final Habit habit;
  final DateTime date;
  final VoidCallback? onTap;

  const HabitTile({
    super.key,
    required this.habit,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(habitLogProvider);
    final logNotifier = ref.read(habitLogProvider.notifier);
    final isCompleted = logNotifier.isHabitCompleted(habit.id, date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: isCompleted,
          onChanged: (_) => _toggleHabitCompletion(context, ref),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          habit.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: habit.description != null && habit.description!.isNotEmpty
            ? Text(
                habit.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isCompleted ? Colors.grey : null,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (habit.time != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      habit.time!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: onTap,
              ),
            ],
          ],
        ),
        onTap: () => _toggleHabitCompletion(context, ref),
      ),
    );
  }

  Future<void> _toggleHabitCompletion(
      BuildContext context, WidgetRef ref) async {
    final logNotifier = ref.read(habitLogProvider.notifier);
    final isCompleted = logNotifier.isHabitCompleted(habit.id, date);

    if (isCompleted) {
      await logNotifier.markHabitIncomplete(habit.id, date);
      if (context.mounted) {
        DialogUtils.showInfoSnackbar(
          context,
          'Hábito desmarcado',
        );
      }
    } else {
      final xp = await logNotifier.markHabitComplete(habit.id, date);
      if (context.mounted) {
        final message = XPCalculator.getMotivationalMessage(xp);
        DialogUtils.showSuccessSnackbar(context, message);
      }
    }
  }
}
