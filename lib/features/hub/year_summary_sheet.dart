import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bitweve/core/i18n/strings.dart';
import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/shared/ui/game_ui.dart';
import 'package:bitweve/shared/ui/log_icons.dart';
import 'package:bitweve/shared/ui/motion.dart';
import 'age_up_overlay.dart';

Future<void> showYearSummary(BuildContext context, YearSummary s) {
  return showGameSheet(context, YearSummarySheet(summary: s));
}

class YearSummarySheet extends StatelessWidget {
  final YearSummary summary;
  const YearSummarySheet({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final s = summary;
    final motion = context.motion;
    final colors = lifeStageColors(s.age);
    var i = 0;
    Widget stagger(Widget w) {
      final d = (i++) * 70;
      if (!motion) return w;
      return w.animate(delay: d.ms).fadeIn(duration: 300.ms).slideY(begin: 0.15, end: 0, duration: 380.ms, curve: Curves.easeOutCubic);
    }

    final moneyDelta = s.moneyAfter - s.moneyBefore;
    final nwDelta = s.netWorthAfter - s.netWorthBefore;

    return GameSheet(
      title: tr('age.summary'),
      subtitle: '${s.age} ${tr('hub.years')} · ${tr('hub.year')} ${s.year}',
      icon: Icons.auto_stories_rounded,
      color: colors[1],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          stagger(GameCard(
            gradient: LinearGradient(colors: [colors[0], colors[1]]),
            child: Row(
              children: [
                Text('${s.age}', style: AppTheme.display(44, color: Colors.white)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.headline, style: AppTheme.display(19, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(s.subtitle, style: TextStyle(color: Colors.white.withAlpha(225), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          stagger(Row(
            children: [
              Expanded(child: _MoneyCard(label: tr('hub.balance'), value: s.moneyAfter, delta: moneyDelta, icon: Icons.account_balance_wallet_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _MoneyCard(label: tr('hub.netWorth'), value: s.netWorthAfter, delta: nwDelta, icon: Icons.diamond_rounded)),
            ],
          )),
          const SizedBox(height: 12),
          stagger(GameCard(
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: StatMeter(label: tr('stat.health'), value: s.statAfter['health']!, icon: Icons.favorite_rounded, delta: s.delta('health'))),
                  const SizedBox(width: 14),
                  Expanded(child: StatMeter(label: tr('stat.happiness'), value: s.statAfter['happiness']!, icon: Icons.sentiment_satisfied_rounded, delta: s.delta('happiness'))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: StatMeter(label: tr('stat.smarts'), value: s.statAfter['smarts']!, icon: Icons.psychology_rounded, delta: s.delta('smarts'))),
                  const SizedBox(width: 14),
                  Expanded(child: StatMeter(label: tr('stat.looks'), value: s.statAfter['looks']!, icon: Icons.face_retouching_natural_rounded, delta: s.delta('looks'))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: StatMeter(label: tr('stat.energy'), value: s.statAfter['energy']!, icon: Icons.bolt_rounded, delta: s.delta('energy'), compact: true)),
                  const SizedBox(width: 14),
                  Expanded(child: StatMeter(label: tr('stat.stress'), value: s.statAfter['stress']!, icon: Icons.whatshot_rounded, inverted: true, delta: s.delta('stress'), compact: true)),
                ]),
              ],
            ),
          )),
          const SizedBox(height: 12),
          stagger(Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.work_rounded,
                  color: GamePalette.blue,
                  title: tr('age.career'),
                  value: s.careerLine ?? (s.age < 6 ? 'Brincando e crescendo' : 'Sem ocupação'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoCard(
                  icon: Icons.favorite_rounded,
                  color: GamePalette.pink,
                  title: tr('age.relationships'),
                  value: s.relationshipsDelta > 5
                      ? 'Laços mais fortes (+${s.relationshipsDelta})'
                      : (s.relationshipsDelta < -5 ? 'Laços enfraqueceram (${s.relationshipsDelta})' : 'Estáveis'),
                ),
              ),
            ],
          )),
          if (s.lifeChanges.isNotEmpty) ...[
            SectionTitle(tr('age.changes'), icon: Icons.change_circle_rounded),
            stagger(Wrap(
              spacing: 8,
              runSpacing: 8,
              children: s.lifeChanges.map((c) => Pill(c, color: GamePalette.violet, icon: Icons.auto_awesome_rounded)).toList(),
            )),
          ],
          SectionTitle(tr('age.highlights'), icon: Icons.history_edu_rounded),
          if (s.highlights.isEmpty)
            Text('Um ano tranquilo, sem grandes acontecimentos.', style: TextStyle(color: p.textMuted))
          else
            ...s.highlights.take(10).map((l) {
              final color = hexColor(l.accentColor);
              return stagger(Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GameCard(
                  padding: const EdgeInsets.all(12),
                  accent: color,
                  child: Row(
                    children: [
                      IconBadge(icon: LogIcons.of(l.icon, l.category), color: color, size: 36),
                      const SizedBox(width: 10),
                      Expanded(child: Text(l.textContent, style: TextStyle(color: p.text, fontSize: 13.5, height: 1.3))),
                    ],
                  ),
                ),
              ));
            }),
          const SizedBox(height: 16),
          GameButton(label: tr('age.continue'), icon: Icons.arrow_forward_rounded, onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

class _MoneyCard extends StatelessWidget {
  final String label;
  final double value;
  final double delta;
  final IconData icon;
  const _MoneyCard({required this.label, required this.value, required this.delta, required this.icon});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final up = delta >= 0;
    return GameCard(
      accent: up ? GamePalette.green : GamePalette.red,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: p.textDim),
            const SizedBox(width: 6),
            Expanded(child: Text(label, style: TextStyle(color: p.textDim, fontSize: 12, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 6),
          AnimatedMoney(value, compact: true, style: AppTheme.display(20, color: p.text)),
          const SizedBox(height: 2),
          Text(Fmt.signedMoney(delta), style: TextStyle(color: up ? GamePalette.green : GamePalette.red, fontWeight: FontWeight.w800, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  const _InfoCard({required this.icon, required this.color, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    return GameCard(
      accent: color,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: p.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
                Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.text, fontSize: 12.5, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
