import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/social_media_system.dart';
import 'package:bitweve/features/social_media/data/social_catalog.dart';
import 'package:bitweve/features/social_media/models/social_state.dart';
import 'package:bitweve/shared/ui/game_ui.dart';
import 'package:bitweve/shared/ui/scene_art.dart';

const _brand = [Color(0xFFF472B6), Color(0xFF7C3AED)];

PhotoArt _photoFor(String imageKey, {double? height}) {
  final parts = imageKey.split('_');
  final cat = SocialCatalog.category(parts.first);
  final i = int.tryParse(parts.length > 1 ? parts.last : '0') ?? 0;
  return PhotoArt(motif: cat.photos[i % cat.photos.length], colors: cat.colors, seed: imageKey.hashCode, height: height);
}

/// Rede social "Pulso".
class SocialAppSheet extends ConsumerStatefulWidget {
  const SocialAppSheet({super.key});

  @override
  ConsumerState<SocialAppSheet> createState() => _SocialAppSheetState();
}

class _SocialAppSheetState extends ConsumerState<SocialAppSheet> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final soc = s.extras.social;
    final age = s.character.currentAge;
    if (age < SocialMediaSystem.minAge) {
      return const GameSheet(
        title: SocialCatalog.appName,
        icon: Icons.bubble_chart_rounded,
        color: Color(0xFFF472B6),
        body: EmptyState(icon: Icons.child_care_rounded, title: 'Ainda não', message: 'O Pulso aceita usuários a partir de 13 anos.', color: Color(0xFFF472B6)),
      );
    }
    if (!soc.hasAccount) return _CreateAccount();
    return GameSheet(
      title: SocialCatalog.appName,
      subtitle: '@${soc.handle}${soc.verified ? ' ✔' : ''} · ${Fmt.compact(s.extras.followers)} seguidores',
      icon: Icons.bubble_chart_rounded,
      color: _brand.first,
      actions: [
        IconButton(
          tooltip: 'Nova publicação',
          onPressed: () => showGameSheet(context, const ComposePostSheet()),
          icon: const Icon(Icons.add_box_rounded, color: Color(0xFFF472B6)),
        ),
      ],
      header: TabBar(controller: _tab, isScrollable: true, tabAlignment: TabAlignment.start, tabs: [
        const Tab(icon: Icon(Icons.dynamic_feed_rounded, size: 18), text: 'Feed'),
        const Tab(icon: Icon(Icons.grid_on_rounded, size: 18), text: 'Meu perfil'),
        Tab(icon: const Icon(Icons.mail_rounded, size: 18), text: 'Mensagens${soc.unread > 0 ? ' (${soc.unread})' : ''}'),
        const Tab(icon: Icon(Icons.trending_up_rounded, size: 18), text: 'Tendências'),
      ]),
      body: TabBarView(controller: _tab, children: [_feed(s), _profile(s), _inbox(s), _trends(s)]),
    );
  }

  Widget _feed(LifeEngineState s) {
    final p = context.gp;
    final feed = SocialMediaSystem.feed(s);
    final notifier = ref.read(lifeEngineProvider.notifier);
    if (feed.isEmpty) {
      return const EmptyState(icon: Icons.people_outline_rounded, title: 'Feed vazio', message: 'Conheça mais pessoas para ver publicações aqui.');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
      itemCount: feed.length,
      itemBuilder: (context, i) {
        final f = feed[i];
        final liked = s.extras.social.likedFeed.contains(f.id);
        final commented = s.extras.social.commentedFeed.contains(f.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GameCard(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                AvatarWidget(config: f.author.avatarConfig, age: f.author.age, size: 36, animate: false),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(f.author.fullName, style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
                    Text('${f.author.relationLabel} · ${f.category.name}', style: TextStyle(color: p.textMuted, fontSize: 11)),
                  ]),
                ),
              ]),
              const SizedBox(height: 8),
              AspectRatio(aspectRatio: 1.4, child: _photoFor('${f.category.id}_${f.photo}')),
              const SizedBox(height: 6),
              Text(f.caption, style: TextStyle(color: p.text)),
              Row(children: [
                IconButton(
                  onPressed: liked ? null : () => notifier.act((v, st) => v.likeFeed(st, f.id, f.author.id)),
                  icon: Icon(liked ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: liked ? GamePalette.pink : p.textDim),
                ),
                Text(Fmt.compact(f.likes + (liked ? 1 : 0)), style: TextStyle(color: p.textDim)),
                IconButton(
                  tooltip: 'Comentar',
                  onPressed: commented
                      ? null
                      : () async {
                          final positive = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => SimpleDialog(title: const Text('Comentar'), children: [
                              SimpleDialogOption(onPressed: () => Navigator.pop(ctx, true), child: const Text('😍 “Que incrível!”')),
                              SimpleDialogOption(onPressed: () => Navigator.pop(ctx, true), child: const Text('😂 “Hahaha muito bom”')),
                              SimpleDialogOption(onPressed: () => Navigator.pop(ctx, false), child: const Text('🙄 “Forçado, hein”')),
                            ]),
                          );
                          if (positive != null) await notifier.act((v, st) => v.commentFeed(st, f.id, f.author.id, positive));
                        },
                  icon: Icon(commented ? Icons.mode_comment_rounded : Icons.mode_comment_outlined, color: p.textDim),
                ),
                IconButton(
                  tooltip: 'Compartilhar',
                  onPressed: () => notifier.act((v, st) => v.shareFeed(st, f.author.id)),
                  icon: Icon(Icons.share_rounded, color: p.textDim),
                ),
              ]),
            ]),
          ),
        );
      },
    );
  }

  Widget _profile(LifeEngineState s) {
    final p = context.gp;
    final soc = s.extras.social;
    final c = s.character;
    return ListView(padding: const EdgeInsets.fromLTRB(14, 10, 14, 24), children: [
      GameCard(
        accent: _brand.first,
        child: Row(children: [
          AvatarWidget(config: c.avatarConfig, age: c.currentAge, size: 70, ringColor: _brand.first),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('@${soc.handle}', style: TextStyle(color: p.text, fontWeight: FontWeight.w900, fontSize: 16)),
                if (soc.verified) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.verified_rounded, color: GamePalette.blue, size: 18)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                _Num(label: 'Posts', value: soc.posts.length),
                _Num(label: 'Seguidores', value: s.extras.followers),
                _Num(label: 'Curtidas', value: soc.totalLikes),
              ]),
              const SizedBox(height: 6),
              StatMeter(label: 'Reputação online', value: soc.socialRep, icon: Icons.shield_rounded, compact: true),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      GameButton(label: 'Nova publicação', icon: Icons.add_a_photo_rounded, colors: _brand, onTap: () => showGameSheet(context, const ComposePostSheet())),
      const SizedBox(height: 12),
      if (soc.posts.isEmpty)
        Text('Você ainda não publicou nada.', textAlign: TextAlign.center, style: TextStyle(color: p.textMuted))
      else
        LayoutBuilder(builder: (context, box) {
          final cols = (box.maxWidth / 140).floor().clamp(3, 5);
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              for (final post in soc.posts)
                GestureDetector(
                  onTap: () => showGameSheet(context, PostDetailSheet(postId: post.id)),
                  child: Stack(fit: StackFit.expand, children: [
                    _photoFor(post.imageKey),
                    Positioned(
                      left: 4,
                      bottom: 4,
                      child: Text('♥ ${Fmt.compact(post.likes)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, shadows: [Shadow(blurRadius: 4)])),
                    ),
                    if (post.controversy) const Positioned(right: 4, top: 4, child: Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 16)),
                    if (post.viral) const Positioned(right: 4, top: 4, child: Icon(Icons.trending_up_rounded, color: Colors.white, size: 16)),
                  ]),
                ),
            ],
          );
        }),
    ]);
  }

  Widget _inbox(LifeEngineState s) {
    final p = context.gp;
    final soc = s.extras.social;
    final notifier = ref.read(lifeEngineProvider.notifier);
    if (soc.inbox.isEmpty) {
      return const EmptyState(icon: Icons.mail_outline_rounded, title: 'Sem mensagens', message: 'Publique para receber mensagens de fãs, amigos e marcas.');
    }
    return ListView(padding: const EdgeInsets.fromLTRB(14, 10, 14, 24), children: [
      if (soc.unread > 0)
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => notifier.act((v, st) => v.markInboxRead(st)), child: const Text('Marcar tudo como lido'))),
      for (final m in soc.inbox)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GameCard(
            accent: m.kind == 'brand' ? GamePalette.gold : (m.kind == 'hater' ? GamePalette.red : (m.read ? null : _brand.first)),
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(switch (m.kind) { 'brand' => Icons.storefront_rounded, 'hater' => Icons.mood_bad_rounded, 'friend' => Icons.person_rounded, _ => Icons.star_rounded },
                    size: 18, color: p.textDim),
                const SizedBox(width: 6),
                Expanded(child: Text(m.from, style: TextStyle(color: p.text, fontWeight: FontWeight.w800))),
                Text('${m.age} anos', style: TextStyle(color: p.textMuted, fontSize: 11)),
              ]),
              const SizedBox(height: 4),
              Text(m.text, style: TextStyle(color: p.textDim)),
              if (m.reply != null)
                Padding(padding: const EdgeInsets.only(top: 6), child: Text('Você: ${m.reply}', style: TextStyle(color: _brand.first, fontWeight: FontWeight.w700)))
              else
                Wrap(spacing: 6, children: [
                  if (m.kind == 'brand') ActionChip(label: const Text('Aceitar publi'), onPressed: () => notifier.act((v, st) => v.replyDm(st, m.id, 'accept'))),
                  ActionChip(label: const Text('Responder com carinho'), onPressed: () => notifier.act((v, st) => v.replyDm(st, m.id, 'kind'))),
                  ActionChip(label: const Text('Ignorar'), onPressed: () => notifier.act((v, st) => v.replyDm(st, m.id, 'ignore'))),
                ]),
            ]),
          ),
        ),
    ]);
  }

  Widget _trends(LifeEngineState s) {
    final p = context.gp;
    final year = s.character.birthYear + s.character.currentAge;
    final trends = SocialMediaSystem.trends(year);
    return ListView(padding: const EdgeInsets.fromLTRB(14, 10, 14, 24), children: [
      Text('Em alta em $year', style: AppTheme.display(18, color: p.text)),
      const SizedBox(height: 4),
      Text('Posts nessas categorias têm 50% mais alcance.', style: TextStyle(color: p.textMuted)),
      const SizedBox(height: 12),
      for (var i = 0; i < trends.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GameCard(
            onTap: () => showGameSheet(context, ComposePostSheet(initialCategory: trends[i])),
            accent: SocialCatalog.category(trends[i]).colors.first,
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              SizedBox(width: 70, height: 70, child: _photoFor('${trends[i]}_$i')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('#${i + 1} · ${SocialCatalog.category(trends[i]).name}', style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
                  Text('#${SocialCatalog.category(trends[i]).name.toLowerCase().replaceAll(' ', '')}$year',
                      style: TextStyle(color: _brand.first, fontWeight: FontWeight.w700)),
                ]),
              ),
              const Icon(Icons.trending_up_rounded, color: GamePalette.green),
            ]),
          ),
        ),
    ]);
  }
}

class _Num extends StatelessWidget {
  final String label;
  final int value;
  const _Num({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(Fmt.compact(value), style: TextStyle(color: context.gp.text, fontWeight: FontWeight.w900)),
          Text(label, style: TextStyle(color: context.gp.textMuted, fontSize: 10.5)),
        ]),
      );
}

class _CreateAccount extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends ConsumerState<_CreateAccount> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    return GameSheet(
      title: SocialCatalog.appName,
      subtitle: 'Crie seu perfil',
      icon: Icons.bubble_chart_rounded,
      color: _brand.first,
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const IconBadge(icon: Icons.bubble_chart_rounded, color: Color(0xFFF472B6), size: 80),
        const SizedBox(height: 14),
        Text('Compartilhe sua vida, conquiste seguidores e cuidado com as polêmicas!', textAlign: TextAlign.center, style: TextStyle(color: p.textDim)),
        const SizedBox(height: 16),
        TextField(controller: _ctl, maxLength: 24, decoration: const InputDecoration(prefixText: '@', labelText: 'Nome de usuário')),
        const SizedBox(height: 10),
        GameButton(
          label: 'Criar conta',
          icon: Icons.person_add_rounded,
          colors: _brand,
          onTap: () => ref.read(lifeEngineProvider.notifier).act((v, st) => v.createSocialAccount(st, _ctl.text)),
        ),
      ]),
    );
  }
}

/// Criação de publicação: categoria → imagem → legenda.
class ComposePostSheet extends ConsumerStatefulWidget {
  final String? initialCategory;
  const ComposePostSheet({super.key, this.initialCategory});

  @override
  ConsumerState<ComposePostSheet> createState() => _ComposePostSheetState();
}

class _ComposePostSheetState extends ConsumerState<ComposePostSheet> {
  late String _cat = widget.initialCategory ?? 'photos';
  int _photo = 0;
  final _caption = TextEditingController();

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final p = context.gp;
    final cat = SocialCatalog.category(_cat);
    final blocker = SocialMediaSystem.categoryBlocker(s, _cat);
    final trending = SocialMediaSystem.trends(s.character.birthYear + s.character.currentAge).contains(_cat);
    final used = s.extras.actionsThisYear['post'] ?? 0;
    return GameSheet(
      title: 'Nova publicação',
      subtitle: '$used de 6 posts neste ano',
      icon: Icons.add_a_photo_rounded,
      color: cat.colors.first,
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        Text('1. Categoria', style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final c in SocialCatalog.categories)
            ChoiceChip(
              avatar: Icon(c.icon, size: 16),
              label: Text(c.name),
              selected: _cat == c.id,
              onSelected: (_) => setState(() {
                _cat = c.id;
                _photo = 0;
              }),
            ),
        ]),
        if (blocker != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              const Icon(Icons.lock_rounded, size: 16, color: GamePalette.orange),
              const SizedBox(width: 6),
              Expanded(child: Text('${cat.requirement ?? 'Indisponível'} — $blocker', style: const TextStyle(color: GamePalette.orange))),
            ]),
          ),
        if (trending)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(children: [Icon(Icons.trending_up_rounded, color: GamePalette.green, size: 16), SizedBox(width: 6), Text('Em alta! +50% de alcance', style: TextStyle(color: GamePalette.green))]),
          ),
        const SizedBox(height: 14),
        Text('2. Imagem', style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Row(children: [
          for (var i = 0; i < cat.photos.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _photo = i),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _photo == i ? cat.colors.first : Colors.transparent, width: 3),
                  ),
                  child: AspectRatio(aspectRatio: 1, child: _photoFor('${_cat}_$i')),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 14),
        Text('3. Legenda', style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        TextField(controller: _caption, maxLength: 140, decoration: const InputDecoration(hintText: 'Escreva algo (ou use uma sugestão)')),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final c in cat.captions) ActionChip(label: Text(c), onPressed: () => setState(() => _caption.text = c)),
        ]),
        const SizedBox(height: 14),
        AspectRatio(aspectRatio: 1.4, child: _photoFor('${_cat}_$_photo')),
        const SizedBox(height: 14),
        GameButton(
          label: 'Publicar',
          icon: Icons.send_rounded,
          colors: cat.colors,
          onTap: blocker != null || used >= 6
              ? null
              : () async {
                  await ref.read(lifeEngineProvider.notifier).act((v, st) => v.publishPost(st, _cat, _photo, _caption.text));
                  if (context.mounted) Navigator.of(context).maybePop();
                },
        ),
        const SizedBox(height: 8),
        Text('Posts influenciam seguidores, fama, reputação e relações. Categorias polêmicas (humor, luxo, festas) podem dar errado.',
            style: TextStyle(color: p.textMuted, fontSize: 11.5)),
      ]),
    );
  }
}

/// Detalhe de um post próprio: curtidas, comentários (com resposta) e exclusão.
class PostDetailSheet extends ConsumerWidget {
  final String postId;
  const PostDetailSheet({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(lifeEngineProvider).value;
    final SocialPost? post = s?.extras.social.posts.where((e) => e.id == postId).firstOrNull;
    if (s == null || post == null) return const SizedBox.shrink();
    final p = context.gp;
    final cat = SocialCatalog.category(post.category);
    final notifier = ref.read(lifeEngineProvider.notifier);
    return GameSheet(
      title: cat.name,
      subtitle: '${post.age} anos · ${post.year}',
      icon: cat.icon,
      color: cat.colors.first,
      actions: [
        IconButton(
          tooltip: 'Apagar publicação',
          onPressed: () async {
            final ok = await confirmDialog(context, title: 'Apagar post?', message: 'A publicação some do seu perfil.', confirm: 'Apagar');
            if (!ok) return;
            await notifier.act((v, st) => v.deletePost(st, post.id));
            if (context.mounted) Navigator.of(context).maybePop();
          },
          icon: const Icon(Icons.delete_rounded, color: GamePalette.red),
        ),
      ],
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        AspectRatio(aspectRatio: 1.3, child: _photoFor(post.imageKey)),
        const SizedBox(height: 10),
        Text(post.caption, style: TextStyle(color: p.text, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 6, children: [
          Pill('♥ ${Fmt.compact(post.likes)}', color: GamePalette.pink),
          Pill('↗ ${Fmt.compact(post.shares)}', color: GamePalette.blue),
          Pill('+${Fmt.compact(post.followersGained < 0 ? 0 : post.followersGained)} seguidores', color: GamePalette.green),
          if (post.viral) const Pill('Viral', color: GamePalette.gold, icon: Icons.trending_up_rounded),
          if (post.controversy) const Pill('Polêmica', color: GamePalette.red, icon: Icons.local_fire_department_rounded),
        ]),
        const SectionTitle('Comentários', icon: Icons.forum_rounded),
        if (post.comments.isEmpty) Text('Sem comentários.', style: TextStyle(color: p.textMuted)),
        for (var i = 0; i < post.comments.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GameCard(
              padding: const EdgeInsets.all(10),
              accent: post.comments[i].mood < 0 ? GamePalette.red : null,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(post.comments[i].author, style: TextStyle(color: p.text, fontWeight: FontWeight.w800)),
                Text(post.comments[i].text, style: TextStyle(color: p.textDim)),
                if (post.comments[i].reply != null)
                  Padding(padding: const EdgeInsets.only(top: 4), child: Text('↳ Você: ${post.comments[i].reply}', style: TextStyle(color: cat.colors.first)))
                else
                  Wrap(spacing: 6, children: [
                    ActionChip(label: const Text('Obrigado(a)! ❤️'), onPressed: () => notifier.act((v, st) => v.replyComment(st, post.id, i, 'Obrigado(a)! ❤️'))),
                    ActionChip(label: const Text('Haha 😂'), onPressed: () => notifier.act((v, st) => v.replyComment(st, post.id, i, 'Haha 😂'))),
                    if (post.comments[i].mood < 0)
                      ActionChip(label: const Text('Rebater 😒'), onPressed: () => notifier.act((v, st) => v.replyComment(st, post.id, i, 'Ninguém te perguntou 😒'))),
                  ]),
              ]),
            ),
          ),
      ]),
    );
  }
}
