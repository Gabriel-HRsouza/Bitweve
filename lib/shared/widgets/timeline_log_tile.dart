import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/life_engine/models/life_log.dart';
import 'package:bitweve/shared/widgets/bw_tap_feedback.dart';

class TimelineLogTile extends StatelessWidget {
  final LifeLog log;

  const TimelineLogTile({
    super.key,
    required this.log,
  });

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('0xFF$clean'));
    } catch (_) {
      return AppColors.primary;
    }
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'birth':
        return Icons.child_care;
      case 'education':
        return Icons.school;
      case 'career':
        return Icons.work;
      case 'romance':
        return Icons.favorite;
      case 'social':
        return Icons.chat_bubble;
      case 'family':
        return Icons.family_restroom;
      case 'finance':
        return Icons.attach_money;
      case 'health':
        return Icons.favorite_border;
      case 'death':
        return Icons.dangerous;
      case 'milestone':
        return Icons.military_tech;
      case 'chronicle':
        return Icons.cake;
      case 'lifestyle':
        return Icons.explore;
      case 'lottery':
        return Icons.casino;
      case 'pets':
        return Icons.pets;
      case 'hobbies':
        return Icons.palette;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'crime':
        return Icons.policy;
      case 'social_media':
        return Icons.share;
      case 'event_result':
        return Icons.verified;
      default:
        return Icons.auto_awesome;
    }
  }

  void _showDetailModal(BuildContext context, Color accent, IconData iconData) {
    AudioService().playSfx(GameSfx.buttonTap);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withAlpha(35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: accent, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Aos ${log.age} Anos (Ano ${log.year})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        content: Text(
          log.textContent,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimaryDark, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar', style: TextStyle(color: AppColors.primaryLight)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = _parseHex(log.accentColor);
    final iconData = _iconForCategory(log.category);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: BwTapFeedback(
        onTap: () => _showDetailModal(context, accent, iconData),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Age Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withAlpha(35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accent.withAlpha(80), width: 1),
              ),
              child: Text(
                '${log.age} a',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Content Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDark, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(iconData, size: 18, color: accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        log.textContent,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textPrimaryDark,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0, duration: 200.ms);
  }
}
