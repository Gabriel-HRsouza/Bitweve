import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/database/database_service.dart';
import 'package:bitweve/features/character/data/character_options.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/events/models/life_event.dart';
import 'package:bitweve/features/finances/models/crypto_asset.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/features/properties/models/property_model.dart';
import 'package:bitweve/features/properties/models/vehicle_model.dart';
import 'package:bitweve/features/life_engine/systems/activity_system.dart';
import 'package:bitweve/features/life_engine/systems/aging_system.dart';
import 'package:bitweve/features/life_engine/systems/business_crime_system.dart';
import 'package:bitweve/features/life_engine/systems/career_system.dart';
import 'package:bitweve/features/life_engine/systems/education_system.dart';
import 'package:bitweve/features/life_engine/systems/event_system.dart';
import 'package:bitweve/features/life_engine/systems/fame_system.dart';
import 'package:bitweve/features/life_engine/systems/finance_system.dart';
import 'package:bitweve/features/life_engine/systems/health_system.dart';
import 'package:bitweve/features/life_engine/systems/life_draft.dart';
import 'package:bitweve/features/life_engine/systems/life_factory.dart';
import 'package:bitweve/features/life_engine/systems/progression_system.dart';
import 'package:bitweve/features/life_engine/systems/relationship_system.dart';
import 'package:bitweve/features/life_engine/systems/shop_system.dart';
import 'package:bitweve/features/life_engine/systems/school_system.dart';
import 'package:bitweve/features/life_engine/systems/underworld_system.dart';
import 'package:bitweve/features/life_engine/systems/social_media_system.dart';
import 'package:bitweve/features/life_engine/systems/dating_system.dart';
import 'package:bitweve/features/life_engine/systems/party_system.dart';
import 'package:bitweve/features/parties/data/party_catalog.dart';
import 'package:bitweve/features/underworld/models/minigame_result.dart';

export 'package:bitweve/features/life_engine/models/life_state.dart';

/// Fachada do motor de vida. Cada ação cria um [LifeDraft], delega ao sistema
/// responsável, verifica conquistas e salva automaticamente no SQLite.
class LifeEngineService {
  final DatabaseService dbService;
  final EngineContext ctx;
  Set<String> _unlocked = {};
  bool _datasetsLoaded = false;

  LifeEngineService({DatabaseService? databaseService, AudioService? audio, Random? rng})
      : dbService = databaseService ?? DatabaseService(),
        ctx = EngineContext(rng: rng, audio: audio);

  AudioService get audioService => ctx.audio;
  List<Map<String, dynamic>> get availableCountries => ctx.countries;
  Set<String> get unlockedAchievements => _unlocked;

  Future<void> initDatasets() async {
    if (!_datasetsLoaded) {
      try {
        final countriesRaw = await rootBundle.loadString('assets/data/countries.json');
        ctx.countries = (jsonDecode(countriesRaw) as List).cast<Map<String, dynamic>>();
        final eventsRaw = await rootBundle.loadString('assets/data/events.json');
        ctx.jsonEvents = (jsonDecode(eventsRaw) as List).map((e) => LifeEvent.fromMap(e as Map<String, dynamic>)).toList();
        _datasetsLoaded = true;
      } catch (_) {
        // Sem asset bundle (testes puros): usa dados embutidos.
      }
    }
    try {
      _unlocked = await dbService.unlockedAchievements();
    } catch (_) {}
  }

  Future<LifeEngineState> _run(
    LifeEngineState s,
    void Function(LifeDraft d) action, {
    bool persist = true,
  }) async {
    final d = LifeDraft(s, ctx);
    ProgressionSystem.ensureDaily(d);
    action(d);
    final newly = ProgressionSystem.checkAchievements(d, _unlocked);
    final out = d.build();
    for (final a in newly) {
      _unlocked.add(a.id);
      try {
        await dbService.unlockAchievement(a.id, a.title, a.description, a.category);
      } catch (_) {}
    }
    if (persist) await dbService.saveState(out);
    return out;
  }

  Future<LifeEngineState> _persistNew(LifeEngineState s) async {
    final d = LifeDraft(s, ctx);
    ProgressionSystem.ensureDaily(d);
    final out = d.build();
    await dbService.saveState(out);
    return out;
  }

  // ------------------------------------------------------------------ vidas
  Future<LifeEngineState> createLife(CharacterSetup setup) async {
    final s = LifeFactory.create(ctx, setup);
    ctx.audio.playSfx(GameSfx.birth);
    return _persistNew(s);
  }

  Future<LifeEngineState> createRandomLife({
    String? countryId,
    String? city,
    String? gender,
    String? firstName,
    String? lastName,
  }) {
    return createLife(LifeFactory.randomSetup(ctx,
        countryId: countryId, city: city, gender: gender, firstName: firstName, lastName: lastName));
  }

  Future<LifeEngineState> continueAsHeir(LifeEngineState s, String heirId) async {
    final next = LifeFactory.heir(ctx, s, heirId);
    ctx.audio.playSfx(GameSfx.achievement);
    return _persistNew(next);
  }

  Future<LifeEngineState> restartLife(LifeEngineState s) async {
    final next = LifeFactory.restart(ctx, s);
    await dbService.deleteSave(s.saveId);
    return _persistNew(next);
  }

  LifeEngineState clearTransient(LifeEngineState s) =>
      s.copyWith(notices: const [], clearSummary: true, clearOutcome: true);

  // ------------------------------------------------------------------ tempo
  Future<LifeEngineState> advanceYear(LifeEngineState s) {
    if (!s.character.isAlive) return Future.value(s);
    return _run(s, AgingSystem.advance);
  }

  Future<LifeEngineState> chooseEvent(LifeEngineState s, int choiceIndex) => _run(s, (d) => EventSystem.resolve(d, choiceIndex));

  /// Compatibilidade: resolve o primeiro evento pendente pela escolha.
  Future<LifeEngineState> makeChoice(LifeEngineState s, EventChoice choice) {
    final ev = s.pendingEvent;
    final idx = ev == null ? -1 : ev.choices.indexWhere((c) => c.label == choice.label);
    return chooseEvent(s, idx < 0 ? 0 : idx);
  }

  // ------------------------------------------------------------------ relações
  Future<LifeEngineState> interactWithNpc(LifeEngineState s, String npcId, String action) {
    const legacy = {'strengthenBond': 'hangout', 'startDating': 'askOut', 'marry': 'propose'};
    return _run(s, (d) => RelationshipSystem.interact(d, npcId, legacy[action] ?? action));
  }

  Future<LifeEngineState> findLove(LifeEngineState s) => _run(s, RelationshipSystem.findLove);
  Future<LifeEngineState> meetPeople(LifeEngineState s) => _run(s, RelationshipSystem.meetPeople);

  // ------------------------------------------------------------------ carreira
  Future<LifeEngineState> applyForJob(LifeEngineState s, String trackId, {double interviewBonus = 0}) =>
      _run(s, (d) => CareerSystem.apply(d, trackId, interviewBonus));
  Future<LifeEngineState> workHard(LifeEngineState s) => _run(s, CareerSystem.workHard);
  Future<LifeEngineState> slackOff(LifeEngineState s) => _run(s, CareerSystem.slackOff);
  Future<LifeEngineState> askForRaise(LifeEngineState s) => _run(s, CareerSystem.askRaise);
  Future<LifeEngineState> askForPromotion(LifeEngineState s) => _run(s, CareerSystem.askPromotion);
  Future<LifeEngineState> quitJob(LifeEngineState s) => _run(s, CareerSystem.quit);
  Future<LifeEngineState> retire(LifeEngineState s) => _run(s, CareerSystem.retire);

  // ------------------------------------------------------------------ educação
  Future<LifeEngineState> enroll(LifeEngineState s, String degreeId, String payMode, [String institutionId = 'unibrasil']) =>
      _run(s, (d) => EducationSystem.enroll(d, degreeId, payMode, institutionId));
  Future<LifeEngineState> dropOut(LifeEngineState s) => _run(s, EducationSystem.dropOut);
  Future<LifeEngineState> studyExtra(LifeEngineState s) => _run(s, EducationSystem.study);
  Future<LifeEngineState> takeCourse(LifeEngineState s, String courseId) => _run(s, (d) => EducationSystem.takeCourse(d, courseId));

  // ------------------------------------------------------------------ loja e bens
  Future<LifeEngineState> buyItem(LifeEngineState s, String itemId) => _run(s, (d) => ShopSystem.buyItem(d, itemId));
  Future<LifeEngineState> sellItem(LifeEngineState s, String ownedId) => _run(s, (d) => ShopSystem.sellItem(d, ownedId));
  Future<LifeEngineState> buyVehicle(LifeEngineState s, VehicleModel v) => _run(s, (d) => ShopSystem.buyVehicle(d, v, needsLicense: false));
  Future<LifeEngineState> buyVehicleListing(LifeEngineState s, String id) => _run(s, (d) => ShopSystem.buyVehicleListing(d, id));
  Future<LifeEngineState> serviceVehicle(LifeEngineState s, String id) => _run(s, (d) => ShopSystem.serviceVehicle(d, id));
  Future<LifeEngineState> sellVehicle(LifeEngineState s, String id) => _run(s, (d) => ShopSystem.sellVehicle(d, id));
  Future<LifeEngineState> toggleVehicleInsurance(LifeEngineState s, String id) => _run(s, (d) => ShopSystem.toggleVehicleInsurance(d, id));
  Future<LifeEngineState> buyProperty(LifeEngineState s, PropertyModel p, bool financed) =>
      _run(s, (d) => ShopSystem.buyProperty(d, p, financed));
  Future<LifeEngineState> buyPropertyListing(LifeEngineState s, String id, bool financed) =>
      _run(s, (d) => ShopSystem.buyPropertyListing(d, id, financed));
  Future<LifeEngineState> sellProperty(LifeEngineState s, String id) => _run(s, (d) => ShopSystem.sellProperty(d, id));
  Future<LifeEngineState> toggleRent(LifeEngineState s, String id) => _run(s, (d) => ShopSystem.toggleRent(d, id));
  Future<LifeEngineState> moveInto(LifeEngineState s, String id) => _run(s, (d) => ShopSystem.moveInto(d, id));
  Future<LifeEngineState> renovate(LifeEngineState s, String id) => _run(s, (d) => ShopSystem.renovate(d, id));

  // ------------------------------------------------------------------ finanças
  Future<LifeEngineState> investMoney(LifeEngineState s, String type, String name, String ticker, double amount) =>
      _run(s, (d) => FinanceSystem.invest(d, type, name, ticker, amount));
  Future<LifeEngineState> sellInvestment(LifeEngineState s, String id) => _run(s, (d) => FinanceSystem.sellInvestment(d, id));
  Future<LifeEngineState> payDebt(LifeEngineState s, double amount) => _run(s, (d) => FinanceSystem.payDebt(d, amount));
  Future<LifeEngineState> takeLoan(LifeEngineState s, double amount) => _run(s, (d) => FinanceSystem.takeLoan(d, amount));
  Future<LifeEngineState> payLoan(LifeEngineState s, String id, double amount) => _run(s, (d) => FinanceSystem.payLoan(d, id, amount));
  Future<LifeEngineState> buyCrypto(LifeEngineState s, String symbol, double amount) => _run(s, (d) => FinanceSystem.buyCrypto(d, symbol, amount));
  Future<LifeEngineState> sellCrypto(LifeEngineState s, String symbol, double amount) => _run(s, (d) => FinanceSystem.sellCrypto(d, symbol, amount));
  Future<LifeEngineState> moveOut(LifeEngineState s) => _run(s, FinanceSystem.moveOut);

  List<CryptoAsset> cryptoWallet(LifeEngineState s) => s.extras.crypto.isEmpty ? FinanceSystem.defaultWallet() : s.extras.crypto;

  // ------------------------------------------------------------------ atividades
  Future<LifeEngineState> doActivity(LifeEngineState s, String id) => _run(s, (d) => ActivitySystem.perform(d, id));
  Future<LifeEngineState> practiceHobby(LifeEngineState s, String name) => _run(s, (d) => ActivitySystem.hobby(d, name));
  Future<LifeEngineState> adoptPet(LifeEngineState s, String type, String name) => _run(s, (d) => ActivitySystem.adoptPet(d, type, name));
  Future<LifeEngineState> playWithPet(LifeEngineState s, String id) => _run(s, (d) => ActivitySystem.petPlay(d, id));

  Future<(LifeEngineState, LotteryResult)> playLotteryDraw(LifeEngineState s, List<int> numbers) async {
    late LotteryResult result;
    final out = await _run(s, (d) => result = ActivitySystem.lottery(d, numbers));
    return (out, result);
  }

  // Compatibilidade com nomes antigos
  Future<LifeEngineState> goToGym(LifeEngineState s) => doActivity(s, 'gym');
  Future<LifeEngineState> goToCinema(LifeEngineState s) => doActivity(s, 'cinema');
  Future<LifeEngineState> shoppingSpree(LifeEngineState s) => doActivity(s, 'shopping');
  Future<LifeEngineState> restAndVacation(LifeEngineState s) => doActivity(s, 'vacation');

  // ------------------------------------------------------------------ fama
  Future<LifeEngineState> postOnSocialMedia(LifeEngineState s, [String kind = 'photo']) => _run(s, (d) => FameSystem.post(d, kind));
  Future<LifeEngineState> giveInterview(LifeEngineState s) => _run(s, FameSystem.interview);
  Future<LifeEngineState> attendGala(LifeEngineState s) => _run(s, FameSystem.publicEvent);
  Future<LifeEngineState> seekSponsor(LifeEngineState s) => _run(s, FameSystem.seekSponsor);

  // ------------------------------------------------------------------ saúde
  Future<LifeEngineState> toggleHealthInsurance(LifeEngineState s) => _run(s, HealthSystem.toggleInsurance);
  Future<LifeEngineState> consultPublicHealth(LifeEngineState s) => _run(s, HealthSystem.publicHealth);
  Future<LifeEngineState> consultGeneralPractitioner(LifeEngineState s) => _run(s, HealthSystem.generalPractitioner);
  Future<LifeEngineState> consultPsychologist(LifeEngineState s) => _run(s, HealthSystem.psychologist);
  Future<LifeEngineState> consultPsychiatrist(LifeEngineState s) => _run(s, HealthSystem.psychiatrist);
  Future<LifeEngineState> consultCardiologist(LifeEngineState s) => _run(s, HealthSystem.cardiologist);
  Future<LifeEngineState> buyPrescribedMedicine(LifeEngineState s) => _run(s, HealthSystem.medicine);
  Future<LifeEngineState> treatSpecificCondition(LifeEngineState s, String id) => _run(s, (d) => HealthSystem.treat(d, id));
  Future<LifeEngineState> plasticSurgery(LifeEngineState s) => _run(s, HealthSystem.plasticSurgery);

  // ------------------------------------------------------------------ empresas / crime
  Future<LifeEngineState> startBusiness(LifeEngineState s, String name, String industry) => _run(s, (d) => BusinessSystem.start(d, name, industry));
  Future<LifeEngineState> hireEmployees(LifeEngineState s, String id) => _run(s, (d) => BusinessSystem.hire(d, id));
  Future<LifeEngineState> investMarketing(LifeEngineState s, String id) => _run(s, (d) => BusinessSystem.marketing(d, id));
  Future<LifeEngineState> sellBusiness(LifeEngineState s, String id) => _run(s, (d) => BusinessSystem.sell(d, id));
  Future<LifeEngineState> attemptCrime(LifeEngineState s, String id) => _run(s, (d) => CrimeSystem.attempt(d, id));
  Future<LifeEngineState> appealCriminalRecord(LifeEngineState s) => _run(s, CrimeSystem.appeal);

  // ------------------------------------------------------------------ modo deus
  Future<LifeEngineState> godModeAddMoney(LifeEngineState s, double amount) => _run(s, (d) => GodModeSystem.addMoney(d, amount));
  Future<LifeEngineState> godModeSetStats(LifeEngineState s, {int? health, int? happiness, int? smarts, int? looks}) =>
      _run(s, (d) => GodModeSystem.setStats(d, health: health, happiness: happiness, smarts: smarts, looks: looks));
  Future<LifeEngineState> godModeCureAll(LifeEngineState s) => _run(s, GodModeSystem.cureAll);
  Future<LifeEngineState> godModeClearRecord(LifeEngineState s) => _run(s, GodModeSystem.clearRecord);
  Future<LifeEngineState> godModeJackpot(LifeEngineState s) => _run(s, GodModeSystem.jackpot);

  // ------------------------------------------------------------------ visual
  /// Novo visual no salão/estilista. Custa dinheiro e dá um pequeno bônus.
  Future<LifeEngineState> changeAppearance(LifeEngineState s, AvatarConfig cfg, {double cost = 300}) => _run(s, (d) {
        if (d.age < 6) {
          d.warn('Muito jovem', 'Seus pais escolhem seu visual por enquanto.');
          return;
        }
        if (!d.useAction('makeover', 2)) return;
        if (!d.pay(cost, what: 'o novo visual')) return;
        d.c = d.c.copyWith(avatarConfig: cfg);
        d.stats({'looks': 2, 'happiness': 4});
        d.log('lifestyle', 'Você mudou o visual: estilo ${AvatarConfig.outfitLabel(cfg.outfit).toLowerCase()} e cabelo ${AvatarConfig.hairStyleLabel(cfg.hairStyle).toLowerCase()}.',
            icon: 'auto_awesome', color: '#EC4899');
        d.notify(NoticeKind.purchase, Icons.content_cut, 'Visual novo!', message: '+Aparência', money: -cost);
        d.sfx(GameSfx.purchase);
      });

  // ------------------------------------------------------------------ escola / faculdade
  Future<LifeEngineState> attendClass(LifeEngineState s) => _run(s, SchoolSystem.attendClass);
  Future<LifeEngineState> schoolStudy(LifeEngineState s) => _run(s, SchoolSystem.study);
  Future<LifeEngineState> takeExam(LifeEngineState s, double score) => _run(s, (d) => SchoolSystem.exam(d, score));
  Future<LifeEngineState> skipSchool(LifeEngineState s) => _run(s, SchoolSystem.skip);
  Future<LifeEngineState> visitNurse(LifeEngineState s) => _run(s, SchoolSystem.nurse);
  Future<LifeEngineState> misbehave(LifeEngineState s) => _run(s, SchoolSystem.misbehave);
  Future<LifeEngineState> joinClub(LifeEngineState s, String id) => _run(s, (d) => SchoolSystem.joinClub(d, id));
  Future<LifeEngineState> joinClique(LifeEngineState s, String id) => _run(s, (d) => SchoolSystem.joinClique(d, id));
  Future<LifeEngineState> makeSchoolFriends(LifeEngineState s) => _run(s, SchoolSystem.makeFriends);
  Future<LifeEngineState> schoolEvent(LifeEngineState s, String id) => _run(s, (d) => SchoolSystem.schoolEvent(d, id));
  Future<LifeEngineState> prom(LifeEngineState s, String? dateId) => _run(s, (d) => SchoolSystem.prom(d, dateId));
  Future<LifeEngineState> changeSchool(LifeEngineState s, String type) => _run(s, (d) => SchoolSystem.changeSchool(d, type));
  Future<LifeEngineState> collegeProject(LifeEngineState s) => _run(s, SchoolSystem.project);
  Future<LifeEngineState> uniParty(LifeEngineState s) => _run(s, SchoolSystem.uniParty);
  Future<LifeEngineState> applyInternship(LifeEngineState s, String company, double pay, int sel) =>
      _run(s, (d) => SchoolSystem.applyInternship(d, company, pay, sel));
  Future<LifeEngineState> leaveInternship(LifeEngineState s) => _run(s, SchoolSystem.leaveInternship);
  Future<LifeEngineState> applyScholarship(LifeEngineState s) => _run(s, SchoolSystem.applyScholarship);
  Future<LifeEngineState> thesis(LifeEngineState s) => _run(s, SchoolSystem.thesis);
  Future<LifeEngineState> exchange(LifeEngineState s) => _run(s, SchoolSystem.exchange);
  Future<LifeEngineState> ensureClass(LifeEngineState s) => _run(s, SchoolSystem.ensureClass);
  Future<LifeEngineState> setNickname(LifeEngineState s, String npcId, String nick) =>
      _run(s, (d) => RelationshipSystem.setNickname(d, npcId, nick));

  // ------------------------------------------------------------------ submundo / justiça
  Future<(LifeEngineState, CrimeReport)> commitCrime(LifeEngineState s, String crimeId, MinigameResult r,
      {String? storeId, bool prepared = false}) async {
    var rep = CrimeReport.none;
    final out = await _run(s, (d) => rep = UnderworldSystem.commit(d, crimeId, r, storeId: storeId, prepared: prepared));
    return (out, rep);
  }

  Future<(LifeEngineState, CrimeReport)> gangMission(LifeEngineState s, String missionId, MinigameResult r) async {
    var rep = CrimeReport.none;
    final out = await _run(s, (d) => rep = UnderworldSystem.gangMission(d, missionId, r));
    return (out, rep);
  }

  Future<LifeEngineState> fence(LifeEngineState s, MinigameResult r) => _run(s, (d) => UnderworldSystem.fence(d, r));
  Future<LifeEngineState> lieLow(LifeEngineState s) => _run(s, UnderworldSystem.lieLow);
  Future<LifeEngineState> joinGang(LifeEngineState s, String gangId, MinigameResult r) =>
      _run(s, (d) => UnderworldSystem.joinGang(d, gangId, r));
  Future<LifeEngineState> leaveGang(LifeEngineState s) => _run(s, UnderworldSystem.leaveGang);
  Future<LifeEngineState> payBail(LifeEngineState s) => _run(s, UnderworldSystem.payBail);

  Future<(LifeEngineState, String)> trial(LifeEngineState s, String lawyer, String plea) async {
    var verdict = '';
    final out = await _run(s, (d) => verdict = UnderworldSystem.trial(d, lawyer, plea));
    return (out, verdict);
  }

  Future<LifeEngineState> prisonAction(LifeEngineState s, String action) => _run(s, (d) => UnderworldSystem.prisonAction(d, action));

  // ------------------------------------------------------------------ rede social
  Future<LifeEngineState> createSocialAccount(LifeEngineState s, String handle) =>
      _run(s, (d) => SocialMediaSystem.createAccount(d, handle));
  Future<LifeEngineState> publishPost(LifeEngineState s, String cat, int photo, String caption) =>
      _run(s, (d) => SocialMediaSystem.publish(d, cat, photo, caption));
  Future<LifeEngineState> deletePost(LifeEngineState s, String id) => _run(s, (d) => SocialMediaSystem.deletePost(d, id));
  Future<LifeEngineState> replyComment(LifeEngineState s, String postId, int i, String reply) =>
      _run(s, (d) => SocialMediaSystem.replyComment(d, postId, i, reply));
  Future<LifeEngineState> replyDm(LifeEngineState s, String id, String tone) => _run(s, (d) => SocialMediaSystem.replyDm(d, id, tone));
  Future<LifeEngineState> markInboxRead(LifeEngineState s) => _run(s, SocialMediaSystem.markRead);
  Future<LifeEngineState> likeFeed(LifeEngineState s, String feedId, String npcId) =>
      _run(s, (d) => SocialMediaSystem.likeFeed(d, feedId, npcId));
  Future<LifeEngineState> commentFeed(LifeEngineState s, String feedId, String npcId, bool positive) =>
      _run(s, (d) => SocialMediaSystem.commentFeed(d, feedId, npcId, positive));
  Future<LifeEngineState> shareFeed(LifeEngineState s, String npcId) => _run(s, (d) => SocialMediaSystem.shareFeed(d, npcId));

  // ------------------------------------------------------------------ app de namoro
  Future<LifeEngineState> datingProfile(LifeEngineState s, String bio, List<String> interests, String lookingFor, int minA, int maxA) =>
      _run(s, (d) => DatingSystem.setupProfile(d, bio, interests, lookingFor, minA, maxA));

  Future<(LifeEngineState, bool)> datingLike(LifeEngineState s, String id, {bool superLike = false}) async {
    var matched = false;
    final out = await _run(s, (d) => matched = DatingSystem.like(d, id, superLike: superLike));
    return (out, matched);
  }

  Future<LifeEngineState> datingPass(LifeEngineState s, String id) => _run(s, (d) => DatingSystem.pass(d, id));
  Future<LifeEngineState> datingChat(LifeEngineState s, String id, String option) => _run(s, (d) => DatingSystem.chat(d, id, option));
  Future<LifeEngineState> datingAskDate(LifeEngineState s, String id) => _run(s, (d) => DatingSystem.askDate(d, id));
  Future<LifeEngineState> datingUnmatch(LifeEngineState s, String id, {bool block = false}) =>
      _run(s, (d) => DatingSystem.unmatch(d, id, block: block));

  // ------------------------------------------------------------------ festas / imóveis
  Future<(LifeEngineState, PartyReport)> hostParty(LifeEngineState s, PartyPlan plan) async {
    var rep = PartyReport.empty;
    final out = await _run(s, (d) => rep = PartySystem.host(d, plan));
    return (out, rep);
  }

  Future<LifeEngineState> decorate(LifeEngineState s, String propertyId, String style) =>
      _run(s, (d) => PartySystem.decorate(d, propertyId, style));

  // ------------------------------------------------------------------ missões
  Future<LifeEngineState> refreshDaily(LifeEngineState s) => _run(s, (_) {});
  Future<LifeEngineState> claimDailyMission(LifeEngineState s, String id) => _run(s, (d) => ProgressionSystem.claimDaily(d, id));
  Future<LifeEngineState> claimLifeMission(LifeEngineState s, String id) => _run(s, (d) => ProgressionSystem.claimLife(d, id));
}
