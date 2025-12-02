# Habit Tracker (Flutter)

## 1) Explicação do Projeto

Aplicativo de rastreamento de hábitos com foco em consistência diária, gamificação e visualização do progresso.

Principais funcionalidades:
- Autenticação de usuário (Supabase Auth).
- CRUD de hábitos com dias da semana e horário opcional.
- Conclusão diária de hábitos com registro em `Hive` (funciona offline).
- Gamificação: ganho de XP e níveis, barra de progresso na tela de Perfil.
- Estatísticas e Heatmap para visualizar consistência e streaks.
- Notificações locais no horário do hábito (Android/iOS), com suporte a fuso horário.

Tecnologias usadas:
- Flutter (Material 3) + Riverpod para gerenciamento de estado reativo.
- Supabase (Auth) para login/registro e estado de sessão.
- Hive para armazenamento local rápido (habits, habit logs, user profile).
- flutter_local_notifications + timezone para lembretes locais exatos.
- flutter_heatmap_calendar para o mapa de calor (calendário de intensidade).

Arquitetura (alto nível):
- `models/` (Habit, HabitLog, UserProfile) ➜ dados persistidos no Hive.
- `services/` (HiveService, NotificationService) ➜ integração local e sistema.
- `providers/` (auth, habits, logs, profile, notifications) ➜ lógica/estado.
- `screens/` (home, profile, stats, heatmap, auth) ➜ UI por funcionalidade.
- `widgets/` (HabitTile, XPLevelBar, etc.) ➜ componentes reutilizáveis.
- `core/utils/` (datas, XP, stats, heatmap) ➜ cálculos e utilidades.

Observações importantes:
- O app requer configuração do Supabase para autenticação (veja seção "Como Rodar").
- Em Android 12+ as notificações exatas exigem permissões do sistema (o app solicita na inicialização). Emuladores podem variar o comportamento; preferencialmente teste em dispositivo real.

---

## 2) Como Rodar o Projeto

Pré‑requisitos:
- Flutter SDK instalado e no PATH.
- Dispositivo ou emulador Android/iOS configurado.
- Projeto configurado no Supabase (URL e ANON KEY).

Passos (Windows PowerShell):

1. Instalar dependências
```powershell
flutter pub get
```

2. Configurar Supabase para autenticação
   - Acesse https://supabase.com/ e crie um projeto (ou use um existente).
   - No dashboard do projeto, copie a **URL** e a **anon key** (Settings > API).
   - Crie um arquivo `.env` na raiz do projeto com as variáveis:
```env
SUPABASE_URL=https://SEU-PROJETO.supabase.co
SUPABASE_ANON_KEY=SEU_ANON_KEY
```
   - Substitua `SEU-PROJETO` e `SEU_ANON_KEY` pelos valores do seu projeto Supabase.

3. Rodar o app (escolha do dispositivo será solicitada se houver mais de um)
```powershell
flutter run
```

4. Testar notificações (Android)
- Na aba Perfil, toque em "Testar Notificação" para enviar uma notificação imediata e uma agendada (5s).
- Garanta que o app tem permissões de Notificações e (em Android 12+) de Alarmes Exatos:
  - Configurações do Android > Apps > Habit Tracker > Notificações = Ativado
  - Configurações > Apps > Habit Tracker > Alarmes e lembretes = Permitir

5. Dicas comuns
- Se notar erros de build relacionados a cache, execute:
```powershell
flutter clean
flutter pub get
flutter run
```
- Para ver o mapa de calor e estatísticas, crie hábitos, marque completados e navegue até as abas "Estatísticas" e "Heatmap".

Estrutura visual (abas):
- Início: resumo do dia e lista de hábitos de hoje.
- Perfil: foto/nível/XP, alterar nome e senha, teste de notificação.
- Estatísticas: cards de taxa de conclusão e totais, lista por hábito.
- Heatmap: calendário de intensidade com streaks.

---


