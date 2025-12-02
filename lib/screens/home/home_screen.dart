import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/habit_log_provider.dart';
import '../../widgets/habit_tile.dart';
import '../../core/utils/dialog_utils.dart';
import '../stats/statistics_screen.dart';
import '../heatmap/heatmap_screen.dart';
import '../habits/habits_manager_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'lib/images/logo_sem_fundo_menor.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Estatísticas',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_on_outlined),
            selectedIcon: Icon(Icons.grid_on),
            label: 'Heatmap',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const ProfileScreen();
      case 2:
        return _buildStatsTab();
      case 3:
        return _buildHeatmapTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final todayHabits = ref.watch(todayHabitsProvider);
    final todayCompleted = ref.watch(todayCompletedCountProvider);
    final todayXP = ref.watch(todayXPProvider);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                'Progresso de Hoje',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    icon: Icons.check_circle,
                    label: 'Completos',
                    value: '$todayCompleted/${todayHabits.length}',
                  ),
                  _buildStatItem(
                    context,
                    icon: Icons.star,
                    label: 'XP Ganho',
                    value: '$todayXP',
                  ),
                ],
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HabitsManagerScreen()),
              );
            },
            icon: const Icon(Icons.settings),
            label: const Text('Configurar Hábitos'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: todayHabits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum hábito para hoje',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Configure seus hábitos para começar!',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: todayHabits.length,
                  itemBuilder: (context, index) {
                    final habit = todayHabits[index];
                    return HabitTile(
                      habit: habit,
                      date: DateTime.now(),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    return const StatisticsScreen();
  }

  Widget _buildHeatmapTab() {
    return const HeatmapScreen();
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await DialogUtils.showConfirmationDialog(
      context: context,
      title: 'Sair',
      message: 'Deseja realmente sair da sua conta?',
      confirmText: 'Sair',
      cancelText: 'Cancelar',
    );

    if (confirm == true && mounted) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }
}
