import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/fame_system.dart';
import 'package:bitweve/shared/ui/game_ui.dart';

class FameSheet extends ConsumerWidget {
  const FameSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final p = context.gp;
    final tier = FameSystem.tier(s.character.fame);

    return GameSheet(
      title: 'Fama & Redes Sociais',
      subtitle: '${Fmt.compact(s.extras.followers)} seguidores • Nível: $tier',
      icon: Icons.star_rounded,
      color: const Color(0xFFA855F7),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner de Status de Fama
          GameCard(
            accent: const Color(0xFFA855F7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: Color(0xFFA855F7), size: 28),
                        const SizedBox(width: 8),
                        Text(
                          tier,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: p.text),
                        ),
                      ],
                    ),
                    Text(
                      '${s.character.fame}/100 Fama',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFA855F7), fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Seguidores', style: TextStyle(fontSize: 12, color: p.textDim)),
                          Text(Fmt.compact(s.extras.followers),
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: p.text)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Posts Publicados', style: TextStyle(fontSize: 12, color: p.textDim)),
                          Text('${s.extras.counter('socialPosts')}',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: p.text)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('Ações de Criador de Conteúdo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: p.text)),
          const SizedBox(height: 8),

          GameCard(
            child: Column(
              children: [
                _actionTile(
                  icon: Icons.photo_camera_rounded,
                  color: const Color(0xFFEC4899),
                  title: 'Publicar Foto',
                  subtitle: 'Gaste um pouco de tempo para postar fotos e interagir.',
                  onTap: () => ref.read(lifeEngineProvider.notifier).postOnSocialMedia('photo'),
                ),
                const Divider(height: 1),
                _actionTile(
                  icon: Icons.videocam_rounded,
                  color: const Color(0xFF8B5CF6),
                  title: 'Postar Vídeo Curto',
                  subtitle: 'Maior chance de viralizar e explodir em visualizações.',
                  onTap: () => ref.read(lifeEngineProvider.notifier).postOnSocialMedia('video'),
                ),
                const Divider(height: 1),
                _actionTile(
                  icon: Icons.sensors_rounded,
                  color: const Color(0xFFEF4444),
                  title: 'Transmitir Live',
                  subtitle: 'Converse ao vivo com os fãs e receba doações em dinheiro.',
                  onTap: () => ref.read(lifeEngineProvider.notifier).postOnSocialMedia('live'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('Vida de Celebridade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: p.text)),
          const SizedBox(height: 8),

          GameCard(
            child: Column(
              children: [
                _actionTile(
                  icon: Icons.record_voice_over_rounded,
                  color: const Color(0xFF3B82F6),
                  title: 'Conceder Entrevista',
                  subtitle: 'Fale com jornais e podcasts famosos.',
                  onTap: () => ref.read(lifeEngineProvider.notifier).giveInterview(),
                ),
                const Divider(height: 1),
                _actionTile(
                  icon: Icons.theater_comedy_rounded,
                  color: const Color(0xFFF59E0B),
                  title: 'Comparecer a Gala / Festa VIP',
                  subtitle: 'Desfile no tapete vermelho e seja fotografado.',
                  onTap: () => ref.read(lifeEngineProvider.notifier).attendGala(),
                ),
                const Divider(height: 1),
                _actionTile(
                  icon: Icons.monetization_on_rounded,
                  color: const Color(0xFF10B981),
                  title: 'Buscar Patrocínios de Marcas',
                  subtitle: 'Monetize sua imagem com campanhas publicitárias.',
                  onTap: () => ref.read(lifeEngineProvider.notifier).seekSponsor(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (s.extras.headlines.isNotEmpty) ...[
            Text('Manchetes & Noticiário', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: p.text)),
            const SizedBox(height: 8),
            GameCard(
              child: Column(
                children: [
                  for (final h in s.extras.headlines.take(5))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.newspaper_rounded, size: 16, color: Color(0xFFA855F7)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(h, style: TextStyle(fontSize: 12.5, color: p.text)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            IconBadge(icon: icon, color: color, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
