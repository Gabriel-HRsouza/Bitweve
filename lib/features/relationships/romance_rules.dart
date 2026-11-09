/// Regras de romance e intimidade do BitWeve.
///
/// * Adultos (18+) só se relacionam com adultos.
/// * Adolescentes (13–17) podem ter paqueras/namoro apropriado à idade apenas
///   com pessoas também menores e de idade próxima (diferença máx. de 2 anos).
/// * Intimidade é exclusiva entre adultos, com consentimento mútuo, e nunca é
///   descrita de forma explícita.
class RomanceRules {
  static const minTeenAge = 13;

  static bool romanceAllowed(int myAge, int otherAge) {
    if (myAge >= 18 || otherAge >= 18) return myAge >= 18 && otherAge >= 18;
    return myAge >= minTeenAge && otherAge >= minTeenAge && (myAge - otherAge).abs() <= 2;
  }

  static bool intimacyAllowed(int myAge, int otherAge) => myAge >= 18 && otherAge >= 18;

  /// Faixa de idade para encontros gerados (paqueras, app, festas).
  static (int, int) datingRange(int myAge) {
    if (myAge < 18) return ((myAge - 1).clamp(minTeenAge, 17), (myAge + 1).clamp(minTeenAge, 17));
    return ((myAge - 8).clamp(18, 99), (myAge + 8).clamp(18, 99));
  }
}
