import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/features/properties/models/property_model.dart';
import 'package:bitweve/features/properties/models/vehicle_model.dart';
import 'package:bitweve/features/shop/data/shop_catalog.dart';
import 'life_draft.dart';

class ShopSystem {
  static void buyItem(LifeDraft d, String itemId) {
    final item = ShopCatalog.item(itemId);
    if (item == null) return;
    if (d.age < item.minAge) {
      d.warn('Idade mínima: ${item.minAge} anos');
      return;
    }
    if (!d.pay(item.price, what: item.name)) return;
    _grantItem(d, item, item.price);
    d.x.bump('purchases');
    d.log('shopping', 'Você comprou ${item.name} por ${Fmt.money(item.price)}.', icon: 'shopping_bag', color: '#14B8A6');
    d.notify(NoticeKind.purchase, item.icon, 'Compra realizada!', message: item.name, celebrate: item.tier >= 3, money: -item.price);
    d.sfx(GameSfx.purchase);
  }

  /// Dá o item ao jogador (compra ou presente).
  static void _grantItem(LifeDraft d, ShopItem item, double paid) {
    d.x.inventory.add(OwnedItem(id: d.ctx.id(), itemId: item.id, boughtAtAge: d.age, pricePaid: paid));
    // Itens repetidos rendem menos felicidade
    final owned = d.x.inventory.where((o) => o.itemId == item.id).length;
    final factor = owned > 1 ? 0.3 : 1.0;
    d.stats(item.effects.map((k, v) => MapEntry(k, (v * factor).round())));
    if (item.fame > 0) d.stats({'fame': item.fame});
  }

  static void giftItem(LifeDraft d, String itemId) {
    final item = ShopCatalog.item(itemId);
    if (item == null) return;
    _grantItem(d, item, 0);
    d.notify(NoticeKind.purchase, item.icon, 'Você ganhou um presente!', message: item.name, celebrate: true);
  }

  static void sellItem(LifeDraft d, String ownedId) {
    final i = d.x.inventory.indexWhere((o) => o.id == ownedId);
    if (i < 0) return;
    final o = d.x.inventory.removeAt(i);
    final item = ShopCatalog.item(o.itemId);
    final base = o.pricePaid > 0 ? o.pricePaid : (item?.price ?? 0);
    final value = (base * (item?.resale ?? 0.3)).roundToDouble();
    d.money(value);
    d.stats({'happiness': -2});
    d.log('shopping', 'Você vendeu ${item?.name ?? 'um item'} por ${Fmt.money(value)}.', icon: 'sell', color: '#22C55E');
    d.notify(NoticeKind.money, Icons.sell, 'Item vendido', message: item?.name ?? '', money: value);
    d.sfx(GameSfx.moneyGain);
  }

  // ------------------------------------------------------------------ veículos
  static void buyVehicle(LifeDraft d, VehicleModel v, {bool needsLicense = true, int happiness = 12, int fame = 0}) {
    if (d.age < 16) {
      d.warn('Muito jovem', 'Veículos a partir dos 16 anos.');
      return;
    }
    if (needsLicense && !d.c.hasDriversLicense) {
      d.warn('Sem carteira de motorista', 'Faça a Autoescola em Educação → Cursos.');
      return;
    }
    if (!d.pay(v.purchasePrice, what: v.name)) return;
    d.x.vehicles.add(v.copyWith(id: d.ctx.id(), currentValue: v.purchasePrice));
    d.x.bump('purchases');
    d.stats({'happiness': happiness, 'fame': fame});
    d.log('assets', 'Garagem nova: você comprou ${v.name} por ${Fmt.money(v.purchasePrice)}!', icon: 'directions_car', color: '#22C55E');
    d.notify(NoticeKind.purchase, Icons.directions_car, 'Veículo novo!', message: v.name, celebrate: true, money: -v.purchasePrice);
    d.sfx(GameSfx.purchase);
  }

  static void buyVehicleListing(LifeDraft d, String listingId) {
    final l = ShopCatalog.vehicleListing(listingId);
    if (l == null) return;
    buyVehicle(d, l.model, needsLicense: l.needsLicense, happiness: l.happiness, fame: l.fame);
  }

  static void serviceVehicle(LifeDraft d, String id) {
    final i = d.x.vehicles.indexWhere((v) => v.id == id);
    if (i < 0) return;
    final v = d.x.vehicles[i];
    final cost = (v.annualMaintenance * 0.3).clamp(300.0, 200000.0).roundToDouble();
    if (!d.pay(cost, what: 'a revisão')) return;
    d.x.vehicles[i] = v.copyWith(conditionPercent: 100);
    d.log('assets', 'Revisão completa do ${v.name} (${Fmt.money(cost)}). Condição 100%.', icon: 'build', color: '#3B82F6');
    d.notify(NoticeKind.info, Icons.build, 'Revisão concluída', message: v.name, money: -cost);
    d.sfx(GameSfx.moneyLoss);
  }

  static void toggleVehicleInsurance(LifeDraft d, String id) {
    final i = d.x.vehicles.indexWhere((v) => v.id == id);
    if (i < 0) return;
    final v = d.x.vehicles[i];
    d.x.vehicles[i] = v.copyWith(hasInsurance: !v.hasInsurance);
    d.notify(NoticeKind.info, Icons.shield, v.hasInsurance ? 'Seguro cancelado' : 'Seguro contratado', message: v.name);
  }

  static void sellVehicle(LifeDraft d, String id) {
    final i = d.x.vehicles.indexWhere((v) => v.id == id);
    if (i < 0) return;
    final v = d.x.vehicles.removeAt(i);
    final value = (v.currentValue * (0.6 + v.conditionPercent / 250)).roundToDouble();
    d.money(value);
    d.log('assets', 'Você vendeu ${v.name} por ${Fmt.money(value)}.', icon: 'monetization_on', color: '#22C55E');
    d.notify(NoticeKind.money, Icons.monetization_on, 'Veículo vendido', message: v.name, money: value);
    d.sfx(GameSfx.moneyGain);
  }

  // ------------------------------------------------------------------ imóveis
  static void buyProperty(LifeDraft d, PropertyModel p, bool financed) {
    if (d.age < 18) {
      d.warn('Menor de idade', 'Imóveis só podem ser comprados a partir dos 18 anos.');
      return;
    }
    final down = financed ? p.purchasePrice * 0.2 : p.purchasePrice;
    if (financed && d.c.creditScore < 550) {
      d.warn('Financiamento negado', 'Seu score de crédito (${d.c.creditScore}) está baixo.');
      return;
    }
    if (!d.pay(down, what: financed ? 'a entrada' : p.name)) return;
    final debt = financed ? p.purchasePrice * 0.8 * 1.35 : 0.0; // juros embutidos
    final prop = p.copyWith(
      id: d.ctx.id(),
      saveId: d.saveId,
      isFinanced: financed,
      remainingDebt: debt,
      monthlyPayment: financed ? debt / (12 * 20) : 0,
      purchasedAtAge: d.age,
      currentValue: p.purchasePrice,
    );
    d.props.add(prop);
    _assignMeta(d, prop.id, prop.type);
    final listing = ShopCatalog.propertyListingByName(p.name);
    d.stats({'happiness': listing?.happiness ?? 15});
    d.x.bump('purchases');
    // Primeiro imóvel vira moradia automaticamente se morar sozinho/com pais
    if (d.x.homePropertyId == null && prop.isRealEstate && !prop.isCommercial) {
      d.x.homePropertyId = prop.id;
      d.x.movedOut = true;
    }
    d.log('finance', 'Você comprou ${p.name} por ${Fmt.money(p.purchasePrice)}${financed ? ' (financiado em 20 anos)' : ' à vista'}!',
        icon: 'home', color: '#22C55E');
    d.notify(NoticeKind.purchase, Icons.house, 'Imóvel adquirido!', message: p.name, celebrate: true, money: -down);
    d.sfx(GameSfx.purchase);
  }

  static const _districts = ['Centro', 'Jardins', 'Vila Nova', 'Beira-Mar', 'Alto da Serra', 'Bela Vista', 'Lago Sul', 'Parque das Flores', 'Distrito Industrial', 'Ilha Bela'];

  static int _size(String type) => switch (type) {
        'studio' => 32,
        'apartment' => 75,
        'house' => 160,
        'beach_house' => 220,
        'penthouse' => 380,
        'farm' => 2000000,
        'mansion' => 1200,
        'castle' => 5000,
        'commercial' => 45,
        'store' => 180,
        'warehouse' => 2000,
        _ => 90,
      };

  static void _assignMeta(LifeDraft d, String id, String type) {
    final m = d.x.propMeta(id);
    if (m.district.isEmpty) m.district = d.ctx.pick(_districts);
    m.sizeM2 = (_size(type) * (0.85 + d.ctx.roll() * 0.3)).round();
  }

  static void buyPropertyListing(LifeDraft d, String listingId, bool financed) {
    final l = ShopCatalog.propertyListing(listingId);
    if (l == null) return;
    buyProperty(
      d,
      PropertyModel(
        id: l.id,
        saveId: d.saveId,
        type: l.type,
        name: l.name,
        purchasePrice: l.price * d.ctx.costMult(d.c.country),
        currentValue: l.price * d.ctx.costMult(d.c.country),
        annualCost: l.annualCost,
        purchasedAtAge: d.age,
      ),
      financed,
    );
  }

  static void sellProperty(LifeDraft d, String id) {
    final i = d.props.indexWhere((p) => p.id == id);
    if (i < 0) return;
    final p = d.props.removeAt(i);
    final net = p.currentValue - p.remainingDebt;
    d.money(net);
    d.x.rentedOut.remove(p.id);
    if (d.x.homePropertyId == p.id) d.x.homePropertyId = null;
    d.log('finance', 'Você vendeu ${p.name} por ${Fmt.money(p.currentValue)} e recebeu ${Fmt.money(net)} líquidos.', icon: 'sell', color: '#22C55E');
    d.notify(NoticeKind.money, Icons.sell, 'Imóvel vendido', message: p.name, money: net);
    d.sfx(GameSfx.moneyGain);
  }

  static void toggleRent(LifeDraft d, String id) {
    final p = d.props.where((e) => e.id == id).firstOrNull;
    if (p == null) return;
    if (d.x.rentedOut.contains(id)) {
      d.x.rentedOut.remove(id);
      d.notify(NoticeKind.info, Icons.key, 'Aluguel encerrado', message: p.name);
    } else {
      if (d.x.homePropertyId == id) d.x.homePropertyId = null;
      d.x.rentedOut.add(id);
      final rent = ShopCatalog.propertyListingByName(p.name)?.rentIncome ?? p.currentValue * 0.05;
      d.log('finance', 'Você colocou ${p.name} para alugar (~${Fmt.money(rent)}/ano).', icon: 'real_estate_agent', color: '#14B8A6');
      d.notify(NoticeKind.money, Icons.real_estate_agent, 'Imóvel alugado!', message: '~${Fmt.money(rent)}/ano de renda');
      d.sfx(GameSfx.moneyGain);
    }
  }

  static void moveInto(LifeDraft d, String id) {
    final p = d.props.where((e) => e.id == id).firstOrNull;
    if (p == null || !p.isRealEstate) return;
    if (p.isCommercial) {
      d.warn('Imóvel comercial', 'Não dá para morar numa sala comercial ou galpão. Alugue-o!');
      return;
    }
    d.x.rentedOut.remove(id);
    d.x.homePropertyId = id;
    d.x.movedOut = true;
    d.stats({'happiness': 6});
    d.log('lifestyle', 'Você se mudou para ${p.name}. Lar, doce lar!', icon: 'home', color: '#7C5CFF');
    d.notify(NoticeKind.info, Icons.home, 'Mudança concluída', message: p.name);
  }

  static void renovate(LifeDraft d, String id) {
    final i = d.props.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final p = d.props[i];
    final cost = (p.currentValue * 0.05).roundToDouble();
    if (!d.pay(cost, what: 'a reforma')) return;
    d.props[i] = p.copyWith(currentValue: p.currentValue + cost * 1.6, condition: 100);
    d.stats({'happiness': 5});
    d.log('finance', 'Reforma em ${p.name} (${Fmt.money(cost)}) valorizou o imóvel.', icon: 'construction', color: '#F59E0B');
    d.notify(NoticeKind.purchase, Icons.construction, 'Reforma concluída', message: p.name, money: -cost);
    d.sfx(GameSfx.purchase);
  }
}
