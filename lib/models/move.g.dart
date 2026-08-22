// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Move _$MoveFromJson(Map<String, dynamic> json) => _Move(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  accuracy: (json['accuracy'] as num?)?.toInt(),
  power: (json['power'] as num?)?.toInt(),
  pp: (json['pp'] as num).toInt(),
  type: MoveType.fromJson(json['type'] as Map<String, dynamic>),
  damageClass: json['damage_class'] == null
      ? null
      : MoveDamageClass.fromJson(json['damage_class'] as Map<String, dynamic>),
  effectEntries: (json['effect_entries'] as List<dynamic>)
      .map((e) => MoveEffectEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MoveToJson(_Move instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'accuracy': instance.accuracy,
  'power': instance.power,
  'pp': instance.pp,
  'type': instance.type,
  'damage_class': instance.damageClass,
  'effect_entries': instance.effectEntries,
};

_MoveDamageClass _$MoveDamageClassFromJson(Map<String, dynamic> json) =>
    _MoveDamageClass(name: json['name'] as String, url: json['url'] as String);

Map<String, dynamic> _$MoveDamageClassToJson(_MoveDamageClass instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};

_MoveType _$MoveTypeFromJson(Map<String, dynamic> json) =>
    _MoveType(name: json['name'] as String, url: json['url'] as String);

Map<String, dynamic> _$MoveTypeToJson(_MoveType instance) => <String, dynamic>{
  'name': instance.name,
  'url': instance.url,
};

_MoveEffectEntry _$MoveEffectEntryFromJson(Map<String, dynamic> json) =>
    _MoveEffectEntry(
      effect: json['effect'] as String,
      shortEffect: json['short_effect'] as String,
    );

Map<String, dynamic> _$MoveEffectEntryToJson(_MoveEffectEntry instance) =>
    <String, dynamic>{
      'effect': instance.effect,
      'short_effect': instance.shortEffect,
    };
