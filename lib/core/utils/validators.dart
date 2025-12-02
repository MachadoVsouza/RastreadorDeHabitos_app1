class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }

    if (value.length < 6) {
      return 'Senha deve ter no mínimo 6 caracteres';
    }

    return null;
  }

  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }

    if (value != password) {
      return 'As senhas não coincidem';
    }

    return null;
  }

  static String? validateHabitTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Título é obrigatório';
    }

    if (value.trim().length < 3) {
      return 'Título deve ter no mínimo 3 caracteres';
    }

    if (value.length > 50) {
      return 'Título muito longo (máx. 50 caracteres)';
    }

    return null;
  }

  static String? validateHabitDescription(String? value) {
    if (value != null && value.length > 200) {
      return 'Descrição muito longa (máx. 200 caracteres)';
    }
    return null;
  }

  static String? validateDaysOfWeek(List<int>? days) {
    if (days == null || days.isEmpty) {
      return 'Selecione pelo menos um dia da semana';
    }
    return null;
  }

  static String? validateDisplayName(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.trim().length < 2) {
        return 'Nome deve ter no mínimo 2 caracteres';
      }

      if (value.length > 30) {
        return 'Nome muito longo (máx. 30 caracteres)';
      }
    }
    return null;
  }

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }
}
