// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GameSavesTable extends GameSaves
    with TableInfo<$GameSavesTable, GameSave> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSavesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotNameMeta = const VerificationMeta(
    'slotName',
  );
  @override
  late final GeneratedColumn<String> slotName = GeneratedColumn<String>(
    'slot_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<String> characterId = GeneratedColumn<String>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSavedAtMeta = const VerificationMeta(
    'lastSavedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSavedAt = GeneratedColumn<DateTime>(
    'last_saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAliveMeta = const VerificationMeta(
    'isAlive',
  );
  @override
  late final GeneratedColumn<bool> isAlive = GeneratedColumn<bool>(
    'is_alive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_alive" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isCurrentSaveMeta = const VerificationMeta(
    'isCurrentSave',
  );
  @override
  late final GeneratedColumn<bool> isCurrentSave = GeneratedColumn<bool>(
    'is_current_save',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_current_save" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _generationMeta = const VerificationMeta(
    'generation',
  );
  @override
  late final GeneratedColumn<int> generation = GeneratedColumn<int>(
    'generation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _biographyMeta = const VerificationMeta(
    'biography',
  );
  @override
  late final GeneratedColumn<String> biography = GeneratedColumn<String>(
    'biography',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    slotName,
    characterId,
    createdAt,
    lastSavedAt,
    isAlive,
    isCurrentSave,
    generation,
    biography,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_saves';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameSave> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('slot_name')) {
      context.handle(
        _slotNameMeta,
        slotName.isAcceptableOrUnknown(data['slot_name']!, _slotNameMeta),
      );
    } else if (isInserting) {
      context.missing(_slotNameMeta);
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_saved_at')) {
      context.handle(
        _lastSavedAtMeta,
        lastSavedAt.isAcceptableOrUnknown(
          data['last_saved_at']!,
          _lastSavedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSavedAtMeta);
    }
    if (data.containsKey('is_alive')) {
      context.handle(
        _isAliveMeta,
        isAlive.isAcceptableOrUnknown(data['is_alive']!, _isAliveMeta),
      );
    }
    if (data.containsKey('is_current_save')) {
      context.handle(
        _isCurrentSaveMeta,
        isCurrentSave.isAcceptableOrUnknown(
          data['is_current_save']!,
          _isCurrentSaveMeta,
        ),
      );
    }
    if (data.containsKey('generation')) {
      context.handle(
        _generationMeta,
        generation.isAcceptableOrUnknown(data['generation']!, _generationMeta),
      );
    }
    if (data.containsKey('biography')) {
      context.handle(
        _biographyMeta,
        biography.isAcceptableOrUnknown(data['biography']!, _biographyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameSave map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSave(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      slotName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot_name'],
      )!,
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastSavedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_saved_at'],
      )!,
      isAlive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_alive'],
      )!,
      isCurrentSave: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_current_save'],
      )!,
      generation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generation'],
      )!,
      biography: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}biography'],
      )!,
    );
  }

  @override
  $GameSavesTable createAlias(String alias) {
    return $GameSavesTable(attachedDatabase, alias);
  }
}

class GameSave extends DataClass implements Insertable<GameSave> {
  final String id;
  final String slotName;
  final String characterId;
  final DateTime createdAt;
  final DateTime lastSavedAt;
  final bool isAlive;
  final bool isCurrentSave;
  final int generation;
  final String biography;
  const GameSave({
    required this.id,
    required this.slotName,
    required this.characterId,
    required this.createdAt,
    required this.lastSavedAt,
    required this.isAlive,
    required this.isCurrentSave,
    required this.generation,
    required this.biography,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['slot_name'] = Variable<String>(slotName);
    map['character_id'] = Variable<String>(characterId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_saved_at'] = Variable<DateTime>(lastSavedAt);
    map['is_alive'] = Variable<bool>(isAlive);
    map['is_current_save'] = Variable<bool>(isCurrentSave);
    map['generation'] = Variable<int>(generation);
    map['biography'] = Variable<String>(biography);
    return map;
  }

  GameSavesCompanion toCompanion(bool nullToAbsent) {
    return GameSavesCompanion(
      id: Value(id),
      slotName: Value(slotName),
      characterId: Value(characterId),
      createdAt: Value(createdAt),
      lastSavedAt: Value(lastSavedAt),
      isAlive: Value(isAlive),
      isCurrentSave: Value(isCurrentSave),
      generation: Value(generation),
      biography: Value(biography),
    );
  }

  factory GameSave.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSave(
      id: serializer.fromJson<String>(json['id']),
      slotName: serializer.fromJson<String>(json['slotName']),
      characterId: serializer.fromJson<String>(json['characterId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastSavedAt: serializer.fromJson<DateTime>(json['lastSavedAt']),
      isAlive: serializer.fromJson<bool>(json['isAlive']),
      isCurrentSave: serializer.fromJson<bool>(json['isCurrentSave']),
      generation: serializer.fromJson<int>(json['generation']),
      biography: serializer.fromJson<String>(json['biography']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'slotName': serializer.toJson<String>(slotName),
      'characterId': serializer.toJson<String>(characterId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastSavedAt': serializer.toJson<DateTime>(lastSavedAt),
      'isAlive': serializer.toJson<bool>(isAlive),
      'isCurrentSave': serializer.toJson<bool>(isCurrentSave),
      'generation': serializer.toJson<int>(generation),
      'biography': serializer.toJson<String>(biography),
    };
  }

  GameSave copyWith({
    String? id,
    String? slotName,
    String? characterId,
    DateTime? createdAt,
    DateTime? lastSavedAt,
    bool? isAlive,
    bool? isCurrentSave,
    int? generation,
    String? biography,
  }) => GameSave(
    id: id ?? this.id,
    slotName: slotName ?? this.slotName,
    characterId: characterId ?? this.characterId,
    createdAt: createdAt ?? this.createdAt,
    lastSavedAt: lastSavedAt ?? this.lastSavedAt,
    isAlive: isAlive ?? this.isAlive,
    isCurrentSave: isCurrentSave ?? this.isCurrentSave,
    generation: generation ?? this.generation,
    biography: biography ?? this.biography,
  );
  GameSave copyWithCompanion(GameSavesCompanion data) {
    return GameSave(
      id: data.id.present ? data.id.value : this.id,
      slotName: data.slotName.present ? data.slotName.value : this.slotName,
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastSavedAt: data.lastSavedAt.present
          ? data.lastSavedAt.value
          : this.lastSavedAt,
      isAlive: data.isAlive.present ? data.isAlive.value : this.isAlive,
      isCurrentSave: data.isCurrentSave.present
          ? data.isCurrentSave.value
          : this.isCurrentSave,
      generation: data.generation.present
          ? data.generation.value
          : this.generation,
      biography: data.biography.present ? data.biography.value : this.biography,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSave(')
          ..write('id: $id, ')
          ..write('slotName: $slotName, ')
          ..write('characterId: $characterId, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSavedAt: $lastSavedAt, ')
          ..write('isAlive: $isAlive, ')
          ..write('isCurrentSave: $isCurrentSave, ')
          ..write('generation: $generation, ')
          ..write('biography: $biography')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    slotName,
    characterId,
    createdAt,
    lastSavedAt,
    isAlive,
    isCurrentSave,
    generation,
    biography,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSave &&
          other.id == this.id &&
          other.slotName == this.slotName &&
          other.characterId == this.characterId &&
          other.createdAt == this.createdAt &&
          other.lastSavedAt == this.lastSavedAt &&
          other.isAlive == this.isAlive &&
          other.isCurrentSave == this.isCurrentSave &&
          other.generation == this.generation &&
          other.biography == this.biography);
}

class GameSavesCompanion extends UpdateCompanion<GameSave> {
  final Value<String> id;
  final Value<String> slotName;
  final Value<String> characterId;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastSavedAt;
  final Value<bool> isAlive;
  final Value<bool> isCurrentSave;
  final Value<int> generation;
  final Value<String> biography;
  final Value<int> rowid;
  const GameSavesCompanion({
    this.id = const Value.absent(),
    this.slotName = const Value.absent(),
    this.characterId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastSavedAt = const Value.absent(),
    this.isAlive = const Value.absent(),
    this.isCurrentSave = const Value.absent(),
    this.generation = const Value.absent(),
    this.biography = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameSavesCompanion.insert({
    required String id,
    required String slotName,
    required String characterId,
    required DateTime createdAt,
    required DateTime lastSavedAt,
    this.isAlive = const Value.absent(),
    this.isCurrentSave = const Value.absent(),
    this.generation = const Value.absent(),
    this.biography = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       slotName = Value(slotName),
       characterId = Value(characterId),
       createdAt = Value(createdAt),
       lastSavedAt = Value(lastSavedAt);
  static Insertable<GameSave> custom({
    Expression<String>? id,
    Expression<String>? slotName,
    Expression<String>? characterId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastSavedAt,
    Expression<bool>? isAlive,
    Expression<bool>? isCurrentSave,
    Expression<int>? generation,
    Expression<String>? biography,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slotName != null) 'slot_name': slotName,
      if (characterId != null) 'character_id': characterId,
      if (createdAt != null) 'created_at': createdAt,
      if (lastSavedAt != null) 'last_saved_at': lastSavedAt,
      if (isAlive != null) 'is_alive': isAlive,
      if (isCurrentSave != null) 'is_current_save': isCurrentSave,
      if (generation != null) 'generation': generation,
      if (biography != null) 'biography': biography,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameSavesCompanion copyWith({
    Value<String>? id,
    Value<String>? slotName,
    Value<String>? characterId,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastSavedAt,
    Value<bool>? isAlive,
    Value<bool>? isCurrentSave,
    Value<int>? generation,
    Value<String>? biography,
    Value<int>? rowid,
  }) {
    return GameSavesCompanion(
      id: id ?? this.id,
      slotName: slotName ?? this.slotName,
      characterId: characterId ?? this.characterId,
      createdAt: createdAt ?? this.createdAt,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      isAlive: isAlive ?? this.isAlive,
      isCurrentSave: isCurrentSave ?? this.isCurrentSave,
      generation: generation ?? this.generation,
      biography: biography ?? this.biography,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (slotName.present) {
      map['slot_name'] = Variable<String>(slotName.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<String>(characterId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastSavedAt.present) {
      map['last_saved_at'] = Variable<DateTime>(lastSavedAt.value);
    }
    if (isAlive.present) {
      map['is_alive'] = Variable<bool>(isAlive.value);
    }
    if (isCurrentSave.present) {
      map['is_current_save'] = Variable<bool>(isCurrentSave.value);
    }
    if (generation.present) {
      map['generation'] = Variable<int>(generation.value);
    }
    if (biography.present) {
      map['biography'] = Variable<String>(biography.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameSavesCompanion(')
          ..write('id: $id, ')
          ..write('slotName: $slotName, ')
          ..write('characterId: $characterId, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSavedAt: $lastSavedAt, ')
          ..write('isAlive: $isAlive, ')
          ..write('isCurrentSave: $isCurrentSave, ')
          ..write('generation: $generation, ')
          ..write('biography: $biography, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CharactersTable extends Characters
    with TableInfo<$CharactersTable, Character> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saveIdMeta = const VerificationMeta('saveId');
  @override
  late final GeneratedColumn<String> saveId = GeneratedColumn<String>(
    'save_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sexualOrientationMeta = const VerificationMeta(
    'sexualOrientation',
  );
  @override
  late final GeneratedColumn<String> sexualOrientation =
      GeneratedColumn<String>(
        'sexual_orientation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _birthYearMeta = const VerificationMeta(
    'birthYear',
  );
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
    'birth_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentAgeMeta = const VerificationMeta(
    'currentAge',
  );
  @override
  late final GeneratedColumn<int> currentAge = GeneratedColumn<int>(
    'current_age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarConfigJsonMeta = const VerificationMeta(
    'avatarConfigJson',
  );
  @override
  late final GeneratedColumn<String> avatarConfigJson = GeneratedColumn<String>(
    'avatar_config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _healthMeta = const VerificationMeta('health');
  @override
  late final GeneratedColumn<int> health = GeneratedColumn<int>(
    'health',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _happinessMeta = const VerificationMeta(
    'happiness',
  );
  @override
  late final GeneratedColumn<int> happiness = GeneratedColumn<int>(
    'happiness',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _smartsMeta = const VerificationMeta('smarts');
  @override
  late final GeneratedColumn<int> smarts = GeneratedColumn<int>(
    'smarts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _looksMeta = const VerificationMeta('looks');
  @override
  late final GeneratedColumn<int> looks = GeneratedColumn<int>(
    'looks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<int> energy = GeneratedColumn<int>(
    'energy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stressMeta = const VerificationMeta('stress');
  @override
  late final GeneratedColumn<int> stress = GeneratedColumn<int>(
    'stress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _disciplineMeta = const VerificationMeta(
    'discipline',
  );
  @override
  late final GeneratedColumn<int> discipline = GeneratedColumn<int>(
    'discipline',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _charismaMeta = const VerificationMeta(
    'charisma',
  );
  @override
  late final GeneratedColumn<int> charisma = GeneratedColumn<int>(
    'charisma',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fitnessMeta = const VerificationMeta(
    'fitness',
  );
  @override
  late final GeneratedColumn<int> fitness = GeneratedColumn<int>(
    'fitness',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reputationMeta = const VerificationMeta(
    'reputation',
  );
  @override
  late final GeneratedColumn<int> reputation = GeneratedColumn<int>(
    'reputation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fameMeta = const VerificationMeta('fame');
  @override
  late final GeneratedColumn<int> fame = GeneratedColumn<int>(
    'fame',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _karmaMeta = const VerificationMeta('karma');
  @override
  late final GeneratedColumn<int> karma = GeneratedColumn<int>(
    'karma',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bankBalanceMeta = const VerificationMeta(
    'bankBalance',
  );
  @override
  late final GeneratedColumn<double> bankBalance = GeneratedColumn<double>(
    'bank_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _annualExpensesMeta = const VerificationMeta(
    'annualExpenses',
  );
  @override
  late final GeneratedColumn<double> annualExpenses = GeneratedColumn<double>(
    'annual_expenses',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _debtMeta = const VerificationMeta('debt');
  @override
  late final GeneratedColumn<double> debt = GeneratedColumn<double>(
    'debt',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditScoreMeta = const VerificationMeta(
    'creditScore',
  );
  @override
  late final GeneratedColumn<int> creditScore = GeneratedColumn<int>(
    'credit_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAliveMeta = const VerificationMeta(
    'isAlive',
  );
  @override
  late final GeneratedColumn<bool> isAlive = GeneratedColumn<bool>(
    'is_alive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_alive" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _causeOfDeathMeta = const VerificationMeta(
    'causeOfDeath',
  );
  @override
  late final GeneratedColumn<String> causeOfDeath = GeneratedColumn<String>(
    'cause_of_death',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ageOfDeathMeta = const VerificationMeta(
    'ageOfDeath',
  );
  @override
  late final GeneratedColumn<int> ageOfDeath = GeneratedColumn<int>(
    'age_of_death',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partnerIdMeta = const VerificationMeta(
    'partnerId',
  );
  @override
  late final GeneratedColumn<String> partnerId = GeneratedColumn<String>(
    'partner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMarriedMeta = const VerificationMeta(
    'isMarried',
  );
  @override
  late final GeneratedColumn<bool> isMarried = GeneratedColumn<bool>(
    'is_married',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_married" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _educationLevelMeta = const VerificationMeta(
    'educationLevel',
  );
  @override
  late final GeneratedColumn<String> educationLevel = GeneratedColumn<String>(
    'education_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentDegreeMeta = const VerificationMeta(
    'currentDegree',
  );
  @override
  late final GeneratedColumn<String> currentDegree = GeneratedColumn<String>(
    'current_degree',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentJobIdMeta = const VerificationMeta(
    'currentJobId',
  );
  @override
  late final GeneratedColumn<String> currentJobId = GeneratedColumn<String>(
    'current_job_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentJobTitleMeta = const VerificationMeta(
    'currentJobTitle',
  );
  @override
  late final GeneratedColumn<String> currentJobTitle = GeneratedColumn<String>(
    'current_job_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentSalaryMeta = const VerificationMeta(
    'currentSalary',
  );
  @override
  late final GeneratedColumn<double> currentSalary = GeneratedColumn<double>(
    'current_salary',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jobPerformanceMeta = const VerificationMeta(
    'jobPerformance',
  );
  @override
  late final GeneratedColumn<int> jobPerformance = GeneratedColumn<int>(
    'job_performance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(50),
  );
  static const VerificationMeta _yearsInCurrentJobMeta = const VerificationMeta(
    'yearsInCurrentJob',
  );
  @override
  late final GeneratedColumn<int> yearsInCurrentJob = GeneratedColumn<int>(
    'years_in_current_job',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hasDriversLicenseMeta = const VerificationMeta(
    'hasDriversLicense',
  );
  @override
  late final GeneratedColumn<bool> hasDriversLicense = GeneratedColumn<bool>(
    'has_drivers_license',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_drivers_license" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _criminalRecordMeta = const VerificationMeta(
    'criminalRecord',
  );
  @override
  late final GeneratedColumn<bool> criminalRecord = GeneratedColumn<bool>(
    'criminal_record',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("criminal_record" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timesArrestedMeta = const VerificationMeta(
    'timesArrested',
  );
  @override
  late final GeneratedColumn<int> timesArrested = GeneratedColumn<int>(
    'times_arrested',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saveId,
    firstName,
    lastName,
    gender,
    sexualOrientation,
    birthYear,
    currentAge,
    country,
    city,
    avatarConfigJson,
    health,
    happiness,
    smarts,
    looks,
    energy,
    stress,
    discipline,
    charisma,
    fitness,
    reputation,
    fame,
    karma,
    bankBalance,
    annualExpenses,
    debt,
    creditScore,
    isAlive,
    causeOfDeath,
    ageOfDeath,
    partnerId,
    isMarried,
    educationLevel,
    currentDegree,
    currentJobId,
    currentJobTitle,
    currentSalary,
    jobPerformance,
    yearsInCurrentJob,
    hasDriversLicense,
    criminalRecord,
    timesArrested,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'characters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Character> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('save_id')) {
      context.handle(
        _saveIdMeta,
        saveId.isAcceptableOrUnknown(data['save_id']!, _saveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saveIdMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('sexual_orientation')) {
      context.handle(
        _sexualOrientationMeta,
        sexualOrientation.isAcceptableOrUnknown(
          data['sexual_orientation']!,
          _sexualOrientationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sexualOrientationMeta);
    }
    if (data.containsKey('birth_year')) {
      context.handle(
        _birthYearMeta,
        birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta),
      );
    } else if (isInserting) {
      context.missing(_birthYearMeta);
    }
    if (data.containsKey('current_age')) {
      context.handle(
        _currentAgeMeta,
        currentAge.isAcceptableOrUnknown(data['current_age']!, _currentAgeMeta),
      );
    } else if (isInserting) {
      context.missing(_currentAgeMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    } else if (isInserting) {
      context.missing(_cityMeta);
    }
    if (data.containsKey('avatar_config_json')) {
      context.handle(
        _avatarConfigJsonMeta,
        avatarConfigJson.isAcceptableOrUnknown(
          data['avatar_config_json']!,
          _avatarConfigJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avatarConfigJsonMeta);
    }
    if (data.containsKey('health')) {
      context.handle(
        _healthMeta,
        health.isAcceptableOrUnknown(data['health']!, _healthMeta),
      );
    } else if (isInserting) {
      context.missing(_healthMeta);
    }
    if (data.containsKey('happiness')) {
      context.handle(
        _happinessMeta,
        happiness.isAcceptableOrUnknown(data['happiness']!, _happinessMeta),
      );
    } else if (isInserting) {
      context.missing(_happinessMeta);
    }
    if (data.containsKey('smarts')) {
      context.handle(
        _smartsMeta,
        smarts.isAcceptableOrUnknown(data['smarts']!, _smartsMeta),
      );
    } else if (isInserting) {
      context.missing(_smartsMeta);
    }
    if (data.containsKey('looks')) {
      context.handle(
        _looksMeta,
        looks.isAcceptableOrUnknown(data['looks']!, _looksMeta),
      );
    } else if (isInserting) {
      context.missing(_looksMeta);
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    } else if (isInserting) {
      context.missing(_energyMeta);
    }
    if (data.containsKey('stress')) {
      context.handle(
        _stressMeta,
        stress.isAcceptableOrUnknown(data['stress']!, _stressMeta),
      );
    } else if (isInserting) {
      context.missing(_stressMeta);
    }
    if (data.containsKey('discipline')) {
      context.handle(
        _disciplineMeta,
        discipline.isAcceptableOrUnknown(data['discipline']!, _disciplineMeta),
      );
    } else if (isInserting) {
      context.missing(_disciplineMeta);
    }
    if (data.containsKey('charisma')) {
      context.handle(
        _charismaMeta,
        charisma.isAcceptableOrUnknown(data['charisma']!, _charismaMeta),
      );
    } else if (isInserting) {
      context.missing(_charismaMeta);
    }
    if (data.containsKey('fitness')) {
      context.handle(
        _fitnessMeta,
        fitness.isAcceptableOrUnknown(data['fitness']!, _fitnessMeta),
      );
    } else if (isInserting) {
      context.missing(_fitnessMeta);
    }
    if (data.containsKey('reputation')) {
      context.handle(
        _reputationMeta,
        reputation.isAcceptableOrUnknown(data['reputation']!, _reputationMeta),
      );
    } else if (isInserting) {
      context.missing(_reputationMeta);
    }
    if (data.containsKey('fame')) {
      context.handle(
        _fameMeta,
        fame.isAcceptableOrUnknown(data['fame']!, _fameMeta),
      );
    } else if (isInserting) {
      context.missing(_fameMeta);
    }
    if (data.containsKey('karma')) {
      context.handle(
        _karmaMeta,
        karma.isAcceptableOrUnknown(data['karma']!, _karmaMeta),
      );
    } else if (isInserting) {
      context.missing(_karmaMeta);
    }
    if (data.containsKey('bank_balance')) {
      context.handle(
        _bankBalanceMeta,
        bankBalance.isAcceptableOrUnknown(
          data['bank_balance']!,
          _bankBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bankBalanceMeta);
    }
    if (data.containsKey('annual_expenses')) {
      context.handle(
        _annualExpensesMeta,
        annualExpenses.isAcceptableOrUnknown(
          data['annual_expenses']!,
          _annualExpensesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_annualExpensesMeta);
    }
    if (data.containsKey('debt')) {
      context.handle(
        _debtMeta,
        debt.isAcceptableOrUnknown(data['debt']!, _debtMeta),
      );
    } else if (isInserting) {
      context.missing(_debtMeta);
    }
    if (data.containsKey('credit_score')) {
      context.handle(
        _creditScoreMeta,
        creditScore.isAcceptableOrUnknown(
          data['credit_score']!,
          _creditScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creditScoreMeta);
    }
    if (data.containsKey('is_alive')) {
      context.handle(
        _isAliveMeta,
        isAlive.isAcceptableOrUnknown(data['is_alive']!, _isAliveMeta),
      );
    }
    if (data.containsKey('cause_of_death')) {
      context.handle(
        _causeOfDeathMeta,
        causeOfDeath.isAcceptableOrUnknown(
          data['cause_of_death']!,
          _causeOfDeathMeta,
        ),
      );
    }
    if (data.containsKey('age_of_death')) {
      context.handle(
        _ageOfDeathMeta,
        ageOfDeath.isAcceptableOrUnknown(
          data['age_of_death']!,
          _ageOfDeathMeta,
        ),
      );
    }
    if (data.containsKey('partner_id')) {
      context.handle(
        _partnerIdMeta,
        partnerId.isAcceptableOrUnknown(data['partner_id']!, _partnerIdMeta),
      );
    }
    if (data.containsKey('is_married')) {
      context.handle(
        _isMarriedMeta,
        isMarried.isAcceptableOrUnknown(data['is_married']!, _isMarriedMeta),
      );
    }
    if (data.containsKey('education_level')) {
      context.handle(
        _educationLevelMeta,
        educationLevel.isAcceptableOrUnknown(
          data['education_level']!,
          _educationLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_educationLevelMeta);
    }
    if (data.containsKey('current_degree')) {
      context.handle(
        _currentDegreeMeta,
        currentDegree.isAcceptableOrUnknown(
          data['current_degree']!,
          _currentDegreeMeta,
        ),
      );
    }
    if (data.containsKey('current_job_id')) {
      context.handle(
        _currentJobIdMeta,
        currentJobId.isAcceptableOrUnknown(
          data['current_job_id']!,
          _currentJobIdMeta,
        ),
      );
    }
    if (data.containsKey('current_job_title')) {
      context.handle(
        _currentJobTitleMeta,
        currentJobTitle.isAcceptableOrUnknown(
          data['current_job_title']!,
          _currentJobTitleMeta,
        ),
      );
    }
    if (data.containsKey('current_salary')) {
      context.handle(
        _currentSalaryMeta,
        currentSalary.isAcceptableOrUnknown(
          data['current_salary']!,
          _currentSalaryMeta,
        ),
      );
    }
    if (data.containsKey('job_performance')) {
      context.handle(
        _jobPerformanceMeta,
        jobPerformance.isAcceptableOrUnknown(
          data['job_performance']!,
          _jobPerformanceMeta,
        ),
      );
    }
    if (data.containsKey('years_in_current_job')) {
      context.handle(
        _yearsInCurrentJobMeta,
        yearsInCurrentJob.isAcceptableOrUnknown(
          data['years_in_current_job']!,
          _yearsInCurrentJobMeta,
        ),
      );
    }
    if (data.containsKey('has_drivers_license')) {
      context.handle(
        _hasDriversLicenseMeta,
        hasDriversLicense.isAcceptableOrUnknown(
          data['has_drivers_license']!,
          _hasDriversLicenseMeta,
        ),
      );
    }
    if (data.containsKey('criminal_record')) {
      context.handle(
        _criminalRecordMeta,
        criminalRecord.isAcceptableOrUnknown(
          data['criminal_record']!,
          _criminalRecordMeta,
        ),
      );
    }
    if (data.containsKey('times_arrested')) {
      context.handle(
        _timesArrestedMeta,
        timesArrested.isAcceptableOrUnknown(
          data['times_arrested']!,
          _timesArrestedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Character map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Character(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_id'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      sexualOrientation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sexual_orientation'],
      )!,
      birthYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_year'],
      )!,
      currentAge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_age'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      avatarConfigJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_config_json'],
      )!,
      health: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}health'],
      )!,
      happiness: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}happiness'],
      )!,
      smarts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}smarts'],
      )!,
      looks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}looks'],
      )!,
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy'],
      )!,
      stress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stress'],
      )!,
      discipline: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discipline'],
      )!,
      charisma: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}charisma'],
      )!,
      fitness: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fitness'],
      )!,
      reputation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reputation'],
      )!,
      fame: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fame'],
      )!,
      karma: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}karma'],
      )!,
      bankBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bank_balance'],
      )!,
      annualExpenses: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}annual_expenses'],
      )!,
      debt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}debt'],
      )!,
      creditScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_score'],
      )!,
      isAlive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_alive'],
      )!,
      causeOfDeath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cause_of_death'],
      ),
      ageOfDeath: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_of_death'],
      ),
      partnerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_id'],
      ),
      isMarried: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_married'],
      )!,
      educationLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}education_level'],
      )!,
      currentDegree: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_degree'],
      ),
      currentJobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_job_id'],
      ),
      currentJobTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_job_title'],
      ),
      currentSalary: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_salary'],
      ),
      jobPerformance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}job_performance'],
      )!,
      yearsInCurrentJob: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}years_in_current_job'],
      )!,
      hasDriversLicense: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_drivers_license'],
      )!,
      criminalRecord: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}criminal_record'],
      )!,
      timesArrested: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_arrested'],
      )!,
    );
  }

  @override
  $CharactersTable createAlias(String alias) {
    return $CharactersTable(attachedDatabase, alias);
  }
}

class Character extends DataClass implements Insertable<Character> {
  final String id;
  final String saveId;
  final String firstName;
  final String lastName;
  final String gender;
  final String sexualOrientation;
  final int birthYear;
  final int currentAge;
  final String country;
  final String city;
  final String avatarConfigJson;
  final int health;
  final int happiness;
  final int smarts;
  final int looks;
  final int energy;
  final int stress;
  final int discipline;
  final int charisma;
  final int fitness;
  final int reputation;
  final int fame;
  final int karma;
  final double bankBalance;
  final double annualExpenses;
  final double debt;
  final int creditScore;
  final bool isAlive;
  final String? causeOfDeath;
  final int? ageOfDeath;
  final String? partnerId;
  final bool isMarried;
  final String educationLevel;
  final String? currentDegree;
  final String? currentJobId;
  final String? currentJobTitle;
  final double? currentSalary;
  final int jobPerformance;
  final int yearsInCurrentJob;
  final bool hasDriversLicense;
  final bool criminalRecord;
  final int timesArrested;
  const Character({
    required this.id,
    required this.saveId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.sexualOrientation,
    required this.birthYear,
    required this.currentAge,
    required this.country,
    required this.city,
    required this.avatarConfigJson,
    required this.health,
    required this.happiness,
    required this.smarts,
    required this.looks,
    required this.energy,
    required this.stress,
    required this.discipline,
    required this.charisma,
    required this.fitness,
    required this.reputation,
    required this.fame,
    required this.karma,
    required this.bankBalance,
    required this.annualExpenses,
    required this.debt,
    required this.creditScore,
    required this.isAlive,
    this.causeOfDeath,
    this.ageOfDeath,
    this.partnerId,
    required this.isMarried,
    required this.educationLevel,
    this.currentDegree,
    this.currentJobId,
    this.currentJobTitle,
    this.currentSalary,
    required this.jobPerformance,
    required this.yearsInCurrentJob,
    required this.hasDriversLicense,
    required this.criminalRecord,
    required this.timesArrested,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['save_id'] = Variable<String>(saveId);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['gender'] = Variable<String>(gender);
    map['sexual_orientation'] = Variable<String>(sexualOrientation);
    map['birth_year'] = Variable<int>(birthYear);
    map['current_age'] = Variable<int>(currentAge);
    map['country'] = Variable<String>(country);
    map['city'] = Variable<String>(city);
    map['avatar_config_json'] = Variable<String>(avatarConfigJson);
    map['health'] = Variable<int>(health);
    map['happiness'] = Variable<int>(happiness);
    map['smarts'] = Variable<int>(smarts);
    map['looks'] = Variable<int>(looks);
    map['energy'] = Variable<int>(energy);
    map['stress'] = Variable<int>(stress);
    map['discipline'] = Variable<int>(discipline);
    map['charisma'] = Variable<int>(charisma);
    map['fitness'] = Variable<int>(fitness);
    map['reputation'] = Variable<int>(reputation);
    map['fame'] = Variable<int>(fame);
    map['karma'] = Variable<int>(karma);
    map['bank_balance'] = Variable<double>(bankBalance);
    map['annual_expenses'] = Variable<double>(annualExpenses);
    map['debt'] = Variable<double>(debt);
    map['credit_score'] = Variable<int>(creditScore);
    map['is_alive'] = Variable<bool>(isAlive);
    if (!nullToAbsent || causeOfDeath != null) {
      map['cause_of_death'] = Variable<String>(causeOfDeath);
    }
    if (!nullToAbsent || ageOfDeath != null) {
      map['age_of_death'] = Variable<int>(ageOfDeath);
    }
    if (!nullToAbsent || partnerId != null) {
      map['partner_id'] = Variable<String>(partnerId);
    }
    map['is_married'] = Variable<bool>(isMarried);
    map['education_level'] = Variable<String>(educationLevel);
    if (!nullToAbsent || currentDegree != null) {
      map['current_degree'] = Variable<String>(currentDegree);
    }
    if (!nullToAbsent || currentJobId != null) {
      map['current_job_id'] = Variable<String>(currentJobId);
    }
    if (!nullToAbsent || currentJobTitle != null) {
      map['current_job_title'] = Variable<String>(currentJobTitle);
    }
    if (!nullToAbsent || currentSalary != null) {
      map['current_salary'] = Variable<double>(currentSalary);
    }
    map['job_performance'] = Variable<int>(jobPerformance);
    map['years_in_current_job'] = Variable<int>(yearsInCurrentJob);
    map['has_drivers_license'] = Variable<bool>(hasDriversLicense);
    map['criminal_record'] = Variable<bool>(criminalRecord);
    map['times_arrested'] = Variable<int>(timesArrested);
    return map;
  }

  CharactersCompanion toCompanion(bool nullToAbsent) {
    return CharactersCompanion(
      id: Value(id),
      saveId: Value(saveId),
      firstName: Value(firstName),
      lastName: Value(lastName),
      gender: Value(gender),
      sexualOrientation: Value(sexualOrientation),
      birthYear: Value(birthYear),
      currentAge: Value(currentAge),
      country: Value(country),
      city: Value(city),
      avatarConfigJson: Value(avatarConfigJson),
      health: Value(health),
      happiness: Value(happiness),
      smarts: Value(smarts),
      looks: Value(looks),
      energy: Value(energy),
      stress: Value(stress),
      discipline: Value(discipline),
      charisma: Value(charisma),
      fitness: Value(fitness),
      reputation: Value(reputation),
      fame: Value(fame),
      karma: Value(karma),
      bankBalance: Value(bankBalance),
      annualExpenses: Value(annualExpenses),
      debt: Value(debt),
      creditScore: Value(creditScore),
      isAlive: Value(isAlive),
      causeOfDeath: causeOfDeath == null && nullToAbsent
          ? const Value.absent()
          : Value(causeOfDeath),
      ageOfDeath: ageOfDeath == null && nullToAbsent
          ? const Value.absent()
          : Value(ageOfDeath),
      partnerId: partnerId == null && nullToAbsent
          ? const Value.absent()
          : Value(partnerId),
      isMarried: Value(isMarried),
      educationLevel: Value(educationLevel),
      currentDegree: currentDegree == null && nullToAbsent
          ? const Value.absent()
          : Value(currentDegree),
      currentJobId: currentJobId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentJobId),
      currentJobTitle: currentJobTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(currentJobTitle),
      currentSalary: currentSalary == null && nullToAbsent
          ? const Value.absent()
          : Value(currentSalary),
      jobPerformance: Value(jobPerformance),
      yearsInCurrentJob: Value(yearsInCurrentJob),
      hasDriversLicense: Value(hasDriversLicense),
      criminalRecord: Value(criminalRecord),
      timesArrested: Value(timesArrested),
    );
  }

  factory Character.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Character(
      id: serializer.fromJson<String>(json['id']),
      saveId: serializer.fromJson<String>(json['saveId']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      gender: serializer.fromJson<String>(json['gender']),
      sexualOrientation: serializer.fromJson<String>(json['sexualOrientation']),
      birthYear: serializer.fromJson<int>(json['birthYear']),
      currentAge: serializer.fromJson<int>(json['currentAge']),
      country: serializer.fromJson<String>(json['country']),
      city: serializer.fromJson<String>(json['city']),
      avatarConfigJson: serializer.fromJson<String>(json['avatarConfigJson']),
      health: serializer.fromJson<int>(json['health']),
      happiness: serializer.fromJson<int>(json['happiness']),
      smarts: serializer.fromJson<int>(json['smarts']),
      looks: serializer.fromJson<int>(json['looks']),
      energy: serializer.fromJson<int>(json['energy']),
      stress: serializer.fromJson<int>(json['stress']),
      discipline: serializer.fromJson<int>(json['discipline']),
      charisma: serializer.fromJson<int>(json['charisma']),
      fitness: serializer.fromJson<int>(json['fitness']),
      reputation: serializer.fromJson<int>(json['reputation']),
      fame: serializer.fromJson<int>(json['fame']),
      karma: serializer.fromJson<int>(json['karma']),
      bankBalance: serializer.fromJson<double>(json['bankBalance']),
      annualExpenses: serializer.fromJson<double>(json['annualExpenses']),
      debt: serializer.fromJson<double>(json['debt']),
      creditScore: serializer.fromJson<int>(json['creditScore']),
      isAlive: serializer.fromJson<bool>(json['isAlive']),
      causeOfDeath: serializer.fromJson<String?>(json['causeOfDeath']),
      ageOfDeath: serializer.fromJson<int?>(json['ageOfDeath']),
      partnerId: serializer.fromJson<String?>(json['partnerId']),
      isMarried: serializer.fromJson<bool>(json['isMarried']),
      educationLevel: serializer.fromJson<String>(json['educationLevel']),
      currentDegree: serializer.fromJson<String?>(json['currentDegree']),
      currentJobId: serializer.fromJson<String?>(json['currentJobId']),
      currentJobTitle: serializer.fromJson<String?>(json['currentJobTitle']),
      currentSalary: serializer.fromJson<double?>(json['currentSalary']),
      jobPerformance: serializer.fromJson<int>(json['jobPerformance']),
      yearsInCurrentJob: serializer.fromJson<int>(json['yearsInCurrentJob']),
      hasDriversLicense: serializer.fromJson<bool>(json['hasDriversLicense']),
      criminalRecord: serializer.fromJson<bool>(json['criminalRecord']),
      timesArrested: serializer.fromJson<int>(json['timesArrested']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saveId': serializer.toJson<String>(saveId),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'gender': serializer.toJson<String>(gender),
      'sexualOrientation': serializer.toJson<String>(sexualOrientation),
      'birthYear': serializer.toJson<int>(birthYear),
      'currentAge': serializer.toJson<int>(currentAge),
      'country': serializer.toJson<String>(country),
      'city': serializer.toJson<String>(city),
      'avatarConfigJson': serializer.toJson<String>(avatarConfigJson),
      'health': serializer.toJson<int>(health),
      'happiness': serializer.toJson<int>(happiness),
      'smarts': serializer.toJson<int>(smarts),
      'looks': serializer.toJson<int>(looks),
      'energy': serializer.toJson<int>(energy),
      'stress': serializer.toJson<int>(stress),
      'discipline': serializer.toJson<int>(discipline),
      'charisma': serializer.toJson<int>(charisma),
      'fitness': serializer.toJson<int>(fitness),
      'reputation': serializer.toJson<int>(reputation),
      'fame': serializer.toJson<int>(fame),
      'karma': serializer.toJson<int>(karma),
      'bankBalance': serializer.toJson<double>(bankBalance),
      'annualExpenses': serializer.toJson<double>(annualExpenses),
      'debt': serializer.toJson<double>(debt),
      'creditScore': serializer.toJson<int>(creditScore),
      'isAlive': serializer.toJson<bool>(isAlive),
      'causeOfDeath': serializer.toJson<String?>(causeOfDeath),
      'ageOfDeath': serializer.toJson<int?>(ageOfDeath),
      'partnerId': serializer.toJson<String?>(partnerId),
      'isMarried': serializer.toJson<bool>(isMarried),
      'educationLevel': serializer.toJson<String>(educationLevel),
      'currentDegree': serializer.toJson<String?>(currentDegree),
      'currentJobId': serializer.toJson<String?>(currentJobId),
      'currentJobTitle': serializer.toJson<String?>(currentJobTitle),
      'currentSalary': serializer.toJson<double?>(currentSalary),
      'jobPerformance': serializer.toJson<int>(jobPerformance),
      'yearsInCurrentJob': serializer.toJson<int>(yearsInCurrentJob),
      'hasDriversLicense': serializer.toJson<bool>(hasDriversLicense),
      'criminalRecord': serializer.toJson<bool>(criminalRecord),
      'timesArrested': serializer.toJson<int>(timesArrested),
    };
  }

  Character copyWith({
    String? id,
    String? saveId,
    String? firstName,
    String? lastName,
    String? gender,
    String? sexualOrientation,
    int? birthYear,
    int? currentAge,
    String? country,
    String? city,
    String? avatarConfigJson,
    int? health,
    int? happiness,
    int? smarts,
    int? looks,
    int? energy,
    int? stress,
    int? discipline,
    int? charisma,
    int? fitness,
    int? reputation,
    int? fame,
    int? karma,
    double? bankBalance,
    double? annualExpenses,
    double? debt,
    int? creditScore,
    bool? isAlive,
    Value<String?> causeOfDeath = const Value.absent(),
    Value<int?> ageOfDeath = const Value.absent(),
    Value<String?> partnerId = const Value.absent(),
    bool? isMarried,
    String? educationLevel,
    Value<String?> currentDegree = const Value.absent(),
    Value<String?> currentJobId = const Value.absent(),
    Value<String?> currentJobTitle = const Value.absent(),
    Value<double?> currentSalary = const Value.absent(),
    int? jobPerformance,
    int? yearsInCurrentJob,
    bool? hasDriversLicense,
    bool? criminalRecord,
    int? timesArrested,
  }) => Character(
    id: id ?? this.id,
    saveId: saveId ?? this.saveId,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    gender: gender ?? this.gender,
    sexualOrientation: sexualOrientation ?? this.sexualOrientation,
    birthYear: birthYear ?? this.birthYear,
    currentAge: currentAge ?? this.currentAge,
    country: country ?? this.country,
    city: city ?? this.city,
    avatarConfigJson: avatarConfigJson ?? this.avatarConfigJson,
    health: health ?? this.health,
    happiness: happiness ?? this.happiness,
    smarts: smarts ?? this.smarts,
    looks: looks ?? this.looks,
    energy: energy ?? this.energy,
    stress: stress ?? this.stress,
    discipline: discipline ?? this.discipline,
    charisma: charisma ?? this.charisma,
    fitness: fitness ?? this.fitness,
    reputation: reputation ?? this.reputation,
    fame: fame ?? this.fame,
    karma: karma ?? this.karma,
    bankBalance: bankBalance ?? this.bankBalance,
    annualExpenses: annualExpenses ?? this.annualExpenses,
    debt: debt ?? this.debt,
    creditScore: creditScore ?? this.creditScore,
    isAlive: isAlive ?? this.isAlive,
    causeOfDeath: causeOfDeath.present ? causeOfDeath.value : this.causeOfDeath,
    ageOfDeath: ageOfDeath.present ? ageOfDeath.value : this.ageOfDeath,
    partnerId: partnerId.present ? partnerId.value : this.partnerId,
    isMarried: isMarried ?? this.isMarried,
    educationLevel: educationLevel ?? this.educationLevel,
    currentDegree: currentDegree.present
        ? currentDegree.value
        : this.currentDegree,
    currentJobId: currentJobId.present ? currentJobId.value : this.currentJobId,
    currentJobTitle: currentJobTitle.present
        ? currentJobTitle.value
        : this.currentJobTitle,
    currentSalary: currentSalary.present
        ? currentSalary.value
        : this.currentSalary,
    jobPerformance: jobPerformance ?? this.jobPerformance,
    yearsInCurrentJob: yearsInCurrentJob ?? this.yearsInCurrentJob,
    hasDriversLicense: hasDriversLicense ?? this.hasDriversLicense,
    criminalRecord: criminalRecord ?? this.criminalRecord,
    timesArrested: timesArrested ?? this.timesArrested,
  );
  Character copyWithCompanion(CharactersCompanion data) {
    return Character(
      id: data.id.present ? data.id.value : this.id,
      saveId: data.saveId.present ? data.saveId.value : this.saveId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      gender: data.gender.present ? data.gender.value : this.gender,
      sexualOrientation: data.sexualOrientation.present
          ? data.sexualOrientation.value
          : this.sexualOrientation,
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      currentAge: data.currentAge.present
          ? data.currentAge.value
          : this.currentAge,
      country: data.country.present ? data.country.value : this.country,
      city: data.city.present ? data.city.value : this.city,
      avatarConfigJson: data.avatarConfigJson.present
          ? data.avatarConfigJson.value
          : this.avatarConfigJson,
      health: data.health.present ? data.health.value : this.health,
      happiness: data.happiness.present ? data.happiness.value : this.happiness,
      smarts: data.smarts.present ? data.smarts.value : this.smarts,
      looks: data.looks.present ? data.looks.value : this.looks,
      energy: data.energy.present ? data.energy.value : this.energy,
      stress: data.stress.present ? data.stress.value : this.stress,
      discipline: data.discipline.present
          ? data.discipline.value
          : this.discipline,
      charisma: data.charisma.present ? data.charisma.value : this.charisma,
      fitness: data.fitness.present ? data.fitness.value : this.fitness,
      reputation: data.reputation.present
          ? data.reputation.value
          : this.reputation,
      fame: data.fame.present ? data.fame.value : this.fame,
      karma: data.karma.present ? data.karma.value : this.karma,
      bankBalance: data.bankBalance.present
          ? data.bankBalance.value
          : this.bankBalance,
      annualExpenses: data.annualExpenses.present
          ? data.annualExpenses.value
          : this.annualExpenses,
      debt: data.debt.present ? data.debt.value : this.debt,
      creditScore: data.creditScore.present
          ? data.creditScore.value
          : this.creditScore,
      isAlive: data.isAlive.present ? data.isAlive.value : this.isAlive,
      causeOfDeath: data.causeOfDeath.present
          ? data.causeOfDeath.value
          : this.causeOfDeath,
      ageOfDeath: data.ageOfDeath.present
          ? data.ageOfDeath.value
          : this.ageOfDeath,
      partnerId: data.partnerId.present ? data.partnerId.value : this.partnerId,
      isMarried: data.isMarried.present ? data.isMarried.value : this.isMarried,
      educationLevel: data.educationLevel.present
          ? data.educationLevel.value
          : this.educationLevel,
      currentDegree: data.currentDegree.present
          ? data.currentDegree.value
          : this.currentDegree,
      currentJobId: data.currentJobId.present
          ? data.currentJobId.value
          : this.currentJobId,
      currentJobTitle: data.currentJobTitle.present
          ? data.currentJobTitle.value
          : this.currentJobTitle,
      currentSalary: data.currentSalary.present
          ? data.currentSalary.value
          : this.currentSalary,
      jobPerformance: data.jobPerformance.present
          ? data.jobPerformance.value
          : this.jobPerformance,
      yearsInCurrentJob: data.yearsInCurrentJob.present
          ? data.yearsInCurrentJob.value
          : this.yearsInCurrentJob,
      hasDriversLicense: data.hasDriversLicense.present
          ? data.hasDriversLicense.value
          : this.hasDriversLicense,
      criminalRecord: data.criminalRecord.present
          ? data.criminalRecord.value
          : this.criminalRecord,
      timesArrested: data.timesArrested.present
          ? data.timesArrested.value
          : this.timesArrested,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Character(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('gender: $gender, ')
          ..write('sexualOrientation: $sexualOrientation, ')
          ..write('birthYear: $birthYear, ')
          ..write('currentAge: $currentAge, ')
          ..write('country: $country, ')
          ..write('city: $city, ')
          ..write('avatarConfigJson: $avatarConfigJson, ')
          ..write('health: $health, ')
          ..write('happiness: $happiness, ')
          ..write('smarts: $smarts, ')
          ..write('looks: $looks, ')
          ..write('energy: $energy, ')
          ..write('stress: $stress, ')
          ..write('discipline: $discipline, ')
          ..write('charisma: $charisma, ')
          ..write('fitness: $fitness, ')
          ..write('reputation: $reputation, ')
          ..write('fame: $fame, ')
          ..write('karma: $karma, ')
          ..write('bankBalance: $bankBalance, ')
          ..write('annualExpenses: $annualExpenses, ')
          ..write('debt: $debt, ')
          ..write('creditScore: $creditScore, ')
          ..write('isAlive: $isAlive, ')
          ..write('causeOfDeath: $causeOfDeath, ')
          ..write('ageOfDeath: $ageOfDeath, ')
          ..write('partnerId: $partnerId, ')
          ..write('isMarried: $isMarried, ')
          ..write('educationLevel: $educationLevel, ')
          ..write('currentDegree: $currentDegree, ')
          ..write('currentJobId: $currentJobId, ')
          ..write('currentJobTitle: $currentJobTitle, ')
          ..write('currentSalary: $currentSalary, ')
          ..write('jobPerformance: $jobPerformance, ')
          ..write('yearsInCurrentJob: $yearsInCurrentJob, ')
          ..write('hasDriversLicense: $hasDriversLicense, ')
          ..write('criminalRecord: $criminalRecord, ')
          ..write('timesArrested: $timesArrested')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    saveId,
    firstName,
    lastName,
    gender,
    sexualOrientation,
    birthYear,
    currentAge,
    country,
    city,
    avatarConfigJson,
    health,
    happiness,
    smarts,
    looks,
    energy,
    stress,
    discipline,
    charisma,
    fitness,
    reputation,
    fame,
    karma,
    bankBalance,
    annualExpenses,
    debt,
    creditScore,
    isAlive,
    causeOfDeath,
    ageOfDeath,
    partnerId,
    isMarried,
    educationLevel,
    currentDegree,
    currentJobId,
    currentJobTitle,
    currentSalary,
    jobPerformance,
    yearsInCurrentJob,
    hasDriversLicense,
    criminalRecord,
    timesArrested,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Character &&
          other.id == this.id &&
          other.saveId == this.saveId &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.gender == this.gender &&
          other.sexualOrientation == this.sexualOrientation &&
          other.birthYear == this.birthYear &&
          other.currentAge == this.currentAge &&
          other.country == this.country &&
          other.city == this.city &&
          other.avatarConfigJson == this.avatarConfigJson &&
          other.health == this.health &&
          other.happiness == this.happiness &&
          other.smarts == this.smarts &&
          other.looks == this.looks &&
          other.energy == this.energy &&
          other.stress == this.stress &&
          other.discipline == this.discipline &&
          other.charisma == this.charisma &&
          other.fitness == this.fitness &&
          other.reputation == this.reputation &&
          other.fame == this.fame &&
          other.karma == this.karma &&
          other.bankBalance == this.bankBalance &&
          other.annualExpenses == this.annualExpenses &&
          other.debt == this.debt &&
          other.creditScore == this.creditScore &&
          other.isAlive == this.isAlive &&
          other.causeOfDeath == this.causeOfDeath &&
          other.ageOfDeath == this.ageOfDeath &&
          other.partnerId == this.partnerId &&
          other.isMarried == this.isMarried &&
          other.educationLevel == this.educationLevel &&
          other.currentDegree == this.currentDegree &&
          other.currentJobId == this.currentJobId &&
          other.currentJobTitle == this.currentJobTitle &&
          other.currentSalary == this.currentSalary &&
          other.jobPerformance == this.jobPerformance &&
          other.yearsInCurrentJob == this.yearsInCurrentJob &&
          other.hasDriversLicense == this.hasDriversLicense &&
          other.criminalRecord == this.criminalRecord &&
          other.timesArrested == this.timesArrested);
}

class CharactersCompanion extends UpdateCompanion<Character> {
  final Value<String> id;
  final Value<String> saveId;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String> gender;
  final Value<String> sexualOrientation;
  final Value<int> birthYear;
  final Value<int> currentAge;
  final Value<String> country;
  final Value<String> city;
  final Value<String> avatarConfigJson;
  final Value<int> health;
  final Value<int> happiness;
  final Value<int> smarts;
  final Value<int> looks;
  final Value<int> energy;
  final Value<int> stress;
  final Value<int> discipline;
  final Value<int> charisma;
  final Value<int> fitness;
  final Value<int> reputation;
  final Value<int> fame;
  final Value<int> karma;
  final Value<double> bankBalance;
  final Value<double> annualExpenses;
  final Value<double> debt;
  final Value<int> creditScore;
  final Value<bool> isAlive;
  final Value<String?> causeOfDeath;
  final Value<int?> ageOfDeath;
  final Value<String?> partnerId;
  final Value<bool> isMarried;
  final Value<String> educationLevel;
  final Value<String?> currentDegree;
  final Value<String?> currentJobId;
  final Value<String?> currentJobTitle;
  final Value<double?> currentSalary;
  final Value<int> jobPerformance;
  final Value<int> yearsInCurrentJob;
  final Value<bool> hasDriversLicense;
  final Value<bool> criminalRecord;
  final Value<int> timesArrested;
  final Value<int> rowid;
  const CharactersCompanion({
    this.id = const Value.absent(),
    this.saveId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.gender = const Value.absent(),
    this.sexualOrientation = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.currentAge = const Value.absent(),
    this.country = const Value.absent(),
    this.city = const Value.absent(),
    this.avatarConfigJson = const Value.absent(),
    this.health = const Value.absent(),
    this.happiness = const Value.absent(),
    this.smarts = const Value.absent(),
    this.looks = const Value.absent(),
    this.energy = const Value.absent(),
    this.stress = const Value.absent(),
    this.discipline = const Value.absent(),
    this.charisma = const Value.absent(),
    this.fitness = const Value.absent(),
    this.reputation = const Value.absent(),
    this.fame = const Value.absent(),
    this.karma = const Value.absent(),
    this.bankBalance = const Value.absent(),
    this.annualExpenses = const Value.absent(),
    this.debt = const Value.absent(),
    this.creditScore = const Value.absent(),
    this.isAlive = const Value.absent(),
    this.causeOfDeath = const Value.absent(),
    this.ageOfDeath = const Value.absent(),
    this.partnerId = const Value.absent(),
    this.isMarried = const Value.absent(),
    this.educationLevel = const Value.absent(),
    this.currentDegree = const Value.absent(),
    this.currentJobId = const Value.absent(),
    this.currentJobTitle = const Value.absent(),
    this.currentSalary = const Value.absent(),
    this.jobPerformance = const Value.absent(),
    this.yearsInCurrentJob = const Value.absent(),
    this.hasDriversLicense = const Value.absent(),
    this.criminalRecord = const Value.absent(),
    this.timesArrested = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharactersCompanion.insert({
    required String id,
    required String saveId,
    required String firstName,
    required String lastName,
    required String gender,
    required String sexualOrientation,
    required int birthYear,
    required int currentAge,
    required String country,
    required String city,
    required String avatarConfigJson,
    required int health,
    required int happiness,
    required int smarts,
    required int looks,
    required int energy,
    required int stress,
    required int discipline,
    required int charisma,
    required int fitness,
    required int reputation,
    required int fame,
    required int karma,
    required double bankBalance,
    required double annualExpenses,
    required double debt,
    required int creditScore,
    this.isAlive = const Value.absent(),
    this.causeOfDeath = const Value.absent(),
    this.ageOfDeath = const Value.absent(),
    this.partnerId = const Value.absent(),
    this.isMarried = const Value.absent(),
    required String educationLevel,
    this.currentDegree = const Value.absent(),
    this.currentJobId = const Value.absent(),
    this.currentJobTitle = const Value.absent(),
    this.currentSalary = const Value.absent(),
    this.jobPerformance = const Value.absent(),
    this.yearsInCurrentJob = const Value.absent(),
    this.hasDriversLicense = const Value.absent(),
    this.criminalRecord = const Value.absent(),
    this.timesArrested = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saveId = Value(saveId),
       firstName = Value(firstName),
       lastName = Value(lastName),
       gender = Value(gender),
       sexualOrientation = Value(sexualOrientation),
       birthYear = Value(birthYear),
       currentAge = Value(currentAge),
       country = Value(country),
       city = Value(city),
       avatarConfigJson = Value(avatarConfigJson),
       health = Value(health),
       happiness = Value(happiness),
       smarts = Value(smarts),
       looks = Value(looks),
       energy = Value(energy),
       stress = Value(stress),
       discipline = Value(discipline),
       charisma = Value(charisma),
       fitness = Value(fitness),
       reputation = Value(reputation),
       fame = Value(fame),
       karma = Value(karma),
       bankBalance = Value(bankBalance),
       annualExpenses = Value(annualExpenses),
       debt = Value(debt),
       creditScore = Value(creditScore),
       educationLevel = Value(educationLevel);
  static Insertable<Character> custom({
    Expression<String>? id,
    Expression<String>? saveId,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? gender,
    Expression<String>? sexualOrientation,
    Expression<int>? birthYear,
    Expression<int>? currentAge,
    Expression<String>? country,
    Expression<String>? city,
    Expression<String>? avatarConfigJson,
    Expression<int>? health,
    Expression<int>? happiness,
    Expression<int>? smarts,
    Expression<int>? looks,
    Expression<int>? energy,
    Expression<int>? stress,
    Expression<int>? discipline,
    Expression<int>? charisma,
    Expression<int>? fitness,
    Expression<int>? reputation,
    Expression<int>? fame,
    Expression<int>? karma,
    Expression<double>? bankBalance,
    Expression<double>? annualExpenses,
    Expression<double>? debt,
    Expression<int>? creditScore,
    Expression<bool>? isAlive,
    Expression<String>? causeOfDeath,
    Expression<int>? ageOfDeath,
    Expression<String>? partnerId,
    Expression<bool>? isMarried,
    Expression<String>? educationLevel,
    Expression<String>? currentDegree,
    Expression<String>? currentJobId,
    Expression<String>? currentJobTitle,
    Expression<double>? currentSalary,
    Expression<int>? jobPerformance,
    Expression<int>? yearsInCurrentJob,
    Expression<bool>? hasDriversLicense,
    Expression<bool>? criminalRecord,
    Expression<int>? timesArrested,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saveId != null) 'save_id': saveId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (gender != null) 'gender': gender,
      if (sexualOrientation != null) 'sexual_orientation': sexualOrientation,
      if (birthYear != null) 'birth_year': birthYear,
      if (currentAge != null) 'current_age': currentAge,
      if (country != null) 'country': country,
      if (city != null) 'city': city,
      if (avatarConfigJson != null) 'avatar_config_json': avatarConfigJson,
      if (health != null) 'health': health,
      if (happiness != null) 'happiness': happiness,
      if (smarts != null) 'smarts': smarts,
      if (looks != null) 'looks': looks,
      if (energy != null) 'energy': energy,
      if (stress != null) 'stress': stress,
      if (discipline != null) 'discipline': discipline,
      if (charisma != null) 'charisma': charisma,
      if (fitness != null) 'fitness': fitness,
      if (reputation != null) 'reputation': reputation,
      if (fame != null) 'fame': fame,
      if (karma != null) 'karma': karma,
      if (bankBalance != null) 'bank_balance': bankBalance,
      if (annualExpenses != null) 'annual_expenses': annualExpenses,
      if (debt != null) 'debt': debt,
      if (creditScore != null) 'credit_score': creditScore,
      if (isAlive != null) 'is_alive': isAlive,
      if (causeOfDeath != null) 'cause_of_death': causeOfDeath,
      if (ageOfDeath != null) 'age_of_death': ageOfDeath,
      if (partnerId != null) 'partner_id': partnerId,
      if (isMarried != null) 'is_married': isMarried,
      if (educationLevel != null) 'education_level': educationLevel,
      if (currentDegree != null) 'current_degree': currentDegree,
      if (currentJobId != null) 'current_job_id': currentJobId,
      if (currentJobTitle != null) 'current_job_title': currentJobTitle,
      if (currentSalary != null) 'current_salary': currentSalary,
      if (jobPerformance != null) 'job_performance': jobPerformance,
      if (yearsInCurrentJob != null) 'years_in_current_job': yearsInCurrentJob,
      if (hasDriversLicense != null) 'has_drivers_license': hasDriversLicense,
      if (criminalRecord != null) 'criminal_record': criminalRecord,
      if (timesArrested != null) 'times_arrested': timesArrested,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharactersCompanion copyWith({
    Value<String>? id,
    Value<String>? saveId,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String>? gender,
    Value<String>? sexualOrientation,
    Value<int>? birthYear,
    Value<int>? currentAge,
    Value<String>? country,
    Value<String>? city,
    Value<String>? avatarConfigJson,
    Value<int>? health,
    Value<int>? happiness,
    Value<int>? smarts,
    Value<int>? looks,
    Value<int>? energy,
    Value<int>? stress,
    Value<int>? discipline,
    Value<int>? charisma,
    Value<int>? fitness,
    Value<int>? reputation,
    Value<int>? fame,
    Value<int>? karma,
    Value<double>? bankBalance,
    Value<double>? annualExpenses,
    Value<double>? debt,
    Value<int>? creditScore,
    Value<bool>? isAlive,
    Value<String?>? causeOfDeath,
    Value<int?>? ageOfDeath,
    Value<String?>? partnerId,
    Value<bool>? isMarried,
    Value<String>? educationLevel,
    Value<String?>? currentDegree,
    Value<String?>? currentJobId,
    Value<String?>? currentJobTitle,
    Value<double?>? currentSalary,
    Value<int>? jobPerformance,
    Value<int>? yearsInCurrentJob,
    Value<bool>? hasDriversLicense,
    Value<bool>? criminalRecord,
    Value<int>? timesArrested,
    Value<int>? rowid,
  }) {
    return CharactersCompanion(
      id: id ?? this.id,
      saveId: saveId ?? this.saveId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      birthYear: birthYear ?? this.birthYear,
      currentAge: currentAge ?? this.currentAge,
      country: country ?? this.country,
      city: city ?? this.city,
      avatarConfigJson: avatarConfigJson ?? this.avatarConfigJson,
      health: health ?? this.health,
      happiness: happiness ?? this.happiness,
      smarts: smarts ?? this.smarts,
      looks: looks ?? this.looks,
      energy: energy ?? this.energy,
      stress: stress ?? this.stress,
      discipline: discipline ?? this.discipline,
      charisma: charisma ?? this.charisma,
      fitness: fitness ?? this.fitness,
      reputation: reputation ?? this.reputation,
      fame: fame ?? this.fame,
      karma: karma ?? this.karma,
      bankBalance: bankBalance ?? this.bankBalance,
      annualExpenses: annualExpenses ?? this.annualExpenses,
      debt: debt ?? this.debt,
      creditScore: creditScore ?? this.creditScore,
      isAlive: isAlive ?? this.isAlive,
      causeOfDeath: causeOfDeath ?? this.causeOfDeath,
      ageOfDeath: ageOfDeath ?? this.ageOfDeath,
      partnerId: partnerId ?? this.partnerId,
      isMarried: isMarried ?? this.isMarried,
      educationLevel: educationLevel ?? this.educationLevel,
      currentDegree: currentDegree ?? this.currentDegree,
      currentJobId: currentJobId ?? this.currentJobId,
      currentJobTitle: currentJobTitle ?? this.currentJobTitle,
      currentSalary: currentSalary ?? this.currentSalary,
      jobPerformance: jobPerformance ?? this.jobPerformance,
      yearsInCurrentJob: yearsInCurrentJob ?? this.yearsInCurrentJob,
      hasDriversLicense: hasDriversLicense ?? this.hasDriversLicense,
      criminalRecord: criminalRecord ?? this.criminalRecord,
      timesArrested: timesArrested ?? this.timesArrested,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saveId.present) {
      map['save_id'] = Variable<String>(saveId.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (sexualOrientation.present) {
      map['sexual_orientation'] = Variable<String>(sexualOrientation.value);
    }
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (currentAge.present) {
      map['current_age'] = Variable<int>(currentAge.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (avatarConfigJson.present) {
      map['avatar_config_json'] = Variable<String>(avatarConfigJson.value);
    }
    if (health.present) {
      map['health'] = Variable<int>(health.value);
    }
    if (happiness.present) {
      map['happiness'] = Variable<int>(happiness.value);
    }
    if (smarts.present) {
      map['smarts'] = Variable<int>(smarts.value);
    }
    if (looks.present) {
      map['looks'] = Variable<int>(looks.value);
    }
    if (energy.present) {
      map['energy'] = Variable<int>(energy.value);
    }
    if (stress.present) {
      map['stress'] = Variable<int>(stress.value);
    }
    if (discipline.present) {
      map['discipline'] = Variable<int>(discipline.value);
    }
    if (charisma.present) {
      map['charisma'] = Variable<int>(charisma.value);
    }
    if (fitness.present) {
      map['fitness'] = Variable<int>(fitness.value);
    }
    if (reputation.present) {
      map['reputation'] = Variable<int>(reputation.value);
    }
    if (fame.present) {
      map['fame'] = Variable<int>(fame.value);
    }
    if (karma.present) {
      map['karma'] = Variable<int>(karma.value);
    }
    if (bankBalance.present) {
      map['bank_balance'] = Variable<double>(bankBalance.value);
    }
    if (annualExpenses.present) {
      map['annual_expenses'] = Variable<double>(annualExpenses.value);
    }
    if (debt.present) {
      map['debt'] = Variable<double>(debt.value);
    }
    if (creditScore.present) {
      map['credit_score'] = Variable<int>(creditScore.value);
    }
    if (isAlive.present) {
      map['is_alive'] = Variable<bool>(isAlive.value);
    }
    if (causeOfDeath.present) {
      map['cause_of_death'] = Variable<String>(causeOfDeath.value);
    }
    if (ageOfDeath.present) {
      map['age_of_death'] = Variable<int>(ageOfDeath.value);
    }
    if (partnerId.present) {
      map['partner_id'] = Variable<String>(partnerId.value);
    }
    if (isMarried.present) {
      map['is_married'] = Variable<bool>(isMarried.value);
    }
    if (educationLevel.present) {
      map['education_level'] = Variable<String>(educationLevel.value);
    }
    if (currentDegree.present) {
      map['current_degree'] = Variable<String>(currentDegree.value);
    }
    if (currentJobId.present) {
      map['current_job_id'] = Variable<String>(currentJobId.value);
    }
    if (currentJobTitle.present) {
      map['current_job_title'] = Variable<String>(currentJobTitle.value);
    }
    if (currentSalary.present) {
      map['current_salary'] = Variable<double>(currentSalary.value);
    }
    if (jobPerformance.present) {
      map['job_performance'] = Variable<int>(jobPerformance.value);
    }
    if (yearsInCurrentJob.present) {
      map['years_in_current_job'] = Variable<int>(yearsInCurrentJob.value);
    }
    if (hasDriversLicense.present) {
      map['has_drivers_license'] = Variable<bool>(hasDriversLicense.value);
    }
    if (criminalRecord.present) {
      map['criminal_record'] = Variable<bool>(criminalRecord.value);
    }
    if (timesArrested.present) {
      map['times_arrested'] = Variable<int>(timesArrested.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharactersCompanion(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('gender: $gender, ')
          ..write('sexualOrientation: $sexualOrientation, ')
          ..write('birthYear: $birthYear, ')
          ..write('currentAge: $currentAge, ')
          ..write('country: $country, ')
          ..write('city: $city, ')
          ..write('avatarConfigJson: $avatarConfigJson, ')
          ..write('health: $health, ')
          ..write('happiness: $happiness, ')
          ..write('smarts: $smarts, ')
          ..write('looks: $looks, ')
          ..write('energy: $energy, ')
          ..write('stress: $stress, ')
          ..write('discipline: $discipline, ')
          ..write('charisma: $charisma, ')
          ..write('fitness: $fitness, ')
          ..write('reputation: $reputation, ')
          ..write('fame: $fame, ')
          ..write('karma: $karma, ')
          ..write('bankBalance: $bankBalance, ')
          ..write('annualExpenses: $annualExpenses, ')
          ..write('debt: $debt, ')
          ..write('creditScore: $creditScore, ')
          ..write('isAlive: $isAlive, ')
          ..write('causeOfDeath: $causeOfDeath, ')
          ..write('ageOfDeath: $ageOfDeath, ')
          ..write('partnerId: $partnerId, ')
          ..write('isMarried: $isMarried, ')
          ..write('educationLevel: $educationLevel, ')
          ..write('currentDegree: $currentDegree, ')
          ..write('currentJobId: $currentJobId, ')
          ..write('currentJobTitle: $currentJobTitle, ')
          ..write('currentSalary: $currentSalary, ')
          ..write('jobPerformance: $jobPerformance, ')
          ..write('yearsInCurrentJob: $yearsInCurrentJob, ')
          ..write('hasDriversLicense: $hasDriversLicense, ')
          ..write('criminalRecord: $criminalRecord, ')
          ..write('timesArrested: $timesArrested, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NpcsTable extends Npcs with TableInfo<$NpcsTable, Npc> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NpcsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saveIdMeta = const VerificationMeta('saveId');
  @override
  late final GeneratedColumn<String> saveId = GeneratedColumn<String>(
    'save_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationshipTypeMeta = const VerificationMeta(
    'relationshipType',
  );
  @override
  late final GeneratedColumn<String> relationshipType = GeneratedColumn<String>(
    'relationship_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationshipLevelMeta = const VerificationMeta(
    'relationshipLevel',
  );
  @override
  late final GeneratedColumn<int> relationshipLevel = GeneratedColumn<int>(
    'relationship_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _respectLevelMeta = const VerificationMeta(
    'respectLevel',
  );
  @override
  late final GeneratedColumn<int> respectLevel = GeneratedColumn<int>(
    'respect_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarConfigJsonMeta = const VerificationMeta(
    'avatarConfigJson',
  );
  @override
  late final GeneratedColumn<String> avatarConfigJson = GeneratedColumn<String>(
    'avatar_config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occupationMeta = const VerificationMeta(
    'occupation',
  );
  @override
  late final GeneratedColumn<String> occupation = GeneratedColumn<String>(
    'occupation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salaryMeta = const VerificationMeta('salary');
  @override
  late final GeneratedColumn<double> salary = GeneratedColumn<double>(
    'salary',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _netWorthMeta = const VerificationMeta(
    'netWorth',
  );
  @override
  late final GeneratedColumn<double> netWorth = GeneratedColumn<double>(
    'net_worth',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _healthMeta = const VerificationMeta('health');
  @override
  late final GeneratedColumn<int> health = GeneratedColumn<int>(
    'health',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _happinessMeta = const VerificationMeta(
    'happiness',
  );
  @override
  late final GeneratedColumn<int> happiness = GeneratedColumn<int>(
    'happiness',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAliveMeta = const VerificationMeta(
    'isAlive',
  );
  @override
  late final GeneratedColumn<bool> isAlive = GeneratedColumn<bool>(
    'is_alive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_alive" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _causeOfDeathMeta = const VerificationMeta(
    'causeOfDeath',
  );
  @override
  late final GeneratedColumn<String> causeOfDeath = GeneratedColumn<String>(
    'cause_of_death',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoryJsonMeta = const VerificationMeta(
    'memoryJson',
  );
  @override
  late final GeneratedColumn<String> memoryJson = GeneratedColumn<String>(
    'memory_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saveId,
    firstName,
    lastName,
    gender,
    age,
    relationshipType,
    relationshipLevel,
    respectLevel,
    avatarConfigJson,
    occupation,
    salary,
    netWorth,
    health,
    happiness,
    isAlive,
    causeOfDeath,
    memoryJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'npcs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Npc> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('save_id')) {
      context.handle(
        _saveIdMeta,
        saveId.isAcceptableOrUnknown(data['save_id']!, _saveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saveIdMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('relationship_type')) {
      context.handle(
        _relationshipTypeMeta,
        relationshipType.isAcceptableOrUnknown(
          data['relationship_type']!,
          _relationshipTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relationshipTypeMeta);
    }
    if (data.containsKey('relationship_level')) {
      context.handle(
        _relationshipLevelMeta,
        relationshipLevel.isAcceptableOrUnknown(
          data['relationship_level']!,
          _relationshipLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relationshipLevelMeta);
    }
    if (data.containsKey('respect_level')) {
      context.handle(
        _respectLevelMeta,
        respectLevel.isAcceptableOrUnknown(
          data['respect_level']!,
          _respectLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_respectLevelMeta);
    }
    if (data.containsKey('avatar_config_json')) {
      context.handle(
        _avatarConfigJsonMeta,
        avatarConfigJson.isAcceptableOrUnknown(
          data['avatar_config_json']!,
          _avatarConfigJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avatarConfigJsonMeta);
    }
    if (data.containsKey('occupation')) {
      context.handle(
        _occupationMeta,
        occupation.isAcceptableOrUnknown(data['occupation']!, _occupationMeta),
      );
    } else if (isInserting) {
      context.missing(_occupationMeta);
    }
    if (data.containsKey('salary')) {
      context.handle(
        _salaryMeta,
        salary.isAcceptableOrUnknown(data['salary']!, _salaryMeta),
      );
    } else if (isInserting) {
      context.missing(_salaryMeta);
    }
    if (data.containsKey('net_worth')) {
      context.handle(
        _netWorthMeta,
        netWorth.isAcceptableOrUnknown(data['net_worth']!, _netWorthMeta),
      );
    } else if (isInserting) {
      context.missing(_netWorthMeta);
    }
    if (data.containsKey('health')) {
      context.handle(
        _healthMeta,
        health.isAcceptableOrUnknown(data['health']!, _healthMeta),
      );
    } else if (isInserting) {
      context.missing(_healthMeta);
    }
    if (data.containsKey('happiness')) {
      context.handle(
        _happinessMeta,
        happiness.isAcceptableOrUnknown(data['happiness']!, _happinessMeta),
      );
    } else if (isInserting) {
      context.missing(_happinessMeta);
    }
    if (data.containsKey('is_alive')) {
      context.handle(
        _isAliveMeta,
        isAlive.isAcceptableOrUnknown(data['is_alive']!, _isAliveMeta),
      );
    }
    if (data.containsKey('cause_of_death')) {
      context.handle(
        _causeOfDeathMeta,
        causeOfDeath.isAcceptableOrUnknown(
          data['cause_of_death']!,
          _causeOfDeathMeta,
        ),
      );
    }
    if (data.containsKey('memory_json')) {
      context.handle(
        _memoryJsonMeta,
        memoryJson.isAcceptableOrUnknown(data['memory_json']!, _memoryJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Npc map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Npc(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_id'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      )!,
      relationshipType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship_type'],
      )!,
      relationshipLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}relationship_level'],
      )!,
      respectLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}respect_level'],
      )!,
      avatarConfigJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_config_json'],
      )!,
      occupation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occupation'],
      )!,
      salary: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}salary'],
      )!,
      netWorth: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}net_worth'],
      )!,
      health: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}health'],
      )!,
      happiness: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}happiness'],
      )!,
      isAlive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_alive'],
      )!,
      causeOfDeath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cause_of_death'],
      ),
      memoryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_json'],
      )!,
    );
  }

  @override
  $NpcsTable createAlias(String alias) {
    return $NpcsTable(attachedDatabase, alias);
  }
}

class Npc extends DataClass implements Insertable<Npc> {
  final String id;
  final String saveId;
  final String firstName;
  final String lastName;
  final String gender;
  final int age;
  final String relationshipType;
  final int relationshipLevel;
  final int respectLevel;
  final String avatarConfigJson;
  final String occupation;
  final double salary;
  final double netWorth;
  final int health;
  final int happiness;
  final bool isAlive;
  final String? causeOfDeath;
  final String memoryJson;
  const Npc({
    required this.id,
    required this.saveId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.relationshipType,
    required this.relationshipLevel,
    required this.respectLevel,
    required this.avatarConfigJson,
    required this.occupation,
    required this.salary,
    required this.netWorth,
    required this.health,
    required this.happiness,
    required this.isAlive,
    this.causeOfDeath,
    required this.memoryJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['save_id'] = Variable<String>(saveId);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['gender'] = Variable<String>(gender);
    map['age'] = Variable<int>(age);
    map['relationship_type'] = Variable<String>(relationshipType);
    map['relationship_level'] = Variable<int>(relationshipLevel);
    map['respect_level'] = Variable<int>(respectLevel);
    map['avatar_config_json'] = Variable<String>(avatarConfigJson);
    map['occupation'] = Variable<String>(occupation);
    map['salary'] = Variable<double>(salary);
    map['net_worth'] = Variable<double>(netWorth);
    map['health'] = Variable<int>(health);
    map['happiness'] = Variable<int>(happiness);
    map['is_alive'] = Variable<bool>(isAlive);
    if (!nullToAbsent || causeOfDeath != null) {
      map['cause_of_death'] = Variable<String>(causeOfDeath);
    }
    map['memory_json'] = Variable<String>(memoryJson);
    return map;
  }

  NpcsCompanion toCompanion(bool nullToAbsent) {
    return NpcsCompanion(
      id: Value(id),
      saveId: Value(saveId),
      firstName: Value(firstName),
      lastName: Value(lastName),
      gender: Value(gender),
      age: Value(age),
      relationshipType: Value(relationshipType),
      relationshipLevel: Value(relationshipLevel),
      respectLevel: Value(respectLevel),
      avatarConfigJson: Value(avatarConfigJson),
      occupation: Value(occupation),
      salary: Value(salary),
      netWorth: Value(netWorth),
      health: Value(health),
      happiness: Value(happiness),
      isAlive: Value(isAlive),
      causeOfDeath: causeOfDeath == null && nullToAbsent
          ? const Value.absent()
          : Value(causeOfDeath),
      memoryJson: Value(memoryJson),
    );
  }

  factory Npc.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Npc(
      id: serializer.fromJson<String>(json['id']),
      saveId: serializer.fromJson<String>(json['saveId']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      gender: serializer.fromJson<String>(json['gender']),
      age: serializer.fromJson<int>(json['age']),
      relationshipType: serializer.fromJson<String>(json['relationshipType']),
      relationshipLevel: serializer.fromJson<int>(json['relationshipLevel']),
      respectLevel: serializer.fromJson<int>(json['respectLevel']),
      avatarConfigJson: serializer.fromJson<String>(json['avatarConfigJson']),
      occupation: serializer.fromJson<String>(json['occupation']),
      salary: serializer.fromJson<double>(json['salary']),
      netWorth: serializer.fromJson<double>(json['netWorth']),
      health: serializer.fromJson<int>(json['health']),
      happiness: serializer.fromJson<int>(json['happiness']),
      isAlive: serializer.fromJson<bool>(json['isAlive']),
      causeOfDeath: serializer.fromJson<String?>(json['causeOfDeath']),
      memoryJson: serializer.fromJson<String>(json['memoryJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saveId': serializer.toJson<String>(saveId),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'gender': serializer.toJson<String>(gender),
      'age': serializer.toJson<int>(age),
      'relationshipType': serializer.toJson<String>(relationshipType),
      'relationshipLevel': serializer.toJson<int>(relationshipLevel),
      'respectLevel': serializer.toJson<int>(respectLevel),
      'avatarConfigJson': serializer.toJson<String>(avatarConfigJson),
      'occupation': serializer.toJson<String>(occupation),
      'salary': serializer.toJson<double>(salary),
      'netWorth': serializer.toJson<double>(netWorth),
      'health': serializer.toJson<int>(health),
      'happiness': serializer.toJson<int>(happiness),
      'isAlive': serializer.toJson<bool>(isAlive),
      'causeOfDeath': serializer.toJson<String?>(causeOfDeath),
      'memoryJson': serializer.toJson<String>(memoryJson),
    };
  }

  Npc copyWith({
    String? id,
    String? saveId,
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
    String? relationshipType,
    int? relationshipLevel,
    int? respectLevel,
    String? avatarConfigJson,
    String? occupation,
    double? salary,
    double? netWorth,
    int? health,
    int? happiness,
    bool? isAlive,
    Value<String?> causeOfDeath = const Value.absent(),
    String? memoryJson,
  }) => Npc(
    id: id ?? this.id,
    saveId: saveId ?? this.saveId,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    gender: gender ?? this.gender,
    age: age ?? this.age,
    relationshipType: relationshipType ?? this.relationshipType,
    relationshipLevel: relationshipLevel ?? this.relationshipLevel,
    respectLevel: respectLevel ?? this.respectLevel,
    avatarConfigJson: avatarConfigJson ?? this.avatarConfigJson,
    occupation: occupation ?? this.occupation,
    salary: salary ?? this.salary,
    netWorth: netWorth ?? this.netWorth,
    health: health ?? this.health,
    happiness: happiness ?? this.happiness,
    isAlive: isAlive ?? this.isAlive,
    causeOfDeath: causeOfDeath.present ? causeOfDeath.value : this.causeOfDeath,
    memoryJson: memoryJson ?? this.memoryJson,
  );
  Npc copyWithCompanion(NpcsCompanion data) {
    return Npc(
      id: data.id.present ? data.id.value : this.id,
      saveId: data.saveId.present ? data.saveId.value : this.saveId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      gender: data.gender.present ? data.gender.value : this.gender,
      age: data.age.present ? data.age.value : this.age,
      relationshipType: data.relationshipType.present
          ? data.relationshipType.value
          : this.relationshipType,
      relationshipLevel: data.relationshipLevel.present
          ? data.relationshipLevel.value
          : this.relationshipLevel,
      respectLevel: data.respectLevel.present
          ? data.respectLevel.value
          : this.respectLevel,
      avatarConfigJson: data.avatarConfigJson.present
          ? data.avatarConfigJson.value
          : this.avatarConfigJson,
      occupation: data.occupation.present
          ? data.occupation.value
          : this.occupation,
      salary: data.salary.present ? data.salary.value : this.salary,
      netWorth: data.netWorth.present ? data.netWorth.value : this.netWorth,
      health: data.health.present ? data.health.value : this.health,
      happiness: data.happiness.present ? data.happiness.value : this.happiness,
      isAlive: data.isAlive.present ? data.isAlive.value : this.isAlive,
      causeOfDeath: data.causeOfDeath.present
          ? data.causeOfDeath.value
          : this.causeOfDeath,
      memoryJson: data.memoryJson.present
          ? data.memoryJson.value
          : this.memoryJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Npc(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('gender: $gender, ')
          ..write('age: $age, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('relationshipLevel: $relationshipLevel, ')
          ..write('respectLevel: $respectLevel, ')
          ..write('avatarConfigJson: $avatarConfigJson, ')
          ..write('occupation: $occupation, ')
          ..write('salary: $salary, ')
          ..write('netWorth: $netWorth, ')
          ..write('health: $health, ')
          ..write('happiness: $happiness, ')
          ..write('isAlive: $isAlive, ')
          ..write('causeOfDeath: $causeOfDeath, ')
          ..write('memoryJson: $memoryJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saveId,
    firstName,
    lastName,
    gender,
    age,
    relationshipType,
    relationshipLevel,
    respectLevel,
    avatarConfigJson,
    occupation,
    salary,
    netWorth,
    health,
    happiness,
    isAlive,
    causeOfDeath,
    memoryJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Npc &&
          other.id == this.id &&
          other.saveId == this.saveId &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.gender == this.gender &&
          other.age == this.age &&
          other.relationshipType == this.relationshipType &&
          other.relationshipLevel == this.relationshipLevel &&
          other.respectLevel == this.respectLevel &&
          other.avatarConfigJson == this.avatarConfigJson &&
          other.occupation == this.occupation &&
          other.salary == this.salary &&
          other.netWorth == this.netWorth &&
          other.health == this.health &&
          other.happiness == this.happiness &&
          other.isAlive == this.isAlive &&
          other.causeOfDeath == this.causeOfDeath &&
          other.memoryJson == this.memoryJson);
}

class NpcsCompanion extends UpdateCompanion<Npc> {
  final Value<String> id;
  final Value<String> saveId;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String> gender;
  final Value<int> age;
  final Value<String> relationshipType;
  final Value<int> relationshipLevel;
  final Value<int> respectLevel;
  final Value<String> avatarConfigJson;
  final Value<String> occupation;
  final Value<double> salary;
  final Value<double> netWorth;
  final Value<int> health;
  final Value<int> happiness;
  final Value<bool> isAlive;
  final Value<String?> causeOfDeath;
  final Value<String> memoryJson;
  final Value<int> rowid;
  const NpcsCompanion({
    this.id = const Value.absent(),
    this.saveId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.gender = const Value.absent(),
    this.age = const Value.absent(),
    this.relationshipType = const Value.absent(),
    this.relationshipLevel = const Value.absent(),
    this.respectLevel = const Value.absent(),
    this.avatarConfigJson = const Value.absent(),
    this.occupation = const Value.absent(),
    this.salary = const Value.absent(),
    this.netWorth = const Value.absent(),
    this.health = const Value.absent(),
    this.happiness = const Value.absent(),
    this.isAlive = const Value.absent(),
    this.causeOfDeath = const Value.absent(),
    this.memoryJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NpcsCompanion.insert({
    required String id,
    required String saveId,
    required String firstName,
    required String lastName,
    required String gender,
    required int age,
    required String relationshipType,
    required int relationshipLevel,
    required int respectLevel,
    required String avatarConfigJson,
    required String occupation,
    required double salary,
    required double netWorth,
    required int health,
    required int happiness,
    this.isAlive = const Value.absent(),
    this.causeOfDeath = const Value.absent(),
    this.memoryJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saveId = Value(saveId),
       firstName = Value(firstName),
       lastName = Value(lastName),
       gender = Value(gender),
       age = Value(age),
       relationshipType = Value(relationshipType),
       relationshipLevel = Value(relationshipLevel),
       respectLevel = Value(respectLevel),
       avatarConfigJson = Value(avatarConfigJson),
       occupation = Value(occupation),
       salary = Value(salary),
       netWorth = Value(netWorth),
       health = Value(health),
       happiness = Value(happiness);
  static Insertable<Npc> custom({
    Expression<String>? id,
    Expression<String>? saveId,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? gender,
    Expression<int>? age,
    Expression<String>? relationshipType,
    Expression<int>? relationshipLevel,
    Expression<int>? respectLevel,
    Expression<String>? avatarConfigJson,
    Expression<String>? occupation,
    Expression<double>? salary,
    Expression<double>? netWorth,
    Expression<int>? health,
    Expression<int>? happiness,
    Expression<bool>? isAlive,
    Expression<String>? causeOfDeath,
    Expression<String>? memoryJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saveId != null) 'save_id': saveId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
      if (relationshipType != null) 'relationship_type': relationshipType,
      if (relationshipLevel != null) 'relationship_level': relationshipLevel,
      if (respectLevel != null) 'respect_level': respectLevel,
      if (avatarConfigJson != null) 'avatar_config_json': avatarConfigJson,
      if (occupation != null) 'occupation': occupation,
      if (salary != null) 'salary': salary,
      if (netWorth != null) 'net_worth': netWorth,
      if (health != null) 'health': health,
      if (happiness != null) 'happiness': happiness,
      if (isAlive != null) 'is_alive': isAlive,
      if (causeOfDeath != null) 'cause_of_death': causeOfDeath,
      if (memoryJson != null) 'memory_json': memoryJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NpcsCompanion copyWith({
    Value<String>? id,
    Value<String>? saveId,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String>? gender,
    Value<int>? age,
    Value<String>? relationshipType,
    Value<int>? relationshipLevel,
    Value<int>? respectLevel,
    Value<String>? avatarConfigJson,
    Value<String>? occupation,
    Value<double>? salary,
    Value<double>? netWorth,
    Value<int>? health,
    Value<int>? happiness,
    Value<bool>? isAlive,
    Value<String?>? causeOfDeath,
    Value<String>? memoryJson,
    Value<int>? rowid,
  }) {
    return NpcsCompanion(
      id: id ?? this.id,
      saveId: saveId ?? this.saveId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      relationshipType: relationshipType ?? this.relationshipType,
      relationshipLevel: relationshipLevel ?? this.relationshipLevel,
      respectLevel: respectLevel ?? this.respectLevel,
      avatarConfigJson: avatarConfigJson ?? this.avatarConfigJson,
      occupation: occupation ?? this.occupation,
      salary: salary ?? this.salary,
      netWorth: netWorth ?? this.netWorth,
      health: health ?? this.health,
      happiness: happiness ?? this.happiness,
      isAlive: isAlive ?? this.isAlive,
      causeOfDeath: causeOfDeath ?? this.causeOfDeath,
      memoryJson: memoryJson ?? this.memoryJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saveId.present) {
      map['save_id'] = Variable<String>(saveId.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (relationshipType.present) {
      map['relationship_type'] = Variable<String>(relationshipType.value);
    }
    if (relationshipLevel.present) {
      map['relationship_level'] = Variable<int>(relationshipLevel.value);
    }
    if (respectLevel.present) {
      map['respect_level'] = Variable<int>(respectLevel.value);
    }
    if (avatarConfigJson.present) {
      map['avatar_config_json'] = Variable<String>(avatarConfigJson.value);
    }
    if (occupation.present) {
      map['occupation'] = Variable<String>(occupation.value);
    }
    if (salary.present) {
      map['salary'] = Variable<double>(salary.value);
    }
    if (netWorth.present) {
      map['net_worth'] = Variable<double>(netWorth.value);
    }
    if (health.present) {
      map['health'] = Variable<int>(health.value);
    }
    if (happiness.present) {
      map['happiness'] = Variable<int>(happiness.value);
    }
    if (isAlive.present) {
      map['is_alive'] = Variable<bool>(isAlive.value);
    }
    if (causeOfDeath.present) {
      map['cause_of_death'] = Variable<String>(causeOfDeath.value);
    }
    if (memoryJson.present) {
      map['memory_json'] = Variable<String>(memoryJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NpcsCompanion(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('gender: $gender, ')
          ..write('age: $age, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('relationshipLevel: $relationshipLevel, ')
          ..write('respectLevel: $respectLevel, ')
          ..write('avatarConfigJson: $avatarConfigJson, ')
          ..write('occupation: $occupation, ')
          ..write('salary: $salary, ')
          ..write('netWorth: $netWorth, ')
          ..write('health: $health, ')
          ..write('happiness: $happiness, ')
          ..write('isAlive: $isAlive, ')
          ..write('causeOfDeath: $causeOfDeath, ')
          ..write('memoryJson: $memoryJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EducationHistoriesTable extends EducationHistories
    with TableInfo<$EducationHistoriesTable, EducationHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EducationHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saveIdMeta = const VerificationMeta('saveId');
  @override
  late final GeneratedColumn<String> saveId = GeneratedColumn<String>(
    'save_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolTypeMeta = const VerificationMeta(
    'schoolType',
  );
  @override
  late final GeneratedColumn<String> schoolType = GeneratedColumn<String>(
    'school_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionNameMeta = const VerificationMeta(
    'institutionName',
  );
  @override
  late final GeneratedColumn<String> institutionName = GeneratedColumn<String>(
    'institution_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _majorOrCourseMeta = const VerificationMeta(
    'majorOrCourse',
  );
  @override
  late final GeneratedColumn<String> majorOrCourse = GeneratedColumn<String>(
    'major_or_course',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startAgeMeta = const VerificationMeta(
    'startAge',
  );
  @override
  late final GeneratedColumn<int> startAge = GeneratedColumn<int>(
    'start_age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _graduatedAgeMeta = const VerificationMeta(
    'graduatedAge',
  );
  @override
  late final GeneratedColumn<int> graduatedAge = GeneratedColumn<int>(
    'graduated_age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _gpaOrGradeMeta = const VerificationMeta(
    'gpaOrGrade',
  );
  @override
  late final GeneratedColumn<double> gpaOrGrade = GeneratedColumn<double>(
    'gpa_or_grade',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saveId,
    schoolType,
    institutionName,
    majorOrCourse,
    startAge,
    graduatedAge,
    isCompleted,
    gpaOrGrade,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'education_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<EducationHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('save_id')) {
      context.handle(
        _saveIdMeta,
        saveId.isAcceptableOrUnknown(data['save_id']!, _saveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saveIdMeta);
    }
    if (data.containsKey('school_type')) {
      context.handle(
        _schoolTypeMeta,
        schoolType.isAcceptableOrUnknown(data['school_type']!, _schoolTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolTypeMeta);
    }
    if (data.containsKey('institution_name')) {
      context.handle(
        _institutionNameMeta,
        institutionName.isAcceptableOrUnknown(
          data['institution_name']!,
          _institutionNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionNameMeta);
    }
    if (data.containsKey('major_or_course')) {
      context.handle(
        _majorOrCourseMeta,
        majorOrCourse.isAcceptableOrUnknown(
          data['major_or_course']!,
          _majorOrCourseMeta,
        ),
      );
    }
    if (data.containsKey('start_age')) {
      context.handle(
        _startAgeMeta,
        startAge.isAcceptableOrUnknown(data['start_age']!, _startAgeMeta),
      );
    } else if (isInserting) {
      context.missing(_startAgeMeta);
    }
    if (data.containsKey('graduated_age')) {
      context.handle(
        _graduatedAgeMeta,
        graduatedAge.isAcceptableOrUnknown(
          data['graduated_age']!,
          _graduatedAgeMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('gpa_or_grade')) {
      context.handle(
        _gpaOrGradeMeta,
        gpaOrGrade.isAcceptableOrUnknown(
          data['gpa_or_grade']!,
          _gpaOrGradeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gpaOrGradeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EducationHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EducationHistory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_id'],
      )!,
      schoolType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_type'],
      )!,
      institutionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution_name'],
      )!,
      majorOrCourse: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}major_or_course'],
      ),
      startAge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_age'],
      )!,
      graduatedAge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}graduated_age'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      gpaOrGrade: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gpa_or_grade'],
      )!,
    );
  }

  @override
  $EducationHistoriesTable createAlias(String alias) {
    return $EducationHistoriesTable(attachedDatabase, alias);
  }
}

class EducationHistory extends DataClass
    implements Insertable<EducationHistory> {
  final String id;
  final String saveId;
  final String schoolType;
  final String institutionName;
  final String? majorOrCourse;
  final int startAge;
  final int? graduatedAge;
  final bool isCompleted;
  final double gpaOrGrade;
  const EducationHistory({
    required this.id,
    required this.saveId,
    required this.schoolType,
    required this.institutionName,
    this.majorOrCourse,
    required this.startAge,
    this.graduatedAge,
    required this.isCompleted,
    required this.gpaOrGrade,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['save_id'] = Variable<String>(saveId);
    map['school_type'] = Variable<String>(schoolType);
    map['institution_name'] = Variable<String>(institutionName);
    if (!nullToAbsent || majorOrCourse != null) {
      map['major_or_course'] = Variable<String>(majorOrCourse);
    }
    map['start_age'] = Variable<int>(startAge);
    if (!nullToAbsent || graduatedAge != null) {
      map['graduated_age'] = Variable<int>(graduatedAge);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['gpa_or_grade'] = Variable<double>(gpaOrGrade);
    return map;
  }

  EducationHistoriesCompanion toCompanion(bool nullToAbsent) {
    return EducationHistoriesCompanion(
      id: Value(id),
      saveId: Value(saveId),
      schoolType: Value(schoolType),
      institutionName: Value(institutionName),
      majorOrCourse: majorOrCourse == null && nullToAbsent
          ? const Value.absent()
          : Value(majorOrCourse),
      startAge: Value(startAge),
      graduatedAge: graduatedAge == null && nullToAbsent
          ? const Value.absent()
          : Value(graduatedAge),
      isCompleted: Value(isCompleted),
      gpaOrGrade: Value(gpaOrGrade),
    );
  }

  factory EducationHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EducationHistory(
      id: serializer.fromJson<String>(json['id']),
      saveId: serializer.fromJson<String>(json['saveId']),
      schoolType: serializer.fromJson<String>(json['schoolType']),
      institutionName: serializer.fromJson<String>(json['institutionName']),
      majorOrCourse: serializer.fromJson<String?>(json['majorOrCourse']),
      startAge: serializer.fromJson<int>(json['startAge']),
      graduatedAge: serializer.fromJson<int?>(json['graduatedAge']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      gpaOrGrade: serializer.fromJson<double>(json['gpaOrGrade']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saveId': serializer.toJson<String>(saveId),
      'schoolType': serializer.toJson<String>(schoolType),
      'institutionName': serializer.toJson<String>(institutionName),
      'majorOrCourse': serializer.toJson<String?>(majorOrCourse),
      'startAge': serializer.toJson<int>(startAge),
      'graduatedAge': serializer.toJson<int?>(graduatedAge),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'gpaOrGrade': serializer.toJson<double>(gpaOrGrade),
    };
  }

  EducationHistory copyWith({
    String? id,
    String? saveId,
    String? schoolType,
    String? institutionName,
    Value<String?> majorOrCourse = const Value.absent(),
    int? startAge,
    Value<int?> graduatedAge = const Value.absent(),
    bool? isCompleted,
    double? gpaOrGrade,
  }) => EducationHistory(
    id: id ?? this.id,
    saveId: saveId ?? this.saveId,
    schoolType: schoolType ?? this.schoolType,
    institutionName: institutionName ?? this.institutionName,
    majorOrCourse: majorOrCourse.present
        ? majorOrCourse.value
        : this.majorOrCourse,
    startAge: startAge ?? this.startAge,
    graduatedAge: graduatedAge.present ? graduatedAge.value : this.graduatedAge,
    isCompleted: isCompleted ?? this.isCompleted,
    gpaOrGrade: gpaOrGrade ?? this.gpaOrGrade,
  );
  EducationHistory copyWithCompanion(EducationHistoriesCompanion data) {
    return EducationHistory(
      id: data.id.present ? data.id.value : this.id,
      saveId: data.saveId.present ? data.saveId.value : this.saveId,
      schoolType: data.schoolType.present
          ? data.schoolType.value
          : this.schoolType,
      institutionName: data.institutionName.present
          ? data.institutionName.value
          : this.institutionName,
      majorOrCourse: data.majorOrCourse.present
          ? data.majorOrCourse.value
          : this.majorOrCourse,
      startAge: data.startAge.present ? data.startAge.value : this.startAge,
      graduatedAge: data.graduatedAge.present
          ? data.graduatedAge.value
          : this.graduatedAge,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      gpaOrGrade: data.gpaOrGrade.present
          ? data.gpaOrGrade.value
          : this.gpaOrGrade,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EducationHistory(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('schoolType: $schoolType, ')
          ..write('institutionName: $institutionName, ')
          ..write('majorOrCourse: $majorOrCourse, ')
          ..write('startAge: $startAge, ')
          ..write('graduatedAge: $graduatedAge, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('gpaOrGrade: $gpaOrGrade')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saveId,
    schoolType,
    institutionName,
    majorOrCourse,
    startAge,
    graduatedAge,
    isCompleted,
    gpaOrGrade,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EducationHistory &&
          other.id == this.id &&
          other.saveId == this.saveId &&
          other.schoolType == this.schoolType &&
          other.institutionName == this.institutionName &&
          other.majorOrCourse == this.majorOrCourse &&
          other.startAge == this.startAge &&
          other.graduatedAge == this.graduatedAge &&
          other.isCompleted == this.isCompleted &&
          other.gpaOrGrade == this.gpaOrGrade);
}

class EducationHistoriesCompanion extends UpdateCompanion<EducationHistory> {
  final Value<String> id;
  final Value<String> saveId;
  final Value<String> schoolType;
  final Value<String> institutionName;
  final Value<String?> majorOrCourse;
  final Value<int> startAge;
  final Value<int?> graduatedAge;
  final Value<bool> isCompleted;
  final Value<double> gpaOrGrade;
  final Value<int> rowid;
  const EducationHistoriesCompanion({
    this.id = const Value.absent(),
    this.saveId = const Value.absent(),
    this.schoolType = const Value.absent(),
    this.institutionName = const Value.absent(),
    this.majorOrCourse = const Value.absent(),
    this.startAge = const Value.absent(),
    this.graduatedAge = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.gpaOrGrade = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EducationHistoriesCompanion.insert({
    required String id,
    required String saveId,
    required String schoolType,
    required String institutionName,
    this.majorOrCourse = const Value.absent(),
    required int startAge,
    this.graduatedAge = const Value.absent(),
    this.isCompleted = const Value.absent(),
    required double gpaOrGrade,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saveId = Value(saveId),
       schoolType = Value(schoolType),
       institutionName = Value(institutionName),
       startAge = Value(startAge),
       gpaOrGrade = Value(gpaOrGrade);
  static Insertable<EducationHistory> custom({
    Expression<String>? id,
    Expression<String>? saveId,
    Expression<String>? schoolType,
    Expression<String>? institutionName,
    Expression<String>? majorOrCourse,
    Expression<int>? startAge,
    Expression<int>? graduatedAge,
    Expression<bool>? isCompleted,
    Expression<double>? gpaOrGrade,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saveId != null) 'save_id': saveId,
      if (schoolType != null) 'school_type': schoolType,
      if (institutionName != null) 'institution_name': institutionName,
      if (majorOrCourse != null) 'major_or_course': majorOrCourse,
      if (startAge != null) 'start_age': startAge,
      if (graduatedAge != null) 'graduated_age': graduatedAge,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (gpaOrGrade != null) 'gpa_or_grade': gpaOrGrade,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EducationHistoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? saveId,
    Value<String>? schoolType,
    Value<String>? institutionName,
    Value<String?>? majorOrCourse,
    Value<int>? startAge,
    Value<int?>? graduatedAge,
    Value<bool>? isCompleted,
    Value<double>? gpaOrGrade,
    Value<int>? rowid,
  }) {
    return EducationHistoriesCompanion(
      id: id ?? this.id,
      saveId: saveId ?? this.saveId,
      schoolType: schoolType ?? this.schoolType,
      institutionName: institutionName ?? this.institutionName,
      majorOrCourse: majorOrCourse ?? this.majorOrCourse,
      startAge: startAge ?? this.startAge,
      graduatedAge: graduatedAge ?? this.graduatedAge,
      isCompleted: isCompleted ?? this.isCompleted,
      gpaOrGrade: gpaOrGrade ?? this.gpaOrGrade,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saveId.present) {
      map['save_id'] = Variable<String>(saveId.value);
    }
    if (schoolType.present) {
      map['school_type'] = Variable<String>(schoolType.value);
    }
    if (institutionName.present) {
      map['institution_name'] = Variable<String>(institutionName.value);
    }
    if (majorOrCourse.present) {
      map['major_or_course'] = Variable<String>(majorOrCourse.value);
    }
    if (startAge.present) {
      map['start_age'] = Variable<int>(startAge.value);
    }
    if (graduatedAge.present) {
      map['graduated_age'] = Variable<int>(graduatedAge.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (gpaOrGrade.present) {
      map['gpa_or_grade'] = Variable<double>(gpaOrGrade.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EducationHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('schoolType: $schoolType, ')
          ..write('institutionName: $institutionName, ')
          ..write('majorOrCourse: $majorOrCourse, ')
          ..write('startAge: $startAge, ')
          ..write('graduatedAge: $graduatedAge, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('gpaOrGrade: $gpaOrGrade, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CareerHistoriesTable extends CareerHistories
    with TableInfo<$CareerHistoriesTable, CareerHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CareerHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saveIdMeta = const VerificationMeta('saveId');
  @override
  late final GeneratedColumn<String> saveId = GeneratedColumn<String>(
    'save_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyNameMeta = const VerificationMeta(
    'companyName',
  );
  @override
  late final GeneratedColumn<String> companyName = GeneratedColumn<String>(
    'company_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jobTitleMeta = const VerificationMeta(
    'jobTitle',
  );
  @override
  late final GeneratedColumn<String> jobTitle = GeneratedColumn<String>(
    'job_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startAgeMeta = const VerificationMeta(
    'startAge',
  );
  @override
  late final GeneratedColumn<int> startAge = GeneratedColumn<int>(
    'start_age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAgeMeta = const VerificationMeta('endAge');
  @override
  late final GeneratedColumn<int> endAge = GeneratedColumn<int>(
    'end_age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salaryMeta = const VerificationMeta('salary');
  @override
  late final GeneratedColumn<double> salary = GeneratedColumn<double>(
    'salary',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonForLeavingMeta = const VerificationMeta(
    'reasonForLeaving',
  );
  @override
  late final GeneratedColumn<String> reasonForLeaving = GeneratedColumn<String>(
    'reason_for_leaving',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saveId,
    companyName,
    jobTitle,
    field,
    startAge,
    endAge,
    salary,
    reasonForLeaving,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'career_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CareerHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('save_id')) {
      context.handle(
        _saveIdMeta,
        saveId.isAcceptableOrUnknown(data['save_id']!, _saveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saveIdMeta);
    }
    if (data.containsKey('company_name')) {
      context.handle(
        _companyNameMeta,
        companyName.isAcceptableOrUnknown(
          data['company_name']!,
          _companyNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companyNameMeta);
    }
    if (data.containsKey('job_title')) {
      context.handle(
        _jobTitleMeta,
        jobTitle.isAcceptableOrUnknown(data['job_title']!, _jobTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_jobTitleMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('start_age')) {
      context.handle(
        _startAgeMeta,
        startAge.isAcceptableOrUnknown(data['start_age']!, _startAgeMeta),
      );
    } else if (isInserting) {
      context.missing(_startAgeMeta);
    }
    if (data.containsKey('end_age')) {
      context.handle(
        _endAgeMeta,
        endAge.isAcceptableOrUnknown(data['end_age']!, _endAgeMeta),
      );
    }
    if (data.containsKey('salary')) {
      context.handle(
        _salaryMeta,
        salary.isAcceptableOrUnknown(data['salary']!, _salaryMeta),
      );
    } else if (isInserting) {
      context.missing(_salaryMeta);
    }
    if (data.containsKey('reason_for_leaving')) {
      context.handle(
        _reasonForLeavingMeta,
        reasonForLeaving.isAcceptableOrUnknown(
          data['reason_for_leaving']!,
          _reasonForLeavingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CareerHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CareerHistory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_id'],
      )!,
      companyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_name'],
      )!,
      jobTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_title'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      startAge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_age'],
      )!,
      endAge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_age'],
      ),
      salary: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}salary'],
      )!,
      reasonForLeaving: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_for_leaving'],
      ),
    );
  }

  @override
  $CareerHistoriesTable createAlias(String alias) {
    return $CareerHistoriesTable(attachedDatabase, alias);
  }
}

class CareerHistory extends DataClass implements Insertable<CareerHistory> {
  final String id;
  final String saveId;
  final String companyName;
  final String jobTitle;
  final String field;
  final int startAge;
  final int? endAge;
  final double salary;
  final String? reasonForLeaving;
  const CareerHistory({
    required this.id,
    required this.saveId,
    required this.companyName,
    required this.jobTitle,
    required this.field,
    required this.startAge,
    this.endAge,
    required this.salary,
    this.reasonForLeaving,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['save_id'] = Variable<String>(saveId);
    map['company_name'] = Variable<String>(companyName);
    map['job_title'] = Variable<String>(jobTitle);
    map['field'] = Variable<String>(field);
    map['start_age'] = Variable<int>(startAge);
    if (!nullToAbsent || endAge != null) {
      map['end_age'] = Variable<int>(endAge);
    }
    map['salary'] = Variable<double>(salary);
    if (!nullToAbsent || reasonForLeaving != null) {
      map['reason_for_leaving'] = Variable<String>(reasonForLeaving);
    }
    return map;
  }

  CareerHistoriesCompanion toCompanion(bool nullToAbsent) {
    return CareerHistoriesCompanion(
      id: Value(id),
      saveId: Value(saveId),
      companyName: Value(companyName),
      jobTitle: Value(jobTitle),
      field: Value(field),
      startAge: Value(startAge),
      endAge: endAge == null && nullToAbsent
          ? const Value.absent()
          : Value(endAge),
      salary: Value(salary),
      reasonForLeaving: reasonForLeaving == null && nullToAbsent
          ? const Value.absent()
          : Value(reasonForLeaving),
    );
  }

  factory CareerHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CareerHistory(
      id: serializer.fromJson<String>(json['id']),
      saveId: serializer.fromJson<String>(json['saveId']),
      companyName: serializer.fromJson<String>(json['companyName']),
      jobTitle: serializer.fromJson<String>(json['jobTitle']),
      field: serializer.fromJson<String>(json['field']),
      startAge: serializer.fromJson<int>(json['startAge']),
      endAge: serializer.fromJson<int?>(json['endAge']),
      salary: serializer.fromJson<double>(json['salary']),
      reasonForLeaving: serializer.fromJson<String?>(json['reasonForLeaving']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saveId': serializer.toJson<String>(saveId),
      'companyName': serializer.toJson<String>(companyName),
      'jobTitle': serializer.toJson<String>(jobTitle),
      'field': serializer.toJson<String>(field),
      'startAge': serializer.toJson<int>(startAge),
      'endAge': serializer.toJson<int?>(endAge),
      'salary': serializer.toJson<double>(salary),
      'reasonForLeaving': serializer.toJson<String?>(reasonForLeaving),
    };
  }

  CareerHistory copyWith({
    String? id,
    String? saveId,
    String? companyName,
    String? jobTitle,
    String? field,
    int? startAge,
    Value<int?> endAge = const Value.absent(),
    double? salary,
    Value<String?> reasonForLeaving = const Value.absent(),
  }) => CareerHistory(
    id: id ?? this.id,
    saveId: saveId ?? this.saveId,
    companyName: companyName ?? this.companyName,
    jobTitle: jobTitle ?? this.jobTitle,
    field: field ?? this.field,
    startAge: startAge ?? this.startAge,
    endAge: endAge.present ? endAge.value : this.endAge,
    salary: salary ?? this.salary,
    reasonForLeaving: reasonForLeaving.present
        ? reasonForLeaving.value
        : this.reasonForLeaving,
  );
  CareerHistory copyWithCompanion(CareerHistoriesCompanion data) {
    return CareerHistory(
      id: data.id.present ? data.id.value : this.id,
      saveId: data.saveId.present ? data.saveId.value : this.saveId,
      companyName: data.companyName.present
          ? data.companyName.value
          : this.companyName,
      jobTitle: data.jobTitle.present ? data.jobTitle.value : this.jobTitle,
      field: data.field.present ? data.field.value : this.field,
      startAge: data.startAge.present ? data.startAge.value : this.startAge,
      endAge: data.endAge.present ? data.endAge.value : this.endAge,
      salary: data.salary.present ? data.salary.value : this.salary,
      reasonForLeaving: data.reasonForLeaving.present
          ? data.reasonForLeaving.value
          : this.reasonForLeaving,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CareerHistory(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('companyName: $companyName, ')
          ..write('jobTitle: $jobTitle, ')
          ..write('field: $field, ')
          ..write('startAge: $startAge, ')
          ..write('endAge: $endAge, ')
          ..write('salary: $salary, ')
          ..write('reasonForLeaving: $reasonForLeaving')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saveId,
    companyName,
    jobTitle,
    field,
    startAge,
    endAge,
    salary,
    reasonForLeaving,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CareerHistory &&
          other.id == this.id &&
          other.saveId == this.saveId &&
          other.companyName == this.companyName &&
          other.jobTitle == this.jobTitle &&
          other.field == this.field &&
          other.startAge == this.startAge &&
          other.endAge == this.endAge &&
          other.salary == this.salary &&
          other.reasonForLeaving == this.reasonForLeaving);
}

class CareerHistoriesCompanion extends UpdateCompanion<CareerHistory> {
  final Value<String> id;
  final Value<String> saveId;
  final Value<String> companyName;
  final Value<String> jobTitle;
  final Value<String> field;
  final Value<int> startAge;
  final Value<int?> endAge;
  final Value<double> salary;
  final Value<String?> reasonForLeaving;
  final Value<int> rowid;
  const CareerHistoriesCompanion({
    this.id = const Value.absent(),
    this.saveId = const Value.absent(),
    this.companyName = const Value.absent(),
    this.jobTitle = const Value.absent(),
    this.field = const Value.absent(),
    this.startAge = const Value.absent(),
    this.endAge = const Value.absent(),
    this.salary = const Value.absent(),
    this.reasonForLeaving = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CareerHistoriesCompanion.insert({
    required String id,
    required String saveId,
    required String companyName,
    required String jobTitle,
    required String field,
    required int startAge,
    this.endAge = const Value.absent(),
    required double salary,
    this.reasonForLeaving = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saveId = Value(saveId),
       companyName = Value(companyName),
       jobTitle = Value(jobTitle),
       field = Value(field),
       startAge = Value(startAge),
       salary = Value(salary);
  static Insertable<CareerHistory> custom({
    Expression<String>? id,
    Expression<String>? saveId,
    Expression<String>? companyName,
    Expression<String>? jobTitle,
    Expression<String>? field,
    Expression<int>? startAge,
    Expression<int>? endAge,
    Expression<double>? salary,
    Expression<String>? reasonForLeaving,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saveId != null) 'save_id': saveId,
      if (companyName != null) 'company_name': companyName,
      if (jobTitle != null) 'job_title': jobTitle,
      if (field != null) 'field': field,
      if (startAge != null) 'start_age': startAge,
      if (endAge != null) 'end_age': endAge,
      if (salary != null) 'salary': salary,
      if (reasonForLeaving != null) 'reason_for_leaving': reasonForLeaving,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CareerHistoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? saveId,
    Value<String>? companyName,
    Value<String>? jobTitle,
    Value<String>? field,
    Value<int>? startAge,
    Value<int?>? endAge,
    Value<double>? salary,
    Value<String?>? reasonForLeaving,
    Value<int>? rowid,
  }) {
    return CareerHistoriesCompanion(
      id: id ?? this.id,
      saveId: saveId ?? this.saveId,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      field: field ?? this.field,
      startAge: startAge ?? this.startAge,
      endAge: endAge ?? this.endAge,
      salary: salary ?? this.salary,
      reasonForLeaving: reasonForLeaving ?? this.reasonForLeaving,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saveId.present) {
      map['save_id'] = Variable<String>(saveId.value);
    }
    if (companyName.present) {
      map['company_name'] = Variable<String>(companyName.value);
    }
    if (jobTitle.present) {
      map['job_title'] = Variable<String>(jobTitle.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (startAge.present) {
      map['start_age'] = Variable<int>(startAge.value);
    }
    if (endAge.present) {
      map['end_age'] = Variable<int>(endAge.value);
    }
    if (salary.present) {
      map['salary'] = Variable<double>(salary.value);
    }
    if (reasonForLeaving.present) {
      map['reason_for_leaving'] = Variable<String>(reasonForLeaving.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CareerHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('companyName: $companyName, ')
          ..write('jobTitle: $jobTitle, ')
          ..write('field: $field, ')
          ..write('startAge: $startAge, ')
          ..write('endAge: $endAge, ')
          ..write('salary: $salary, ')
          ..write('reasonForLeaving: $reasonForLeaving, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PropertiesTable extends Properties
    with TableInfo<$PropertiesTable, Property> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PropertiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saveIdMeta = const VerificationMeta('saveId');
  @override
  late final GeneratedColumn<String> saveId = GeneratedColumn<String>(
    'save_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentValueMeta = const VerificationMeta(
    'currentValue',
  );
  @override
  late final GeneratedColumn<double> currentValue = GeneratedColumn<double>(
    'current_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _annualCostMeta = const VerificationMeta(
    'annualCost',
  );
  @override
  late final GeneratedColumn<double> annualCost = GeneratedColumn<double>(
    'annual_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conditionMeta = const VerificationMeta(
    'condition',
  );
  @override
  late final GeneratedColumn<int> condition = GeneratedColumn<int>(
    'condition',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFinancedMeta = const VerificationMeta(
    'isFinanced',
  );
  @override
  late final GeneratedColumn<bool> isFinanced = GeneratedColumn<bool>(
    'is_financed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_financed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _monthlyPaymentMeta = const VerificationMeta(
    'monthlyPayment',
  );
  @override
  late final GeneratedColumn<double> monthlyPayment = GeneratedColumn<double>(
    'monthly_payment',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _remainingDebtMeta = const VerificationMeta(
    'remainingDebt',
  );
  @override
  late final GeneratedColumn<double> remainingDebt = GeneratedColumn<double>(
    'remaining_debt',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _purchasedAtAgeMeta = const VerificationMeta(
    'purchasedAtAge',
  );
  @override
  late final GeneratedColumn<int> purchasedAtAge = GeneratedColumn<int>(
    'purchased_at_age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saveId,
    type,
    name,
    purchasePrice,
    currentValue,
    annualCost,
    condition,
    isFinanced,
    monthlyPayment,
    remainingDebt,
    purchasedAtAge,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'properties';
  @override
  VerificationContext validateIntegrity(
    Insertable<Property> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('save_id')) {
      context.handle(
        _saveIdMeta,
        saveId.isAcceptableOrUnknown(data['save_id']!, _saveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saveIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('current_value')) {
      context.handle(
        _currentValueMeta,
        currentValue.isAcceptableOrUnknown(
          data['current_value']!,
          _currentValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentValueMeta);
    }
    if (data.containsKey('annual_cost')) {
      context.handle(
        _annualCostMeta,
        annualCost.isAcceptableOrUnknown(data['annual_cost']!, _annualCostMeta),
      );
    } else if (isInserting) {
      context.missing(_annualCostMeta);
    }
    if (data.containsKey('condition')) {
      context.handle(
        _conditionMeta,
        condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta),
      );
    } else if (isInserting) {
      context.missing(_conditionMeta);
    }
    if (data.containsKey('is_financed')) {
      context.handle(
        _isFinancedMeta,
        isFinanced.isAcceptableOrUnknown(data['is_financed']!, _isFinancedMeta),
      );
    }
    if (data.containsKey('monthly_payment')) {
      context.handle(
        _monthlyPaymentMeta,
        monthlyPayment.isAcceptableOrUnknown(
          data['monthly_payment']!,
          _monthlyPaymentMeta,
        ),
      );
    }
    if (data.containsKey('remaining_debt')) {
      context.handle(
        _remainingDebtMeta,
        remainingDebt.isAcceptableOrUnknown(
          data['remaining_debt']!,
          _remainingDebtMeta,
        ),
      );
    }
    if (data.containsKey('purchased_at_age')) {
      context.handle(
        _purchasedAtAgeMeta,
        purchasedAtAge.isAcceptableOrUnknown(
          data['purchased_at_age']!,
          _purchasedAtAgeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasedAtAgeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Property map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Property(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      )!,
      currentValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_value'],
      )!,
      annualCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}annual_cost'],
      )!,
      condition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}condition'],
      )!,
      isFinanced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_financed'],
      )!,
      monthlyPayment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_payment'],
      )!,
      remainingDebt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}remaining_debt'],
      )!,
      purchasedAtAge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purchased_at_age'],
      )!,
    );
  }

  @override
  $PropertiesTable createAlias(String alias) {
    return $PropertiesTable(attachedDatabase, alias);
  }
}

class Property extends DataClass implements Insertable<Property> {
  final String id;
  final String saveId;
  final String type;
  final String name;
  final double purchasePrice;
  final double currentValue;
  final double annualCost;
  final int condition;
  final bool isFinanced;
  final double monthlyPayment;
  final double remainingDebt;
  final int purchasedAtAge;
  const Property({
    required this.id,
    required this.saveId,
    required this.type,
    required this.name,
    required this.purchasePrice,
    required this.currentValue,
    required this.annualCost,
    required this.condition,
    required this.isFinanced,
    required this.monthlyPayment,
    required this.remainingDebt,
    required this.purchasedAtAge,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['save_id'] = Variable<String>(saveId);
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['current_value'] = Variable<double>(currentValue);
    map['annual_cost'] = Variable<double>(annualCost);
    map['condition'] = Variable<int>(condition);
    map['is_financed'] = Variable<bool>(isFinanced);
    map['monthly_payment'] = Variable<double>(monthlyPayment);
    map['remaining_debt'] = Variable<double>(remainingDebt);
    map['purchased_at_age'] = Variable<int>(purchasedAtAge);
    return map;
  }

  PropertiesCompanion toCompanion(bool nullToAbsent) {
    return PropertiesCompanion(
      id: Value(id),
      saveId: Value(saveId),
      type: Value(type),
      name: Value(name),
      purchasePrice: Value(purchasePrice),
      currentValue: Value(currentValue),
      annualCost: Value(annualCost),
      condition: Value(condition),
      isFinanced: Value(isFinanced),
      monthlyPayment: Value(monthlyPayment),
      remainingDebt: Value(remainingDebt),
      purchasedAtAge: Value(purchasedAtAge),
    );
  }

  factory Property.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Property(
      id: serializer.fromJson<String>(json['id']),
      saveId: serializer.fromJson<String>(json['saveId']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      currentValue: serializer.fromJson<double>(json['currentValue']),
      annualCost: serializer.fromJson<double>(json['annualCost']),
      condition: serializer.fromJson<int>(json['condition']),
      isFinanced: serializer.fromJson<bool>(json['isFinanced']),
      monthlyPayment: serializer.fromJson<double>(json['monthlyPayment']),
      remainingDebt: serializer.fromJson<double>(json['remainingDebt']),
      purchasedAtAge: serializer.fromJson<int>(json['purchasedAtAge']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saveId': serializer.toJson<String>(saveId),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'currentValue': serializer.toJson<double>(currentValue),
      'annualCost': serializer.toJson<double>(annualCost),
      'condition': serializer.toJson<int>(condition),
      'isFinanced': serializer.toJson<bool>(isFinanced),
      'monthlyPayment': serializer.toJson<double>(monthlyPayment),
      'remainingDebt': serializer.toJson<double>(remainingDebt),
      'purchasedAtAge': serializer.toJson<int>(purchasedAtAge),
    };
  }

  Property copyWith({
    String? id,
    String? saveId,
    String? type,
    String? name,
    double? purchasePrice,
    double? currentValue,
    double? annualCost,
    int? condition,
    bool? isFinanced,
    double? monthlyPayment,
    double? remainingDebt,
    int? purchasedAtAge,
  }) => Property(
    id: id ?? this.id,
    saveId: saveId ?? this.saveId,
    type: type ?? this.type,
    name: name ?? this.name,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    currentValue: currentValue ?? this.currentValue,
    annualCost: annualCost ?? this.annualCost,
    condition: condition ?? this.condition,
    isFinanced: isFinanced ?? this.isFinanced,
    monthlyPayment: monthlyPayment ?? this.monthlyPayment,
    remainingDebt: remainingDebt ?? this.remainingDebt,
    purchasedAtAge: purchasedAtAge ?? this.purchasedAtAge,
  );
  Property copyWithCompanion(PropertiesCompanion data) {
    return Property(
      id: data.id.present ? data.id.value : this.id,
      saveId: data.saveId.present ? data.saveId.value : this.saveId,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      annualCost: data.annualCost.present
          ? data.annualCost.value
          : this.annualCost,
      condition: data.condition.present ? data.condition.value : this.condition,
      isFinanced: data.isFinanced.present
          ? data.isFinanced.value
          : this.isFinanced,
      monthlyPayment: data.monthlyPayment.present
          ? data.monthlyPayment.value
          : this.monthlyPayment,
      remainingDebt: data.remainingDebt.present
          ? data.remainingDebt.value
          : this.remainingDebt,
      purchasedAtAge: data.purchasedAtAge.present
          ? data.purchasedAtAge.value
          : this.purchasedAtAge,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Property(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('currentValue: $currentValue, ')
          ..write('annualCost: $annualCost, ')
          ..write('condition: $condition, ')
          ..write('isFinanced: $isFinanced, ')
          ..write('monthlyPayment: $monthlyPayment, ')
          ..write('remainingDebt: $remainingDebt, ')
          ..write('purchasedAtAge: $purchasedAtAge')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saveId,
    type,
    name,
    purchasePrice,
    currentValue,
    annualCost,
    condition,
    isFinanced,
    monthlyPayment,
    remainingDebt,
    purchasedAtAge,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Property &&
          other.id == this.id &&
          other.saveId == this.saveId &&
          other.type == this.type &&
          other.name == this.name &&
          other.purchasePrice == this.purchasePrice &&
          other.currentValue == this.currentValue &&
          other.annualCost == this.annualCost &&
          other.condition == this.condition &&
          other.isFinanced == this.isFinanced &&
          other.monthlyPayment == this.monthlyPayment &&
          other.remainingDebt == this.remainingDebt &&
          other.purchasedAtAge == this.purchasedAtAge);
}

class PropertiesCompanion extends UpdateCompanion<Property> {
  final Value<String> id;
  final Value<String> saveId;
  final Value<String> type;
  final Value<String> name;
  final Value<double> purchasePrice;
  final Value<double> currentValue;
  final Value<double> annualCost;
  final Value<int> condition;
  final Value<bool> isFinanced;
  final Value<double> monthlyPayment;
  final Value<double> remainingDebt;
  final Value<int> purchasedAtAge;
  final Value<int> rowid;
  const PropertiesCompanion({
    this.id = const Value.absent(),
    this.saveId = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.annualCost = const Value.absent(),
    this.condition = const Value.absent(),
    this.isFinanced = const Value.absent(),
    this.monthlyPayment = const Value.absent(),
    this.remainingDebt = const Value.absent(),
    this.purchasedAtAge = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PropertiesCompanion.insert({
    required String id,
    required String saveId,
    required String type,
    required String name,
    required double purchasePrice,
    required double currentValue,
    required double annualCost,
    required int condition,
    this.isFinanced = const Value.absent(),
    this.monthlyPayment = const Value.absent(),
    this.remainingDebt = const Value.absent(),
    required int purchasedAtAge,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saveId = Value(saveId),
       type = Value(type),
       name = Value(name),
       purchasePrice = Value(purchasePrice),
       currentValue = Value(currentValue),
       annualCost = Value(annualCost),
       condition = Value(condition),
       purchasedAtAge = Value(purchasedAtAge);
  static Insertable<Property> custom({
    Expression<String>? id,
    Expression<String>? saveId,
    Expression<String>? type,
    Expression<String>? name,
    Expression<double>? purchasePrice,
    Expression<double>? currentValue,
    Expression<double>? annualCost,
    Expression<int>? condition,
    Expression<bool>? isFinanced,
    Expression<double>? monthlyPayment,
    Expression<double>? remainingDebt,
    Expression<int>? purchasedAtAge,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saveId != null) 'save_id': saveId,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (currentValue != null) 'current_value': currentValue,
      if (annualCost != null) 'annual_cost': annualCost,
      if (condition != null) 'condition': condition,
      if (isFinanced != null) 'is_financed': isFinanced,
      if (monthlyPayment != null) 'monthly_payment': monthlyPayment,
      if (remainingDebt != null) 'remaining_debt': remainingDebt,
      if (purchasedAtAge != null) 'purchased_at_age': purchasedAtAge,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PropertiesCompanion copyWith({
    Value<String>? id,
    Value<String>? saveId,
    Value<String>? type,
    Value<String>? name,
    Value<double>? purchasePrice,
    Value<double>? currentValue,
    Value<double>? annualCost,
    Value<int>? condition,
    Value<bool>? isFinanced,
    Value<double>? monthlyPayment,
    Value<double>? remainingDebt,
    Value<int>? purchasedAtAge,
    Value<int>? rowid,
  }) {
    return PropertiesCompanion(
      id: id ?? this.id,
      saveId: saveId ?? this.saveId,
      type: type ?? this.type,
      name: name ?? this.name,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentValue: currentValue ?? this.currentValue,
      annualCost: annualCost ?? this.annualCost,
      condition: condition ?? this.condition,
      isFinanced: isFinanced ?? this.isFinanced,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      remainingDebt: remainingDebt ?? this.remainingDebt,
      purchasedAtAge: purchasedAtAge ?? this.purchasedAtAge,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saveId.present) {
      map['save_id'] = Variable<String>(saveId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<double>(currentValue.value);
    }
    if (annualCost.present) {
      map['annual_cost'] = Variable<double>(annualCost.value);
    }
    if (condition.present) {
      map['condition'] = Variable<int>(condition.value);
    }
    if (isFinanced.present) {
      map['is_financed'] = Variable<bool>(isFinanced.value);
    }
    if (monthlyPayment.present) {
      map['monthly_payment'] = Variable<double>(monthlyPayment.value);
    }
    if (remainingDebt.present) {
      map['remaining_debt'] = Variable<double>(remainingDebt.value);
    }
    if (purchasedAtAge.present) {
      map['purchased_at_age'] = Variable<int>(purchasedAtAge.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PropertiesCompanion(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('currentValue: $currentValue, ')
          ..write('annualCost: $annualCost, ')
          ..write('condition: $condition, ')
          ..write('isFinanced: $isFinanced, ')
          ..write('monthlyPayment: $monthlyPayment, ')
          ..write('remainingDebt: $remainingDebt, ')
          ..write('purchasedAtAge: $purchasedAtAge, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentsTable extends Investments
    with TableInfo<$InvestmentsTable, Investment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saveIdMeta = const VerificationMeta('saveId');
  @override
  late final GeneratedColumn<String> saveId = GeneratedColumn<String>(
    'save_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tickerMeta = const VerificationMeta('ticker');
  @override
  late final GeneratedColumn<String> ticker = GeneratedColumn<String>(
    'ticker',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _investedAmountMeta = const VerificationMeta(
    'investedAmount',
  );
  @override
  late final GeneratedColumn<double> investedAmount = GeneratedColumn<double>(
    'invested_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentValueMeta = const VerificationMeta(
    'currentValue',
  );
  @override
  late final GeneratedColumn<double> currentValue = GeneratedColumn<double>(
    'current_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitsMeta = const VerificationMeta('units');
  @override
  late final GeneratedColumn<double> units = GeneratedColumn<double>(
    'units',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _annualYieldPercentMeta =
      const VerificationMeta('annualYieldPercent');
  @override
  late final GeneratedColumn<double> annualYieldPercent =
      GeneratedColumn<double>(
        'annual_yield_percent',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saveId,
    type,
    name,
    ticker,
    investedAmount,
    currentValue,
    units,
    annualYieldPercent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Investment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('save_id')) {
      context.handle(
        _saveIdMeta,
        saveId.isAcceptableOrUnknown(data['save_id']!, _saveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saveIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('ticker')) {
      context.handle(
        _tickerMeta,
        ticker.isAcceptableOrUnknown(data['ticker']!, _tickerMeta),
      );
    } else if (isInserting) {
      context.missing(_tickerMeta);
    }
    if (data.containsKey('invested_amount')) {
      context.handle(
        _investedAmountMeta,
        investedAmount.isAcceptableOrUnknown(
          data['invested_amount']!,
          _investedAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_investedAmountMeta);
    }
    if (data.containsKey('current_value')) {
      context.handle(
        _currentValueMeta,
        currentValue.isAcceptableOrUnknown(
          data['current_value']!,
          _currentValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentValueMeta);
    }
    if (data.containsKey('units')) {
      context.handle(
        _unitsMeta,
        units.isAcceptableOrUnknown(data['units']!, _unitsMeta),
      );
    } else if (isInserting) {
      context.missing(_unitsMeta);
    }
    if (data.containsKey('annual_yield_percent')) {
      context.handle(
        _annualYieldPercentMeta,
        annualYieldPercent.isAcceptableOrUnknown(
          data['annual_yield_percent']!,
          _annualYieldPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_annualYieldPercentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Investment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Investment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      ticker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticker'],
      )!,
      investedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}invested_amount'],
      )!,
      currentValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_value'],
      )!,
      units: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}units'],
      )!,
      annualYieldPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}annual_yield_percent'],
      )!,
    );
  }

  @override
  $InvestmentsTable createAlias(String alias) {
    return $InvestmentsTable(attachedDatabase, alias);
  }
}

class Investment extends DataClass implements Insertable<Investment> {
  final String id;
  final String saveId;
  final String type;
  final String name;
  final String ticker;
  final double investedAmount;
  final double currentValue;
  final double units;
  final double annualYieldPercent;
  const Investment({
    required this.id,
    required this.saveId,
    required this.type,
    required this.name,
    required this.ticker,
    required this.investedAmount,
    required this.currentValue,
    required this.units,
    required this.annualYieldPercent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['save_id'] = Variable<String>(saveId);
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    map['ticker'] = Variable<String>(ticker);
    map['invested_amount'] = Variable<double>(investedAmount);
    map['current_value'] = Variable<double>(currentValue);
    map['units'] = Variable<double>(units);
    map['annual_yield_percent'] = Variable<double>(annualYieldPercent);
    return map;
  }

  InvestmentsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentsCompanion(
      id: Value(id),
      saveId: Value(saveId),
      type: Value(type),
      name: Value(name),
      ticker: Value(ticker),
      investedAmount: Value(investedAmount),
      currentValue: Value(currentValue),
      units: Value(units),
      annualYieldPercent: Value(annualYieldPercent),
    );
  }

  factory Investment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Investment(
      id: serializer.fromJson<String>(json['id']),
      saveId: serializer.fromJson<String>(json['saveId']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      ticker: serializer.fromJson<String>(json['ticker']),
      investedAmount: serializer.fromJson<double>(json['investedAmount']),
      currentValue: serializer.fromJson<double>(json['currentValue']),
      units: serializer.fromJson<double>(json['units']),
      annualYieldPercent: serializer.fromJson<double>(
        json['annualYieldPercent'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saveId': serializer.toJson<String>(saveId),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'ticker': serializer.toJson<String>(ticker),
      'investedAmount': serializer.toJson<double>(investedAmount),
      'currentValue': serializer.toJson<double>(currentValue),
      'units': serializer.toJson<double>(units),
      'annualYieldPercent': serializer.toJson<double>(annualYieldPercent),
    };
  }

  Investment copyWith({
    String? id,
    String? saveId,
    String? type,
    String? name,
    String? ticker,
    double? investedAmount,
    double? currentValue,
    double? units,
    double? annualYieldPercent,
  }) => Investment(
    id: id ?? this.id,
    saveId: saveId ?? this.saveId,
    type: type ?? this.type,
    name: name ?? this.name,
    ticker: ticker ?? this.ticker,
    investedAmount: investedAmount ?? this.investedAmount,
    currentValue: currentValue ?? this.currentValue,
    units: units ?? this.units,
    annualYieldPercent: annualYieldPercent ?? this.annualYieldPercent,
  );
  Investment copyWithCompanion(InvestmentsCompanion data) {
    return Investment(
      id: data.id.present ? data.id.value : this.id,
      saveId: data.saveId.present ? data.saveId.value : this.saveId,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      ticker: data.ticker.present ? data.ticker.value : this.ticker,
      investedAmount: data.investedAmount.present
          ? data.investedAmount.value
          : this.investedAmount,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      units: data.units.present ? data.units.value : this.units,
      annualYieldPercent: data.annualYieldPercent.present
          ? data.annualYieldPercent.value
          : this.annualYieldPercent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Investment(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('ticker: $ticker, ')
          ..write('investedAmount: $investedAmount, ')
          ..write('currentValue: $currentValue, ')
          ..write('units: $units, ')
          ..write('annualYieldPercent: $annualYieldPercent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saveId,
    type,
    name,
    ticker,
    investedAmount,
    currentValue,
    units,
    annualYieldPercent,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Investment &&
          other.id == this.id &&
          other.saveId == this.saveId &&
          other.type == this.type &&
          other.name == this.name &&
          other.ticker == this.ticker &&
          other.investedAmount == this.investedAmount &&
          other.currentValue == this.currentValue &&
          other.units == this.units &&
          other.annualYieldPercent == this.annualYieldPercent);
}

class InvestmentsCompanion extends UpdateCompanion<Investment> {
  final Value<String> id;
  final Value<String> saveId;
  final Value<String> type;
  final Value<String> name;
  final Value<String> ticker;
  final Value<double> investedAmount;
  final Value<double> currentValue;
  final Value<double> units;
  final Value<double> annualYieldPercent;
  final Value<int> rowid;
  const InvestmentsCompanion({
    this.id = const Value.absent(),
    this.saveId = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.ticker = const Value.absent(),
    this.investedAmount = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.units = const Value.absent(),
    this.annualYieldPercent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentsCompanion.insert({
    required String id,
    required String saveId,
    required String type,
    required String name,
    required String ticker,
    required double investedAmount,
    required double currentValue,
    required double units,
    required double annualYieldPercent,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saveId = Value(saveId),
       type = Value(type),
       name = Value(name),
       ticker = Value(ticker),
       investedAmount = Value(investedAmount),
       currentValue = Value(currentValue),
       units = Value(units),
       annualYieldPercent = Value(annualYieldPercent);
  static Insertable<Investment> custom({
    Expression<String>? id,
    Expression<String>? saveId,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? ticker,
    Expression<double>? investedAmount,
    Expression<double>? currentValue,
    Expression<double>? units,
    Expression<double>? annualYieldPercent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saveId != null) 'save_id': saveId,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (ticker != null) 'ticker': ticker,
      if (investedAmount != null) 'invested_amount': investedAmount,
      if (currentValue != null) 'current_value': currentValue,
      if (units != null) 'units': units,
      if (annualYieldPercent != null)
        'annual_yield_percent': annualYieldPercent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? saveId,
    Value<String>? type,
    Value<String>? name,
    Value<String>? ticker,
    Value<double>? investedAmount,
    Value<double>? currentValue,
    Value<double>? units,
    Value<double>? annualYieldPercent,
    Value<int>? rowid,
  }) {
    return InvestmentsCompanion(
      id: id ?? this.id,
      saveId: saveId ?? this.saveId,
      type: type ?? this.type,
      name: name ?? this.name,
      ticker: ticker ?? this.ticker,
      investedAmount: investedAmount ?? this.investedAmount,
      currentValue: currentValue ?? this.currentValue,
      units: units ?? this.units,
      annualYieldPercent: annualYieldPercent ?? this.annualYieldPercent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saveId.present) {
      map['save_id'] = Variable<String>(saveId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (ticker.present) {
      map['ticker'] = Variable<String>(ticker.value);
    }
    if (investedAmount.present) {
      map['invested_amount'] = Variable<double>(investedAmount.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<double>(currentValue.value);
    }
    if (units.present) {
      map['units'] = Variable<double>(units.value);
    }
    if (annualYieldPercent.present) {
      map['annual_yield_percent'] = Variable<double>(annualYieldPercent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentsCompanion(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('ticker: $ticker, ')
          ..write('investedAmount: $investedAmount, ')
          ..write('currentValue: $currentValue, ')
          ..write('units: $units, ')
          ..write('annualYieldPercent: $annualYieldPercent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BusinessesTable extends Businesses
    with TableInfo<$BusinessesTable, BusinessesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BusinessesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saveIdMeta = const VerificationMeta('saveId');
  @override
  late final GeneratedColumn<String> saveId = GeneratedColumn<String>(
    'save_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _industryMeta = const VerificationMeta(
    'industry',
  );
  @override
  late final GeneratedColumn<String> industry = GeneratedColumn<String>(
    'industry',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valuationMeta = const VerificationMeta(
    'valuation',
  );
  @override
  late final GeneratedColumn<double> valuation = GeneratedColumn<double>(
    'valuation',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revenueMeta = const VerificationMeta(
    'revenue',
  );
  @override
  late final GeneratedColumn<double> revenue = GeneratedColumn<double>(
    'revenue',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expensesMeta = const VerificationMeta(
    'expenses',
  );
  @override
  late final GeneratedColumn<double> expenses = GeneratedColumn<double>(
    'expenses',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeCountMeta = const VerificationMeta(
    'employeeCount',
  );
  @override
  late final GeneratedColumn<int> employeeCount = GeneratedColumn<int>(
    'employee_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reputationMeta = const VerificationMeta(
    'reputation',
  );
  @override
  late final GeneratedColumn<int> reputation = GeneratedColumn<int>(
    'reputation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productPriceMeta = const VerificationMeta(
    'productPrice',
  );
  @override
  late final GeneratedColumn<double> productPrice = GeneratedColumn<double>(
    'product_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketingBudgetMeta = const VerificationMeta(
    'marketingBudget',
  );
  @override
  late final GeneratedColumn<double> marketingBudget = GeneratedColumn<double>(
    'marketing_budget',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saveId,
    name,
    industry,
    valuation,
    revenue,
    expenses,
    employeeCount,
    reputation,
    productPrice,
    marketingBudget,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'businesses';
  @override
  VerificationContext validateIntegrity(
    Insertable<BusinessesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('save_id')) {
      context.handle(
        _saveIdMeta,
        saveId.isAcceptableOrUnknown(data['save_id']!, _saveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saveIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('industry')) {
      context.handle(
        _industryMeta,
        industry.isAcceptableOrUnknown(data['industry']!, _industryMeta),
      );
    } else if (isInserting) {
      context.missing(_industryMeta);
    }
    if (data.containsKey('valuation')) {
      context.handle(
        _valuationMeta,
        valuation.isAcceptableOrUnknown(data['valuation']!, _valuationMeta),
      );
    } else if (isInserting) {
      context.missing(_valuationMeta);
    }
    if (data.containsKey('revenue')) {
      context.handle(
        _revenueMeta,
        revenue.isAcceptableOrUnknown(data['revenue']!, _revenueMeta),
      );
    } else if (isInserting) {
      context.missing(_revenueMeta);
    }
    if (data.containsKey('expenses')) {
      context.handle(
        _expensesMeta,
        expenses.isAcceptableOrUnknown(data['expenses']!, _expensesMeta),
      );
    } else if (isInserting) {
      context.missing(_expensesMeta);
    }
    if (data.containsKey('employee_count')) {
      context.handle(
        _employeeCountMeta,
        employeeCount.isAcceptableOrUnknown(
          data['employee_count']!,
          _employeeCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeCountMeta);
    }
    if (data.containsKey('reputation')) {
      context.handle(
        _reputationMeta,
        reputation.isAcceptableOrUnknown(data['reputation']!, _reputationMeta),
      );
    } else if (isInserting) {
      context.missing(_reputationMeta);
    }
    if (data.containsKey('product_price')) {
      context.handle(
        _productPriceMeta,
        productPrice.isAcceptableOrUnknown(
          data['product_price']!,
          _productPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productPriceMeta);
    }
    if (data.containsKey('marketing_budget')) {
      context.handle(
        _marketingBudgetMeta,
        marketingBudget.isAcceptableOrUnknown(
          data['marketing_budget']!,
          _marketingBudgetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_marketingBudgetMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BusinessesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BusinessesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      industry: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}industry'],
      )!,
      valuation: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valuation'],
      )!,
      revenue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}revenue'],
      )!,
      expenses: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}expenses'],
      )!,
      employeeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}employee_count'],
      )!,
      reputation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reputation'],
      )!,
      productPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}product_price'],
      )!,
      marketingBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}marketing_budget'],
      )!,
    );
  }

  @override
  $BusinessesTable createAlias(String alias) {
    return $BusinessesTable(attachedDatabase, alias);
  }
}

class BusinessesData extends DataClass implements Insertable<BusinessesData> {
  final String id;
  final String saveId;
  final String name;
  final String industry;
  final double valuation;
  final double revenue;
  final double expenses;
  final int employeeCount;
  final int reputation;
  final double productPrice;
  final double marketingBudget;
  const BusinessesData({
    required this.id,
    required this.saveId,
    required this.name,
    required this.industry,
    required this.valuation,
    required this.revenue,
    required this.expenses,
    required this.employeeCount,
    required this.reputation,
    required this.productPrice,
    required this.marketingBudget,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['save_id'] = Variable<String>(saveId);
    map['name'] = Variable<String>(name);
    map['industry'] = Variable<String>(industry);
    map['valuation'] = Variable<double>(valuation);
    map['revenue'] = Variable<double>(revenue);
    map['expenses'] = Variable<double>(expenses);
    map['employee_count'] = Variable<int>(employeeCount);
    map['reputation'] = Variable<int>(reputation);
    map['product_price'] = Variable<double>(productPrice);
    map['marketing_budget'] = Variable<double>(marketingBudget);
    return map;
  }

  BusinessesCompanion toCompanion(bool nullToAbsent) {
    return BusinessesCompanion(
      id: Value(id),
      saveId: Value(saveId),
      name: Value(name),
      industry: Value(industry),
      valuation: Value(valuation),
      revenue: Value(revenue),
      expenses: Value(expenses),
      employeeCount: Value(employeeCount),
      reputation: Value(reputation),
      productPrice: Value(productPrice),
      marketingBudget: Value(marketingBudget),
    );
  }

  factory BusinessesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BusinessesData(
      id: serializer.fromJson<String>(json['id']),
      saveId: serializer.fromJson<String>(json['saveId']),
      name: serializer.fromJson<String>(json['name']),
      industry: serializer.fromJson<String>(json['industry']),
      valuation: serializer.fromJson<double>(json['valuation']),
      revenue: serializer.fromJson<double>(json['revenue']),
      expenses: serializer.fromJson<double>(json['expenses']),
      employeeCount: serializer.fromJson<int>(json['employeeCount']),
      reputation: serializer.fromJson<int>(json['reputation']),
      productPrice: serializer.fromJson<double>(json['productPrice']),
      marketingBudget: serializer.fromJson<double>(json['marketingBudget']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saveId': serializer.toJson<String>(saveId),
      'name': serializer.toJson<String>(name),
      'industry': serializer.toJson<String>(industry),
      'valuation': serializer.toJson<double>(valuation),
      'revenue': serializer.toJson<double>(revenue),
      'expenses': serializer.toJson<double>(expenses),
      'employeeCount': serializer.toJson<int>(employeeCount),
      'reputation': serializer.toJson<int>(reputation),
      'productPrice': serializer.toJson<double>(productPrice),
      'marketingBudget': serializer.toJson<double>(marketingBudget),
    };
  }

  BusinessesData copyWith({
    String? id,
    String? saveId,
    String? name,
    String? industry,
    double? valuation,
    double? revenue,
    double? expenses,
    int? employeeCount,
    int? reputation,
    double? productPrice,
    double? marketingBudget,
  }) => BusinessesData(
    id: id ?? this.id,
    saveId: saveId ?? this.saveId,
    name: name ?? this.name,
    industry: industry ?? this.industry,
    valuation: valuation ?? this.valuation,
    revenue: revenue ?? this.revenue,
    expenses: expenses ?? this.expenses,
    employeeCount: employeeCount ?? this.employeeCount,
    reputation: reputation ?? this.reputation,
    productPrice: productPrice ?? this.productPrice,
    marketingBudget: marketingBudget ?? this.marketingBudget,
  );
  BusinessesData copyWithCompanion(BusinessesCompanion data) {
    return BusinessesData(
      id: data.id.present ? data.id.value : this.id,
      saveId: data.saveId.present ? data.saveId.value : this.saveId,
      name: data.name.present ? data.name.value : this.name,
      industry: data.industry.present ? data.industry.value : this.industry,
      valuation: data.valuation.present ? data.valuation.value : this.valuation,
      revenue: data.revenue.present ? data.revenue.value : this.revenue,
      expenses: data.expenses.present ? data.expenses.value : this.expenses,
      employeeCount: data.employeeCount.present
          ? data.employeeCount.value
          : this.employeeCount,
      reputation: data.reputation.present
          ? data.reputation.value
          : this.reputation,
      productPrice: data.productPrice.present
          ? data.productPrice.value
          : this.productPrice,
      marketingBudget: data.marketingBudget.present
          ? data.marketingBudget.value
          : this.marketingBudget,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BusinessesData(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('name: $name, ')
          ..write('industry: $industry, ')
          ..write('valuation: $valuation, ')
          ..write('revenue: $revenue, ')
          ..write('expenses: $expenses, ')
          ..write('employeeCount: $employeeCount, ')
          ..write('reputation: $reputation, ')
          ..write('productPrice: $productPrice, ')
          ..write('marketingBudget: $marketingBudget')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saveId,
    name,
    industry,
    valuation,
    revenue,
    expenses,
    employeeCount,
    reputation,
    productPrice,
    marketingBudget,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BusinessesData &&
          other.id == this.id &&
          other.saveId == this.saveId &&
          other.name == this.name &&
          other.industry == this.industry &&
          other.valuation == this.valuation &&
          other.revenue == this.revenue &&
          other.expenses == this.expenses &&
          other.employeeCount == this.employeeCount &&
          other.reputation == this.reputation &&
          other.productPrice == this.productPrice &&
          other.marketingBudget == this.marketingBudget);
}

class BusinessesCompanion extends UpdateCompanion<BusinessesData> {
  final Value<String> id;
  final Value<String> saveId;
  final Value<String> name;
  final Value<String> industry;
  final Value<double> valuation;
  final Value<double> revenue;
  final Value<double> expenses;
  final Value<int> employeeCount;
  final Value<int> reputation;
  final Value<double> productPrice;
  final Value<double> marketingBudget;
  final Value<int> rowid;
  const BusinessesCompanion({
    this.id = const Value.absent(),
    this.saveId = const Value.absent(),
    this.name = const Value.absent(),
    this.industry = const Value.absent(),
    this.valuation = const Value.absent(),
    this.revenue = const Value.absent(),
    this.expenses = const Value.absent(),
    this.employeeCount = const Value.absent(),
    this.reputation = const Value.absent(),
    this.productPrice = const Value.absent(),
    this.marketingBudget = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BusinessesCompanion.insert({
    required String id,
    required String saveId,
    required String name,
    required String industry,
    required double valuation,
    required double revenue,
    required double expenses,
    required int employeeCount,
    required int reputation,
    required double productPrice,
    required double marketingBudget,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saveId = Value(saveId),
       name = Value(name),
       industry = Value(industry),
       valuation = Value(valuation),
       revenue = Value(revenue),
       expenses = Value(expenses),
       employeeCount = Value(employeeCount),
       reputation = Value(reputation),
       productPrice = Value(productPrice),
       marketingBudget = Value(marketingBudget);
  static Insertable<BusinessesData> custom({
    Expression<String>? id,
    Expression<String>? saveId,
    Expression<String>? name,
    Expression<String>? industry,
    Expression<double>? valuation,
    Expression<double>? revenue,
    Expression<double>? expenses,
    Expression<int>? employeeCount,
    Expression<int>? reputation,
    Expression<double>? productPrice,
    Expression<double>? marketingBudget,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saveId != null) 'save_id': saveId,
      if (name != null) 'name': name,
      if (industry != null) 'industry': industry,
      if (valuation != null) 'valuation': valuation,
      if (revenue != null) 'revenue': revenue,
      if (expenses != null) 'expenses': expenses,
      if (employeeCount != null) 'employee_count': employeeCount,
      if (reputation != null) 'reputation': reputation,
      if (productPrice != null) 'product_price': productPrice,
      if (marketingBudget != null) 'marketing_budget': marketingBudget,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BusinessesCompanion copyWith({
    Value<String>? id,
    Value<String>? saveId,
    Value<String>? name,
    Value<String>? industry,
    Value<double>? valuation,
    Value<double>? revenue,
    Value<double>? expenses,
    Value<int>? employeeCount,
    Value<int>? reputation,
    Value<double>? productPrice,
    Value<double>? marketingBudget,
    Value<int>? rowid,
  }) {
    return BusinessesCompanion(
      id: id ?? this.id,
      saveId: saveId ?? this.saveId,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      valuation: valuation ?? this.valuation,
      revenue: revenue ?? this.revenue,
      expenses: expenses ?? this.expenses,
      employeeCount: employeeCount ?? this.employeeCount,
      reputation: reputation ?? this.reputation,
      productPrice: productPrice ?? this.productPrice,
      marketingBudget: marketingBudget ?? this.marketingBudget,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saveId.present) {
      map['save_id'] = Variable<String>(saveId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (industry.present) {
      map['industry'] = Variable<String>(industry.value);
    }
    if (valuation.present) {
      map['valuation'] = Variable<double>(valuation.value);
    }
    if (revenue.present) {
      map['revenue'] = Variable<double>(revenue.value);
    }
    if (expenses.present) {
      map['expenses'] = Variable<double>(expenses.value);
    }
    if (employeeCount.present) {
      map['employee_count'] = Variable<int>(employeeCount.value);
    }
    if (reputation.present) {
      map['reputation'] = Variable<int>(reputation.value);
    }
    if (productPrice.present) {
      map['product_price'] = Variable<double>(productPrice.value);
    }
    if (marketingBudget.present) {
      map['marketing_budget'] = Variable<double>(marketingBudget.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BusinessesCompanion(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('name: $name, ')
          ..write('industry: $industry, ')
          ..write('valuation: $valuation, ')
          ..write('revenue: $revenue, ')
          ..write('expenses: $expenses, ')
          ..write('employeeCount: $employeeCount, ')
          ..write('reputation: $reputation, ')
          ..write('productPrice: $productPrice, ')
          ..write('marketingBudget: $marketingBudget, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeLogsTable extends LifeLogs with TableInfo<$LifeLogsTable, LifeLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saveIdMeta = const VerificationMeta('saveId');
  @override
  late final GeneratedColumn<String> saveId = GeneratedColumn<String>(
    'save_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accentColorMeta = const VerificationMeta(
    'accentColor',
  );
  @override
  late final GeneratedColumn<String> accentColor = GeneratedColumn<String>(
    'accent_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saveId,
    age,
    year,
    category,
    textContent,
    icon,
    accentColor,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'life_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('save_id')) {
      context.handle(
        _saveIdMeta,
        saveId.isAcceptableOrUnknown(data['save_id']!, _saveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saveIdMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('text_content')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(
          data['text_content']!,
          _textContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('accent_color')) {
      context.handle(
        _accentColorMeta,
        accentColor.isAcceptableOrUnknown(
          data['accent_color']!,
          _accentColorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accentColorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LifeLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_id'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_content'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      accentColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accent_color'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LifeLogsTable createAlias(String alias) {
    return $LifeLogsTable(attachedDatabase, alias);
  }
}

class LifeLog extends DataClass implements Insertable<LifeLog> {
  final String id;
  final String saveId;
  final int age;
  final int year;
  final String category;
  final String textContent;
  final String icon;
  final String accentColor;
  final DateTime createdAt;
  const LifeLog({
    required this.id,
    required this.saveId,
    required this.age,
    required this.year,
    required this.category,
    required this.textContent,
    required this.icon,
    required this.accentColor,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['save_id'] = Variable<String>(saveId);
    map['age'] = Variable<int>(age);
    map['year'] = Variable<int>(year);
    map['category'] = Variable<String>(category);
    map['text_content'] = Variable<String>(textContent);
    map['icon'] = Variable<String>(icon);
    map['accent_color'] = Variable<String>(accentColor);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LifeLogsCompanion toCompanion(bool nullToAbsent) {
    return LifeLogsCompanion(
      id: Value(id),
      saveId: Value(saveId),
      age: Value(age),
      year: Value(year),
      category: Value(category),
      textContent: Value(textContent),
      icon: Value(icon),
      accentColor: Value(accentColor),
      createdAt: Value(createdAt),
    );
  }

  factory LifeLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeLog(
      id: serializer.fromJson<String>(json['id']),
      saveId: serializer.fromJson<String>(json['saveId']),
      age: serializer.fromJson<int>(json['age']),
      year: serializer.fromJson<int>(json['year']),
      category: serializer.fromJson<String>(json['category']),
      textContent: serializer.fromJson<String>(json['textContent']),
      icon: serializer.fromJson<String>(json['icon']),
      accentColor: serializer.fromJson<String>(json['accentColor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saveId': serializer.toJson<String>(saveId),
      'age': serializer.toJson<int>(age),
      'year': serializer.toJson<int>(year),
      'category': serializer.toJson<String>(category),
      'textContent': serializer.toJson<String>(textContent),
      'icon': serializer.toJson<String>(icon),
      'accentColor': serializer.toJson<String>(accentColor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LifeLog copyWith({
    String? id,
    String? saveId,
    int? age,
    int? year,
    String? category,
    String? textContent,
    String? icon,
    String? accentColor,
    DateTime? createdAt,
  }) => LifeLog(
    id: id ?? this.id,
    saveId: saveId ?? this.saveId,
    age: age ?? this.age,
    year: year ?? this.year,
    category: category ?? this.category,
    textContent: textContent ?? this.textContent,
    icon: icon ?? this.icon,
    accentColor: accentColor ?? this.accentColor,
    createdAt: createdAt ?? this.createdAt,
  );
  LifeLog copyWithCompanion(LifeLogsCompanion data) {
    return LifeLog(
      id: data.id.present ? data.id.value : this.id,
      saveId: data.saveId.present ? data.saveId.value : this.saveId,
      age: data.age.present ? data.age.value : this.age,
      year: data.year.present ? data.year.value : this.year,
      category: data.category.present ? data.category.value : this.category,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      icon: data.icon.present ? data.icon.value : this.icon,
      accentColor: data.accentColor.present
          ? data.accentColor.value
          : this.accentColor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeLog(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('age: $age, ')
          ..write('year: $year, ')
          ..write('category: $category, ')
          ..write('textContent: $textContent, ')
          ..write('icon: $icon, ')
          ..write('accentColor: $accentColor, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saveId,
    age,
    year,
    category,
    textContent,
    icon,
    accentColor,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeLog &&
          other.id == this.id &&
          other.saveId == this.saveId &&
          other.age == this.age &&
          other.year == this.year &&
          other.category == this.category &&
          other.textContent == this.textContent &&
          other.icon == this.icon &&
          other.accentColor == this.accentColor &&
          other.createdAt == this.createdAt);
}

class LifeLogsCompanion extends UpdateCompanion<LifeLog> {
  final Value<String> id;
  final Value<String> saveId;
  final Value<int> age;
  final Value<int> year;
  final Value<String> category;
  final Value<String> textContent;
  final Value<String> icon;
  final Value<String> accentColor;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LifeLogsCompanion({
    this.id = const Value.absent(),
    this.saveId = const Value.absent(),
    this.age = const Value.absent(),
    this.year = const Value.absent(),
    this.category = const Value.absent(),
    this.textContent = const Value.absent(),
    this.icon = const Value.absent(),
    this.accentColor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeLogsCompanion.insert({
    required String id,
    required String saveId,
    required int age,
    required int year,
    required String category,
    required String textContent,
    required String icon,
    required String accentColor,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saveId = Value(saveId),
       age = Value(age),
       year = Value(year),
       category = Value(category),
       textContent = Value(textContent),
       icon = Value(icon),
       accentColor = Value(accentColor),
       createdAt = Value(createdAt);
  static Insertable<LifeLog> custom({
    Expression<String>? id,
    Expression<String>? saveId,
    Expression<int>? age,
    Expression<int>? year,
    Expression<String>? category,
    Expression<String>? textContent,
    Expression<String>? icon,
    Expression<String>? accentColor,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saveId != null) 'save_id': saveId,
      if (age != null) 'age': age,
      if (year != null) 'year': year,
      if (category != null) 'category': category,
      if (textContent != null) 'text_content': textContent,
      if (icon != null) 'icon': icon,
      if (accentColor != null) 'accent_color': accentColor,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? saveId,
    Value<int>? age,
    Value<int>? year,
    Value<String>? category,
    Value<String>? textContent,
    Value<String>? icon,
    Value<String>? accentColor,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LifeLogsCompanion(
      id: id ?? this.id,
      saveId: saveId ?? this.saveId,
      age: age ?? this.age,
      year: year ?? this.year,
      category: category ?? this.category,
      textContent: textContent ?? this.textContent,
      icon: icon ?? this.icon,
      accentColor: accentColor ?? this.accentColor,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saveId.present) {
      map['save_id'] = Variable<String>(saveId.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (accentColor.present) {
      map['accent_color'] = Variable<String>(accentColor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeLogsCompanion(')
          ..write('id: $id, ')
          ..write('saveId: $saveId, ')
          ..write('age: $age, ')
          ..write('year: $year, ')
          ..write('category: $category, ')
          ..write('textContent: $textContent, ')
          ..write('icon: $icon, ')
          ..write('accentColor: $accentColor, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    title,
    description,
    icon,
    unlockedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      ),
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final String id;
  final String code;
  final String title;
  final String description;
  final String icon;
  final DateTime? unlockedAt;
  const Achievement({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['icon'] = Variable<String>(icon);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      code: Value(code),
      title: Value(title),
      description: Value(description),
      icon: Value(icon),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      icon: serializer.fromJson<String>(json['icon']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'icon': serializer.toJson<String>(icon),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
    };
  }

  Achievement copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? icon,
    Value<DateTime?> unlockedAt = const Value.absent(),
  }) => Achievement(
    id: id ?? this.id,
    code: code ?? this.code,
    title: title ?? this.title,
    description: description ?? this.description,
    icon: icon ?? this.icon,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
  );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      icon: data.icon.present ? data.icon.value : this.icon,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, code, title, description, icon, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.id == this.id &&
          other.code == this.code &&
          other.title == this.title &&
          other.description == this.description &&
          other.icon == this.icon &&
          other.unlockedAt == this.unlockedAt);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> title;
  final Value<String> description;
  final Value<String> icon;
  final Value<DateTime?> unlockedAt;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String id,
    required String code,
    required String title,
    required String description,
    required String icon,
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       title = Value(title),
       description = Value(description),
       icon = Value(icon);
  static Insertable<Achievement> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? icon,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? title,
    Value<String>? description,
    Value<String>? icon,
    Value<DateTime?>? unlockedAt,
    Value<int>? rowid,
  }) {
    return AchievementsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GameSavesTable gameSaves = $GameSavesTable(this);
  late final $CharactersTable characters = $CharactersTable(this);
  late final $NpcsTable npcs = $NpcsTable(this);
  late final $EducationHistoriesTable educationHistories =
      $EducationHistoriesTable(this);
  late final $CareerHistoriesTable careerHistories = $CareerHistoriesTable(
    this,
  );
  late final $PropertiesTable properties = $PropertiesTable(this);
  late final $InvestmentsTable investments = $InvestmentsTable(this);
  late final $BusinessesTable businesses = $BusinessesTable(this);
  late final $LifeLogsTable lifeLogs = $LifeLogsTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    gameSaves,
    characters,
    npcs,
    educationHistories,
    careerHistories,
    properties,
    investments,
    businesses,
    lifeLogs,
    achievements,
  ];
}

typedef $$GameSavesTableCreateCompanionBuilder = GameSavesCompanion Function({
  required String id,
  required String slotName,
  required String characterId,
  required DateTime createdAt,
  required DateTime lastSavedAt,
  Value<bool> isAlive,
  Value<bool> isCurrentSave,
  Value<int> generation,
  Value<String> biography,
  Value<int> rowid,
});
typedef $$GameSavesTableUpdateCompanionBuilder = GameSavesCompanion Function({
  Value<String> id,
  Value<String> slotName,
  Value<String> characterId,
  Value<DateTime> createdAt,
  Value<DateTime> lastSavedAt,
  Value<bool> isAlive,
  Value<bool> isCurrentSave,
  Value<int> generation,
  Value<String> biography,
  Value<int> rowid,
});

class $$GameSavesTableFilterComposer
    extends Composer<_$AppDatabase, $GameSavesTable> {
  $$GameSavesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slotName => $composableBuilder(
    column: $table.slotName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSavedAt => $composableBuilder(
    column: $table.lastSavedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAlive => $composableBuilder(
    column: $table.isAlive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCurrentSave => $composableBuilder(
    column: $table.isCurrentSave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get biography => $composableBuilder(
    column: $table.biography,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameSavesTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSavesTable> {
  $$GameSavesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slotName => $composableBuilder(
    column: $table.slotName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSavedAt => $composableBuilder(
    column: $table.lastSavedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAlive => $composableBuilder(
    column: $table.isAlive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCurrentSave => $composableBuilder(
    column: $table.isCurrentSave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get biography => $composableBuilder(
    column: $table.biography,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameSavesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSavesTable> {
  $$GameSavesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slotName =>
      $composableBuilder(column: $table.slotName, builder: (column) => column);

  GeneratedColumn<String> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSavedAt => $composableBuilder(
    column: $table.lastSavedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAlive =>
      $composableBuilder(column: $table.isAlive, builder: (column) => column);

  GeneratedColumn<bool> get isCurrentSave => $composableBuilder(
    column: $table.isCurrentSave,
    builder: (column) => column,
  );

  GeneratedColumn<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get biography =>
      $composableBuilder(column: $table.biography, builder: (column) => column);
}

class $$GameSavesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameSavesTable,
          GameSave,
          $$GameSavesTableFilterComposer,
          $$GameSavesTableOrderingComposer,
          $$GameSavesTableAnnotationComposer,
          $$GameSavesTableCreateCompanionBuilder,
          $$GameSavesTableUpdateCompanionBuilder,
          (GameSave, BaseReferences<_$AppDatabase, $GameSavesTable, GameSave>),
          GameSave,
          PrefetchHooks Function()
        > {
  $$GameSavesTableTableManager(_$AppDatabase db, $GameSavesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSavesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSavesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSavesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> slotName = const Value.absent(),
                Value<String> characterId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastSavedAt = const Value.absent(),
                Value<bool> isAlive = const Value.absent(),
                Value<bool> isCurrentSave = const Value.absent(),
                Value<int> generation = const Value.absent(),
                Value<String> biography = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameSavesCompanion(
                id: id,
                slotName: slotName,
                characterId: characterId,
                createdAt: createdAt,
                lastSavedAt: lastSavedAt,
                isAlive: isAlive,
                isCurrentSave: isCurrentSave,
                generation: generation,
                biography: biography,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String slotName,
                required String characterId,
                required DateTime createdAt,
                required DateTime lastSavedAt,
                Value<bool> isAlive = const Value.absent(),
                Value<bool> isCurrentSave = const Value.absent(),
                Value<int> generation = const Value.absent(),
                Value<String> biography = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameSavesCompanion.insert(
                id: id,
                slotName: slotName,
                characterId: characterId,
                createdAt: createdAt,
                lastSavedAt: lastSavedAt,
                isAlive: isAlive,
                isCurrentSave: isCurrentSave,
                generation: generation,
                biography: biography,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameSavesTable, GameSave>(table),
                  BaseReferences<_$AppDatabase, $GameSavesTable, GameSave>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameSavesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameSavesTable,
      GameSave,
      $$GameSavesTableFilterComposer,
      $$GameSavesTableOrderingComposer,
      $$GameSavesTableAnnotationComposer,
      $$GameSavesTableCreateCompanionBuilder,
      $$GameSavesTableUpdateCompanionBuilder,
      (GameSave, BaseReferences<_$AppDatabase, $GameSavesTable, GameSave>),
      GameSave,
      PrefetchHooks Function()
    >;
typedef $$CharactersTableCreateCompanionBuilder = CharactersCompanion Function({
  required String id,
  required String saveId,
  required String firstName,
  required String lastName,
  required String gender,
  required String sexualOrientation,
  required int birthYear,
  required int currentAge,
  required String country,
  required String city,
  required String avatarConfigJson,
  required int health,
  required int happiness,
  required int smarts,
  required int looks,
  required int energy,
  required int stress,
  required int discipline,
  required int charisma,
  required int fitness,
  required int reputation,
  required int fame,
  required int karma,
  required double bankBalance,
  required double annualExpenses,
  required double debt,
  required int creditScore,
  Value<bool> isAlive,
  Value<String?> causeOfDeath,
  Value<int?> ageOfDeath,
  Value<String?> partnerId,
  Value<bool> isMarried,
  required String educationLevel,
  Value<String?> currentDegree,
  Value<String?> currentJobId,
  Value<String?> currentJobTitle,
  Value<double?> currentSalary,
  Value<int> jobPerformance,
  Value<int> yearsInCurrentJob,
  Value<bool> hasDriversLicense,
  Value<bool> criminalRecord,
  Value<int> timesArrested,
  Value<int> rowid,
});
typedef $$CharactersTableUpdateCompanionBuilder = CharactersCompanion Function({
  Value<String> id,
  Value<String> saveId,
  Value<String> firstName,
  Value<String> lastName,
  Value<String> gender,
  Value<String> sexualOrientation,
  Value<int> birthYear,
  Value<int> currentAge,
  Value<String> country,
  Value<String> city,
  Value<String> avatarConfigJson,
  Value<int> health,
  Value<int> happiness,
  Value<int> smarts,
  Value<int> looks,
  Value<int> energy,
  Value<int> stress,
  Value<int> discipline,
  Value<int> charisma,
  Value<int> fitness,
  Value<int> reputation,
  Value<int> fame,
  Value<int> karma,
  Value<double> bankBalance,
  Value<double> annualExpenses,
  Value<double> debt,
  Value<int> creditScore,
  Value<bool> isAlive,
  Value<String?> causeOfDeath,
  Value<int?> ageOfDeath,
  Value<String?> partnerId,
  Value<bool> isMarried,
  Value<String> educationLevel,
  Value<String?> currentDegree,
  Value<String?> currentJobId,
  Value<String?> currentJobTitle,
  Value<double?> currentSalary,
  Value<int> jobPerformance,
  Value<int> yearsInCurrentJob,
  Value<bool> hasDriversLicense,
  Value<bool> criminalRecord,
  Value<int> timesArrested,
  Value<int> rowid,
});

class $$CharactersTableFilterComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sexualOrientation => $composableBuilder(
    column: $table.sexualOrientation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentAge => $composableBuilder(
    column: $table.currentAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarConfigJson => $composableBuilder(
    column: $table.avatarConfigJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get health => $composableBuilder(
    column: $table.health,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get happiness => $composableBuilder(
    column: $table.happiness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get smarts => $composableBuilder(
    column: $table.smarts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get looks => $composableBuilder(
    column: $table.looks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stress => $composableBuilder(
    column: $table.stress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discipline => $composableBuilder(
    column: $table.discipline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get charisma => $composableBuilder(
    column: $table.charisma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fitness => $composableBuilder(
    column: $table.fitness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reputation => $composableBuilder(
    column: $table.reputation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fame => $composableBuilder(
    column: $table.fame,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get karma => $composableBuilder(
    column: $table.karma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bankBalance => $composableBuilder(
    column: $table.bankBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get annualExpenses => $composableBuilder(
    column: $table.annualExpenses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get debt => $composableBuilder(
    column: $table.debt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditScore => $composableBuilder(
    column: $table.creditScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAlive => $composableBuilder(
    column: $table.isAlive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get causeOfDeath => $composableBuilder(
    column: $table.causeOfDeath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageOfDeath => $composableBuilder(
    column: $table.ageOfDeath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerId => $composableBuilder(
    column: $table.partnerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMarried => $composableBuilder(
    column: $table.isMarried,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get educationLevel => $composableBuilder(
    column: $table.educationLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentDegree => $composableBuilder(
    column: $table.currentDegree,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentJobId => $composableBuilder(
    column: $table.currentJobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentJobTitle => $composableBuilder(
    column: $table.currentJobTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentSalary => $composableBuilder(
    column: $table.currentSalary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jobPerformance => $composableBuilder(
    column: $table.jobPerformance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearsInCurrentJob => $composableBuilder(
    column: $table.yearsInCurrentJob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasDriversLicense => $composableBuilder(
    column: $table.hasDriversLicense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get criminalRecord => $composableBuilder(
    column: $table.criminalRecord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesArrested => $composableBuilder(
    column: $table.timesArrested,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CharactersTableOrderingComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sexualOrientation => $composableBuilder(
    column: $table.sexualOrientation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentAge => $composableBuilder(
    column: $table.currentAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarConfigJson => $composableBuilder(
    column: $table.avatarConfigJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get health => $composableBuilder(
    column: $table.health,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get happiness => $composableBuilder(
    column: $table.happiness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get smarts => $composableBuilder(
    column: $table.smarts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get looks => $composableBuilder(
    column: $table.looks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stress => $composableBuilder(
    column: $table.stress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discipline => $composableBuilder(
    column: $table.discipline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get charisma => $composableBuilder(
    column: $table.charisma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fitness => $composableBuilder(
    column: $table.fitness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reputation => $composableBuilder(
    column: $table.reputation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fame => $composableBuilder(
    column: $table.fame,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get karma => $composableBuilder(
    column: $table.karma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bankBalance => $composableBuilder(
    column: $table.bankBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get annualExpenses => $composableBuilder(
    column: $table.annualExpenses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get debt => $composableBuilder(
    column: $table.debt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditScore => $composableBuilder(
    column: $table.creditScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAlive => $composableBuilder(
    column: $table.isAlive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get causeOfDeath => $composableBuilder(
    column: $table.causeOfDeath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageOfDeath => $composableBuilder(
    column: $table.ageOfDeath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerId => $composableBuilder(
    column: $table.partnerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMarried => $composableBuilder(
    column: $table.isMarried,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get educationLevel => $composableBuilder(
    column: $table.educationLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentDegree => $composableBuilder(
    column: $table.currentDegree,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentJobId => $composableBuilder(
    column: $table.currentJobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentJobTitle => $composableBuilder(
    column: $table.currentJobTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentSalary => $composableBuilder(
    column: $table.currentSalary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jobPerformance => $composableBuilder(
    column: $table.jobPerformance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearsInCurrentJob => $composableBuilder(
    column: $table.yearsInCurrentJob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasDriversLicense => $composableBuilder(
    column: $table.hasDriversLicense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get criminalRecord => $composableBuilder(
    column: $table.criminalRecord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesArrested => $composableBuilder(
    column: $table.timesArrested,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharactersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saveId =>
      $composableBuilder(column: $table.saveId, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get sexualOrientation => $composableBuilder(
    column: $table.sexualOrientation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumn<int> get currentAge => $composableBuilder(
    column: $table.currentAge,
    builder: (column) => column,
  );

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get avatarConfigJson => $composableBuilder(
    column: $table.avatarConfigJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get health =>
      $composableBuilder(column: $table.health, builder: (column) => column);

  GeneratedColumn<int> get happiness =>
      $composableBuilder(column: $table.happiness, builder: (column) => column);

  GeneratedColumn<int> get smarts =>
      $composableBuilder(column: $table.smarts, builder: (column) => column);

  GeneratedColumn<int> get looks =>
      $composableBuilder(column: $table.looks, builder: (column) => column);

  GeneratedColumn<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<int> get stress =>
      $composableBuilder(column: $table.stress, builder: (column) => column);

  GeneratedColumn<int> get discipline => $composableBuilder(
    column: $table.discipline,
    builder: (column) => column,
  );

  GeneratedColumn<int> get charisma =>
      $composableBuilder(column: $table.charisma, builder: (column) => column);

  GeneratedColumn<int> get fitness =>
      $composableBuilder(column: $table.fitness, builder: (column) => column);

  GeneratedColumn<int> get reputation => $composableBuilder(
    column: $table.reputation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fame =>
      $composableBuilder(column: $table.fame, builder: (column) => column);

  GeneratedColumn<int> get karma =>
      $composableBuilder(column: $table.karma, builder: (column) => column);

  GeneratedColumn<double> get bankBalance => $composableBuilder(
    column: $table.bankBalance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get annualExpenses => $composableBuilder(
    column: $table.annualExpenses,
    builder: (column) => column,
  );

  GeneratedColumn<double> get debt =>
      $composableBuilder(column: $table.debt, builder: (column) => column);

  GeneratedColumn<int> get creditScore => $composableBuilder(
    column: $table.creditScore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAlive =>
      $composableBuilder(column: $table.isAlive, builder: (column) => column);

  GeneratedColumn<String> get causeOfDeath => $composableBuilder(
    column: $table.causeOfDeath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ageOfDeath => $composableBuilder(
    column: $table.ageOfDeath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partnerId =>
      $composableBuilder(column: $table.partnerId, builder: (column) => column);

  GeneratedColumn<bool> get isMarried =>
      $composableBuilder(column: $table.isMarried, builder: (column) => column);

  GeneratedColumn<String> get educationLevel => $composableBuilder(
    column: $table.educationLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentDegree => $composableBuilder(
    column: $table.currentDegree,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentJobId => $composableBuilder(
    column: $table.currentJobId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentJobTitle => $composableBuilder(
    column: $table.currentJobTitle,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentSalary => $composableBuilder(
    column: $table.currentSalary,
    builder: (column) => column,
  );

  GeneratedColumn<int> get jobPerformance => $composableBuilder(
    column: $table.jobPerformance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get yearsInCurrentJob => $composableBuilder(
    column: $table.yearsInCurrentJob,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasDriversLicense => $composableBuilder(
    column: $table.hasDriversLicense,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get criminalRecord => $composableBuilder(
    column: $table.criminalRecord,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timesArrested => $composableBuilder(
    column: $table.timesArrested,
    builder: (column) => column,
  );
}

class $$CharactersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharactersTable,
          Character,
          $$CharactersTableFilterComposer,
          $$CharactersTableOrderingComposer,
          $$CharactersTableAnnotationComposer,
          $$CharactersTableCreateCompanionBuilder,
          $$CharactersTableUpdateCompanionBuilder,
          (
            Character,
            BaseReferences<_$AppDatabase, $CharactersTable, Character>,
          ),
          Character,
          PrefetchHooks Function()
        > {
  $$CharactersTableTableManager(_$AppDatabase db, $CharactersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharactersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saveId = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String> sexualOrientation = const Value.absent(),
                Value<int> birthYear = const Value.absent(),
                Value<int> currentAge = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> avatarConfigJson = const Value.absent(),
                Value<int> health = const Value.absent(),
                Value<int> happiness = const Value.absent(),
                Value<int> smarts = const Value.absent(),
                Value<int> looks = const Value.absent(),
                Value<int> energy = const Value.absent(),
                Value<int> stress = const Value.absent(),
                Value<int> discipline = const Value.absent(),
                Value<int> charisma = const Value.absent(),
                Value<int> fitness = const Value.absent(),
                Value<int> reputation = const Value.absent(),
                Value<int> fame = const Value.absent(),
                Value<int> karma = const Value.absent(),
                Value<double> bankBalance = const Value.absent(),
                Value<double> annualExpenses = const Value.absent(),
                Value<double> debt = const Value.absent(),
                Value<int> creditScore = const Value.absent(),
                Value<bool> isAlive = const Value.absent(),
                Value<String?> causeOfDeath = const Value.absent(),
                Value<int?> ageOfDeath = const Value.absent(),
                Value<String?> partnerId = const Value.absent(),
                Value<bool> isMarried = const Value.absent(),
                Value<String> educationLevel = const Value.absent(),
                Value<String?> currentDegree = const Value.absent(),
                Value<String?> currentJobId = const Value.absent(),
                Value<String?> currentJobTitle = const Value.absent(),
                Value<double?> currentSalary = const Value.absent(),
                Value<int> jobPerformance = const Value.absent(),
                Value<int> yearsInCurrentJob = const Value.absent(),
                Value<bool> hasDriversLicense = const Value.absent(),
                Value<bool> criminalRecord = const Value.absent(),
                Value<int> timesArrested = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharactersCompanion(
                id: id,
                saveId: saveId,
                firstName: firstName,
                lastName: lastName,
                gender: gender,
                sexualOrientation: sexualOrientation,
                birthYear: birthYear,
                currentAge: currentAge,
                country: country,
                city: city,
                avatarConfigJson: avatarConfigJson,
                health: health,
                happiness: happiness,
                smarts: smarts,
                looks: looks,
                energy: energy,
                stress: stress,
                discipline: discipline,
                charisma: charisma,
                fitness: fitness,
                reputation: reputation,
                fame: fame,
                karma: karma,
                bankBalance: bankBalance,
                annualExpenses: annualExpenses,
                debt: debt,
                creditScore: creditScore,
                isAlive: isAlive,
                causeOfDeath: causeOfDeath,
                ageOfDeath: ageOfDeath,
                partnerId: partnerId,
                isMarried: isMarried,
                educationLevel: educationLevel,
                currentDegree: currentDegree,
                currentJobId: currentJobId,
                currentJobTitle: currentJobTitle,
                currentSalary: currentSalary,
                jobPerformance: jobPerformance,
                yearsInCurrentJob: yearsInCurrentJob,
                hasDriversLicense: hasDriversLicense,
                criminalRecord: criminalRecord,
                timesArrested: timesArrested,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saveId,
                required String firstName,
                required String lastName,
                required String gender,
                required String sexualOrientation,
                required int birthYear,
                required int currentAge,
                required String country,
                required String city,
                required String avatarConfigJson,
                required int health,
                required int happiness,
                required int smarts,
                required int looks,
                required int energy,
                required int stress,
                required int discipline,
                required int charisma,
                required int fitness,
                required int reputation,
                required int fame,
                required int karma,
                required double bankBalance,
                required double annualExpenses,
                required double debt,
                required int creditScore,
                Value<bool> isAlive = const Value.absent(),
                Value<String?> causeOfDeath = const Value.absent(),
                Value<int?> ageOfDeath = const Value.absent(),
                Value<String?> partnerId = const Value.absent(),
                Value<bool> isMarried = const Value.absent(),
                required String educationLevel,
                Value<String?> currentDegree = const Value.absent(),
                Value<String?> currentJobId = const Value.absent(),
                Value<String?> currentJobTitle = const Value.absent(),
                Value<double?> currentSalary = const Value.absent(),
                Value<int> jobPerformance = const Value.absent(),
                Value<int> yearsInCurrentJob = const Value.absent(),
                Value<bool> hasDriversLicense = const Value.absent(),
                Value<bool> criminalRecord = const Value.absent(),
                Value<int> timesArrested = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharactersCompanion.insert(
                id: id,
                saveId: saveId,
                firstName: firstName,
                lastName: lastName,
                gender: gender,
                sexualOrientation: sexualOrientation,
                birthYear: birthYear,
                currentAge: currentAge,
                country: country,
                city: city,
                avatarConfigJson: avatarConfigJson,
                health: health,
                happiness: happiness,
                smarts: smarts,
                looks: looks,
                energy: energy,
                stress: stress,
                discipline: discipline,
                charisma: charisma,
                fitness: fitness,
                reputation: reputation,
                fame: fame,
                karma: karma,
                bankBalance: bankBalance,
                annualExpenses: annualExpenses,
                debt: debt,
                creditScore: creditScore,
                isAlive: isAlive,
                causeOfDeath: causeOfDeath,
                ageOfDeath: ageOfDeath,
                partnerId: partnerId,
                isMarried: isMarried,
                educationLevel: educationLevel,
                currentDegree: currentDegree,
                currentJobId: currentJobId,
                currentJobTitle: currentJobTitle,
                currentSalary: currentSalary,
                jobPerformance: jobPerformance,
                yearsInCurrentJob: yearsInCurrentJob,
                hasDriversLicense: hasDriversLicense,
                criminalRecord: criminalRecord,
                timesArrested: timesArrested,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CharactersTable, Character>(table),
                  BaseReferences<_$AppDatabase, $CharactersTable, Character>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CharactersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharactersTable,
      Character,
      $$CharactersTableFilterComposer,
      $$CharactersTableOrderingComposer,
      $$CharactersTableAnnotationComposer,
      $$CharactersTableCreateCompanionBuilder,
      $$CharactersTableUpdateCompanionBuilder,
      (Character, BaseReferences<_$AppDatabase, $CharactersTable, Character>),
      Character,
      PrefetchHooks Function()
    >;
typedef $$NpcsTableCreateCompanionBuilder = NpcsCompanion Function({
  required String id,
  required String saveId,
  required String firstName,
  required String lastName,
  required String gender,
  required int age,
  required String relationshipType,
  required int relationshipLevel,
  required int respectLevel,
  required String avatarConfigJson,
  required String occupation,
  required double salary,
  required double netWorth,
  required int health,
  required int happiness,
  Value<bool> isAlive,
  Value<String?> causeOfDeath,
  Value<String> memoryJson,
  Value<int> rowid,
});
typedef $$NpcsTableUpdateCompanionBuilder = NpcsCompanion Function({
  Value<String> id,
  Value<String> saveId,
  Value<String> firstName,
  Value<String> lastName,
  Value<String> gender,
  Value<int> age,
  Value<String> relationshipType,
  Value<int> relationshipLevel,
  Value<int> respectLevel,
  Value<String> avatarConfigJson,
  Value<String> occupation,
  Value<double> salary,
  Value<double> netWorth,
  Value<int> health,
  Value<int> happiness,
  Value<bool> isAlive,
  Value<String?> causeOfDeath,
  Value<String> memoryJson,
  Value<int> rowid,
});

class $$NpcsTableFilterComposer extends Composer<_$AppDatabase, $NpcsTable> {
  $$NpcsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get relationshipLevel => $composableBuilder(
    column: $table.relationshipLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get respectLevel => $composableBuilder(
    column: $table.respectLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarConfigJson => $composableBuilder(
    column: $table.avatarConfigJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occupation => $composableBuilder(
    column: $table.occupation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salary => $composableBuilder(
    column: $table.salary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get netWorth => $composableBuilder(
    column: $table.netWorth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get health => $composableBuilder(
    column: $table.health,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get happiness => $composableBuilder(
    column: $table.happiness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAlive => $composableBuilder(
    column: $table.isAlive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get causeOfDeath => $composableBuilder(
    column: $table.causeOfDeath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memoryJson => $composableBuilder(
    column: $table.memoryJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NpcsTableOrderingComposer extends Composer<_$AppDatabase, $NpcsTable> {
  $$NpcsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get relationshipLevel => $composableBuilder(
    column: $table.relationshipLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get respectLevel => $composableBuilder(
    column: $table.respectLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarConfigJson => $composableBuilder(
    column: $table.avatarConfigJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occupation => $composableBuilder(
    column: $table.occupation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salary => $composableBuilder(
    column: $table.salary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get netWorth => $composableBuilder(
    column: $table.netWorth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get health => $composableBuilder(
    column: $table.health,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get happiness => $composableBuilder(
    column: $table.happiness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAlive => $composableBuilder(
    column: $table.isAlive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get causeOfDeath => $composableBuilder(
    column: $table.causeOfDeath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memoryJson => $composableBuilder(
    column: $table.memoryJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NpcsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NpcsTable> {
  $$NpcsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saveId =>
      $composableBuilder(column: $table.saveId, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get relationshipLevel => $composableBuilder(
    column: $table.relationshipLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get respectLevel => $composableBuilder(
    column: $table.respectLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarConfigJson => $composableBuilder(
    column: $table.avatarConfigJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get occupation => $composableBuilder(
    column: $table.occupation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get salary =>
      $composableBuilder(column: $table.salary, builder: (column) => column);

  GeneratedColumn<double> get netWorth =>
      $composableBuilder(column: $table.netWorth, builder: (column) => column);

  GeneratedColumn<int> get health =>
      $composableBuilder(column: $table.health, builder: (column) => column);

  GeneratedColumn<int> get happiness =>
      $composableBuilder(column: $table.happiness, builder: (column) => column);

  GeneratedColumn<bool> get isAlive =>
      $composableBuilder(column: $table.isAlive, builder: (column) => column);

  GeneratedColumn<String> get causeOfDeath => $composableBuilder(
    column: $table.causeOfDeath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memoryJson => $composableBuilder(
    column: $table.memoryJson,
    builder: (column) => column,
  );
}

class $$NpcsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NpcsTable,
          Npc,
          $$NpcsTableFilterComposer,
          $$NpcsTableOrderingComposer,
          $$NpcsTableAnnotationComposer,
          $$NpcsTableCreateCompanionBuilder,
          $$NpcsTableUpdateCompanionBuilder,
          (Npc, BaseReferences<_$AppDatabase, $NpcsTable, Npc>),
          Npc,
          PrefetchHooks Function()
        > {
  $$NpcsTableTableManager(_$AppDatabase db, $NpcsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NpcsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NpcsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NpcsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saveId = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<String> relationshipType = const Value.absent(),
                Value<int> relationshipLevel = const Value.absent(),
                Value<int> respectLevel = const Value.absent(),
                Value<String> avatarConfigJson = const Value.absent(),
                Value<String> occupation = const Value.absent(),
                Value<double> salary = const Value.absent(),
                Value<double> netWorth = const Value.absent(),
                Value<int> health = const Value.absent(),
                Value<int> happiness = const Value.absent(),
                Value<bool> isAlive = const Value.absent(),
                Value<String?> causeOfDeath = const Value.absent(),
                Value<String> memoryJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NpcsCompanion(
                id: id,
                saveId: saveId,
                firstName: firstName,
                lastName: lastName,
                gender: gender,
                age: age,
                relationshipType: relationshipType,
                relationshipLevel: relationshipLevel,
                respectLevel: respectLevel,
                avatarConfigJson: avatarConfigJson,
                occupation: occupation,
                salary: salary,
                netWorth: netWorth,
                health: health,
                happiness: happiness,
                isAlive: isAlive,
                causeOfDeath: causeOfDeath,
                memoryJson: memoryJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saveId,
                required String firstName,
                required String lastName,
                required String gender,
                required int age,
                required String relationshipType,
                required int relationshipLevel,
                required int respectLevel,
                required String avatarConfigJson,
                required String occupation,
                required double salary,
                required double netWorth,
                required int health,
                required int happiness,
                Value<bool> isAlive = const Value.absent(),
                Value<String?> causeOfDeath = const Value.absent(),
                Value<String> memoryJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NpcsCompanion.insert(
                id: id,
                saveId: saveId,
                firstName: firstName,
                lastName: lastName,
                gender: gender,
                age: age,
                relationshipType: relationshipType,
                relationshipLevel: relationshipLevel,
                respectLevel: respectLevel,
                avatarConfigJson: avatarConfigJson,
                occupation: occupation,
                salary: salary,
                netWorth: netWorth,
                health: health,
                happiness: happiness,
                isAlive: isAlive,
                causeOfDeath: causeOfDeath,
                memoryJson: memoryJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NpcsTable, Npc>(table),
                  BaseReferences<_$AppDatabase, $NpcsTable, Npc>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NpcsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NpcsTable,
      Npc,
      $$NpcsTableFilterComposer,
      $$NpcsTableOrderingComposer,
      $$NpcsTableAnnotationComposer,
      $$NpcsTableCreateCompanionBuilder,
      $$NpcsTableUpdateCompanionBuilder,
      (Npc, BaseReferences<_$AppDatabase, $NpcsTable, Npc>),
      Npc,
      PrefetchHooks Function()
    >;
typedef $$EducationHistoriesTableCreateCompanionBuilder =
    EducationHistoriesCompanion Function({
      required String id,
      required String saveId,
      required String schoolType,
      required String institutionName,
      Value<String?> majorOrCourse,
      required int startAge,
      Value<int?> graduatedAge,
      Value<bool> isCompleted,
      required double gpaOrGrade,
      Value<int> rowid,
    });
typedef $$EducationHistoriesTableUpdateCompanionBuilder =
    EducationHistoriesCompanion Function({
      Value<String> id,
      Value<String> saveId,
      Value<String> schoolType,
      Value<String> institutionName,
      Value<String?> majorOrCourse,
      Value<int> startAge,
      Value<int?> graduatedAge,
      Value<bool> isCompleted,
      Value<double> gpaOrGrade,
      Value<int> rowid,
    });

class $$EducationHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $EducationHistoriesTable> {
  $$EducationHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolType => $composableBuilder(
    column: $table.schoolType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionName => $composableBuilder(
    column: $table.institutionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get majorOrCourse => $composableBuilder(
    column: $table.majorOrCourse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startAge => $composableBuilder(
    column: $table.startAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get graduatedAge => $composableBuilder(
    column: $table.graduatedAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpaOrGrade => $composableBuilder(
    column: $table.gpaOrGrade,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EducationHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EducationHistoriesTable> {
  $$EducationHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolType => $composableBuilder(
    column: $table.schoolType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionName => $composableBuilder(
    column: $table.institutionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get majorOrCourse => $composableBuilder(
    column: $table.majorOrCourse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startAge => $composableBuilder(
    column: $table.startAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get graduatedAge => $composableBuilder(
    column: $table.graduatedAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpaOrGrade => $composableBuilder(
    column: $table.gpaOrGrade,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EducationHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EducationHistoriesTable> {
  $$EducationHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saveId =>
      $composableBuilder(column: $table.saveId, builder: (column) => column);

  GeneratedColumn<String> get schoolType => $composableBuilder(
    column: $table.schoolType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get institutionName => $composableBuilder(
    column: $table.institutionName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get majorOrCourse => $composableBuilder(
    column: $table.majorOrCourse,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startAge =>
      $composableBuilder(column: $table.startAge, builder: (column) => column);

  GeneratedColumn<int> get graduatedAge => $composableBuilder(
    column: $table.graduatedAge,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gpaOrGrade => $composableBuilder(
    column: $table.gpaOrGrade,
    builder: (column) => column,
  );
}

class $$EducationHistoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EducationHistoriesTable,
          EducationHistory,
          $$EducationHistoriesTableFilterComposer,
          $$EducationHistoriesTableOrderingComposer,
          $$EducationHistoriesTableAnnotationComposer,
          $$EducationHistoriesTableCreateCompanionBuilder,
          $$EducationHistoriesTableUpdateCompanionBuilder,
          (
            EducationHistory,
            BaseReferences<
              _$AppDatabase,
              $EducationHistoriesTable,
              EducationHistory
            >,
          ),
          EducationHistory,
          PrefetchHooks Function()
        > {
  $$EducationHistoriesTableTableManager(
    _$AppDatabase db,
    $EducationHistoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EducationHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EducationHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EducationHistoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saveId = const Value.absent(),
                Value<String> schoolType = const Value.absent(),
                Value<String> institutionName = const Value.absent(),
                Value<String?> majorOrCourse = const Value.absent(),
                Value<int> startAge = const Value.absent(),
                Value<int?> graduatedAge = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<double> gpaOrGrade = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EducationHistoriesCompanion(
                id: id,
                saveId: saveId,
                schoolType: schoolType,
                institutionName: institutionName,
                majorOrCourse: majorOrCourse,
                startAge: startAge,
                graduatedAge: graduatedAge,
                isCompleted: isCompleted,
                gpaOrGrade: gpaOrGrade,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saveId,
                required String schoolType,
                required String institutionName,
                Value<String?> majorOrCourse = const Value.absent(),
                required int startAge,
                Value<int?> graduatedAge = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                required double gpaOrGrade,
                Value<int> rowid = const Value.absent(),
              }) => EducationHistoriesCompanion.insert(
                id: id,
                saveId: saveId,
                schoolType: schoolType,
                institutionName: institutionName,
                majorOrCourse: majorOrCourse,
                startAge: startAge,
                graduatedAge: graduatedAge,
                isCompleted: isCompleted,
                gpaOrGrade: gpaOrGrade,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EducationHistoriesTable, EducationHistory>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $EducationHistoriesTable,
                    EducationHistory
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EducationHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EducationHistoriesTable,
      EducationHistory,
      $$EducationHistoriesTableFilterComposer,
      $$EducationHistoriesTableOrderingComposer,
      $$EducationHistoriesTableAnnotationComposer,
      $$EducationHistoriesTableCreateCompanionBuilder,
      $$EducationHistoriesTableUpdateCompanionBuilder,
      (
        EducationHistory,
        BaseReferences<
          _$AppDatabase,
          $EducationHistoriesTable,
          EducationHistory
        >,
      ),
      EducationHistory,
      PrefetchHooks Function()
    >;
typedef $$CareerHistoriesTableCreateCompanionBuilder =
    CareerHistoriesCompanion Function({
      required String id,
      required String saveId,
      required String companyName,
      required String jobTitle,
      required String field,
      required int startAge,
      Value<int?> endAge,
      required double salary,
      Value<String?> reasonForLeaving,
      Value<int> rowid,
    });
typedef $$CareerHistoriesTableUpdateCompanionBuilder =
    CareerHistoriesCompanion Function({
      Value<String> id,
      Value<String> saveId,
      Value<String> companyName,
      Value<String> jobTitle,
      Value<String> field,
      Value<int> startAge,
      Value<int?> endAge,
      Value<double> salary,
      Value<String?> reasonForLeaving,
      Value<int> rowid,
    });

class $$CareerHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CareerHistoriesTable> {
  $$CareerHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobTitle => $composableBuilder(
    column: $table.jobTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startAge => $composableBuilder(
    column: $table.startAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endAge => $composableBuilder(
    column: $table.endAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salary => $composableBuilder(
    column: $table.salary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonForLeaving => $composableBuilder(
    column: $table.reasonForLeaving,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CareerHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CareerHistoriesTable> {
  $$CareerHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobTitle => $composableBuilder(
    column: $table.jobTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startAge => $composableBuilder(
    column: $table.startAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endAge => $composableBuilder(
    column: $table.endAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salary => $composableBuilder(
    column: $table.salary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonForLeaving => $composableBuilder(
    column: $table.reasonForLeaving,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CareerHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CareerHistoriesTable> {
  $$CareerHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saveId =>
      $composableBuilder(column: $table.saveId, builder: (column) => column);

  GeneratedColumn<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jobTitle =>
      $composableBuilder(column: $table.jobTitle, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<int> get startAge =>
      $composableBuilder(column: $table.startAge, builder: (column) => column);

  GeneratedColumn<int> get endAge =>
      $composableBuilder(column: $table.endAge, builder: (column) => column);

  GeneratedColumn<double> get salary =>
      $composableBuilder(column: $table.salary, builder: (column) => column);

  GeneratedColumn<String> get reasonForLeaving => $composableBuilder(
    column: $table.reasonForLeaving,
    builder: (column) => column,
  );
}

class $$CareerHistoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CareerHistoriesTable,
          CareerHistory,
          $$CareerHistoriesTableFilterComposer,
          $$CareerHistoriesTableOrderingComposer,
          $$CareerHistoriesTableAnnotationComposer,
          $$CareerHistoriesTableCreateCompanionBuilder,
          $$CareerHistoriesTableUpdateCompanionBuilder,
          (
            CareerHistory,
            BaseReferences<_$AppDatabase, $CareerHistoriesTable, CareerHistory>,
          ),
          CareerHistory,
          PrefetchHooks Function()
        > {
  $$CareerHistoriesTableTableManager(
    _$AppDatabase db,
    $CareerHistoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CareerHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CareerHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CareerHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saveId = const Value.absent(),
                Value<String> companyName = const Value.absent(),
                Value<String> jobTitle = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<int> startAge = const Value.absent(),
                Value<int?> endAge = const Value.absent(),
                Value<double> salary = const Value.absent(),
                Value<String?> reasonForLeaving = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CareerHistoriesCompanion(
                id: id,
                saveId: saveId,
                companyName: companyName,
                jobTitle: jobTitle,
                field: field,
                startAge: startAge,
                endAge: endAge,
                salary: salary,
                reasonForLeaving: reasonForLeaving,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saveId,
                required String companyName,
                required String jobTitle,
                required String field,
                required int startAge,
                Value<int?> endAge = const Value.absent(),
                required double salary,
                Value<String?> reasonForLeaving = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CareerHistoriesCompanion.insert(
                id: id,
                saveId: saveId,
                companyName: companyName,
                jobTitle: jobTitle,
                field: field,
                startAge: startAge,
                endAge: endAge,
                salary: salary,
                reasonForLeaving: reasonForLeaving,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CareerHistoriesTable, CareerHistory>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CareerHistoriesTable,
                    CareerHistory
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CareerHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CareerHistoriesTable,
      CareerHistory,
      $$CareerHistoriesTableFilterComposer,
      $$CareerHistoriesTableOrderingComposer,
      $$CareerHistoriesTableAnnotationComposer,
      $$CareerHistoriesTableCreateCompanionBuilder,
      $$CareerHistoriesTableUpdateCompanionBuilder,
      (
        CareerHistory,
        BaseReferences<_$AppDatabase, $CareerHistoriesTable, CareerHistory>,
      ),
      CareerHistory,
      PrefetchHooks Function()
    >;
typedef $$PropertiesTableCreateCompanionBuilder = PropertiesCompanion Function({
  required String id,
  required String saveId,
  required String type,
  required String name,
  required double purchasePrice,
  required double currentValue,
  required double annualCost,
  required int condition,
  Value<bool> isFinanced,
  Value<double> monthlyPayment,
  Value<double> remainingDebt,
  required int purchasedAtAge,
  Value<int> rowid,
});
typedef $$PropertiesTableUpdateCompanionBuilder = PropertiesCompanion Function({
  Value<String> id,
  Value<String> saveId,
  Value<String> type,
  Value<String> name,
  Value<double> purchasePrice,
  Value<double> currentValue,
  Value<double> annualCost,
  Value<int> condition,
  Value<bool> isFinanced,
  Value<double> monthlyPayment,
  Value<double> remainingDebt,
  Value<int> purchasedAtAge,
  Value<int> rowid,
});

class $$PropertiesTableFilterComposer
    extends Composer<_$AppDatabase, $PropertiesTable> {
  $$PropertiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get annualCost => $composableBuilder(
    column: $table.annualCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFinanced => $composableBuilder(
    column: $table.isFinanced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyPayment => $composableBuilder(
    column: $table.monthlyPayment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get remainingDebt => $composableBuilder(
    column: $table.remainingDebt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get purchasedAtAge => $composableBuilder(
    column: $table.purchasedAtAge,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PropertiesTableOrderingComposer
    extends Composer<_$AppDatabase, $PropertiesTable> {
  $$PropertiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get annualCost => $composableBuilder(
    column: $table.annualCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFinanced => $composableBuilder(
    column: $table.isFinanced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyPayment => $composableBuilder(
    column: $table.monthlyPayment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get remainingDebt => $composableBuilder(
    column: $table.remainingDebt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purchasedAtAge => $composableBuilder(
    column: $table.purchasedAtAge,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PropertiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PropertiesTable> {
  $$PropertiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saveId =>
      $composableBuilder(column: $table.saveId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get annualCost => $composableBuilder(
    column: $table.annualCost,
    builder: (column) => column,
  );

  GeneratedColumn<int> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<bool> get isFinanced => $composableBuilder(
    column: $table.isFinanced,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyPayment => $composableBuilder(
    column: $table.monthlyPayment,
    builder: (column) => column,
  );

  GeneratedColumn<double> get remainingDebt => $composableBuilder(
    column: $table.remainingDebt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get purchasedAtAge => $composableBuilder(
    column: $table.purchasedAtAge,
    builder: (column) => column,
  );
}

class $$PropertiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PropertiesTable,
          Property,
          $$PropertiesTableFilterComposer,
          $$PropertiesTableOrderingComposer,
          $$PropertiesTableAnnotationComposer,
          $$PropertiesTableCreateCompanionBuilder,
          $$PropertiesTableUpdateCompanionBuilder,
          (Property, BaseReferences<_$AppDatabase, $PropertiesTable, Property>),
          Property,
          PrefetchHooks Function()
        > {
  $$PropertiesTableTableManager(_$AppDatabase db, $PropertiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PropertiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PropertiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PropertiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saveId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<double> currentValue = const Value.absent(),
                Value<double> annualCost = const Value.absent(),
                Value<int> condition = const Value.absent(),
                Value<bool> isFinanced = const Value.absent(),
                Value<double> monthlyPayment = const Value.absent(),
                Value<double> remainingDebt = const Value.absent(),
                Value<int> purchasedAtAge = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PropertiesCompanion(
                id: id,
                saveId: saveId,
                type: type,
                name: name,
                purchasePrice: purchasePrice,
                currentValue: currentValue,
                annualCost: annualCost,
                condition: condition,
                isFinanced: isFinanced,
                monthlyPayment: monthlyPayment,
                remainingDebt: remainingDebt,
                purchasedAtAge: purchasedAtAge,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saveId,
                required String type,
                required String name,
                required double purchasePrice,
                required double currentValue,
                required double annualCost,
                required int condition,
                Value<bool> isFinanced = const Value.absent(),
                Value<double> monthlyPayment = const Value.absent(),
                Value<double> remainingDebt = const Value.absent(),
                required int purchasedAtAge,
                Value<int> rowid = const Value.absent(),
              }) => PropertiesCompanion.insert(
                id: id,
                saveId: saveId,
                type: type,
                name: name,
                purchasePrice: purchasePrice,
                currentValue: currentValue,
                annualCost: annualCost,
                condition: condition,
                isFinanced: isFinanced,
                monthlyPayment: monthlyPayment,
                remainingDebt: remainingDebt,
                purchasedAtAge: purchasedAtAge,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PropertiesTable, Property>(table),
                  BaseReferences<_$AppDatabase, $PropertiesTable, Property>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PropertiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PropertiesTable,
      Property,
      $$PropertiesTableFilterComposer,
      $$PropertiesTableOrderingComposer,
      $$PropertiesTableAnnotationComposer,
      $$PropertiesTableCreateCompanionBuilder,
      $$PropertiesTableUpdateCompanionBuilder,
      (Property, BaseReferences<_$AppDatabase, $PropertiesTable, Property>),
      Property,
      PrefetchHooks Function()
    >;
typedef $$InvestmentsTableCreateCompanionBuilder =
    InvestmentsCompanion Function({
      required String id,
      required String saveId,
      required String type,
      required String name,
      required String ticker,
      required double investedAmount,
      required double currentValue,
      required double units,
      required double annualYieldPercent,
      Value<int> rowid,
    });
typedef $$InvestmentsTableUpdateCompanionBuilder =
    InvestmentsCompanion Function({
      Value<String> id,
      Value<String> saveId,
      Value<String> type,
      Value<String> name,
      Value<String> ticker,
      Value<double> investedAmount,
      Value<double> currentValue,
      Value<double> units,
      Value<double> annualYieldPercent,
      Value<int> rowid,
    });

class $$InvestmentsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ticker => $composableBuilder(
    column: $table.ticker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get investedAmount => $composableBuilder(
    column: $table.investedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get units => $composableBuilder(
    column: $table.units,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get annualYieldPercent => $composableBuilder(
    column: $table.annualYieldPercent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InvestmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ticker => $composableBuilder(
    column: $table.ticker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get investedAmount => $composableBuilder(
    column: $table.investedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get units => $composableBuilder(
    column: $table.units,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get annualYieldPercent => $composableBuilder(
    column: $table.annualYieldPercent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvestmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saveId =>
      $composableBuilder(column: $table.saveId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get ticker =>
      $composableBuilder(column: $table.ticker, builder: (column) => column);

  GeneratedColumn<double> get investedAmount => $composableBuilder(
    column: $table.investedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get units =>
      $composableBuilder(column: $table.units, builder: (column) => column);

  GeneratedColumn<double> get annualYieldPercent => $composableBuilder(
    column: $table.annualYieldPercent,
    builder: (column) => column,
  );
}

class $$InvestmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestmentsTable,
          Investment,
          $$InvestmentsTableFilterComposer,
          $$InvestmentsTableOrderingComposer,
          $$InvestmentsTableAnnotationComposer,
          $$InvestmentsTableCreateCompanionBuilder,
          $$InvestmentsTableUpdateCompanionBuilder,
          (
            Investment,
            BaseReferences<_$AppDatabase, $InvestmentsTable, Investment>,
          ),
          Investment,
          PrefetchHooks Function()
        > {
  $$InvestmentsTableTableManager(_$AppDatabase db, $InvestmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saveId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> ticker = const Value.absent(),
                Value<double> investedAmount = const Value.absent(),
                Value<double> currentValue = const Value.absent(),
                Value<double> units = const Value.absent(),
                Value<double> annualYieldPercent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentsCompanion(
                id: id,
                saveId: saveId,
                type: type,
                name: name,
                ticker: ticker,
                investedAmount: investedAmount,
                currentValue: currentValue,
                units: units,
                annualYieldPercent: annualYieldPercent,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saveId,
                required String type,
                required String name,
                required String ticker,
                required double investedAmount,
                required double currentValue,
                required double units,
                required double annualYieldPercent,
                Value<int> rowid = const Value.absent(),
              }) => InvestmentsCompanion.insert(
                id: id,
                saveId: saveId,
                type: type,
                name: name,
                ticker: ticker,
                investedAmount: investedAmount,
                currentValue: currentValue,
                units: units,
                annualYieldPercent: annualYieldPercent,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InvestmentsTable, Investment>(table),
                  BaseReferences<_$AppDatabase, $InvestmentsTable, Investment>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvestmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestmentsTable,
      Investment,
      $$InvestmentsTableFilterComposer,
      $$InvestmentsTableOrderingComposer,
      $$InvestmentsTableAnnotationComposer,
      $$InvestmentsTableCreateCompanionBuilder,
      $$InvestmentsTableUpdateCompanionBuilder,
      (
        Investment,
        BaseReferences<_$AppDatabase, $InvestmentsTable, Investment>,
      ),
      Investment,
      PrefetchHooks Function()
    >;
typedef $$BusinessesTableCreateCompanionBuilder = BusinessesCompanion Function({
  required String id,
  required String saveId,
  required String name,
  required String industry,
  required double valuation,
  required double revenue,
  required double expenses,
  required int employeeCount,
  required int reputation,
  required double productPrice,
  required double marketingBudget,
  Value<int> rowid,
});
typedef $$BusinessesTableUpdateCompanionBuilder = BusinessesCompanion Function({
  Value<String> id,
  Value<String> saveId,
  Value<String> name,
  Value<String> industry,
  Value<double> valuation,
  Value<double> revenue,
  Value<double> expenses,
  Value<int> employeeCount,
  Value<int> reputation,
  Value<double> productPrice,
  Value<double> marketingBudget,
  Value<int> rowid,
});

class $$BusinessesTableFilterComposer
    extends Composer<_$AppDatabase, $BusinessesTable> {
  $$BusinessesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get industry => $composableBuilder(
    column: $table.industry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valuation => $composableBuilder(
    column: $table.valuation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get revenue => $composableBuilder(
    column: $table.revenue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get expenses => $composableBuilder(
    column: $table.expenses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get employeeCount => $composableBuilder(
    column: $table.employeeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reputation => $composableBuilder(
    column: $table.reputation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get productPrice => $composableBuilder(
    column: $table.productPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get marketingBudget => $composableBuilder(
    column: $table.marketingBudget,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BusinessesTableOrderingComposer
    extends Composer<_$AppDatabase, $BusinessesTable> {
  $$BusinessesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get industry => $composableBuilder(
    column: $table.industry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valuation => $composableBuilder(
    column: $table.valuation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get revenue => $composableBuilder(
    column: $table.revenue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get expenses => $composableBuilder(
    column: $table.expenses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get employeeCount => $composableBuilder(
    column: $table.employeeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reputation => $composableBuilder(
    column: $table.reputation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get productPrice => $composableBuilder(
    column: $table.productPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get marketingBudget => $composableBuilder(
    column: $table.marketingBudget,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BusinessesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BusinessesTable> {
  $$BusinessesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saveId =>
      $composableBuilder(column: $table.saveId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get industry =>
      $composableBuilder(column: $table.industry, builder: (column) => column);

  GeneratedColumn<double> get valuation =>
      $composableBuilder(column: $table.valuation, builder: (column) => column);

  GeneratedColumn<double> get revenue =>
      $composableBuilder(column: $table.revenue, builder: (column) => column);

  GeneratedColumn<double> get expenses =>
      $composableBuilder(column: $table.expenses, builder: (column) => column);

  GeneratedColumn<int> get employeeCount => $composableBuilder(
    column: $table.employeeCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reputation => $composableBuilder(
    column: $table.reputation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get productPrice => $composableBuilder(
    column: $table.productPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get marketingBudget => $composableBuilder(
    column: $table.marketingBudget,
    builder: (column) => column,
  );
}

class $$BusinessesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BusinessesTable,
          BusinessesData,
          $$BusinessesTableFilterComposer,
          $$BusinessesTableOrderingComposer,
          $$BusinessesTableAnnotationComposer,
          $$BusinessesTableCreateCompanionBuilder,
          $$BusinessesTableUpdateCompanionBuilder,
          (
            BusinessesData,
            BaseReferences<_$AppDatabase, $BusinessesTable, BusinessesData>,
          ),
          BusinessesData,
          PrefetchHooks Function()
        > {
  $$BusinessesTableTableManager(_$AppDatabase db, $BusinessesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BusinessesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BusinessesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BusinessesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saveId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> industry = const Value.absent(),
                Value<double> valuation = const Value.absent(),
                Value<double> revenue = const Value.absent(),
                Value<double> expenses = const Value.absent(),
                Value<int> employeeCount = const Value.absent(),
                Value<int> reputation = const Value.absent(),
                Value<double> productPrice = const Value.absent(),
                Value<double> marketingBudget = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BusinessesCompanion(
                id: id,
                saveId: saveId,
                name: name,
                industry: industry,
                valuation: valuation,
                revenue: revenue,
                expenses: expenses,
                employeeCount: employeeCount,
                reputation: reputation,
                productPrice: productPrice,
                marketingBudget: marketingBudget,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saveId,
                required String name,
                required String industry,
                required double valuation,
                required double revenue,
                required double expenses,
                required int employeeCount,
                required int reputation,
                required double productPrice,
                required double marketingBudget,
                Value<int> rowid = const Value.absent(),
              }) => BusinessesCompanion.insert(
                id: id,
                saveId: saveId,
                name: name,
                industry: industry,
                valuation: valuation,
                revenue: revenue,
                expenses: expenses,
                employeeCount: employeeCount,
                reputation: reputation,
                productPrice: productPrice,
                marketingBudget: marketingBudget,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BusinessesTable, BusinessesData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BusinessesTable,
                    BusinessesData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BusinessesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BusinessesTable,
      BusinessesData,
      $$BusinessesTableFilterComposer,
      $$BusinessesTableOrderingComposer,
      $$BusinessesTableAnnotationComposer,
      $$BusinessesTableCreateCompanionBuilder,
      $$BusinessesTableUpdateCompanionBuilder,
      (
        BusinessesData,
        BaseReferences<_$AppDatabase, $BusinessesTable, BusinessesData>,
      ),
      BusinessesData,
      PrefetchHooks Function()
    >;
typedef $$LifeLogsTableCreateCompanionBuilder = LifeLogsCompanion Function({
  required String id,
  required String saveId,
  required int age,
  required int year,
  required String category,
  required String textContent,
  required String icon,
  required String accentColor,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$LifeLogsTableUpdateCompanionBuilder = LifeLogsCompanion Function({
  Value<String> id,
  Value<String> saveId,
  Value<int> age,
  Value<int> year,
  Value<String> category,
  Value<String> textContent,
  Value<String> icon,
  Value<String> accentColor,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$LifeLogsTableFilterComposer
    extends Composer<_$AppDatabase, $LifeLogsTable> {
  $$LifeLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $LifeLogsTable> {
  $$LifeLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saveId => $composableBuilder(
    column: $table.saveId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LifeLogsTable> {
  $$LifeLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saveId =>
      $composableBuilder(column: $table.saveId, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LifeLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LifeLogsTable,
          LifeLog,
          $$LifeLogsTableFilterComposer,
          $$LifeLogsTableOrderingComposer,
          $$LifeLogsTableAnnotationComposer,
          $$LifeLogsTableCreateCompanionBuilder,
          $$LifeLogsTableUpdateCompanionBuilder,
          (LifeLog, BaseReferences<_$AppDatabase, $LifeLogsTable, LifeLog>),
          LifeLog,
          PrefetchHooks Function()
        > {
  $$LifeLogsTableTableManager(_$AppDatabase db, $LifeLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LifeLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LifeLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saveId = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> accentColor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeLogsCompanion(
                id: id,
                saveId: saveId,
                age: age,
                year: year,
                category: category,
                textContent: textContent,
                icon: icon,
                accentColor: accentColor,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saveId,
                required int age,
                required int year,
                required String category,
                required String textContent,
                required String icon,
                required String accentColor,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LifeLogsCompanion.insert(
                id: id,
                saveId: saveId,
                age: age,
                year: year,
                category: category,
                textContent: textContent,
                icon: icon,
                accentColor: accentColor,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LifeLogsTable, LifeLog>(table),
                  BaseReferences<_$AppDatabase, $LifeLogsTable, LifeLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LifeLogsTable,
      LifeLog,
      $$LifeLogsTableFilterComposer,
      $$LifeLogsTableOrderingComposer,
      $$LifeLogsTableAnnotationComposer,
      $$LifeLogsTableCreateCompanionBuilder,
      $$LifeLogsTableUpdateCompanionBuilder,
      (LifeLog, BaseReferences<_$AppDatabase, $LifeLogsTable, LifeLog>),
      LifeLog,
      PrefetchHooks Function()
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      required String id,
      required String code,
      required String title,
      required String description,
      required String icon,
      Value<DateTime?> unlockedAt,
      Value<int> rowid,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> title,
      Value<String> description,
      Value<String> icon,
      Value<DateTime?> unlockedAt,
      Value<int> rowid,
    });

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTable,
          Achievement,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (
            Achievement,
            BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
          ),
          Achievement,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion(
                id: id,
                code: code,
                title: title,
                description: description,
                icon: icon,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String title,
                required String description,
                required String icon,
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion.insert(
                id: id,
                code: code,
                title: title,
                description: description,
                icon: icon,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AchievementsTable, Achievement>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AchievementsTable,
                    Achievement
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTable,
      Achievement,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (
        Achievement,
        BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
      ),
      Achievement,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GameSavesTableTableManager get gameSaves =>
      $$GameSavesTableTableManager(_db, _db.gameSaves);
  $$CharactersTableTableManager get characters =>
      $$CharactersTableTableManager(_db, _db.characters);
  $$NpcsTableTableManager get npcs => $$NpcsTableTableManager(_db, _db.npcs);
  $$EducationHistoriesTableTableManager get educationHistories =>
      $$EducationHistoriesTableTableManager(_db, _db.educationHistories);
  $$CareerHistoriesTableTableManager get careerHistories =>
      $$CareerHistoriesTableTableManager(_db, _db.careerHistories);
  $$PropertiesTableTableManager get properties =>
      $$PropertiesTableTableManager(_db, _db.properties);
  $$InvestmentsTableTableManager get investments =>
      $$InvestmentsTableTableManager(_db, _db.investments);
  $$BusinessesTableTableManager get businesses =>
      $$BusinessesTableTableManager(_db, _db.businesses);
  $$LifeLogsTableTableManager get lifeLogs =>
      $$LifeLogsTableTableManager(_db, _db.lifeLogs);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
}
