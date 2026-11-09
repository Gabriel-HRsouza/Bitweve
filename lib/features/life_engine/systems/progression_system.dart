import 'dart:math';

import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/features/progression/data/progression_catalog.dart';
import 'life_draft.dart';

class ProgressionSystem {
  static String todayKey([DateTime? now]) {
    final n = now ?? DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  /// Garante as 3 missões do dia (data real), sorteadas de forma estável.
  static void ensureDaily(LifeDraft d, [DateTime? now]) {
    final key = todayKey(now);
    if (d.x.daily?.dateKey == key) return;
    final eligible = ProgressionCatalog.daily.where((m) => d.age >= m.minAge).toList();
    final rng = Random(key.hashCode ^ d.saveId.hashCode);
    eligible.shuffle(rng);
    final chosen = eligible.take(3).toList();
    d.x.daily = DailyMissionState(
      dateKey: key,
      missionIds: chosen.map((m) => m.id).toList(),
      baselines: {for (final m in chosen) m.counter!: d.x.counter(m.counter!)},
      claimed: [],
    );
  }

  static int dailyProgress(LifeExtras x, MissionDef m) {
    final base = x.daily?.baselines[m.counter] ?? 0;
    return (x.counter(m.counter!) - base).clamp(0, m.target);
  }

  static void claimDaily(LifeDraft d, String missionId) {
    final daily = d.x.daily;
    if (daily == null || daily.claimed.contains(missionId)) return;
    final m = ProgressionCatalog.daily.where((e) => e.id == missionId).firstOrNull;
    if (m == null || dailyProgress(d.x, m) < m.target) return;
    daily.claimed.add(missionId);
    _reward(d, m);
  }

  static void claimLife(LifeDraft d, String missionId) {
    if (d.x.lifeMissionsClaimed.contains(missionId)) return;
    final m = ProgressionCatalog.life.where((e) => e.id == missionId).firstOrNull;
    if (m == null || (m.progress?.call(d.toState()) ?? 0) < 1) return;
    d.x.lifeMissionsClaimed.add(missionId);
    _reward(d, m);
  }

  static void _reward(LifeDraft d, MissionDef m) {
    if (m.rewardMoney > 0) d.money(m.rewardMoney);
    d.stats(m.rewardStats);
    d.log('milestone', 'Missão concluída: ${m.title}! Recompensa: ${Fmt.money(m.rewardMoney)}.', icon: 'flag', color: '#FFC53D');
    d.notify(NoticeKind.mission, m.icon, 'Missão concluída!', message: m.title, celebrate: true, money: m.rewardMoney);
    d.sfx(GameSfx.mission);
  }

  /// Verifica conquistas novas. Retorna os ids desbloqueados agora.
  static List<AchievementDef> checkAchievements(LifeDraft d, Set<String> unlocked) {
    final snapshot = d.toState();
    final out = <AchievementDef>[];
    for (final a in ProgressionCatalog.achievements) {
      if (unlocked.contains(a.id)) continue;
      if (a.progress(snapshot) >= 1) out.add(a);
    }
    for (final a in out) {
      if (a.reward > 0) d.money(a.reward);
      d.log('milestone', 'Conquista desbloqueada: ${a.title} (${a.rarity.label})${a.reward > 0 ? ' · +${Fmt.money(a.reward)}' : ''}',
          icon: 'military_tech', color: '#FFC53D');
      d.notify(NoticeKind.achievement, a.icon, 'Conquista: ${a.title}', message: a.description, celebrate: true, money: a.reward > 0 ? a.reward : null);
    }
    if (out.isNotEmpty) d.sfx(GameSfx.achievement);
    return out;
  }

  static IconData iconFor(AchievementDef a) => a.icon;
}
