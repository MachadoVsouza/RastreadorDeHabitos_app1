import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/xp_level_bar.dart';
import '../../core/utils/dialog_utils.dart';
import '../../services/notification_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final xpNeeded = ref.watch(xpNeededProvider);
    ref.watch(levelProgressProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          Text(
            profile.displayName ?? 'Usuário',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          Text(
            'Nível ${profile.level}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          XPLevelBar(level: profile.level, currentXP: profile.xp, xpNeeded: xpNeeded),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          
          // Opções de perfil
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Alterar senha'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Editar nome de exibição'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEditNameDialog(context, ref),
          ),
          ListTile(
            leading: Icon(
              profile.notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
            ),
            title: const Text('Notificações'),
            trailing: Switch.adaptive(
              value: profile.notificationsEnabled,
              onChanged: (value) {
                ref.read(userProfileProvider.notifier).toggleNotifications(value);
              },
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          
          // Botão de teste de notificações
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.orange),
            title: const Text('Testar Notificação'),
            subtitle: const Text('Receba uma notificação em 5 segundos'),
            trailing: const Icon(Icons.play_arrow),
            onTap: () => _testNotification(context),
          ),
        ],
      ),
    );
  }

  static Future<void> _showChangePasswordDialog(BuildContext context, WidgetRef ref) async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar senha'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha atual',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nova senha',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obrigatório';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nova senha',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obrigatório';
                  if (v != newPasswordController.text) return 'Senhas não conferem';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Alterar'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      try {
        final authService = ref.read(authServiceProvider);
        await authService.updatePassword(newPasswordController.text);
        if (context.mounted) {
          DialogUtils.showSuccessSnackbar(context, 'Senha alterada com sucesso!');
        }
      } catch (e) {
        if (context.mounted) {
          DialogUtils.showErrorSnackbar(context, 'Erro ao alterar senha. Verifique sua senha atual.');
        }
      }
    }
  }

  static Future<void> _showEditNameDialog(BuildContext context, WidgetRef ref) async {
    final profile = ref.read(userProfileProvider);
    final nameController = TextEditingController(text: profile.displayName ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nome'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nome de exibição',
            prefixIcon: Icon(Icons.person_outline),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      ref.read(userProfileProvider.notifier).updateDisplayName(result);
      DialogUtils.showSuccessSnackbar(context, 'Nome atualizado!');
    }
  }

  static Future<void> _testNotification(BuildContext context) async {
    try {
      await NotificationService.scheduleTestNotification();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏰ Notificação de teste agendada! Aguarde 5 segundos...'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        DialogUtils.showErrorSnackbar(context, 'Erro ao agendar notificação: $e');
      }
    }
  }

}
