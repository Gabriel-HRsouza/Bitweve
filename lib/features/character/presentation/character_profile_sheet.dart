import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/i18n/strings.dart';
import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/careers/models/career_track.dart';
import 'package:bitweve/features/character/data/character_options.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/character/presentation/widgets/appearance_editor.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/education_system.dart';
import 'package:bitweve/features/life_engine/systems/fame_system.dart';
import 'package:bitweve/shared/ui/game_ui.dart';

class CharacterProfileSheet extends ConsumerWidget {
  const CharacterProfileSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final p = context.gp;
    final c = s.character;
    final x = s.extras;
    final pers = CharacterOptions.personality(x.personality);
    final orientation = const {'heterosexual': 'Heterossexual', 'homosexual': 'Homossexual', 'bisexual': 'Bissexual'}[c.sexualOrientation] ?? c.sexualOrientation;
    final gender = const {'male': 'Masculino', 'female': 'Feminino', 'non_binary': 'Não-binário'}[c.gender] ?? c.gender;

    Widget info(IconData icon, String label, String value, {Color color = GamePalette.violet}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: p.textMuted, fontSize: 13)),
            const SizedBox(width: 12),
            Expanded(child: Text(value, textAlign: TextAlign.right, style: TextStyle(color: p.text, fontWeight: FontWeight.w700, fontSize: 13))),
          ]),
        );

    final stats = [
      (tr('stat.health'), c.health, Icons.favorite_rounded, false),
      (tr('stat.happiness'), c.happiness, Icons.sentiment_satisfied_rounded, false),
      (tr('stat.smarts'), c.smarts, Icons.psychology_rounded, false),
      (tr('stat.looks'), c.looks, Icons.face_retouching_natural_rounded, false),
      (tr('stat.energy'), c.energy, Icons.bolt_rounded, false),
      (tr('stat.stress'), c.stress, Icons.whatshot_rounded, true),
      (tr('stat.reputation'), c.reputation, Icons.verified_rounded, false),
      (tr('stat.charisma'), c.charisma, Icons.record_voice_over_rounded, false),
      ('Disciplina', c.discipline, Icons.schedule_rounded, false),
      ('Condicionamento', c.fitness, Icons.fitness_center_rounded, false),
      ('Fama', c.fame, Icons.star_rounded, false),
      ('Karma', c.karma, Icons.volunteer_activism_rounded, false),
    ];

    return GameSheet(
      title: c.fullName,
      subtitle: 'Ficha do personagem · ${c.currentAge} anos',
      icon: Icons.badge_rounded,
      color: GamePalette.violet,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
        children: [
          GameCard(
            accent: GamePalette.violet,
            glow: true,
            child: Column(
              children: [
                AvatarWidget(
                  config: c.avatarConfig.copyWith(expression: expressionFor(happiness: c.happiness, health: c.health, stress: c.stress)),
                  age: c.currentAge,
                  size: 150,
                  ringColor: GamePalette.violet,
                ),
                const SizedBox(height: 10),
                Text(c.fullName, style: AppTheme.display(24, color: p.text)),
                Text('${AvatarConfig.outfitLabel(c.avatarConfig.outfit)} · ${AvatarConfig.bodyLabel(c.avatarConfig.bodyType)} · ${FameSystem.tier(c.fame)}',
                    style: TextStyle(color: p.textMuted)),
                const SizedBox(height: 12),
                GameButton(
                  label: 'Mudar visual',
                  caption: 'Salão e estilista · ${Fmt.money(300)}',
                  icon: Icons.content_cut_rounded,
                  colors: const [GamePalette.pink, GamePalette.violet],
                  expand: false,
                  onTap: () => _makeover(context, ref, c.avatarConfig, c.currentAge),
                ),
              ],
            ),
          ),
          const SectionTitle('Atributos', icon: Icons.insights_rounded),
          GameCard(
            child: LayoutBuilder(builder: (context, box) {
              final cols = box.maxWidth > 520 ? 3 : 2;
              return Wrap(
                runSpacing: 12,
                spacing: 14,
                children: [
                  for (final st in stats)
                    SizedBox(
                      width: (box.maxWidth - 14 * (cols - 1)) / cols,
                      child: StatMeter(label: st.$1, value: st.$2, icon: st.$3, inverted: st.$4),
                    ),
                ],
              );
            }),
          ),
          const SectionTitle('Identidade', icon: Icons.fingerprint_rounded),
          GameCard(
            child: Column(children: [
              info(Icons.cake_rounded, 'Nascimento', '${x.birthDay} de ${CharacterOptions.months[(x.birthMonth - 1).clamp(0, 11)]} de ${c.birthYear}'),
              info(Icons.auto_awesome_rounded, 'Signo', CharacterOptions.zodiac(x.birthDay, x.birthMonth)),
              info(Icons.wc_rounded, 'Gênero', gender),
              info(Icons.favorite_rounded, 'Orientação', orientation, color: GamePalette.pink),
              info(Icons.public_rounded, 'Nacionalidade', c.country),
              info(Icons.location_city_rounded, 'Cidade', c.city),
              info(pers.icon, 'Personalidade', pers.name, color: pers.color),
              if (x.traits.isNotEmpty)
                info(Icons.star_rounded, 'Características', x.traits.map((t) => CharacterOptions.trait(t)?.name ?? t).join(', '), color: GamePalette.gold),
              info(Icons.house_rounded, 'Origem', CharacterOptions.family(x.familyWealth).name),
            ]),
          ),
          const SectionTitle('Situação', icon: Icons.assignment_rounded),
          GameCard(
            child: Column(children: [
              info(Icons.school_rounded, 'Escolaridade', educationLabel(c.educationLevel)),
              if (x.education.isStudying) info(Icons.menu_book_rounded, 'Estudando', EducationSystem.stageLabel(x.education)),
              info(Icons.work_rounded, 'Ocupação', c.currentJobTitle ?? (x.retired ? 'Aposentado(a)' : 'Nenhuma'), color: GamePalette.blue),
              if (c.currentSalary != null) info(Icons.payments_rounded, 'Salário', '${Fmt.money(c.currentSalary!)}/ano', color: GamePalette.green),
              info(Icons.credit_score_rounded, 'Score de crédito', '${c.creditScore}', color: GamePalette.forValue(((c.creditScore - 300) / 5.5).round())),
              info(Icons.directions_car_rounded, 'Carteira de motorista', c.hasDriversLicense ? 'Sim' : 'Não', color: GamePalette.cyan),
              info(Icons.gavel_rounded, 'Ficha criminal', c.criminalRecord ? 'Com antecedentes (${c.timesArrested} prisões)' : 'Limpa',
                  color: c.criminalRecord ? GamePalette.red : GamePalette.green),
              info(Icons.people_alt_rounded, 'Seguidores', Fmt.compact(x.followers), color: const Color(0xFFA855F7)),
            ]),
          ),
          if (x.jobHistory.isNotEmpty) ...[
            const SectionTitle('Histórico profissional', icon: Icons.history_rounded),
            ...x.jobHistory.reversed.take(12).map((j) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GameCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      const IconBadge(icon: Icons.work_history_rounded, color: GamePalette.blue, size: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(j.title, style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
                          Text('${j.company} · ${j.startAge}–${j.endAge ?? 'atual'} anos${j.reason != null ? ' · ${j.reason}' : ''}',
                              style: TextStyle(color: p.textMuted, fontSize: 12)),
                        ]),
                      ),
                      Text(Fmt.compactMoney(j.salary), style: const TextStyle(color: GamePalette.green, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Future<void> _makeover(BuildContext context, WidgetRef ref, AvatarConfig current, int age) async {
    var draft = current;
    final result = await showDialog<AvatarConfig>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) {
        final p = ctx.gp;
        return Dialog(
          insetPadding: const EdgeInsets.all(14),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  AvatarWidget(config: draft, age: age, size: 84, ringColor: GamePalette.pink),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Novo visual', style: AppTheme.display(22, color: p.text))),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                ]),
              ),
              Expanded(child: AppearanceEditor(config: draft, previewAge: age, onChanged: (c) => setLocal(() => draft = c))),
              Padding(
                padding: const EdgeInsets.all(14),
                child: GameButton(label: 'Confirmar (${Fmt.money(300)})', icon: Icons.check_rounded, onTap: () => Navigator.pop(ctx, draft)),
              ),
            ]),
          ),
        );
      }),
    );
    if (result != null) {
      await ref.read(lifeEngineProvider.notifier).act((svc, st) => svc.changeAppearance(st, result));
    }
  }
}
