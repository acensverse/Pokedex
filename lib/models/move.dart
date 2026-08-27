import 'package:freezed_annotation/freezed_annotation.dart';

part 'move.freezed.dart';
part 'move.g.dart';

@freezed
abstract class Move with _$Move {
  const factory Move({
    required int id,
    required String name,
    int? accuracy,
    int? power,
    required int pp,
    required MoveType type,
    @JsonKey(name: 'damage_class') MoveDamageClass? damageClass,
    @JsonKey(name: 'effect_entries')
    required List<MoveEffectEntry> effectEntries,
  }) = _Move;

  factory Move.fromJson(Map<String, dynamic> json) => _$MoveFromJson(json);
}

@freezed
abstract class MoveDamageClass with _$MoveDamageClass {
  const factory MoveDamageClass({required String name, required String url}) =
      _MoveDamageClass;

  factory MoveDamageClass.fromJson(Map<String, dynamic> json) =>
      _$MoveDamageClassFromJson(json);
}

@freezed
abstract class MoveType with _$MoveType {
  const factory MoveType({required String name, required String url}) =
      _MoveType;

  factory MoveType.fromJson(Map<String, dynamic> json) =>
      _$MoveTypeFromJson(json);
}

@freezed
abstract class MoveEffectEntry with _$MoveEffectEntry {
  const factory MoveEffectEntry({
    required String effect,
    @JsonKey(name: 'short_effect') required String shortEffect,
  }) = _MoveEffectEntry;

  factory MoveEffectEntry.fromJson(Map<String, dynamic> json) =>
      _$MoveEffectEntryFromJson(json);
}
