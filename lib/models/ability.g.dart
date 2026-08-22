// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Ability _$AbilityFromJson(Map<String, dynamic> json) => _Ability(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  effectEntries: (json['effect_entries'] as List<dynamic>)
      .map((e) => AbilityEffectEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AbilityToJson(_Ability instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'effect_entries': instance.effectEntries,
};

_AbilityEffectEntry _$AbilityEffectEntryFromJson(Map<String, dynamic> json) =>
    _AbilityEffectEntry(
      effect: json['effect'] as String,
      shortEffect: json['short_effect'] as String,
    );

Map<String, dynamic> _$AbilityEffectEntryToJson(_AbilityEffectEntry instance) =>
    <String, dynamic>{
      'effect': instance.effect,
      'short_effect': instance.shortEffect,
    };
