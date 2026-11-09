import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bitweve/core/i18n/strings.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/businesses/presentation/business_sheet.dart';
import 'package:bitweve/features/careers/presentation/careers_sheet.dart';
import 'package:bitweve/features/character/presentation/character_profile_sheet.dart';
import 'package:bitweve/features/dating/presentation/dating_app_sheet.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart' show lifeEngineProvider;
import 'package:bitweve/features/parties/presentation/party_planner_sheet.dart';
import 'package:bitweve/features/school/presentation/school_sheet.dart';
import 'package:bitweve/features/social_media/presentation/social_app_sheet.dart';
import 'package:bitweve/features/underworld/presentation/justice_sheets.dart';
import 'package:bitweve/features/underworld/presentation/underworld_sheet.dart';
import 'package:bitweve/features/education/presentation/education_sheet.dart';
import 'package:bitweve/features/fame/presentation/fame_sheet.dart';
import 'package:bitweve/features/finances/presentation/crypto_modal.dart';
import 'package:bitweve/features/finances/presentation/finances_sheet.dart';
import 'package:bitweve/features/health/presentation/health_sheet.dart';
import 'package:bitweve/features/life_engine/presentation/widgets/activities_sheet.dart';
import 'package:bitweve/features/life_engine/presentation/widgets/god_mode_modal.dart';
import 'package:bitweve/features/life_engine/presentation/widgets/lottery_modal.dart';
import 'package:bitweve/features/life_engine/services/life_engine_service.dart';
import 'package:bitweve/features/progression/presentation/achievements_sheet.dart';
import 'package:bitweve/features/progression/presentation/missions_sheet.dart';
import 'package:bitweve/features/properties/presentation/properties_sheet.dart';
import 'package:bitweve/features/properties/presentation/vehicles_sheet.dart';
import 'package:bitweve/features/relationships/presentation/relationships_sheet.dart';
import 'package:bitweve/features/shop/presentation/shop_sheet.dart';
import 'package:bitweve/shared/ui/game_ui.dart';

class ModuleDef {
  final String id;
  final String labelKey;
  final IconData icon;
  final Color color;
  final String Function(LifeEngineState s)? status;
  final int minAge;

  const ModuleDef(this.id, this.labelKey, this.icon, this.color, {this.status, this.minAge = 0});

  String get label => tr(labelKey);
}

class Modules {
  static final all = <ModuleDef>[
    ModuleDef('character', 'mod.character', Icons.badge_rounded, GamePalette.violet,
        status: (s) => '${s.character.currentAge} anos'),
    ModuleDef('family', 'mod.family', Icons.family_restroom_rounded, const Color(0xFFFB7185),
        status: (s) => '${s.npcs.where((n) => n.isAlive && n.isFamily).length} parentes'),
    ModuleDef('relationships', 'mod.relationships', Icons.favorite_rounded, GamePalette.pink,
        status: (s) => '${s.npcs.where((n) => n.isAlive && !n.isFamily).length} pessoas'),
    ModuleDef('jobs', 'mod.jobs', Icons.work_rounded, GamePalette.blue, minAge: 14,
        status: (s) => s.character.currentJobTitle ?? 'Sem emprego'),
    ModuleDef('school', 'mod.school', Icons.backpack_rounded, const Color(0xFF4F46E5), minAge: 5,
        status: (s) => s.extras.education.inSchool
            ? 'Popularidade ${s.extras.school.popularity}'
            : (s.extras.education.inHigherEd ? (s.extras.school.institutionName ?? 'Faculdade') : 'Não estuda')),
    ModuleDef('education', 'mod.education', Icons.school_rounded, const Color(0xFF6366F1), minAge: 5,
        status: (s) => s.extras.education.isStudying ? 'Estudando' : 'Vestibular e cursos'),
    ModuleDef('finances', 'mod.finances', Icons.account_balance_rounded, GamePalette.green,
        status: (s) => Fmt.compactMoney(s.netWorth)),
    ModuleDef('shop', 'mod.shop', Icons.shopping_bag_rounded, GamePalette.teal, minAge: 6,
        status: (s) => '${s.extras.inventory.length} itens'),
    ModuleDef('properties', 'mod.properties', Icons.villa_rounded, GamePalette.orange, minAge: 18,
        status: (s) => '${s.properties.length} imóveis'),
    ModuleDef('vehicles', 'mod.vehicles', Icons.directions_car_rounded, GamePalette.cyan, minAge: 16,
        status: (s) => '${s.extras.vehicles.length} veículos'),
    ModuleDef('health', 'mod.health', Icons.medical_services_rounded, GamePalette.red,
        status: (s) => '${s.character.health}% saúde'),
    ModuleDef('fame', 'mod.fame', Icons.star_rounded, const Color(0xFFA855F7), minAge: 12,
        status: (s) => '${Fmt.compact(s.extras.followers)} seguidores'),
    ModuleDef('social', 'mod.social', Icons.bubble_chart_rounded, const Color(0xFFF472B6), minAge: 13,
        status: (s) => s.extras.social.hasAccount ? '@${s.extras.social.handle}' : 'Criar perfil'),
    ModuleDef('dating', 'mod.dating', Icons.local_fire_department_rounded, const Color(0xFFFF5A5F), minAge: 18,
        status: (s) => '${s.extras.dating.matches.where((m) => m.active).length} matches'),
    ModuleDef('parties', 'mod.parties', Icons.celebration_rounded, const Color(0xFFDB2777), minAge: 10,
        status: (s) => '${s.extras.counter('partiesHosted')} festas'),
    ModuleDef('activities', 'mod.activities', Icons.celebration_rounded, GamePalette.gold, minAge: 3),
    ModuleDef('missions', 'mod.missions', Icons.flag_rounded, const Color(0xFFF97316)),
    ModuleDef('achievements', 'mod.achievements', Icons.emoji_events_rounded, const Color(0xFFEAB308)),
    ModuleDef('business', 'mod.business', Icons.rocket_launch_rounded, const Color(0xFF14B8A6), minAge: 18,
        status: (s) => '${s.extras.businesses.length} empresas'),
    ModuleDef('crypto', 'mod.crypto', Icons.currency_bitcoin_rounded, const Color(0xFFF59E0B), minAge: 18),
    ModuleDef('lottery', 'mod.lottery', Icons.casino_rounded, const Color(0xFF22C55E), minAge: 18),
    ModuleDef('crime', 'mod.crime', Icons.local_police_rounded, const Color(0xFF64748B), minAge: 12,
        status: (s) => s.extras.crime.inPrison
            ? 'Preso(a)'
            : (s.extras.crime.pendingCase != null ? 'Julgamento pendente' : 'Notoriedade ${s.extras.crime.notoriety}')),
    ModuleDef('prison', 'mod.prison', Icons.lock_rounded, const Color(0xFF475569),
        status: (s) => s.extras.crime.inPrison ? '${s.extras.crime.yearsLeft} ano(s) restantes' : 'Livre'),
    ModuleDef('settings', 'mod.settings', Icons.settings_rounded, const Color(0xFF94A3B8)),
  ];

  static ModuleDef byId(String id) => all.firstWhere((m) => m.id == id);

  /// Módulos acessíveis enquanto cumpre pena.
  static const prisonAllowed = {'character', 'family', 'relationships', 'health', 'missions', 'achievements', 'settings', 'prison', 'crime', 'finances', 'godmode'};

  static void open(BuildContext context, String id) {
    final st = ProviderScope.containerOf(context, listen: false).read(lifeEngineProvider).value;
    if (st != null && st.extras.crime.inPrison && !prisonAllowed.contains(id)) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(content: Text('Você está na prisão — isso terá que esperar.')));
      showGameSheet(context, const PrisonSheet());
      return;
    }
    switch (id) {
      case 'school':
        showGameSheet(context, const SchoolSheet());
      case 'social':
        showGameSheet(context, const SocialAppSheet());
      case 'dating':
        showGameSheet(context, const DatingAppSheet());
      case 'parties':
        showGameSheet(context, const PartyPlannerSheet());
      case 'prison':
        showGameSheet(context, st?.extras.crime.pendingCase != null && !(st?.extras.crime.inPrison ?? false) ? const TrialSheet() : const PrisonSheet());
      case 'character':
        showGameSheet(context, const CharacterProfileSheet());
      case 'family':
        showGameSheet(context, const RelationshipsSheet(initialTab: 0));
      case 'relationships':
        showGameSheet(context, const RelationshipsSheet(initialTab: 1));
      case 'jobs':
        showGameSheet(context, const CareersSheet());
      case 'education':
        showGameSheet(context, const EducationSheet());
      case 'finances':
        showGameSheet(context, const FinancesSheet());
      case 'shop':
        showGameSheet(context, const ShopSheet());
      case 'properties':
        showGameSheet(context, const PropertiesSheet());
      case 'vehicles':
        showGameSheet(context, const VehiclesSheet());
      case 'health':
        showGameSheet(context, const HealthSheet(), full: false);
      case 'fame':
        showGameSheet(context, const FameSheet());
      case 'activities':
        showGameSheet(context, const ActivitiesSheet());
      case 'missions':
        showGameSheet(context, const MissionsSheet());
      case 'achievements':
        showGameSheet(context, const AchievementsSheet());
      case 'business':
        showGameSheet(context, const BusinessSheet(), full: false);
      case 'crypto':
        showGameSheet(context, const CryptoModal(), full: false);
      case 'lottery':
        showGameSheet(context, const LotteryModal(), full: false);
      case 'crime':
        showGameSheet(context, const UnderworldSheet());
      case 'godmode':
        showGameSheet(context, const GodModeModal(), full: false);
      case 'settings':
        context.push('/settings');
    }
  }
}

/// Botão ilustrado de módulo (ícone em relevo + título + status).
class ModuleTile extends StatelessWidget {
  final ModuleDef module;
  final LifeEngineState? state;
  final VoidCallback onTap;
  final bool compact;

  const ModuleTile({super.key, required this.module, required this.state, required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final locked = state != null && state!.character.currentAge < module.minAge;
    final status = locked ? 'A partir de ${module.minAge} anos' : (state != null ? module.status?.call(state!) : null);
    return GameCard(
      onTap: onTap,
      accent: module.color,
      padding: EdgeInsets.all(compact ? 10 : 12),
      radius: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconBadge(icon: module.icon, color: locked ? const Color(0xFF64748B) : module.color, size: compact ? 42 : 50),
              if (locked)
                const Positioned(right: -4, top: -4, child: Icon(Icons.lock_rounded, size: 16, color: Color(0xFF94A3B8))),
            ],
          ),
          SizedBox(height: compact ? 6 : 8),
          Text(module.label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: compact ? 12 : 13, color: p.text)),
          if (status != null && !compact)
            Text(status, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.5, color: p.textMuted)),
        ],
      ),
    );
  }
}
