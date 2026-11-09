import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/events/models/life_event.dart';
import 'package:bitweve/shared/ui/game_ui.dart';
import 'package:bitweve/shared/ui/motion.dart';

class EventStyle {
  final IconData icon;
  final List<Color> colors;
  final String label;
  const EventStyle(this.icon, this.colors, this.label);

  static EventStyle of(String category) {
    final c = category.toLowerCase();
    if (c.contains('famíl') || c.contains('heran')) return const EventStyle(Icons.family_restroom_rounded, [Color(0xFFFB7185), Color(0xFFBE123C)], 'Família');
    if (c.contains('amor') || c.contains('relacion')) return const EventStyle(Icons.favorite_rounded, [Color(0xFFFF4F9A), Color(0xFF9D174D)], 'Amor');
    if (c.contains('social') || c.contains('amizad')) return const EventStyle(Icons.forum_rounded, [Color(0xFFF472B6), Color(0xFF7C3AED)], 'Social');
    if (c.contains('carreira') || c.contains('trabalho') || c.contains('promo') || c.contains('negóc')) {
      return const EventStyle(Icons.work_rounded, [Color(0xFF60A5FA), Color(0xFF1D4ED8)], 'Carreira');
    }
    if (c.contains('financ') || c.contains('dinheiro') || c.contains('compras')) return const EventStyle(Icons.payments_rounded, [Color(0xFF4ADE80), Color(0xFF15803D)], 'Finanças');
    if (c.contains('saúde') || c.contains('médic')) return const EventStyle(Icons.medical_services_rounded, [Color(0xFFF87171), Color(0xFFB91C1C)], 'Saúde');
    if (c.contains('fama') || c.contains('redes')) return const EventStyle(Icons.star_rounded, [Color(0xFFC084FC), Color(0xFF6D28D9)], 'Fama');
    if (c.contains('raro') || c.contains('sorte') || c.contains('loteria') || c.contains('oportun')) {
      return const EventStyle(Icons.auto_awesome_rounded, [Color(0xFFFDE047), Color(0xFFD97706)], 'Raro');
    }
    if (c.contains('crime') || c.contains('moral')) return const EventStyle(Icons.gavel_rounded, [Color(0xFF94A3B8), Color(0xFF334155)], 'Moral');
    if (c.contains('escola') || c.contains('estudo')) return const EventStyle(Icons.school_rounded, [Color(0xFF818CF8), Color(0xFF4338CA)], 'Escola');
    if (c.contains('infân') || c.contains('adolesc')) return const EventStyle(Icons.toys_rounded, [Color(0xFFFFC53D), Color(0xFFF97316)], 'Infância');
    if (c.contains('azar') || c.contains('crise')) return const EventStyle(Icons.thunderstorm_rounded, [Color(0xFF64748B), Color(0xFF1E293B)], 'Crise');
    return const EventStyle(Icons.alt_route_rounded, [Color(0xFF22D3EE), Color(0xFF0E7490)], 'Vida');
  }
}

String rarityLabel(String r) => const {'uncommon': 'Incomum', 'rare': 'Raro', 'legendary': 'Lendário'}[r] ?? '';

/// Mostra o evento e retorna o índice da escolha.
Future<int?> showEventDialog(BuildContext context, LifeEvent event, {double balance = double.infinity}) {
  AudioService().playSfx(GameSfx.notification);
  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (_) => EventDialog(event: event, balance: balance),
  );
}

class EventDialog extends StatelessWidget {
  final LifeEvent event;
  final double balance;
  final void Function(EventChoice choice)? onSelectChoice;

  const EventDialog({super.key, required this.event, this.balance = double.infinity, this.onSelectChoice});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final style = EventStyle.of(event.category);
    final rarity = rarityLabel(event.rarity);
    final dialog = Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItemArt(icon: style.icon, colors: style.colors, height: 120, radius: 0, tier: event.rarity == 'legendary' ? 4 : (event.rarity == 'rare' ? 3 : 1),
                  badge: style.label.toUpperCase()),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (rarity.isNotEmpty)
                      Align(alignment: Alignment.centerLeft, child: Pill(rarity, color: GamePalette.gold, icon: Icons.auto_awesome_rounded)),
                    if (rarity.isNotEmpty) const SizedBox(height: 8),
                    Text(event.title, style: AppTheme.display(23, color: p.text)),
                    const SizedBox(height: 8),
                    Text(event.description, style: TextStyle(color: p.textDim, fontSize: 15, height: 1.4)),
                    const SizedBox(height: 18),
                    for (var i = 0; i < event.choices.length; i++) ...[
                      _ChoiceButton(
                        choice: event.choices[i],
                        index: i,
                        balance: balance,
                        color: style.colors.first,
                        onTap: () {
                          if (onSelectChoice != null) {
                            onSelectChoice!(event.choices[i]);
                          } else {
                            Navigator.of(context).pop(i);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!context.motion) return dialog;
    return dialog.animate().scale(begin: const Offset(0.88, 0.88), duration: 320.ms, curve: Curves.easeOutBack).fadeIn(duration: 200.ms);
  }
}

class _ChoiceButton extends StatelessWidget {
  final EventChoice choice;
  final int index;
  final double balance;
  final Color color;
  final VoidCallback onTap;
  const _ChoiceButton({required this.choice, required this.index, required this.balance, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final cost = choice.upfrontCost;
    final cantAfford = cost > 0 && balance < cost;
    final risky = choice.chance != null;
    return Pressable(
      onTap: cantAfford ? null : onTap,
      enabled: !cantAfford,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: p.cardHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(110), width: 1.4),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: color.withAlpha(50), shape: BoxShape.circle),
              child: Text(String.fromCharCode(65 + index), style: TextStyle(color: color, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(choice.label, style: TextStyle(color: p.text, fontWeight: FontWeight.w700, fontSize: 14.5)),
                  if (cost > 0 || risky)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Wrap(spacing: 6, children: [
                        if (cost > 0) Text(cantAfford ? 'Sem saldo: ${Fmt.money(cost)}' : 'Custa ${Fmt.money(cost)}',
                            style: TextStyle(fontSize: 11.5, color: cantAfford ? GamePalette.red : p.textMuted, fontWeight: FontWeight.w600)),
                        if (risky) const Text('· Arriscado', style: TextStyle(fontSize: 11.5, color: GamePalette.orange, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.textMuted),
          ],
        ),
      ),
    );
  }
}

const _statNames = {
  'health': ('Saúde', Icons.favorite_rounded),
  'happiness': ('Felicidade', Icons.sentiment_satisfied_rounded),
  'smarts': ('Inteligência', Icons.psychology_rounded),
  'looks': ('Aparência', Icons.face_retouching_natural_rounded),
  'energy': ('Energia', Icons.bolt_rounded),
  'stress': ('Estresse', Icons.whatshot_rounded),
  'reputation': ('Reputação', Icons.verified_rounded),
  'charisma': ('Carisma', Icons.record_voice_over_rounded),
  'fame': ('Fama', Icons.star_rounded),
  'fitness': ('Físico', Icons.fitness_center_rounded),
  'karma': ('Karma', Icons.volunteer_activism_rounded),
  'money': ('Dinheiro', Icons.payments_rounded),
  'followers': ('Seguidores', Icons.people_alt_rounded),
};

/// Mostra o resultado da escolha com as consequências aplicadas.
Future<void> showOutcomeDialog(BuildContext context, EventOutcome o) {
  final p = context.gp;
  final color = o.success ? GamePalette.green : GamePalette.red;
  return showDialog(
    context: context,
    builder: (ctx) {
      final d = Dialog(
        insetPadding: const EdgeInsets.all(22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconBadge(icon: o.success ? Icons.check_rounded : Icons.close_rounded, color: color, size: 56),
                const SizedBox(height: 12),
                Text(o.title, textAlign: TextAlign.center, style: AppTheme.display(20, color: p.text)),
                const SizedBox(height: 8),
                Text(o.text, textAlign: TextAlign.center, style: TextStyle(color: p.textDim, fontSize: 15, height: 1.4)),
                if (o.deltas.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: o.deltas.entries.where((e) => _statNames.containsKey(e.key)).map((e) {
                      final info = _statNames[e.key]!;
                      final positive = e.key == 'stress' ? e.value < 0 : e.value > 0;
                      final txt = e.key == 'money'
                          ? Fmt.signedMoney(e.value)
                          : (e.key == 'followers' ? '${e.value > 0 ? '+' : ''}${Fmt.compact(e.value)}' : Fmt.signed(e.value.round()));
                      return Pill('${info.$1} $txt', color: positive ? GamePalette.green : GamePalette.red, icon: info.$2);
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 18),
                GameButton(label: 'Continuar', height: 48, onTap: () => Navigator.pop(ctx)),
              ],
            ),
          ),
        ),
      );
      if (!ctx.motion) return d;
      return d.animate().scale(begin: const Offset(0.9, 0.9), duration: 260.ms, curve: Curves.easeOutBack).fadeIn();
    },
  );
}
