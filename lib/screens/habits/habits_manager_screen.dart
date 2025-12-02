import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/dialog_utils.dart';
import 'habit_form_screen.dart';
import 'habit_edit_screen.dart';

class HabitsManagerScreen extends ConsumerWidget {
  const HabitsManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seus Hábitos'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HabitFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Criar hábito'),
      ),
      body: habits.isEmpty
          ? _EmptyState(onCreate: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HabitFormScreen()),
              );
            })
          : ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return _HabitListItem(habit: habit);
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Você ainda não criou hábitos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Crie seu primeiro hábito para começar a sua jornada!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Criar hábito'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitListItem extends ConsumerWidget {
  final Habit habit;
  const _HabitListItem({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Row(
          children: [
            if (!habit.isActive)
              const Padding(
                padding: EdgeInsets.only(right: 6.0),
                child: Icon(Icons.pause_circle_filled, size: 18, color: Colors.orange),
              ),
            Expanded(
              child: Text(
                habit.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (habit.description != null && habit.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  habit.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: -8,
              children: [
                ...habit.daysOfWeek.map((d) => Chip(
                      label: Text(AppDateUtils.getWeekdayShort(d)),
                      visualDensity: VisualDensity.compact,
                    )),
                if (habit.time != null)
                  Chip(
                    avatar: const Icon(Icons.access_time, size: 16),
                    label: Text(habit.time!),
                    visualDensity: VisualDensity.compact,
                  ),
                Chip(
                  avatar: Icon(
                    habit.notificationEnabled ? Icons.notifications_active : Icons.notifications_off,
                    size: 16,
                  ),
                  label: Text(habit.notificationEnabled ? 'Notificações' : 'Sem notificações'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: habit.isActive ? 'Desativar' : 'Ativar',
              icon: Icon(habit.isActive ? Icons.toggle_on : Icons.toggle_off, size: 28),
              onPressed: () => ref.read(habitProvider.notifier).toggleHabitActive(habit.id),
            ),
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => HabitEditScreen(habitId: habit.id)),
                );
              },
            ),
            IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirmed = await DialogUtils.showConfirmationDialog(
                  context: context,
                  title: 'Excluir hábito',
                  message: 'Tem certeza que deseja excluir "${habit.title}"? Esta ação não pode ser desfeita.',
                  confirmText: 'Excluir',
                  isDestructive: true,
                );
                if (confirmed == true) {
                  await ref.read(habitProvider.notifier).deleteHabit(habit.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
