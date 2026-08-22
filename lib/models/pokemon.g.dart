// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pokemon _$PokemonFromJson(Map<String, dynamic> json) => _Pokemon(
  id: (json['id'] as num).toInt(),
  speciesId: (json['speciesId'] as num).toInt(),
  name: json['name'] as String,
  height: (json['height'] as num).toInt(),
  weight: (json['weight'] as num).toInt(),
  baseExperience: (json['base_experience'] as num?)?.toInt(),
  types: (json['types'] as List<dynamic>)
      .map((e) => PokemonTypeSlot.fromJson(e as Map<String, dynamic>))
      .toList(),
  stats: (json['stats'] as List<dynamic>)
      .map((e) => PokemonStatSlot.fromJson(e as Map<String, dynamic>))
      .toList(),
  abilities: (json['abilities'] as List<dynamic>)
      .map((e) => PokemonAbilitySlot.fromJson(e as Map<String, dynamic>))
      .toList(),
  moves: (json['moves'] as List<dynamic>)
      .map((e) => PokemonMoveSlot.fromJson(e as Map<String, dynamic>))
      .toList(),
  forms: json['forms'] as String?,
  evolutionInfo: json['evolutionInfo'] as String?,
);

Map<String, dynamic> _$PokemonToJson(_Pokemon instance) => <String, dynamic>{
  'id': instance.id,
  'speciesId': instance.speciesId,
  'name': instance.name,
  'height': instance.height,
  'weight': instance.weight,
  'base_experience': instance.baseExperience,
  'types': instance.types,
  'stats': instance.stats,
  'abilities': instance.abilities,
  'moves': instance.moves,
  'forms': instance.forms,
  'evolutionInfo': instance.evolutionInfo,
};

_PokemonTypeSlot _$PokemonTypeSlotFromJson(Map<String, dynamic> json) =>
    _PokemonTypeSlot(
      slot: (json['slot'] as num).toInt(),
      type: PokemonType.fromJson(json['type'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PokemonTypeSlotToJson(_PokemonTypeSlot instance) =>
    <String, dynamic>{'slot': instance.slot, 'type': instance.type};

_PokemonType _$PokemonTypeFromJson(Map<String, dynamic> json) =>
    _PokemonType(name: json['name'] as String, url: json['url'] as String);

Map<String, dynamic> _$PokemonTypeToJson(_PokemonType instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};

_PokemonStatSlot _$PokemonStatSlotFromJson(Map<String, dynamic> json) =>
    _PokemonStatSlot(
      baseStat: (json['base_stat'] as num).toInt(),
      effort: (json['effort'] as num).toInt(),
      stat: PokemonStat.fromJson(json['stat'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PokemonStatSlotToJson(_PokemonStatSlot instance) =>
    <String, dynamic>{
      'base_stat': instance.baseStat,
      'effort': instance.effort,
      'stat': instance.stat,
    };

_PokemonStat _$PokemonStatFromJson(Map<String, dynamic> json) =>
    _PokemonStat(name: json['name'] as String, url: json['url'] as String);

Map<String, dynamic> _$PokemonStatToJson(_PokemonStat instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};

_PokemonAbilitySlot _$PokemonAbilitySlotFromJson(Map<String, dynamic> json) =>
    _PokemonAbilitySlot(
      isHidden: json['is_hidden'] as bool,
      slot: (json['slot'] as num).toInt(),
      ability: PokemonAbilityInfo.fromJson(
        json['ability'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$PokemonAbilitySlotToJson(_PokemonAbilitySlot instance) =>
    <String, dynamic>{
      'is_hidden': instance.isHidden,
      'slot': instance.slot,
      'ability': instance.ability,
    };

_PokemonAbilityInfo _$PokemonAbilityInfoFromJson(Map<String, dynamic> json) =>
    _PokemonAbilityInfo(
      name: json['name'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$PokemonAbilityInfoToJson(_PokemonAbilityInfo instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};

_PokemonMoveSlot _$PokemonMoveSlotFromJson(Map<String, dynamic> json) =>
    _PokemonMoveSlot(
      move: PokemonMoveInfo.fromJson(json['move'] as Map<String, dynamic>),
      versionGroupDetails:
          (json['version_group_details'] as List<dynamic>?)
              ?.map(
                (e) => PokemonMoveVersionDetail.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PokemonMoveSlotToJson(_PokemonMoveSlot instance) =>
    <String, dynamic>{
      'move': instance.move,
      'version_group_details': instance.versionGroupDetails,
    };

_PokemonMoveVersionDetail _$PokemonMoveVersionDetailFromJson(
  Map<String, dynamic> json,
) => _PokemonMoveVersionDetail(
  levelLearnedAt: (json['level_learned_at'] as num).toInt(),
  moveLearnMethod: NamedAPIResource.fromJson(
    json['move_learn_method'] as Map<String, dynamic>,
  ),
  versionGroup: json['version_group'] == null
      ? null
      : NamedAPIResource.fromJson(
          json['version_group'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$PokemonMoveVersionDetailToJson(
  _PokemonMoveVersionDetail instance,
) => <String, dynamic>{
  'level_learned_at': instance.levelLearnedAt,
  'move_learn_method': instance.moveLearnMethod,
  'version_group': instance.versionGroup,
};

_NamedAPIResource _$NamedAPIResourceFromJson(Map<String, dynamic> json) =>
    _NamedAPIResource(name: json['name'] as String, url: json['url'] as String);

Map<String, dynamic> _$NamedAPIResourceToJson(_NamedAPIResource instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};

_PokemonMoveInfo _$PokemonMoveInfoFromJson(Map<String, dynamic> json) =>
    _PokemonMoveInfo(name: json['name'] as String, url: json['url'] as String);

Map<String, dynamic> _$PokemonMoveInfoToJson(_PokemonMoveInfo instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};
