import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/database/database_service.dart';
import 'package:bitweve/features/character/models/character_model.dart';
import 'package:bitweve/features/careers/models/career_model.dart';
import 'package:bitweve/features/events/models/life_event.dart';
import 'package:bitweve/features/properties/models/property_model.dart';
import 'package:bitweve/features/properties/models/vehicle_model.dart';
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

  Future<void> askForRaise() async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.askForRaise(current);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> quitJob() async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.quitJob(current);
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

  Future<void> sellProperty(String propertyId) async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.sellProperty(current, propertyId);
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

  Future<void> sellInvestment(String investmentId) async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.sellInvestment(current, investmentId);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> payDebt(double amount) async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.payDebt(current, amount);
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

  Future<void> goToCinema() async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.goToCinema(current);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> consultDoctor() async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.consultDoctor(current);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> shoppingSpree() async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.shoppingSpree(current);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> adoptPet(String petType, String petName) async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.adoptPet(current, petType, petName);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> practiceHobby(String hobbyName) async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.practiceHobby(current, hobbyName);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> restAndVacation() async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.restAndVacation(current);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> postOnSocialMedia() async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.postOnSocialMedia(current);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> playLottery(List<int> numbers) async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.playLotteryDraw(current, numbers);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> commitPettyCrime() async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.commitPettyCrime(current);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> studyExtra() async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await service.studyExtra(current);
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

  // Saúde
  Future<void> toggleHealthInsurance() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.toggleHealthInsurance(current));
  }

  Future<void> consultPublicHealth() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.consultPublicHealth(current));
  }

  Future<void> consultGeneralPractitioner() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.consultGeneralPractitioner(current));
  }

  Future<void> consultPsychologist() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.consultPsychologist(current));
  }

  Future<void> consultPsychiatrist() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.consultPsychiatrist(current));
  }

  Future<void> consultCardiologist() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.consultCardiologist(current));
  }

  Future<void> buyPrescribedMedicine() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.buyPrescribedMedicine(current));
  }

  Future<void> treatSpecificCondition(String conditionId) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.treatSpecificCondition(current, conditionId));
  }

  // Cripto
  Future<void> buyCrypto(String symbol, double amount) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.buyCrypto(current, symbol, amount));
  }

  Future<void> sellCrypto(String symbol, double amount) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.sellCrypto(current, symbol, amount));
  }

  // Veículos
  Future<void> buyVehicle(VehicleModel v) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.buyVehicle(current, v));
  }

  Future<void> serviceVehicle(String vehicleId) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.serviceVehicle(current, vehicleId));
  }

  Future<void> sellVehicle(String vehicleId) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.sellVehicle(current, vehicleId));
  }

  // Empresas
  Future<void> startBusiness(String name, String industry) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.startBusiness(current, name, industry));
  }

  Future<void> hireEmployees(String businessId) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.hireEmployees(current, businessId));
  }

  Future<void> investMarketing(String businessId) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.investMarketing(current, businessId));
  }

  Future<void> sellBusiness(String businessId) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.sellBusiness(current, businessId));
  }

  // Crime & Justiça
  Future<void> attemptCrime(String crimeId) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.attemptCrime(current, crimeId));
  }

  Future<void> appealCriminalRecord() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.appealCriminalRecord(current));
  }

  // Modo Deus
  Future<void> godModeAddMoney(double amount) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.godModeAddMoney(current, amount));
  }

  Future<void> godModeSetStats({int? health, int? happiness, int? smarts, int? looks}) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.godModeSetStats(
      current,
      health: health,
      happiness: happiness,
      smarts: smarts,
      looks: looks,
    ));
  }

  Future<void> godModeCureAll() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.godModeCureAll(current));
  }

  Future<void> godModeClearRecord() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.godModeClearRecord(current));
  }

  Future<void> godModeJackpot() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(await service.godModeJackpot(current));
  }
}

final lifeEngineProvider =
    NotifierProvider<LifeEngineNotifier, AsyncValue<LifeEngineState?>>(LifeEngineNotifier.new);
