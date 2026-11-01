import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/shared/widgets/bw_tap_feedback.dart';

class CreateCharacterScreen extends ConsumerStatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  ConsumerState<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends ConsumerState<CreateCharacterScreen> {
  final _firstNameController = TextEditingController(text: 'Lucas');
  final _lastNameController = TextEditingController(text: 'Silva');
  String _gender = 'male';
  String _countryId = 'br';
  String _city = 'São Paulo';

  late AvatarConfig _avatar;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _avatar = AvatarConfig.random(gender: _gender, rng: _rng);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _randomizeName() {
    const maleNames = ['Lucas', 'Gabriel', 'Mateus', 'Felipe', 'Leonardo', 'Thiago', 'Rafael', 'Bruno', 'Arthur'];
    const femaleNames = ['Sophia', 'Isabella', 'Julia', 'Mariana', 'Beatriz', 'Camila', 'Larissa', 'Alice'];
    const lastNames = ['Silva', 'Santos', 'Oliveira', 'Souza', 'Rodrigues', 'Ferreira', 'Alves', 'Pereira'];

    final fList = _gender == 'female' ? femaleNames : maleNames;
    setState(() {
      _firstNameController.text = fList[_rng.nextInt(fList.length)];
      _lastNameController.text = lastNames[_rng.nextInt(lastNames.length)];
      _avatar = AvatarConfig.random(gender: _gender, rng: _rng);
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(lifeEngineServiceProvider);
    final countries = service.availableCountries;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: const Text(
          'Criar Vida Personalizada',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          BwTapFeedback(
            sfx: GameSfx.buttonTap,
            onTap: _randomizeName,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.casino, color: AppColors.primaryLight, size: 26),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(80),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AvatarWidget(config: _avatar, size: 110),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        filled: true,
                        fillColor: AppColors.cardDark,
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Sobrenome',
                        filled: true,
                        fillColor: AppColors.cardDark,
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Identidade de Gênero', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13)),
              const SizedBox(height: 6),
              Row(
                children: [
                  _genderChoice('Masculino', 'male'),
                  const SizedBox(width: 8),
                  _genderChoice('Feminino', 'female'),
                  const SizedBox(width: 8),
                  _genderChoice('Não-binário', 'non_binary'),
                ],
              ),
              const SizedBox(height: 20),
              if (countries.isNotEmpty) ...[
                const Text('Local de Nascimento', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _countryId,
                      dropdownColor: AppColors.surfaceDark,
                      isExpanded: true,
                      items: countries.map((c) {
                        return DropdownMenuItem<String>(
                          value: c['id'] as String,
                          child: Text('${c['flag']} ${c['name']}', style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _countryId = val;
                            final selected = countries.firstWhere((c) => c['id'] == val);
                            final cities = (selected['cities'] as List).cast<String>();
                            _city = cities.first;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text('Aparência Física', style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Tom de Pele', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: AvatarConfig.availableSkins.map((skin) {
                  final isSelected = _avatar.skinColor == skin;
                  return GestureDetector(
                    onTap: () => setState(() => _avatar = _avatar.copyWith(skinColor: skin)),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(int.parse(skin.replaceAll('#', '0xFF'))),
                        border: isSelected ? Border.all(color: AppColors.primary, width: 3) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Estilo de Cabelo', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: HairStyle.values.map((style) {
                  final isSelected = _avatar.hairStyle == style;
                  return ChoiceChip(
                    label: Text(style.name),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    onSelected: (_) => setState(() => _avatar = _avatar.copyWith(hairStyle: style)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Cor do Cabelo', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: AvatarConfig.availableHairColors.map((color) {
                  final isSelected = _avatar.hairColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _avatar = _avatar.copyWith(hairColor: color)),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(int.parse(color.replaceAll('#', '0xFF'))),
                        border: isSelected ? Border.all(color: AppColors.primary, width: 3) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Óculos', style: TextStyle(fontSize: 14, color: Colors.white)),
                      value: _avatar.hasGlasses,
                      onChanged: (v) => setState(() => _avatar = _avatar.copyWith(hasGlasses: v)),
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Barba', style: TextStyle(fontSize: 14, color: Colors.white)),
                      value: _avatar.hasBeard,
                      onChanged: (v) => setState(() => _avatar = _avatar.copyWith(hasBeard: v)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              BwTapFeedback(
                sfx: GameSfx.achievement,
                onTap: () async {
                  await ref.read(lifeEngineProvider.notifier).startRandomLife(
                        countryId: _countryId,
                        city: _city,
                        gender: _gender,
                        firstName: _firstNameController.text.trim(),
                        lastName: _lastNameController.text.trim(),
                      );
                  if (context.mounted) {
                    context.go('/game');
                  }
                },
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(90),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Começar Minha Vida no BitWeve 🚀',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderChoice(String label, String value) {
    final isSelected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withAlpha(40) : AppColors.cardDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderDark,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primaryLight : AppColors.textSecondaryDark,
            ),
          ),
        ),
      ),
    );
  }
}
