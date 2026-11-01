import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late AudioService _audio;

  @override
  void initState() {
    super.initState();
    _audio = ref.read(audioServiceProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: const Text('Configurações', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Áudio e Vibração',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Efeitos Sonoros (SFX)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Toques, promoções e celebrações', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                  value: _audio.sfxEnabled,
                  onChanged: (val) async {
                    await _audio.setSfxEnabled(val);
                    setState(() {});
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Música Ambiente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Trilha sonora do jogo', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                  value: _audio.musicEnabled,
                  onChanged: (val) async {
                    await _audio.setMusicEnabled(val);
                    setState(() {});
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Vibração / Hápticos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Feedback tátil nas decisões', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                  value: _audio.vibrationEnabled,
                  onChanged: (val) async {
                    await _audio.setVibrationEnabled(val);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Armazenamento e Privacidade',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock_outline, color: AppColors.secondary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Salvamento Local Seguro (SQLite)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Todos os dados das suas vidas e conquistas ficam salvos exclusivamente no armazenamento privado deste aparelho celular. Suas vidas continuam intactas ao fechar ou reiniciar o aplicativo, e só serão apagadas caso você decida desinstalar o BitWeve.',
                  style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Sobre o BitWeve',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BitWeve Life Simulator', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                SizedBox(height: 4),
                Text('Versão 1.0.0 • 100% Gratuito sem anúncios ou paywalls', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
