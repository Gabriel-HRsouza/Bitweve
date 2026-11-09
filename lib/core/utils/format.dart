import 'package:intl/intl.dart';

/// Formatação monetária e numérica centralizada do jogo.
class Fmt {
  static final NumberFormat _money = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
    decimalDigits: 0,
  );
  static final NumberFormat _int = NumberFormat.decimalPattern('pt_BR');

  /// R$ 1.234.567
  static String money(num value) {
    final v = value.isFinite ? value : 0;
    return _money.format(v).replaceAll(' ', ' ');
  }

  /// +R$ 1.234 / -R$ 1.234
  static String signedMoney(num value) {
    final sign = value >= 0 ? '+' : '-';
    return '$sign${money(value.abs())}';
  }

  /// R$ 1,2 mi / R$ 350 mil
  static String compactMoney(num value) {
    final abs = value.abs();
    final sign = value < 0 ? '-' : '';
    if (abs >= 1e9) return '${sign}R\$ ${_dec(abs / 1e9)} bi';
    if (abs >= 1e6) return '${sign}R\$ ${_dec(abs / 1e6)} mi';
    if (abs >= 1e4) return '${sign}R\$ ${(abs / 1e3).toStringAsFixed(0)} mil';
    return '$sign${money(abs)}';
  }

  /// 1,2 mi / 35 mil / 980
  static String compact(num value) {
    final abs = value.abs();
    if (abs >= 1e9) return '${_dec(abs / 1e9)} bi';
    if (abs >= 1e6) return '${_dec(abs / 1e6)} mi';
    if (abs >= 1e4) return '${(abs / 1e3).toStringAsFixed(0)} mil';
    return _int.format(value.round());
  }

  static String integer(num value) => _int.format(value.round());

  static String _dec(double v) {
    final s = v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    return s.replaceAll('.', ',').replaceAll(',0', '');
  }

  static String signed(int v) => v > 0 ? '+$v' : '$v';
}
