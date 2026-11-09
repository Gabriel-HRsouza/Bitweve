import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/database/database_service.dart';
import 'package:bitweve/features/character/data/character_options.dart';
import 'package:bitweve/features/events/models/life_event.dart';
import 'package:bitweve/features/life_engine/services/life_engine_service.dart';
import 'package:bitweve/features/life_engine/systems/activity_system.dart';
import 'package:bitweve/features/properties/models/property_model.dart';
import 'package:bitweve/features/properties/models/vehicle_model.dart';

export 'package:bitweve/features/life_engine/services/life_engine_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());
final audioServiceProvider = Provider<AudioService>((ref) => AudioService());

final lifeEngineServiceProvider = Provider<LifeEngineService>((ref) {
  return LifeEngineService(
    databaseService: ref.watch(databaseServiceProvider),
    audio: ref.watch(audioServiceProvider),
  );
});

/// Fila de notificações exibidas pelo NotificationHost.
class NoticeQueue extends Notifier<List<GameNotice>> {
  @override
  List<GameNotice> build() => const [];

  void pushAll(List<GameNotice> items) {
    if (items.isEmpty) return;
    final next = [...state, ...items];
    state = next.length > 8 ? next.sublist(next.length - 8) : next;
  }

  GameNotice? pop() {
    if (state.isEmpty) return null;
    final first = state.first;
    state = state.sublist(1);
    return first;
  }

  void clear() => state = const [];
}

final noticeQueueProvider = NotifierProvider<NoticeQueue, List<GameNotice>>(NoticeQueue.new);

/// Lista de vidas salvas (atualizada ao criar/excluir).
final saveSummariesProvider = FutureProvider<List<SaveSummary>>((ref) async {
  ref.watch(lifeEngineProvider.select((s) => s.value?.saveId));
  return ref.read(databaseServiceProvider).getSaveSummaries();
});

/// Conquistas globais desbloqueadas (com data).
final unlockedAchievementsProvider = FutureProvider<Map<String, DateTime>>((ref) async {
  ref.watch(lifeEngineProvider.select((s) => s.value?.logs.length));
  return ref.read(databaseServiceProvider).unlockedAchievementDates();
});

class LifeEngineNotifier extends Notifier<AsyncValue<LifeEngineState?>> {
  LifeEngineService get service => ref.read(lifeEngineServiceProvider);
  bool _busy = false;
  bool get busy => _busy;

  @override
  AsyncValue<LifeEngineState?> build() {
    _init();
    return const AsyncValue.loading();
  }

  Future<void> _init() async {
    try {
      await service.initDatasets();
      final current = await service.dbService.getCurrentSave();
      if (current != null) {
        final data = await service.dbService.loadFullLifeData(current.id);
        if (data != null) {
          state = AsyncValue.data(_fromData(data));
          return;
        }
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  LifeEngineState _fromData(FullLifeData data) => LifeEngineState(
        saveId: data.save.id,
        slotName: data.save.slotName,
        generation: data.save.generation,
        character: data.character,
        npcs: data.npcs,
        properties: data.properties,
        investments: data.investments,
        logs: data.logs,
        extras: data.extras,
      );

  /// Executa uma ação do motor com trava contra toques duplos.
  Future<LifeEngineState?> act(Future<LifeEngineState> Function(LifeEngineService s, LifeEngineState st) fn) async {
    final current = state.value;
    if (current == null || _busy) return null;
    _busy = true;
    try {
      final updated = await fn(service, current);
      state = AsyncValue.data(updated);
      ref.read(noticeQueueProvider.notifier).pushAll(updated.notices);
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    } finally {
      _busy = false;
    }
  }

  /// Executa uma ação que devolve um resultado extra (relatório de crime, festa...).
  Future<T?> actResult<T>(Future<(LifeEngineState, T)> Function(LifeEngineService s, LifeEngineState st) fn) async {
    T? result;
    await act((s, st) async {
      final (out, r) = await fn(s, st);
      result = r;
      return out;
    });
    return result;
  }

  Future<void> _replace(Future<LifeEngineState> Function() fn) async {
    if (_busy) return;
    _busy = true;
    state = const AsyncValue.loading();
    try {
      final s = await fn();
      state = AsyncValue.data(s);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _busy = false;
    }
  }

  // ------------------------------------------------------------------ vidas
  Future<void> createLife(CharacterSetup setup) => _replace(() => service.createLife(setup));

  Future<void> startRandomLife({String? countryId, String? city, String? gender, String? firstName, String? lastName}) =>
      _replace(() => service.createRandomLife(countryId: countryId, city: city, gender: gender, firstName: firstName, lastName: lastName));

  Future<void> loadSave(String saveId) async {
    await _replace(() async {
      await service.dbService.setCurrentSave(saveId);
      final data = await service.dbService.loadFullLifeData(saveId);
      if (data == null) throw StateError('Vida não encontrada');
      return _fromData(data);
    });
  }

  Future<void> deleteSave(String saveId) async {
    await service.dbService.deleteSave(saveId);
    if (state.value?.saveId == saveId) {
      final next = await service.dbService.getCurrentSave();
      if (next != null) {
        await loadSave(next.id);
      } else {
        state = const AsyncValue.data(null);
      }
    } else {
      ref.invalidate(saveSummariesProvider);
    }
  }

  Future<void> eraseEverything() async {
    await service.dbService.deleteAllSaves();
    await service.initDatasets();
    state = const AsyncValue.data(null);
    ref.invalidate(saveSummariesProvider);
    ref.invalidate(unlockedAchievementsProvider);
  }

  Future<void> restartLife() async {
    final s = state.value;
    if (s == null) return;
    await _replace(() => service.restartLife(s));
  }

  Future<void> continueAsHeir(String heirId) async {
    final s = state.value;
    if (s == null) return;
    await _replace(() => service.continueAsHeir(s, heirId));
  }

  void clearTransient() {
    final s = state.value;
    if (s == null) return;
    state = AsyncValue.data(service.clearTransient(s));
  }

  // ------------------------------------------------------------------ atalhos
  Future<LifeEngineState?> advanceYear() => act((s, st) => s.advanceYear(st));
  Future<LifeEngineState?> chooseEvent(int index) => act((s, st) => s.chooseEvent(st, index));
  Future<void> makeChoice(EventChoice choice) => act((s, st) => s.makeChoice(st, choice));
  Future<void> interactNpc(String npcId, String action) => act((s, st) => s.interactWithNpc(st, npcId, action));
  Future<void> applyJob(String trackId, double bonus) => act((s, st) => s.applyForJob(st, trackId, interviewBonus: bonus));
  Future<void> workHard() => act((s, st) => s.workHard(st));
  Future<void> askForRaise() => act((s, st) => s.askForRaise(st));
  Future<void> quitJob() => act((s, st) => s.quitJob(st));
  Future<void> buyProperty(PropertyModel p, bool financed) => act((s, st) => s.buyProperty(st, p, financed));
  Future<void> sellProperty(String id) => act((s, st) => s.sellProperty(st, id));
  Future<void> invest(String type, String name, String ticker, double amount) => act((s, st) => s.investMoney(st, type, name, ticker, amount));
  Future<void> sellInvestment(String id) => act((s, st) => s.sellInvestment(st, id));
  Future<void> payDebt(double amount) => act((s, st) => s.payDebt(st, amount));
  Future<void> studyExtra() => act((s, st) => s.studyExtra(st));
  Future<void> adoptPet(String type, String name) => act((s, st) => s.adoptPet(st, type, name));
  Future<void> practiceHobby(String name) => act((s, st) => s.practiceHobby(st, name));
  Future<void> postOnSocialMedia([String kind = 'photo']) => act((s, st) => s.postOnSocialMedia(st, kind));
  Future<void> giveInterview() => act((s, st) => s.giveInterview(st));
  Future<void> attendGala() => act((s, st) => s.attendGala(st));
  Future<void> seekSponsor() => act((s, st) => s.seekSponsor(st));

  // Atividades
  Future<void> goToGym() => act((s, st) => s.goToGym(st));
  Future<void> goToCinema() => act((s, st) => s.goToCinema(st));
  Future<void> shoppingSpree() => act((s, st) => s.shoppingSpree(st));
  Future<void> restAndVacation() => act((s, st) => s.restAndVacation(st));
  Future<void> doActivity(String id) => act((s, st) => s.doActivity(st, id));

  // Missões
  Future<void> claimDailyMission(String id) => act((s, st) => s.claimDailyMission(st, id));
  Future<void> claimLifeMission(String id) => act((s, st) => s.claimLifeMission(st, id));
  Future<void> refreshDaily() => act((s, st) => s.refreshDaily(st));

  Future<LotteryResult?> playLottery(List<int> numbers) async {
    LotteryResult? result;
    await act((s, st) async {
      final (out, r) = await s.playLotteryDraw(st, numbers);
      result = r;
      return out;
    });
    return result;
  }

  // Saúde
  Future<void> toggleHealthInsurance() => act((s, st) => s.toggleHealthInsurance(st));
  Future<void> consultPublicHealth() => act((s, st) => s.consultPublicHealth(st));
  Future<void> consultGeneralPractitioner() => act((s, st) => s.consultGeneralPractitioner(st));
  Future<void> consultPsychologist() => act((s, st) => s.consultPsychologist(st));
  Future<void> consultPsychiatrist() => act((s, st) => s.consultPsychiatrist(st));
  Future<void> consultCardiologist() => act((s, st) => s.consultCardiologist(st));
  Future<void> buyPrescribedMedicine() => act((s, st) => s.buyPrescribedMedicine(st));
  Future<void> treatSpecificCondition(String id) => act((s, st) => s.treatSpecificCondition(st, id));

  // Cripto / veículos / empresas / crime
  Future<void> buyCrypto(String symbol, double amount) => act((s, st) => s.buyCrypto(st, symbol, amount));
  Future<void> sellCrypto(String symbol, double amount) => act((s, st) => s.sellCrypto(st, symbol, amount));
  Future<void> buyVehicle(VehicleModel v) => act((s, st) => s.buyVehicle(st, v));
  Future<void> buyVehicleListing(String id) => act((s, st) => s.buyVehicleListing(st, id));
  Future<void> serviceVehicle(String id) => act((s, st) => s.serviceVehicle(st, id));
  Future<void> sellVehicle(String id) => act((s, st) => s.sellVehicle(st, id));
  Future<void> toggleVehicleInsurance(String id) => act((s, st) => s.toggleVehicleInsurance(st, id));
  Future<void> buyPropertyListing(String id, bool financed) => act((s, st) => s.buyPropertyListing(st, id, financed));
  Future<void> toggleRent(String id) => act((s, st) => s.toggleRent(st, id));
  Future<void> moveInto(String id) => act((s, st) => s.moveInto(st, id));
  Future<void> renovate(String id) => act((s, st) => s.renovate(st, id));
  Future<void> startBusiness(String name, String industry) => act((s, st) => s.startBusiness(st, name, industry));
  Future<void> hireEmployees(String id) => act((s, st) => s.hireEmployees(st, id));
  Future<void> investMarketing(String id) => act((s, st) => s.investMarketing(st, id));
  Future<void> sellBusiness(String id) => act((s, st) => s.sellBusiness(st, id));
  Future<void> attemptCrime(String id) => act((s, st) => s.attemptCrime(st, id));
  Future<void> appealCriminalRecord() => act((s, st) => s.appealCriminalRecord(st));

  // Modo Deus
  Future<void> godModeAddMoney(double amount) => act((s, st) => s.godModeAddMoney(st, amount));
  Future<void> godModeSetStats({int? health, int? happiness, int? smarts, int? looks}) =>
      act((s, st) => s.godModeSetStats(st, health: health, happiness: happiness, smarts: smarts, looks: looks));
  Future<void> godModeCureAll() => act((s, st) => s.godModeCureAll(st));
  Future<void> godModeClearRecord() => act((s, st) => s.godModeClearRecord(st));
  Future<void> godModeJackpot() => act((s, st) => s.godModeJackpot(st));
}

final lifeEngineProvider =
    NotifierProvider<LifeEngineNotifier, AsyncValue<LifeEngineState?>>(LifeEngineNotifier.new);
