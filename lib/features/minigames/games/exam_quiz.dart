import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/shared/ui/game_ui.dart';

class _Q {
  final String text;
  final List<String> options;
  final int answer;
  const _Q(this.text, this.options, this.answer);
}

/// Prova: 5 questões geradas conforme a idade. Devolve a nota (0..1) ou null se desistir.
Future<double?> showExamQuiz(BuildContext context, {required int age, required bool college, String subject = 'Prova'}) {
  return Navigator.of(context).push<double>(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => _ExamQuiz(age: age, college: college, subject: subject),
  ));
}

class _ExamQuiz extends StatefulWidget {
  final int age;
  final bool college;
  final String subject;
  const _ExamQuiz({required this.age, required this.college, required this.subject});

  @override
  State<_ExamQuiz> createState() => _ExamQuizState();
}

class _ExamQuizState extends State<_ExamQuiz> {
  final _rng = Random();
  late final List<_Q> _qs = List.generate(5, (i) => _make(i));
  int _i = 0;
  int _correct = 0;
  int? _picked;
  double _time = 15;
  Timer? _timer;

  static const _facts = [
    ('Capital do Brasil?', ['Brasília', 'Rio de Janeiro', 'São Paulo', 'Salvador']),
    ('Planeta mais próximo do Sol?', ['Mercúrio', 'Vênus', 'Terra', 'Marte']),
    ('Quem escreveu "Dom Casmurro"?', ['Machado de Assis', 'José de Alencar', 'Clarice Lispector', 'Jorge Amado']),
    ('Fórmula da água?', ['H₂O', 'CO₂', 'O₂', 'NaCl']),
    ('Maior oceano da Terra?', ['Pacífico', 'Atlântico', 'Índico', 'Ártico']),
    ('Ano da Independência do Brasil?', ['1822', '1889', '1500', '1922']),
    ('Órgão que bombeia o sangue?', ['Coração', 'Pulmão', 'Fígado', 'Rim']),
    ('"Book" em português é...', ['Livro', 'Caderno', 'Mesa', 'Lápis']),
    ('Quantos lados tem um hexágono?', ['6', '5', '7', '8']),
    ('Gás que as plantas absorvem?', ['Gás carbônico', 'Oxigênio', 'Hélio', 'Nitrogênio']),
  ];

  _Q _make(int i) {
    final hard = widget.college ? 3 : (widget.age < 10 ? 0 : (widget.age < 14 ? 1 : 2));
    if (i.isOdd) {
      final f = _facts[_rng.nextInt(_facts.length)];
      final opts = List.of(f.$2)..shuffle(_rng);
      return _Q(f.$1, opts, opts.indexOf(f.$2.first));
    }
    int a, b, ans;
    String text;
    switch (hard) {
      case 0:
        a = 1 + _rng.nextInt(10);
        b = 1 + _rng.nextInt(10);
        ans = a + b;
        text = '$a + $b = ?';
      case 1:
        a = 2 + _rng.nextInt(10);
        b = 2 + _rng.nextInt(10);
        ans = a * b;
        text = '$a × $b = ?';
      case 2:
        a = 10 + _rng.nextInt(40);
        b = 2 + _rng.nextInt(8);
        final c = 1 + _rng.nextInt(20);
        ans = a * b - c;
        text = '$a × $b − $c = ?';
      default:
        final x = 2 + _rng.nextInt(12);
        a = 2 + _rng.nextInt(6);
        b = _rng.nextInt(30);
        ans = x;
        text = 'Resolva: ${a}x + $b = ${a * x + b}. x = ?';
    }
    final opts = <int>{ans};
    while (opts.length < 4) {
      opts.add(ans + _rng.nextInt(11) - 5);
    }
    final list = opts.map((e) => '$e').toList()..shuffle(_rng);
    return _Q(text, list, list.indexOf('$ans'));
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _time = 15;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) return;
      setState(() => _time -= 0.1);
      if (_time <= 0) _answer(-1);
    });
  }

  void _answer(int k) {
    if (_picked != null) return;
    _timer?.cancel();
    final right = k == _qs[_i].answer;
    if (right) _correct++;
    AudioService().playSfx(right ? GameSfx.positiveEvent : GameSfx.error);
    setState(() => _picked = k);
    Future.delayed(const Duration(milliseconds: 750), () {
      if (!mounted) return;
      if (_i >= _qs.length - 1) {
        Navigator.of(context).pop(_correct / _qs.length);
        return;
      }
      setState(() {
        _i++;
        _picked = null;
      });
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final q = _qs[_i];
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} · Questão ${_i + 1}/5'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                LinearProgressIndicator(value: (_time / 15).clamp(0, 1), minHeight: 8, color: _time > 5 ? GamePalette.green : GamePalette.red),
                const SizedBox(height: 26),
                Text(q.text, textAlign: TextAlign.center, style: AppTheme.display(24, color: p.text)),
                const SizedBox(height: 26),
                for (var k = 0; k < q.options.length; k++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GameCard(
                      onTap: _picked == null ? () => _answer(k) : null,
                      accent: _picked == null
                          ? null
                          : (k == q.answer ? GamePalette.green : (k == _picked ? GamePalette.red : null)),
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        CircleAvatar(radius: 14, backgroundColor: GamePalette.violet.withAlpha(60), child: Text(String.fromCharCode(65 + k))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(q.options[k], style: TextStyle(color: p.text, fontSize: 17, fontWeight: FontWeight.w700))),
                        if (_picked != null && k == q.answer) const Icon(Icons.check_circle, color: GamePalette.green),
                        if (_picked == k && k != q.answer) const Icon(Icons.cancel, color: GamePalette.red),
                      ]),
                    ),
                  ),
                const SizedBox(height: 10),
                Text('Acertos: $_correct', textAlign: TextAlign.center, style: TextStyle(color: p.textDim)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
