import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/database/database_service.dart';
import 'package:bitweve/features/character/models/character_model.dart';
import 'package:bitweve/features/careers/models/career_model.dart';
import 'package:bitweve/features/events/models/life_event.dart';
import 'package:bitweve/features/properties/models/property_model.dart';
import 'package:bitweve/features/life_engine/services/life_engine_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

final lifeEngineServiceProvider = Provider<LifeEngineService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  final audio = ref.watch(audioServiceProvider);
  return LifeEngineService(databaseService: db, audio: audio);
});

class LifeEngineNotifier extends Notifier<AsyncValue<LifeEngineState?>> {
  LifeEngineService get service => ref.read(lifeEngineServiceProvider);

  @override
  AsyncValue<LifeEngineState?> build() {
    _init();
    return const AsyncValue.loading();
  }

  Future<void> _init() async {
    try {
      await service.initDatasets();
      final currentSave = await service.dbService.getCurrentSave();
      if (currentSave != null) {
        final data = await service.dbService.loadFullLifeData(currentSave.id);
        if (data != null) {
          state = AsyncValue.data(
            LifeEngineState(
              saveId: data.save.id,
              slotName: data.save.slotName,
              generation: data.save.generation,
              character: data.character,
              npcs: data.npcs,
              properties: data.properties,
              investments: data.investments,
              logs: data.logs,
            ),
          );
          return;
        }
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> startRandomLife({
    String? countryId,
    String? city,
    String? gender,
    String? firstName,
    String? lastName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final newState = await service.createRandomLife(
        countryId: countryId,
        city: city,
        gender: gender,
        firstName: firstName,
        lastName: lastName,
      );
      state = AsyncValue.data(newState);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadSave(String saveId) async {
    state = const AsyncValue.loading();
    try {
      await service.dbService.setCurrentSave(saveId);
      final data = await service.dbService.loadFullLifeData(saveId);
      if (data != null) {
        state = AsyncValue.data(
          LifeEngineState(
            saveId: data.save.id,
            slotName: data.save.slotName,
            generation: data.save.generation,
            character: data.character,
            npcs: data.npcs,
            properties: data.properties,
            investments: data.investments,
            logs: data.logs,
          ),
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> advanceYear() async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.advanceYear(current);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> makeChoice(EventChoice choice) async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.makeChoice(current, choice);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> interactNpc(String npcId, String action) async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.interactWithNpc(current, npcId, action);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> applyJob(CareerModel career) async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.applyForJob(current, career);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> workHard() async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.workHard(current);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> buyProperty(PropertyModel prop, bool financed) async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.buyProperty(current, prop, financed);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> invest(String type, String name, String ticker, double amount) async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.investMoney(current, type, name, ticker, amount);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> goToGym() async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.goToGym(current);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCharacter(CharacterModel char) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(character: char);
    state = AsyncValue.data(updated);
    await service.dbService.saveFullLife(
      saveId: updated.saveId,
      slotName: updated.slotName,
      generation: updated.generation,
      character: updated.character,
      npcs: updated.npcs,
      properties: updated.properties,
      investments: updated.investments,
      logs: updated.logs,
    );
  }

  Future<void> continueAsHeir(String heirId) async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.continueAsHeir(current, heirId);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final lifeEngineProvider =
    NotifierProvider<LifeEngineNotifier, AsyncValue<LifeEngineState?>>(LifeEngineNotifier.new);
