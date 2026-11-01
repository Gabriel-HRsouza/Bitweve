import 'package:flutter/material.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/life_engine/models/life_log.dart';

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
      case 'family':
        return Icons.people;
      case 'finance':
        return Icons.attach_money;
      case 'health':
        return Icons.favorite_border;
      case 'death':
        return Icons.nightlight_round;
      case 'milestone':
        return Icons.emoji_events;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _parseHex(log.accentColor);
    final iconData = _iconForCategory(log.category);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          const SizedBox(width: 12),
          // Content Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
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
                        fontSize: 14,
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
    );
  }
}
