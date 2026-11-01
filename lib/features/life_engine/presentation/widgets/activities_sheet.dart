import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/presentation/widgets/lottery_modal.dart';
import 'package:bitweve/features/health/presentation/health_sheet.dart';
import 'package:bitweve/features/crime/presentation/crime_sheet.dart';
import 'package:bitweve/features/businesses/presentation/business_sheet.dart';
import 'package:bitweve/shared/widgets/bw_tap_feedback.dart';

class ActivitiesSheet extends ConsumerWidget {
  const ActivitiesSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Atividades de Vida',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '11 Atividades',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildActivityTile(
                  icon: Icons.fitness_center,
                  color: AppColors.statHealth,
                  title: 'Treinar na Academia',
                  subtitle: 'Melhora condicionamento, aparência física e alivia o estresse.',
                  badge: 'Grátis',
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(lifeEngineProvider.notifier).goToGym();
                  },
                ),
                _buildActivityTile(
                  icon: Icons.casino,
                  color: AppColors.accent,
                  title: 'Mega-Sena BitWeve',
                  subtitle: 'Escolha suas 6 dezenas e concorra ao Jackpot de R\$ 12,5 Milhões!',
                  badge: 'R\$ 5',
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const LotteryModal(),
                    );
                  },
                ),
                _buildActivityTile(
                  icon: Icons.movie,
                  color: AppColors.primaryLight,
                  title: 'Ir ao Cinema',
                  subtitle: 'Assista ao lançamento mais recente nas telonas com pipoca.',
                  badge: 'R\$ 40',
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(lifeEngineProvider.notifier).goToCinema();
                  },
                ),
                _buildActivityTile(
                  icon: Icons.local_hospital,
                  color: AppColors.accentRose,
                  title: 'Centro de Saúde & Cuidados',
                  subtitle: 'SUS, consultas particulares, psicoterapia, neurodesenvolvimento e medicamentos.',
                  badge: 'Hospital',
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const HealthSheet(),
                    );
                  },
                ),
                _buildActivityTile(
                  icon: Icons.shopping_bag,
                  color: AppColors.accent,
                  title: 'Compras no Shopping',
                  subtitle: 'Renove o guarda-roupa com roupas estilosas e aumente sua aparência.',
                  badge: 'R\$ 350',
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(lifeEngineProvider.notifier).shoppingSpree();
                  },
                ),
                _buildActivityTile(
                  icon: Icons.pets,
                  color: AppColors.statHappiness,
                  title: 'Adotar um Pet',
                  subtitle: 'Acolha um cãozinho ou gatinho para trazer alegria e amor incondicional.',
                  badge: 'Adoção',
                  onTap: () {
                    Navigator.pop(context);
                    _showAdoptPetDialog(context, ref);
                  },
                ),
                _buildActivityTile(
                  icon: Icons.palette,
                  color: const Color(0xFF8B5CF6),
                  title: 'Praticar um Hobby',
                  subtitle: 'Pintura, música, culinária ou jardinagem para inspirar a mente.',
                  badge: 'Lazer',
                  onTap: () {
                    Navigator.pop(context);
                    _showHobbyDialog(context, ref);
                  },
                ),
                _buildActivityTile(
                  icon: Icons.flight_takeoff,
                  color: const Color(0xFF00F2FE),
                  title: 'Férias & Descanso',
                  subtitle: 'Viagem para um resort paradisíaco para zerar todo o estresse.',
                  badge: 'R\$ 1.200',
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(lifeEngineProvider.notifier).restAndVacation();
                  },
                ),
                _buildActivityTile(
                  icon: Icons.share,
                  color: const Color(0xFFEC4899),
                  title: 'Postar nas Redes Sociais',
                  subtitle: 'Crie postagens e vídeos virais para ganhar seguidores e fama.',
                  badge: 'Engajamento',
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(lifeEngineProvider.notifier).postOnSocialMedia();
                  },
                ),
                _buildActivityTile(
                  icon: Icons.menu_book,
                  color: const Color(0xFF3B82F6),
                  title: 'Estudos na Biblioteca',
                  subtitle: 'Devore livros e artigos científicos para expandir seu intelecto.',
                  badge: 'Grátis',
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(lifeEngineProvider.notifier).studyExtra();
                  },
                ),
                _buildActivityTile(
                  icon: Icons.business_center,
                  color: Colors.amber,
                  title: 'Empreendedorismo & Startups',
                  subtitle: 'Abra restaurantes, startups tech, gerencie funcionários e fature milhões.',
                  badge: 'Negócios',
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const BusinessSheet(),
                    );
                  },
                ),
                _buildActivityTile(
                  icon: Icons.gavel,
                  color: const Color(0xFFEF4444),
                  title: 'Submundo & Justiça Criminal',
                  subtitle: 'Golpes, desvios e delitos de alto risco narrativo com consequências judiciais.',
                  badge: 'Justiça',
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const CrimeSheet(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String badge,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: BwTapFeedback(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryDark,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color.withAlpha(80)),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdoptPetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        final nameController = TextEditingController(text: 'Pipoca');
        String chosenType = 'Cachorrinho Caramelo';

        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.pets, color: AppColors.statHappiness),
                  SizedBox(width: 10),
                  Text('Adotar Novo Pet', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Escolha o tipo de pet:', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: chosenType,
                    dropdownColor: AppColors.cardDark,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.cardDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Cachorrinho Caramelo', child: Text('🐶 Cachorrinho Caramelo')),
                      DropdownMenuItem(value: 'Gatinho Siamês', child: Text('🐱 Gatinho Siamês')),
                      DropdownMenuItem(value: 'Golden Retriever', child: Text('🐕 Golden Retriever')),
                      DropdownMenuItem(value: 'Gato Preto da Sorte', child: Text('🐈 Gato Preto')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => chosenType = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Dê um nome carinhoso:', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.cardDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondaryDark)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    final name = nameController.text.trim().isEmpty ? 'Amigo' : nameController.text.trim();
                    Navigator.pop(ctx);
                    ref.read(lifeEngineProvider.notifier).adoptPet(chosenType, name);
                  },
                  child: const Text('Adotar com Amor'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showHobbyDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        final hobbies = [
          {'title': 'Tocar Violão e Compor', 'icon': Icons.music_note, 'color': AppColors.primaryLight},
          {'title': 'Pintura a Óleo', 'icon': Icons.brush, 'color': AppColors.secondary},
          {'title': 'Culinária Gourmet', 'icon': Icons.restaurant, 'color': AppColors.accent},
          {'title': 'Jardinagem & Flores', 'icon': Icons.yard, 'color': AppColors.statHealth},
        ];

        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Escolha um Hobby', style: TextStyle(color: Colors.white, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: hobbies.map((h) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  tileColor: AppColors.cardDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: Icon(h['icon'] as IconData, color: h['color'] as Color),
                  title: Text(h['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondaryDark, size: 18),
                  onTap: () {
                    Navigator.pop(ctx);
                    ref.read(lifeEngineProvider.notifier).practiceHobby(h['title'] as String);
                  },
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Voltar', style: TextStyle(color: AppColors.textSecondaryDark)),
            ),
          ],
        );
      },
    );
  }
}
