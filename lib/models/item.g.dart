// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Item _$ItemFromJson(Map<String, dynamic> json) => _Item(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  cost: (json['cost'] as num).toInt(),
  effectEntries: (json['effect_entries'] as List<dynamic>)
      .map((e) => ItemEffectEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  sprites: ItemSprites.fromJson(json['sprites'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ItemToJson(_Item instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'cost': instance.cost,
  'effect_entries': instance.effectEntries,
  'sprites': instance.sprites,
};

_ItemEffectEntry _$ItemEffectEntryFromJson(Map<String, dynamic> json) =>
    _ItemEffectEntry(
      effect: json['effect'] as String,
      shortEffect: json['short_effect'] as String,
    );

Map<String, dynamic> _$ItemEffectEntryToJson(_ItemEffectEntry instance) =>
    <String, dynamic>{
      'effect': instance.effect,
      'short_effect': instance.shortEffect,
    };

_ItemSprites _$ItemSpritesFromJson(Map<String, dynamic> json) =>
    _ItemSprites(defaultSprite: json['defaultSprite'] as String);

Map<String, dynamic> _$ItemSpritesToJson(_ItemSprites instance) =>
    <String, dynamic>{'defaultSprite': instance.defaultSprite};
