import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bitweve/core/database/app_database.dart';
import 'package:bitweve/core/theme/app_colors.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';

class SavesScreen extends ConsumerStatefulWidget {
  const SavesScreen({super.key});

  @override
  ConsumerState<SavesScreen> createState() => _SavesScreenState();
}

class _SavesScreenState extends ConsumerState<SavesScreen> {
  List<GameSave> _saves = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSaves();
  }

  Future<void> _loadSaves() async {
    final db = ref.read(databaseServiceProvider);
    final list = await db.getAllSaves();
    setState(() {
      _saves = list;
      _loading = false;
    });
  }

  Future<void> _deleteSave(String saveId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Excluir Vida?'),
        content: const Text('Essa ação apagará permanentemente essa vida do aparelho celular.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRose),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = ref.read(databaseServiceProvider);
      await db.deleteSave(saveId);
      _loadSaves();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: const Text('Minhas Vidas Salvas', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _saves.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma vida salva no momento.',
                    style: TextStyle(color: AppColors.textSecondaryDark),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _saves.length,
                  itemBuilder: (context, index) {
                    final save = _saves[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: save.isCurrentSave ? AppColors.primary : AppColors.borderDark,
                          width: save.isCurrentSave ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Row(
                          children: [
                            Text(
                              save.slotName,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            if (save.isCurrentSave) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(40),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Ativa',
                                  style: TextStyle(fontSize: 10, color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          'Geração ${save.generation} • Salvo em: ${save.lastSavedAt.day}/${save.lastSavedAt.month}/${save.lastSavedAt.year}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_circle_outline, color: AppColors.secondary, size: 28),
                              onPressed: () async {
                                await ref.read(lifeEngineProvider.notifier).loadSave(save.id);
                                if (context.mounted) {
                                  context.go('/game');
                                }
                              },
                              tooltip: 'Jogar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.accentRose, size: 22),
                              onPressed: () => _deleteSave(save.id),
                              tooltip: 'Excluir',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
