/// Resultado de um minigame. [performance] vai de 0 a 1.
class MinigameResult {
  final bool success;
  final double performance;
  final int score;
  final bool aborted;

  const MinigameResult({required this.success, required this.performance, this.score = 0, this.aborted = false});

  static const quit = MinigameResult(success: false, performance: 0, aborted: true);
}

/// Relatório de um crime para a UI exibir.
class CrimeReport {
  final bool success;
  final bool caught;
  final double loot;
  final String title;
  final String text;

  const CrimeReport({required this.success, required this.caught, required this.loot, required this.title, required this.text});

  static const none = CrimeReport(success: false, caught: false, loot: 0, title: '', text: '');
}
