import 'package:flutter/material.dart';

import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/shared/ui/game_ui.dart';
import 'avatar_widget.dart';

/// Editor visual de aparência: cada opção é uma miniatura do próprio avatar.
class AppearanceEditor extends StatefulWidget {
  final AvatarConfig config;
  final ValueChanged<AvatarConfig> onChanged;
  final int previewAge;

  const AppearanceEditor({super.key, required this.config, required this.onChanged, this.previewAge = 25});

  @override
  State<AppearanceEditor> createState() => _AppearanceEditorState();
}

class _AppearanceEditorState extends State<AppearanceEditor> with SingleTickerProviderStateMixin {
  static const _tabs = [
    ('Estilo', Icons.checkroom_rounded),
    ('Cabelo', Icons.content_cut_rounded),
    ('Cores', Icons.palette_rounded),
    ('Rosto', Icons.face_rounded),
    ('Corpo', Icons.accessibility_new_rounded),
    ('Acessórios', Icons.diamond_rounded),
  ];
  late final TabController _tab = TabController(length: _tabs.length, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  AvatarConfig get c => widget.config;
  void set(AvatarConfig n) => widget.onChanged(n);

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    return Column(
      children: [
        TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [for (final t in _tabs) Tab(height: 44, icon: Icon(t.$2, size: 18), iconMargin: const EdgeInsets.only(bottom: 2), text: t.$1)],
        ),
        Divider(height: 1, color: p.border),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _grid(OutfitStyle.values, (o) => c.copyWith(outfit: o), (o) => c.outfit == o, (o) => AvatarConfig.outfitLabel(o)),
              _grid(HairStyle.values, (h) => c.copyWith(hairStyle: h), (h) => c.hairStyle == h, (h) => AvatarConfig.hairStyleLabel(h)),
              _colors(),
              _faceTab(),
              _grid(BodyType.values, (b) => c.copyWith(bodyType: b), (b) => c.bodyType == b, (b) => AvatarConfig.bodyLabel(b)),
              _accessories(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _thumb<T>(T value, AvatarConfig preview, bool selected, String label, {AvatarConfig? tapValue}) {
    final p = context.gp;
    return Pressable(
      onTap: () => set(tapValue ?? preview),
      semanticLabel: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? GamePalette.violet.withAlpha(40) : p.cardHigh,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? GamePalette.violet : p.border, width: selected ? 2.2 : 1),
          boxShadow: selected ? [BoxShadow(color: GamePalette.violet.withAlpha(80), blurRadius: 14)] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarWidget(config: preview, age: widget.previewAge, size: 62),
            const SizedBox(height: 6),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: selected ? GamePalette.violet : p.textDim)),
          ],
        ),
      ),
    );
  }

  Widget _grid<T>(List<T> values, AvatarConfig Function(T) apply, bool Function(T) isSel, String Function(T) label) {
    return LayoutBuilder(builder: (context, box) {
      final cols = (box.maxWidth / 100).floor().clamp(3, 8);
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.82),
        itemCount: values.length,
        itemBuilder: (_, i) => _thumb(values[i], apply(values[i]), isSel(values[i]), label(values[i])),
      );
    });
  }

  Widget _swatches(String title, List<String> colors, List<String>? names, String current, AvatarConfig Function(String) apply) {
    final p = context.gp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 6),
          child: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: p.text)),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < colors.length; i++)
              Tooltip(
                message: names != null && i < names.length ? names[i] : colors[i],
                child: Pressable(
                  onTap: () => set(apply(colors[i])),
                  semanticLabel: names != null && i < names.length ? names[i] : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [Color.lerp(hexColor(colors[i]), Colors.white, 0.25)!, hexColor(colors[i])], center: const Alignment(-0.3, -0.3)),
                      border: Border.all(color: current == colors[i] ? GamePalette.violet : p.border, width: current == colors[i] ? 3.5 : 1.5),
                      boxShadow: current == colors[i] ? [BoxShadow(color: GamePalette.violet.withAlpha(110), blurRadius: 10)] : null,
                    ),
                    child: current == colors[i] ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _colors() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _swatches('Tom de pele', AvatarConfig.availableSkins, AvatarConfig.skinNames, c.skinColor, (v) => c.copyWith(skinColor: v)),
        _swatches('Cor do cabelo', AvatarConfig.availableHairColors, AvatarConfig.hairColorNames, c.hairColor, (v) => c.copyWith(hairColor: v)),
        _swatches('Cor dos olhos', AvatarConfig.availableEyeColors, AvatarConfig.eyeColorNames, c.eyeColor, (v) => c.copyWith(eyeColor: v)),
        _swatches('Cor da roupa', AvatarConfig.availableClothesColors, null, c.clothesColor, (v) => c.copyWith(clothesColor: v)),
      ],
    );
  }

  Widget _faceTab() {
    final p = context.gp;
    return LayoutBuilder(builder: (context, box) {
      final cols = (box.maxWidth / 100).floor().clamp(3, 8);
      Widget section(String title, List<Widget> children) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(4, 8, 4, 8), child: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: p.text))),
              GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.82,
                children: children,
              ),
            ],
          );
      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          section('Formato do rosto', [
            for (final f in FaceShape.values)
              _thumb(f, c.copyWith(faceShape: f), c.faceShape == f, const {FaceShape.round: 'Redondo', FaceShape.oval: 'Oval', FaceShape.square: 'Quadrado'}[f]!),
          ]),
          section('Barba', [
            for (final b in BeardStyle.values)
              _thumb(b, c.copyWith(beardStyle: b, hasBeard: false), c.effectiveBeard == b, AvatarConfig.beardLabel(b)),
          ]),
          section('Expressão da foto', [
            for (final e in const [AvatarExpression.happy, AvatarExpression.neutral, AvatarExpression.love, AvatarExpression.surprised])
              _thumb(e, c.copyWith(expression: e), c.expression == e,
                  const {AvatarExpression.happy: 'Sorriso', AvatarExpression.neutral: 'Sério', AvatarExpression.love: 'Apaixonado', AvatarExpression.surprised: 'Surpreso'}[e]!),
          ]),
        ],
      );
    });
  }

  Widget _accessories() {
    return LayoutBuilder(builder: (context, box) {
      final cols = (box.maxWidth / 100).floor().clamp(3, 8);
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.82),
        itemCount: AvatarAccessory.all.length,
        itemBuilder: (_, i) {
          final id = AvatarAccessory.all[i];
          final on = c.has(id);
          // A miniatura sempre mostra o acessório; o toque liga/desliga.
          final preview = on ? c : c.toggleAccessory(id);
          return Stack(
            children: [
              Positioned.fill(child: _thumb(id, preview, on, AvatarAccessory.label(id), tapValue: c.toggleAccessory(id))),
              if (on)
                const Positioned(right: 8, top: 8, child: IgnorePointer(child: Icon(Icons.check_circle_rounded, color: GamePalette.violet, size: 20))),
            ],
          );
        },
      );
    });
  }
}
