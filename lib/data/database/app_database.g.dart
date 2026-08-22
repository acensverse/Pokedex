// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PokemonCacheTable extends PokemonCache
    with TableInfo<$PokemonCacheTable, PokemonCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _generationMeta = const VerificationMeta(
    'generation',
  );
  @override
  late final GeneratedColumn<int> generation = GeneratedColumn<int>(
    'generation',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typesMeta = const VerificationMeta('types');
  @override
  late final GeneratedColumn<String> types = GeneratedColumn<String>(
    'types',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hpMeta = const VerificationMeta('hp');
  @override
  late final GeneratedColumn<int> hp = GeneratedColumn<int>(
    'hp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attackMeta = const VerificationMeta('attack');
  @override
  late final GeneratedColumn<int> attack = GeneratedColumn<int>(
    'attack',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defenseMeta = const VerificationMeta(
    'defense',
  );
  @override
  late final GeneratedColumn<int> defense = GeneratedColumn<int>(
    'defense',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spAttackMeta = const VerificationMeta(
    'spAttack',
  );
  @override
  late final GeneratedColumn<int> spAttack = GeneratedColumn<int>(
    'sp_attack',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spDefenseMeta = const VerificationMeta(
    'spDefense',
  );
  @override
  late final GeneratedColumn<int> spDefense = GeneratedColumn<int>(
    'sp_defense',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<int> speed = GeneratedColumn<int>(
    'speed',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _abilitiesMeta = const VerificationMeta(
    'abilities',
  );
  @override
  late final GeneratedColumn<String> abilities = GeneratedColumn<String>(
    'abilities',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formsMeta = const VerificationMeta('forms');
  @override
  late final GeneratedColumn<String> forms = GeneratedColumn<String>(
    'forms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _evolutionInfoMeta = const VerificationMeta(
    'evolutionInfo',
  );
  @override
  late final GeneratedColumn<String> evolutionInfo = GeneratedColumn<String>(
    'evolution_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flavorTextMeta = const VerificationMeta(
    'flavorText',
  );
  @override
  late final GeneratedColumn<String> flavorText = GeneratedColumn<String>(
    'flavor_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _jsonDataMeta = const VerificationMeta(
    'jsonData',
  );
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
    'json_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    speciesId,
    name,
    species,
    generation,
    types,
    hp,
    attack,
    defense,
    spAttack,
    spDefense,
    speed,
    height,
    weight,
    abilities,
    forms,
    evolutionInfo,
    flavorText,
    isFavorite,
    jsonData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    }
    if (data.containsKey('generation')) {
      context.handle(
        _generationMeta,
        generation.isAcceptableOrUnknown(data['generation']!, _generationMeta),
      );
    }
    if (data.containsKey('types')) {
      context.handle(
        _typesMeta,
        types.isAcceptableOrUnknown(data['types']!, _typesMeta),
      );
    } else if (isInserting) {
      context.missing(_typesMeta);
    }
    if (data.containsKey('hp')) {
      context.handle(_hpMeta, hp.isAcceptableOrUnknown(data['hp']!, _hpMeta));
    }
    if (data.containsKey('attack')) {
      context.handle(
        _attackMeta,
        attack.isAcceptableOrUnknown(data['attack']!, _attackMeta),
      );
    }
    if (data.containsKey('defense')) {
      context.handle(
        _defenseMeta,
        defense.isAcceptableOrUnknown(data['defense']!, _defenseMeta),
      );
    }
    if (data.containsKey('sp_attack')) {
      context.handle(
        _spAttackMeta,
        spAttack.isAcceptableOrUnknown(data['sp_attack']!, _spAttackMeta),
      );
    }
    if (data.containsKey('sp_defense')) {
      context.handle(
        _spDefenseMeta,
        spDefense.isAcceptableOrUnknown(data['sp_defense']!, _spDefenseMeta),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('abilities')) {
      context.handle(
        _abilitiesMeta,
        abilities.isAcceptableOrUnknown(data['abilities']!, _abilitiesMeta),
      );
    }
    if (data.containsKey('forms')) {
      context.handle(
        _formsMeta,
        forms.isAcceptableOrUnknown(data['forms']!, _formsMeta),
      );
    }
    if (data.containsKey('evolution_info')) {
      context.handle(
        _evolutionInfoMeta,
        evolutionInfo.isAcceptableOrUnknown(
          data['evolution_info']!,
          _evolutionInfoMeta,
        ),
      );
    }
    if (data.containsKey('flavor_text')) {
      context.handle(
        _flavorTextMeta,
        flavorText.isAcceptableOrUnknown(data['flavor_text']!, _flavorTextMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('json_data')) {
      context.handle(
        _jsonDataMeta,
        jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PokemonCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      ),
      generation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generation'],
      ),
      types: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}types'],
      )!,
      hp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hp'],
      ),
      attack: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attack'],
      ),
      defense: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}defense'],
      ),
      spAttack: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sp_attack'],
      ),
      spDefense: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sp_defense'],
      ),
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speed'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      ),
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      ),
      abilities: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}abilities'],
      ),
      forms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}forms'],
      ),
      evolutionInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evolution_info'],
      ),
      flavorText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flavor_text'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      jsonData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_data'],
      ),
    );
  }

  @override
  $PokemonCacheTable createAlias(String alias) {
    return $PokemonCacheTable(attachedDatabase, alias);
  }
}

class PokemonCacheData extends DataClass
    implements Insertable<PokemonCacheData> {
  final int id;
  final int? speciesId;
  final String name;
  final String? species;
  final int? generation;
  final String types;
  final int? hp;
  final int? attack;
  final int? defense;
  final int? spAttack;
  final int? spDefense;
  final int? speed;
  final double? height;
  final double? weight;
  final String? abilities;
  final String? forms;
  final String? evolutionInfo;
  final String? flavorText;
  final bool isFavorite;
  final String? jsonData;
  const PokemonCacheData({
    required this.id,
    this.speciesId,
    required this.name,
    this.species,
    this.generation,
    required this.types,
    this.hp,
    this.attack,
    this.defense,
    this.spAttack,
    this.spDefense,
    this.speed,
    this.height,
    this.weight,
    this.abilities,
    this.forms,
    this.evolutionInfo,
    this.flavorText,
    required this.isFavorite,
    this.jsonData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || speciesId != null) {
      map['species_id'] = Variable<int>(speciesId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || species != null) {
      map['species'] = Variable<String>(species);
    }
    if (!nullToAbsent || generation != null) {
      map['generation'] = Variable<int>(generation);
    }
    map['types'] = Variable<String>(types);
    if (!nullToAbsent || hp != null) {
      map['hp'] = Variable<int>(hp);
    }
    if (!nullToAbsent || attack != null) {
      map['attack'] = Variable<int>(attack);
    }
    if (!nullToAbsent || defense != null) {
      map['defense'] = Variable<int>(defense);
    }
    if (!nullToAbsent || spAttack != null) {
      map['sp_attack'] = Variable<int>(spAttack);
    }
    if (!nullToAbsent || spDefense != null) {
      map['sp_defense'] = Variable<int>(spDefense);
    }
    if (!nullToAbsent || speed != null) {
      map['speed'] = Variable<int>(speed);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<double>(height);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    if (!nullToAbsent || abilities != null) {
      map['abilities'] = Variable<String>(abilities);
    }
    if (!nullToAbsent || forms != null) {
      map['forms'] = Variable<String>(forms);
    }
    if (!nullToAbsent || evolutionInfo != null) {
      map['evolution_info'] = Variable<String>(evolutionInfo);
    }
    if (!nullToAbsent || flavorText != null) {
      map['flavor_text'] = Variable<String>(flavorText);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || jsonData != null) {
      map['json_data'] = Variable<String>(jsonData);
    }
    return map;
  }

  PokemonCacheCompanion toCompanion(bool nullToAbsent) {
    return PokemonCacheCompanion(
      id: Value(id),
      speciesId: speciesId == null && nullToAbsent
          ? const Value.absent()
          : Value(speciesId),
      name: Value(name),
      species: species == null && nullToAbsent
          ? const Value.absent()
          : Value(species),
      generation: generation == null && nullToAbsent
          ? const Value.absent()
          : Value(generation),
      types: Value(types),
      hp: hp == null && nullToAbsent ? const Value.absent() : Value(hp),
      attack: attack == null && nullToAbsent
          ? const Value.absent()
          : Value(attack),
      defense: defense == null && nullToAbsent
          ? const Value.absent()
          : Value(defense),
      spAttack: spAttack == null && nullToAbsent
          ? const Value.absent()
          : Value(spAttack),
      spDefense: spDefense == null && nullToAbsent
          ? const Value.absent()
          : Value(spDefense),
      speed: speed == null && nullToAbsent
          ? const Value.absent()
          : Value(speed),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      weight: weight == null && nullToAbsent
          ? const Value.absent()
          : Value(weight),
      abilities: abilities == null && nullToAbsent
          ? const Value.absent()
          : Value(abilities),
      forms: forms == null && nullToAbsent
          ? const Value.absent()
          : Value(forms),
      evolutionInfo: evolutionInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(evolutionInfo),
      flavorText: flavorText == null && nullToAbsent
          ? const Value.absent()
          : Value(flavorText),
      isFavorite: Value(isFavorite),
      jsonData: jsonData == null && nullToAbsent
          ? const Value.absent()
          : Value(jsonData),
    );
  }

  factory PokemonCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonCacheData(
      id: serializer.fromJson<int>(json['id']),
      speciesId: serializer.fromJson<int?>(json['speciesId']),
      name: serializer.fromJson<String>(json['name']),
      species: serializer.fromJson<String?>(json['species']),
      generation: serializer.fromJson<int?>(json['generation']),
      types: serializer.fromJson<String>(json['types']),
      hp: serializer.fromJson<int?>(json['hp']),
      attack: serializer.fromJson<int?>(json['attack']),
      defense: serializer.fromJson<int?>(json['defense']),
      spAttack: serializer.fromJson<int?>(json['spAttack']),
      spDefense: serializer.fromJson<int?>(json['spDefense']),
      speed: serializer.fromJson<int?>(json['speed']),
      height: serializer.fromJson<double?>(json['height']),
      weight: serializer.fromJson<double?>(json['weight']),
      abilities: serializer.fromJson<String?>(json['abilities']),
      forms: serializer.fromJson<String?>(json['forms']),
      evolutionInfo: serializer.fromJson<String?>(json['evolutionInfo']),
      flavorText: serializer.fromJson<String?>(json['flavorText']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      jsonData: serializer.fromJson<String?>(json['jsonData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'speciesId': serializer.toJson<int?>(speciesId),
      'name': serializer.toJson<String>(name),
      'species': serializer.toJson<String?>(species),
      'generation': serializer.toJson<int?>(generation),
      'types': serializer.toJson<String>(types),
      'hp': serializer.toJson<int?>(hp),
      'attack': serializer.toJson<int?>(attack),
      'defense': serializer.toJson<int?>(defense),
      'spAttack': serializer.toJson<int?>(spAttack),
      'spDefense': serializer.toJson<int?>(spDefense),
      'speed': serializer.toJson<int?>(speed),
      'height': serializer.toJson<double?>(height),
      'weight': serializer.toJson<double?>(weight),
      'abilities': serializer.toJson<String?>(abilities),
      'forms': serializer.toJson<String?>(forms),
      'evolutionInfo': serializer.toJson<String?>(evolutionInfo),
      'flavorText': serializer.toJson<String?>(flavorText),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'jsonData': serializer.toJson<String?>(jsonData),
    };
  }

  PokemonCacheData copyWith({
    int? id,
    Value<int?> speciesId = const Value.absent(),
    String? name,
    Value<String?> species = const Value.absent(),
    Value<int?> generation = const Value.absent(),
    String? types,
    Value<int?> hp = const Value.absent(),
    Value<int?> attack = const Value.absent(),
    Value<int?> defense = const Value.absent(),
    Value<int?> spAttack = const Value.absent(),
    Value<int?> spDefense = const Value.absent(),
    Value<int?> speed = const Value.absent(),
    Value<double?> height = const Value.absent(),
    Value<double?> weight = const Value.absent(),
    Value<String?> abilities = const Value.absent(),
    Value<String?> forms = const Value.absent(),
    Value<String?> evolutionInfo = const Value.absent(),
    Value<String?> flavorText = const Value.absent(),
    bool? isFavorite,
    Value<String?> jsonData = const Value.absent(),
  }) => PokemonCacheData(
    id: id ?? this.id,
    speciesId: speciesId.present ? speciesId.value : this.speciesId,
    name: name ?? this.name,
    species: species.present ? species.value : this.species,
    generation: generation.present ? generation.value : this.generation,
    types: types ?? this.types,
    hp: hp.present ? hp.value : this.hp,
    attack: attack.present ? attack.value : this.attack,
    defense: defense.present ? defense.value : this.defense,
    spAttack: spAttack.present ? spAttack.value : this.spAttack,
    spDefense: spDefense.present ? spDefense.value : this.spDefense,
    speed: speed.present ? speed.value : this.speed,
    height: height.present ? height.value : this.height,
    weight: weight.present ? weight.value : this.weight,
    abilities: abilities.present ? abilities.value : this.abilities,
    forms: forms.present ? forms.value : this.forms,
    evolutionInfo: evolutionInfo.present
        ? evolutionInfo.value
        : this.evolutionInfo,
    flavorText: flavorText.present ? flavorText.value : this.flavorText,
    isFavorite: isFavorite ?? this.isFavorite,
    jsonData: jsonData.present ? jsonData.value : this.jsonData,
  );
  PokemonCacheData copyWithCompanion(PokemonCacheCompanion data) {
    return PokemonCacheData(
      id: data.id.present ? data.id.value : this.id,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      name: data.name.present ? data.name.value : this.name,
      species: data.species.present ? data.species.value : this.species,
      generation: data.generation.present
          ? data.generation.value
          : this.generation,
      types: data.types.present ? data.types.value : this.types,
      hp: data.hp.present ? data.hp.value : this.hp,
      attack: data.attack.present ? data.attack.value : this.attack,
      defense: data.defense.present ? data.defense.value : this.defense,
      spAttack: data.spAttack.present ? data.spAttack.value : this.spAttack,
      spDefense: data.spDefense.present ? data.spDefense.value : this.spDefense,
      speed: data.speed.present ? data.speed.value : this.speed,
      height: data.height.present ? data.height.value : this.height,
      weight: data.weight.present ? data.weight.value : this.weight,
      abilities: data.abilities.present ? data.abilities.value : this.abilities,
      forms: data.forms.present ? data.forms.value : this.forms,
      evolutionInfo: data.evolutionInfo.present
          ? data.evolutionInfo.value
          : this.evolutionInfo,
      flavorText: data.flavorText.present
          ? data.flavorText.value
          : this.flavorText,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      jsonData: data.jsonData.present ? data.jsonData.value : this.jsonData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonCacheData(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('generation: $generation, ')
          ..write('types: $types, ')
          ..write('hp: $hp, ')
          ..write('attack: $attack, ')
          ..write('defense: $defense, ')
          ..write('spAttack: $spAttack, ')
          ..write('spDefense: $spDefense, ')
          ..write('speed: $speed, ')
          ..write('height: $height, ')
          ..write('weight: $weight, ')
          ..write('abilities: $abilities, ')
          ..write('forms: $forms, ')
          ..write('evolutionInfo: $evolutionInfo, ')
          ..write('flavorText: $flavorText, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('jsonData: $jsonData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    speciesId,
    name,
    species,
    generation,
    types,
    hp,
    attack,
    defense,
    spAttack,
    spDefense,
    speed,
    height,
    weight,
    abilities,
    forms,
    evolutionInfo,
    flavorText,
    isFavorite,
    jsonData,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonCacheData &&
          other.id == this.id &&
          other.speciesId == this.speciesId &&
          other.name == this.name &&
          other.species == this.species &&
          other.generation == this.generation &&
          other.types == this.types &&
          other.hp == this.hp &&
          other.attack == this.attack &&
          other.defense == this.defense &&
          other.spAttack == this.spAttack &&
          other.spDefense == this.spDefense &&
          other.speed == this.speed &&
          other.height == this.height &&
          other.weight == this.weight &&
          other.abilities == this.abilities &&
          other.forms == this.forms &&
          other.evolutionInfo == this.evolutionInfo &&
          other.flavorText == this.flavorText &&
          other.isFavorite == this.isFavorite &&
          other.jsonData == this.jsonData);
}

class PokemonCacheCompanion extends UpdateCompanion<PokemonCacheData> {
  final Value<int> id;
  final Value<int?> speciesId;
  final Value<String> name;
  final Value<String?> species;
  final Value<int?> generation;
  final Value<String> types;
  final Value<int?> hp;
  final Value<int?> attack;
  final Value<int?> defense;
  final Value<int?> spAttack;
  final Value<int?> spDefense;
  final Value<int?> speed;
  final Value<double?> height;
  final Value<double?> weight;
  final Value<String?> abilities;
  final Value<String?> forms;
  final Value<String?> evolutionInfo;
  final Value<String?> flavorText;
  final Value<bool> isFavorite;
  final Value<String?> jsonData;
  const PokemonCacheCompanion({
    this.id = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.name = const Value.absent(),
    this.species = const Value.absent(),
    this.generation = const Value.absent(),
    this.types = const Value.absent(),
    this.hp = const Value.absent(),
    this.attack = const Value.absent(),
    this.defense = const Value.absent(),
    this.spAttack = const Value.absent(),
    this.spDefense = const Value.absent(),
    this.speed = const Value.absent(),
    this.height = const Value.absent(),
    this.weight = const Value.absent(),
    this.abilities = const Value.absent(),
    this.forms = const Value.absent(),
    this.evolutionInfo = const Value.absent(),
    this.flavorText = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.jsonData = const Value.absent(),
  });
  PokemonCacheCompanion.insert({
    this.id = const Value.absent(),
    this.speciesId = const Value.absent(),
    required String name,
    this.species = const Value.absent(),
    this.generation = const Value.absent(),
    required String types,
    this.hp = const Value.absent(),
    this.attack = const Value.absent(),
    this.defense = const Value.absent(),
    this.spAttack = const Value.absent(),
    this.spDefense = const Value.absent(),
    this.speed = const Value.absent(),
    this.height = const Value.absent(),
    this.weight = const Value.absent(),
    this.abilities = const Value.absent(),
    this.forms = const Value.absent(),
    this.evolutionInfo = const Value.absent(),
    this.flavorText = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.jsonData = const Value.absent(),
  }) : name = Value(name),
       types = Value(types);
  static Insertable<PokemonCacheData> custom({
    Expression<int>? id,
    Expression<int>? speciesId,
    Expression<String>? name,
    Expression<String>? species,
    Expression<int>? generation,
    Expression<String>? types,
    Expression<int>? hp,
    Expression<int>? attack,
    Expression<int>? defense,
    Expression<int>? spAttack,
    Expression<int>? spDefense,
    Expression<int>? speed,
    Expression<double>? height,
    Expression<double>? weight,
    Expression<String>? abilities,
    Expression<String>? forms,
    Expression<String>? evolutionInfo,
    Expression<String>? flavorText,
    Expression<bool>? isFavorite,
    Expression<String>? jsonData,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (speciesId != null) 'species_id': speciesId,
      if (name != null) 'name': name,
      if (species != null) 'species': species,
      if (generation != null) 'generation': generation,
      if (types != null) 'types': types,
      if (hp != null) 'hp': hp,
      if (attack != null) 'attack': attack,
      if (defense != null) 'defense': defense,
      if (spAttack != null) 'sp_attack': spAttack,
      if (spDefense != null) 'sp_defense': spDefense,
      if (speed != null) 'speed': speed,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (abilities != null) 'abilities': abilities,
      if (forms != null) 'forms': forms,
      if (evolutionInfo != null) 'evolution_info': evolutionInfo,
      if (flavorText != null) 'flavor_text': flavorText,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (jsonData != null) 'json_data': jsonData,
    });
  }

  PokemonCacheCompanion copyWith({
    Value<int>? id,
    Value<int?>? speciesId,
    Value<String>? name,
    Value<String?>? species,
    Value<int?>? generation,
    Value<String>? types,
    Value<int?>? hp,
    Value<int?>? attack,
    Value<int?>? defense,
    Value<int?>? spAttack,
    Value<int?>? spDefense,
    Value<int?>? speed,
    Value<double?>? height,
    Value<double?>? weight,
    Value<String?>? abilities,
    Value<String?>? forms,
    Value<String?>? evolutionInfo,
    Value<String?>? flavorText,
    Value<bool>? isFavorite,
    Value<String?>? jsonData,
  }) {
    return PokemonCacheCompanion(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      name: name ?? this.name,
      species: species ?? this.species,
      generation: generation ?? this.generation,
      types: types ?? this.types,
      hp: hp ?? this.hp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      spAttack: spAttack ?? this.spAttack,
      spDefense: spDefense ?? this.spDefense,
      speed: speed ?? this.speed,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      abilities: abilities ?? this.abilities,
      forms: forms ?? this.forms,
      evolutionInfo: evolutionInfo ?? this.evolutionInfo,
      flavorText: flavorText ?? this.flavorText,
      isFavorite: isFavorite ?? this.isFavorite,
      jsonData: jsonData ?? this.jsonData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (generation.present) {
      map['generation'] = Variable<int>(generation.value);
    }
    if (types.present) {
      map['types'] = Variable<String>(types.value);
    }
    if (hp.present) {
      map['hp'] = Variable<int>(hp.value);
    }
    if (attack.present) {
      map['attack'] = Variable<int>(attack.value);
    }
    if (defense.present) {
      map['defense'] = Variable<int>(defense.value);
    }
    if (spAttack.present) {
      map['sp_attack'] = Variable<int>(spAttack.value);
    }
    if (spDefense.present) {
      map['sp_defense'] = Variable<int>(spDefense.value);
    }
    if (speed.present) {
      map['speed'] = Variable<int>(speed.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (abilities.present) {
      map['abilities'] = Variable<String>(abilities.value);
    }
    if (forms.present) {
      map['forms'] = Variable<String>(forms.value);
    }
    if (evolutionInfo.present) {
      map['evolution_info'] = Variable<String>(evolutionInfo.value);
    }
    if (flavorText.present) {
      map['flavor_text'] = Variable<String>(flavorText.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (jsonData.present) {
      map['json_data'] = Variable<String>(jsonData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonCacheCompanion(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('generation: $generation, ')
          ..write('types: $types, ')
          ..write('hp: $hp, ')
          ..write('attack: $attack, ')
          ..write('defense: $defense, ')
          ..write('spAttack: $spAttack, ')
          ..write('spDefense: $spDefense, ')
          ..write('speed: $speed, ')
          ..write('height: $height, ')
          ..write('weight: $weight, ')
          ..write('abilities: $abilities, ')
          ..write('forms: $forms, ')
          ..write('evolutionInfo: $evolutionInfo, ')
          ..write('flavorText: $flavorText, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('jsonData: $jsonData')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PokemonCacheTable pokemonCache = $PokemonCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [pokemonCache];
}

typedef $$PokemonCacheTableCreateCompanionBuilder =
    PokemonCacheCompanion Function({
      Value<int> id,
      Value<int?> speciesId,
      required String name,
      Value<String?> species,
      Value<int?> generation,
      required String types,
      Value<int?> hp,
      Value<int?> attack,
      Value<int?> defense,
      Value<int?> spAttack,
      Value<int?> spDefense,
      Value<int?> speed,
      Value<double?> height,
      Value<double?> weight,
      Value<String?> abilities,
      Value<String?> forms,
      Value<String?> evolutionInfo,
      Value<String?> flavorText,
      Value<bool> isFavorite,
      Value<String?> jsonData,
    });
typedef $$PokemonCacheTableUpdateCompanionBuilder =
    PokemonCacheCompanion Function({
      Value<int> id,
      Value<int?> speciesId,
      Value<String> name,
      Value<String?> species,
      Value<int?> generation,
      Value<String> types,
      Value<int?> hp,
      Value<int?> attack,
      Value<int?> defense,
      Value<int?> spAttack,
      Value<int?> spDefense,
      Value<int?> speed,
      Value<double?> height,
      Value<double?> weight,
      Value<String?> abilities,
      Value<String?> forms,
      Value<String?> evolutionInfo,
      Value<String?> flavorText,
      Value<bool> isFavorite,
      Value<String?> jsonData,
    });

class $$PokemonCacheTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonCacheTable> {
  $$PokemonCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get types => $composableBuilder(
    column: $table.types,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hp => $composableBuilder(
    column: $table.hp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attack => $composableBuilder(
    column: $table.attack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defense => $composableBuilder(
    column: $table.defense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spAttack => $composableBuilder(
    column: $table.spAttack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spDefense => $composableBuilder(
    column: $table.spDefense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get abilities => $composableBuilder(
    column: $table.abilities,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get forms => $composableBuilder(
    column: $table.forms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evolutionInfo => $composableBuilder(
    column: $table.evolutionInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flavorText => $composableBuilder(
    column: $table.flavorText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PokemonCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonCacheTable> {
  $$PokemonCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get types => $composableBuilder(
    column: $table.types,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hp => $composableBuilder(
    column: $table.hp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attack => $composableBuilder(
    column: $table.attack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defense => $composableBuilder(
    column: $table.defense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spAttack => $composableBuilder(
    column: $table.spAttack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spDefense => $composableBuilder(
    column: $table.spDefense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abilities => $composableBuilder(
    column: $table.abilities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forms => $composableBuilder(
    column: $table.forms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evolutionInfo => $composableBuilder(
    column: $table.evolutionInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flavorText => $composableBuilder(
    column: $table.flavorText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PokemonCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonCacheTable> {
  $$PokemonCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get types =>
      $composableBuilder(column: $table.types, builder: (column) => column);

  GeneratedColumn<int> get hp =>
      $composableBuilder(column: $table.hp, builder: (column) => column);

  GeneratedColumn<int> get attack =>
      $composableBuilder(column: $table.attack, builder: (column) => column);

  GeneratedColumn<int> get defense =>
      $composableBuilder(column: $table.defense, builder: (column) => column);

  GeneratedColumn<int> get spAttack =>
      $composableBuilder(column: $table.spAttack, builder: (column) => column);

  GeneratedColumn<int> get spDefense =>
      $composableBuilder(column: $table.spDefense, builder: (column) => column);

  GeneratedColumn<int> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get abilities =>
      $composableBuilder(column: $table.abilities, builder: (column) => column);

  GeneratedColumn<String> get forms =>
      $composableBuilder(column: $table.forms, builder: (column) => column);

  GeneratedColumn<String> get evolutionInfo => $composableBuilder(
    column: $table.evolutionInfo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flavorText => $composableBuilder(
    column: $table.flavorText,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jsonData =>
      $composableBuilder(column: $table.jsonData, builder: (column) => column);
}

class $$PokemonCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokemonCacheTable,
          PokemonCacheData,
          $$PokemonCacheTableFilterComposer,
          $$PokemonCacheTableOrderingComposer,
          $$PokemonCacheTableAnnotationComposer,
          $$PokemonCacheTableCreateCompanionBuilder,
          $$PokemonCacheTableUpdateCompanionBuilder,
          (
            PokemonCacheData,
            BaseReferences<_$AppDatabase, $PokemonCacheTable, PokemonCacheData>,
          ),
          PokemonCacheData,
          PrefetchHooks Function()
        > {
  $$PokemonCacheTableTableManager(_$AppDatabase db, $PokemonCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PokemonCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PokemonCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> speciesId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> species = const Value.absent(),
                Value<int?> generation = const Value.absent(),
                Value<String> types = const Value.absent(),
                Value<int?> hp = const Value.absent(),
                Value<int?> attack = const Value.absent(),
                Value<int?> defense = const Value.absent(),
                Value<int?> spAttack = const Value.absent(),
                Value<int?> spDefense = const Value.absent(),
                Value<int?> speed = const Value.absent(),
                Value<double?> height = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<String?> abilities = const Value.absent(),
                Value<String?> forms = const Value.absent(),
                Value<String?> evolutionInfo = const Value.absent(),
                Value<String?> flavorText = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> jsonData = const Value.absent(),
              }) => PokemonCacheCompanion(
                id: id,
                speciesId: speciesId,
                name: name,
                species: species,
                generation: generation,
                types: types,
                hp: hp,
                attack: attack,
                defense: defense,
                spAttack: spAttack,
                spDefense: spDefense,
                speed: speed,
                height: height,
                weight: weight,
                abilities: abilities,
                forms: forms,
                evolutionInfo: evolutionInfo,
                flavorText: flavorText,
                isFavorite: isFavorite,
                jsonData: jsonData,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> speciesId = const Value.absent(),
                required String name,
                Value<String?> species = const Value.absent(),
                Value<int?> generation = const Value.absent(),
                required String types,
                Value<int?> hp = const Value.absent(),
                Value<int?> attack = const Value.absent(),
                Value<int?> defense = const Value.absent(),
                Value<int?> spAttack = const Value.absent(),
                Value<int?> spDefense = const Value.absent(),
                Value<int?> speed = const Value.absent(),
                Value<double?> height = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<String?> abilities = const Value.absent(),
                Value<String?> forms = const Value.absent(),
                Value<String?> evolutionInfo = const Value.absent(),
                Value<String?> flavorText = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> jsonData = const Value.absent(),
              }) => PokemonCacheCompanion.insert(
                id: id,
                speciesId: speciesId,
                name: name,
                species: species,
                generation: generation,
                types: types,
                hp: hp,
                attack: attack,
                defense: defense,
                spAttack: spAttack,
                spDefense: spDefense,
                speed: speed,
                height: height,
                weight: weight,
                abilities: abilities,
                forms: forms,
                evolutionInfo: evolutionInfo,
                flavorText: flavorText,
                isFavorite: isFavorite,
                jsonData: jsonData,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PokemonCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokemonCacheTable,
      PokemonCacheData,
      $$PokemonCacheTableFilterComposer,
      $$PokemonCacheTableOrderingComposer,
      $$PokemonCacheTableAnnotationComposer,
      $$PokemonCacheTableCreateCompanionBuilder,
      $$PokemonCacheTableUpdateCompanionBuilder,
      (
        PokemonCacheData,
        BaseReferences<_$AppDatabase, $PokemonCacheTable, PokemonCacheData>,
      ),
      PokemonCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PokemonCacheTableTableManager get pokemonCache =>
      $$PokemonCacheTableTableManager(_db, _db.pokemonCache);
}
