import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/shared/widgets/bw_tap_feedback.dart';

class LotteryModal extends ConsumerStatefulWidget {
  const LotteryModal({super.key});

  @override
  ConsumerState<LotteryModal> createState() => _LotteryModalState();
}

class _LotteryModalState extends ConsumerState<LotteryModal> {
  final Set<int> _selectedNumbers = {};
  List<int>? _drawnNumbers;
  int? _hits;
  double? _prizeWon;
  bool _isDrawing = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _autoPickNumbers(); // Começa com uma sugestão preenchida
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _autoPickNumbers() {
    AudioService().playSfx(GameSfx.buttonTap);
    final rng = Random();
    final numbers = <int>{};
    while (numbers.length < 6) {
      numbers.add(1 + rng.nextInt(60));
    }
    setState(() {
      _selectedNumbers.clear();
      _selectedNumbers.addAll(numbers);
      _drawnNumbers = null;
      _hits = null;
      _prizeWon = null;
    });
  }

  void _toggleNumber(int number) {
    AudioService().playSfx(GameSfx.buttonTap);
    setState(() {
      if (_selectedNumbers.contains(number)) {
        _selectedNumbers.remove(number);
      } else {
        if (_selectedNumbers.length < 6) {
          _selectedNumbers.add(number);
        }
      }
      _drawnNumbers = null;
      _hits = null;
      _prizeWon = null;
    });
  }

  Future<void> _performDraw() async {
    final state = ref.read(lifeEngineProvider).value;
    if (state == null) return;

    if (state.character.bankBalance < 5.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo insuficiente para comprar a aposta (R\$ 5,00).')),
      );
      return;
    }

    if (_selectedNumbers.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione exatamente 6 dezenas para apostar.')),
      );
      return;
    }

    setState(() {
      _isDrawing = true;
    });

    AudioService().playSfx(GameSfx.buttonTap);
    await Future.delayed(const Duration(milliseconds: 600));

    // Executa sorteio via provider
    final chosenList = _selectedNumbers.toList()..sort();
    final result = await ref.read(lifeEngineProvider.notifier).playLottery(chosenList);
    if (result == null || result.drawn.isEmpty) {
      if (mounted) setState(() => _isDrawing = false);
      return;
    }
    // Exibe exatamente o sorteio usado pelo motor (antes era um sorteio visual diferente)
    final sortedDraw = result.drawn;
    final hitsCount = result.hits;
    final prize = result.prize;
    if (result.hits >= 5) _confettiController.play();

    if (mounted) {
      setState(() {
        _isDrawing = false;
        _drawnNumbers = sortedDraw;
        _hits = hitsCount;
        _prizeWon = prize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lifeEngineProvider).value;
    final balance = state?.character.bankBalance ?? 0.0;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.borderDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.casino, color: AppColors.accent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mega-Sena BitWeve',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                          Text(
                            'Jackpot Estimado: R\$ 12.500.000',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Text(
                      'R\$ ${balance.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Bar de dezenas selecionadas & botão Surpresinha
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suas Dezenas (${_selectedNumbers.length}/6):',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: (_selectedNumbers.toList()..sort()).map((n) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  n.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    BwTapFeedback(
                      onTap: _autoPickNumbers,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(40),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary.withAlpha(90)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shuffle, size: 16, color: AppColors.primaryLight),
                            SizedBox(width: 4),
                            Text(
                              'Surpresinha',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Resultado do Sorteio se realizado
              if (_drawnNumbers != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (_prizeWon ?? 0) > 0 ? AppColors.secondary.withAlpha(35) : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (_prizeWon ?? 0) > 0 ? AppColors.secondary : AppColors.borderDark,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        (_prizeWon ?? 0) > 0
                            ? '🎉 $_hits ACERTOS: GANHOU R\$ ${_prizeWon!.toStringAsFixed(2)}! 🎉'
                            : 'Resultado: $_hits acertos. Não foi dessa vez!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: (_prizeWon ?? 0) > 0 ? AppColors.secondary : AppColors.textPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: _drawnNumbers!.map((n) {
                          final hit = _selectedNumbers.contains(n);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: hit ? AppColors.secondary : AppColors.cardHoverDark,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: hit ? Colors.white : AppColors.borderDark),
                            ),
                            child: Text(
                              n.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: hit ? Colors.black : Colors.white70,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),
              const Text(
                'Escolha 6 números de 01 a 60:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
              ),
              const SizedBox(height: 6),

              // Grade de dezenas 1 a 60
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: 60,
                  itemBuilder: (context, index) {
                    final num = index + 1;
                    final isSelected = _selectedNumbers.contains(num);
                    return InkWell(
                      onTap: () => _toggleNumber(num),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.cardDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryLight : AppColors.borderDark,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          num.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondaryDark,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Botão de Apostar
              BwTapFeedback(
                sfx: GameSfx.buttonTap,
                onTap: _isDrawing ? null : _performDraw,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(120),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isDrawing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Apostar na Mega-Sena (R\$ 5,00)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [Colors.amber, Colors.cyan, Colors.purple, Colors.green, Colors.pink],
        ),
      ],
    );
  }
}
