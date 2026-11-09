import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/finances/models/crypto_asset.dart';
import 'package:bitweve/features/finances/models/investment_model.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/features/shop/data/shop_catalog.dart';
import 'life_draft.dart';

class InvestmentOption {
  final String type;
  final String name;
  final String ticker;
  final String description;
  final String risk;
  final IconData icon;
  final Color color;
  const InvestmentOption(this.type, this.name, this.ticker, this.description, this.risk, this.icon, this.color);
}

class FinanceSystem {
  static const investmentOptions = [
    InvestmentOption('fixed_income', 'Tesouro Selic', 'SELIC', 'Renda fixa segura, ~10% ao ano.', 'Baixo', Icons.account_balance, Color(0xFF22C55E)),
    InvestmentOption('real_estate_fund', 'Fundo Imobiliário', 'FII11', 'Aluguéis de shoppings e galpões. ~4% a 14% a.a.', 'Médio', Icons.apartment, Color(0xFF14B8A6)),
    InvestmentOption('stock', 'Ações Brasil', 'BOVA11', 'Bolsa de valores: pode subir ou cair bastante.', 'Alto', Icons.show_chart, Color(0xFF3B82F6)),
    InvestmentOption('stock_global', 'Ações Globais', 'IVVB11', 'Empresas gigantes do mundo todo.', 'Alto', Icons.public, Color(0xFF6366F1)),
    InvestmentOption('crypto', 'ETF de Cripto', 'HASH11', 'Altíssima volatilidade.', 'Muito alto', Icons.currency_bitcoin, Color(0xFFF59E0B)),
  ];

  static List<CryptoAsset> defaultWallet() => const [
        CryptoAsset(symbol: 'BTC', name: 'Bitcoin', currentPrice: 382450.0, change24hPercent: 3.4, priceHistory: [365000.0, 371000.0, 368000.0, 375000.0, 382450.0]),
        CryptoAsset(symbol: 'ETH', name: 'Ethereum', currentPrice: 19800.0, change24hPercent: -1.2, priceHistory: [20500.0, 20100.0, 19900.0, 19600.0, 19800.0]),
        CryptoAsset(symbol: 'BWV', name: 'BitWeve Token', currentPrice: 2.45, change24hPercent: 12.8, priceHistory: [1.80, 1.95, 2.10, 2.25, 2.45]),
      ];

  static void ensureWallet(LifeDraft d) {
    if (d.x.crypto.isEmpty) d.x.crypto.addAll(defaultWallet());
  }

  /// Despesa obrigatória: paga do saldo; o que faltar vira dívida (cheque especial).
  static void charge(LifeDraft d, double amount, String what) {
    if (amount <= 0) return;
    final available = d.c.bankBalance.clamp(0.0, double.infinity);
    if (available >= amount) {
      d.money(-amount);
      return;
    }
    final shortfall = amount - available;
    d.c = d.c.copyWith(bankBalance: 0, debt: d.c.debt + shortfall, creditScore: d.c.creditScore - 25);
    d.log('finance', 'Sem saldo para $what: ${Fmt.money(shortfall)} entraram no cheque especial.', icon: 'warning', color: '#EF4444');
  }

  static void addOverdraft(LifeDraft d, double amount) => d.c = d.c.copyWith(debt: d.c.debt + amount);

  static Loan createLoan(LifeDraft d, double amount, double rate, int years, String label) {
    final r = rate;
    final payment = r == 0 ? amount / years : amount * r / (1 - 1 / _pow(1 + r, years));
    final loan = Loan(
      id: d.ctx.id(),
      label: label,
      principal: amount,
      remaining: amount,
      rate: rate,
      annualPayment: payment.roundToDouble(),
    );
    d.x.loans.add(loan);
    d.x.bump('loansTaken');
    return loan;
  }

  static double _pow(double b, int e) {
    var r = 1.0;
    for (var i = 0; i < e; i++) {
      r *= b;
    }
    return r;
  }

  /// Taxa de juros oferecida conforme score de crédito.
  static double loanRate(int creditScore) {
    if (creditScore >= 800) return 0.11;
    if (creditScore >= 700) return 0.15;
    if (creditScore >= 600) return 0.22;
    return 0.32;
  }

  static double loanLimit(LifeDraft d) {
    final income = (d.c.currentSalary ?? 0) + d.props.fold<double>(0, (s, p) => s + p.currentValue * 0.05);
    final base = income * 3 + 5000;
    final scoreFactor = (d.c.creditScore - 400) / 400;
    return (base * scoreFactor.clamp(0.2, 1.5) - d.x.loansTotal).clamp(0, 5000000).roundToDouble();
  }

  static void takeLoan(LifeDraft d, double amount) {
    if (d.age < 18) {
      d.warn('Menor de idade', 'Bancos só emprestam para maiores de 18 anos.');
      return;
    }
    final limit = loanLimit(d);
    if (amount > limit) {
      d.warn('Crédito negado', 'Seu limite atual é ${Fmt.money(limit)}.');
      return;
    }
    final rate = loanRate(d.c.creditScore);
    final loan = createLoan(d, amount, rate, 5, 'Empréstimo pessoal');
    d.money(amount);
    d.log('finance', 'Empréstimo aprovado: ${Fmt.money(amount)} a ${(rate * 100).toStringAsFixed(0)}% a.a. (parcela anual ${Fmt.money(loan.annualPayment)}).', icon: 'account_balance', color: '#F59E0B');
    d.notify(NoticeKind.money, Icons.account_balance, 'Empréstimo aprovado', message: Fmt.money(amount), money: amount);
    d.sfx(GameSfx.moneyGain);
  }

  static void payLoan(LifeDraft d, String loanId, double amount) {
    final i = d.x.loans.indexWhere((l) => l.id == loanId);
    if (i < 0) return;
    final loan = d.x.loans[i];
    final pay = amount.clamp(0.0, loan.remaining);
    if (!d.pay(pay, what: 'amortizar o empréstimo')) return;
    loan.remaining -= pay;
    if (loan.remaining <= 1) {
      d.x.loans.removeAt(i);
      d.c = d.c.copyWith(creditScore: d.c.creditScore + 30);
      d.log('finance', 'Você quitou "${loan.label}"! Score de crédito subiu.', icon: 'check_circle', color: '#22C55E');
      d.notify(NoticeKind.money, Icons.verified, 'Empréstimo quitado!', celebrate: true);
    } else {
      d.log('finance', 'Você amortizou ${Fmt.money(pay)} de "${loan.label}".', icon: 'check_circle', color: '#22C55E');
      d.notify(NoticeKind.money, Icons.check_circle, 'Pagamento realizado', money: -pay);
    }
    d.sfx(GameSfx.moneyLoss);
  }

  static void payDebt(LifeDraft d, double amount) {
    if (d.c.debt <= 0) {
      d.warn('Sem dívidas', 'Você não tem saldo devedor no cheque especial.');
      return;
    }
    final pay = amount.clamp(0.0, d.c.debt);
    if (!d.pay(pay, what: 'pagar a dívida')) return;
    d.c = d.c.copyWith(debt: d.c.debt - pay, creditScore: d.c.creditScore + 15, stress: d.c.stress - 6);
    d.log('finance', 'Você pagou ${Fmt.money(pay)} de dívidas. Score de crédito melhorou!', icon: 'check_circle', color: '#22C55E');
    d.notify(NoticeKind.money, Icons.check_circle, 'Dívida paga', message: Fmt.money(pay), money: -pay);
    d.sfx(GameSfx.moneyLoss);
  }

  static void invest(LifeDraft d, String type, String name, String ticker, double amount) {
    if (d.age < 16) {
      d.warn('Menor de idade', 'Investimentos a partir dos 16 anos.');
      return;
    }
    if (amount <= 0 || !d.pay(amount, what: 'investir')) return;
    final existing = d.invs.indexWhere((i) => i.ticker == ticker);
    if (existing >= 0) {
      final inv = d.invs[existing];
      d.invs[existing] = inv.copyWith(
        investedAmount: inv.investedAmount + amount,
        currentValue: inv.currentValue + amount,
        units: inv.units + amount / 100.0,
      );
    } else {
      d.invs.add(InvestmentModel(
        id: d.ctx.id(),
        saveId: d.saveId,
        type: type,
        name: name,
        ticker: ticker,
        investedAmount: amount,
        currentValue: amount,
        units: amount / 100.0,
        annualYieldPercent: 10.0,
      ));
    }
    d.log('finance', 'Você investiu ${Fmt.money(amount)} em $name ($ticker).', icon: 'savings', color: '#22C55E');
    d.notify(NoticeKind.money, Icons.savings, 'Investimento realizado', message: '$name · ${Fmt.money(amount)}', money: -amount);
    d.sfx(GameSfx.moneyLoss);
  }

  static void sellInvestment(LifeDraft d, String id) {
    final i = d.invs.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final inv = d.invs.removeAt(i);
    d.money(inv.currentValue);
    final profit = inv.currentValue - inv.investedAmount;
    d.log('finance', 'Você resgatou ${inv.name}: ${Fmt.money(inv.currentValue)} (${profit >= 0 ? 'lucro' : 'prejuízo'} de ${Fmt.money(profit.abs())}).',
        icon: 'account_balance_wallet', color: profit >= 0 ? '#22C55E' : '#EF4444');
    d.notify(NoticeKind.money, Icons.account_balance_wallet, 'Resgate concluído', message: inv.name, money: inv.currentValue);
    d.sfx(GameSfx.moneyGain);
  }

  static void buyCrypto(LifeDraft d, String symbol, double amount) {
    ensureWallet(d);
    final i = d.x.crypto.indexWhere((a) => a.symbol == symbol);
    if (i < 0 || amount <= 0) return;
    if (d.age < 18) {
      d.warn('Menor de idade', 'Corretoras exigem 18 anos.');
      return;
    }
    if (!d.pay(amount, what: 'comprar $symbol')) return;
    final a = d.x.crypto[i];
    final units = amount / a.currentPrice;
    d.x.crypto[i] = a.copyWith(ownedUnits: a.ownedUnits + units);
    d.log('finance', 'Compra cripto: ${Fmt.money(amount)} → ${units.toStringAsFixed(6)} $symbol.', icon: 'currency_bitcoin', color: '#F59E0B');
    d.notify(NoticeKind.money, Icons.currency_bitcoin, 'Compra de $symbol', money: -amount);
    d.sfx(GameSfx.moneyLoss);
  }

  static void sellCrypto(LifeDraft d, String symbol, double amount) {
    ensureWallet(d);
    final i = d.x.crypto.indexWhere((a) => a.symbol == symbol);
    if (i < 0) return;
    final a = d.x.crypto[i];
    if (a.totalValue <= 0) return;
    final value = amount.clamp(0.0, a.totalValue);
    final units = value / a.currentPrice;
    d.x.crypto[i] = a.copyWith(ownedUnits: (a.ownedUnits - units).clamp(0.0, double.infinity));
    d.money(value);
    d.log('finance', 'Venda cripto: ${units.toStringAsFixed(6)} $symbol → ${Fmt.money(value)}.', icon: 'currency_bitcoin', color: '#22C55E');
    d.notify(NoticeKind.money, Icons.currency_bitcoin, 'Venda de $symbol', money: value);
    d.sfx(GameSfx.moneyGain);
  }

  static void moveOut(LifeDraft d) {
    if (d.age < 18) {
      d.warn('Menor de idade', 'Você só pode sair de casa aos 18 anos.');
      return;
    }
    if (d.x.movedOut) return;
    d.x.movedOut = true;
    d.stats({'happiness': 8, 'discipline': 5, 'stress': 5});
    d.log('lifestyle', 'Você saiu da casa dos pais! Independência tem gosto de liberdade (e de boletos).', icon: 'home', color: '#7C5CFF');
    d.notify(NoticeKind.info, Icons.home, 'Você saiu de casa!', message: 'Agora há custo de aluguel enquanto não tiver imóvel.', celebrate: true);
  }

  /// Simulação financeira do ano. Retorna o total de despesas.
  static double yearly(LifeDraft d) {
    final ctx = d.ctx;
    final mult = ctx.costMult(d.c.country);
    double expenses = 0;
    void spend(double v, String what) {
      if (v <= 0) return;
      expenses += v;
      charge(d, v, what);
    }

    // Custo de vida
    if (d.age >= 18) {
      spend(9000 * mult, 'o custo de vida');
      final home = d.x.homePropertyId != null && d.props.any((p) => p.id == d.x.homePropertyId);
      if (d.x.movedOut && !home) spend(15000 * mult, 'o aluguel');
    }
    // Filhos
    final kids = d.living((n) => n.isChild && n.age < 18).length;
    if (kids > 0 && d.age >= 18) spend(6000.0 * kids * mult, 'as despesas com os filhos');
    // Pets
    final pets = d.x.pets.where((p) => p.alive).length;
    if (pets > 0 && d.age >= 18) spend(1200.0 * pets, 'os pets');
    // Plano de saúde
    if (d.x.hasInsurance) spend(2400 * mult, 'o plano de saúde');
    // Itens com manutenção
    for (final it in d.x.inventory) {
      final item = ShopCatalog.item(it.itemId);
      if (item != null && item.annualCost > 0) spend(item.annualCost, 'a manutenção de ${item.name}');
    }

    // Imóveis: custos, financiamento, valorização e aluguel recebido
    double rentIncome = 0;
    for (var i = 0; i < d.props.length; i++) {
      final p = d.props[i];
      spend(p.annualCost, 'IPTU/condomínio de ${p.name}');
      var remaining = p.remainingDebt;
      if (p.isFinanced && remaining > 0) {
        final payment = (p.monthlyPayment * 12).clamp(0.0, remaining);
        spend(payment, 'o financiamento de ${p.name}');
        remaining -= payment;
      }
      var value = p.currentValue;
      if (p.isRealEstate) {
        value *= 1.0 + (ctx.roll() * 0.09 - 0.015);
      } else {
        value *= 1.0 - (ctx.roll() * 0.08 + 0.04);
      }
      if (d.x.rentedOut.contains(p.id)) {
        final listing = ShopCatalog.propertyListingByName(p.name);
        rentIncome += listing?.rentIncome ?? p.currentValue * 0.05;
      }
      d.props[i] = p.copyWith(currentValue: value, remainingDebt: remaining, isFinanced: remaining > 0);
    }
    if (rentIncome > 0) {
      d.money(rentIncome);
      d.log('finance', 'Seus inquilinos pagaram ${Fmt.money(rentIncome)} de aluguel este ano.', icon: 'real_estate_agent', color: '#22C55E');
    }

    // Investimentos
    final bonus = d.x.education.courses.contains('personal_finance') ? 1.05 : 1.0;
    for (var i = 0; i < d.invs.length; i++) {
      final inv = d.invs[i];
      double r;
      switch (inv.type) {
        case 'fixed_income':
          r = 0.1 + ctx.roll() * 0.015;
          break;
        case 'real_estate_fund':
          r = 0.04 + ctx.roll() * 0.10;
          break;
        case 'stock':
          r = ctx.roll() * 0.42 - 0.12;
          break;
        case 'stock_global':
          r = ctx.roll() * 0.36 - 0.08;
          break;
        default:
          r = ctx.roll() * 0.9 - 0.35;
      }
      if (r > 0) r *= bonus;
      d.invs[i] = inv.copyWith(currentValue: (inv.currentValue * (1 + r)).clamp(0.0, double.infinity), annualYieldPercent: r * 100);
    }

    // Cripto
    for (var i = 0; i < d.x.crypto.length; i++) {
      final a = d.x.crypto[i];
      final pct = a.symbol == 'BWV' ? ctx.roll() * 0.9 - 0.4 : ctx.roll() * 0.55 - 0.22;
      final price = (a.currentPrice * (1 + pct)).clamp(0.01, 5000000.0);
      final hist = [...a.priceHistory, price];
      d.x.crypto[i] = a.copyWith(
        currentPrice: price,
        change24hPercent: pct * 100,
        priceHistory: hist.length > 12 ? hist.sublist(hist.length - 12) : hist,
      );
    }

    // Veículos
    for (var i = 0; i < d.x.vehicles.length; i++) {
      final v = d.x.vehicles[i];
      spend(v.annualMaintenance + (v.hasInsurance ? v.annualInsurance : 0), 'a manutenção de ${v.name}');
      d.x.vehicles[i] = v.copyWith(
        mileageKm: v.mileageKm + 8000 + ctx.rng.nextInt(7000),
        conditionPercent: (v.conditionPercent - (4 + ctx.rng.nextInt(5))).clamp(5, 100),
        currentValue: (v.currentValue * (v.category.name == 'aircraft' || v.category.name == 'boat' ? 0.95 : 0.9)).clamp(500.0, double.infinity),
      );
    }

    // Patrocínios
    double sponsorIncome = 0;
    for (final s in d.x.sponsorships) {
      sponsorIncome += s.annualPay;
      s.yearsLeft -= 1;
    }
    d.x.sponsorships.removeWhere((s) => s.yearsLeft <= 0);
    if (sponsorIncome > 0) {
      d.money(sponsorIncome);
      d.log('fame', 'Seus patrocínios renderam ${Fmt.money(sponsorIncome)} este ano.', icon: 'handshake', color: '#A855F7');
    }

    // Empréstimos
    for (final loan in List.of(d.x.loans)) {
      final interest = loan.remaining * loan.rate;
      loan.remaining += interest;
      final pay = loan.annualPayment.clamp(0.0, loan.remaining);
      if (d.c.bankBalance >= pay) {
        d.money(-pay);
        expenses += pay;
        loan.remaining -= pay;
        d.c = d.c.copyWith(creditScore: d.c.creditScore + 5);
      } else {
        loan.missedPayments += 1;
        loan.remaining += pay * 0.1;
        d.c = d.c.copyWith(creditScore: d.c.creditScore - 45, stress: d.c.stress + 8);
        d.log('finance', 'Você não conseguiu pagar a parcela de "${loan.label}". Multa aplicada e score caiu.', icon: 'warning', color: '#EF4444');
        d.notify(NoticeKind.warning, Icons.warning_amber, 'Parcela atrasada', message: loan.label);
      }
      if (loan.remaining <= 1) {
        d.x.loans.remove(loan);
        d.log('finance', 'Empréstimo "${loan.label}" quitado!', icon: 'check_circle', color: '#22C55E');
      }
    }

    // Cheque especial: juros altos
    if (d.c.debt > 0) {
      final interest = d.c.debt * 0.14;
      d.c = d.c.copyWith(debt: d.c.debt + interest, stress: d.c.stress + 5, creditScore: d.c.creditScore - 10);
      if (d.c.bankBalance > 0) {
        final pay = d.c.bankBalance.clamp(0.0, d.c.debt);
        d.c = d.c.copyWith(bankBalance: d.c.bankBalance - pay, debt: d.c.debt - pay);
      }
    }

    d.c = d.c.copyWith(annualExpenses: expenses);
    return expenses;
  }
}
