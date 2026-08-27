import 'package:freezed_annotation/freezed_annotation.dart';

part 'ability.freezed.dart';
part 'ability.g.dart';

@freezed
abstract class Ability with _$Ability {
  const factory Ability({
    required int id,
    required String name,
    @JsonKey(name: 'effect_entries')
    required List<AbilityEffectEntry> effectEntries,
  }) = _Ability;

  factory Ability.fromJson(Map<String, dynamic> json) =>
      _$AbilityFromJson(json);
}

@freezed
abstract class AbilityEffectEntry with _$AbilityEffectEntry {
  const factory AbilityEffectEntry({
    required String effect,
    @JsonKey(name: 'short_effect') required String shortEffect,
  }) = _AbilityEffectEntry;

  factory AbilityEffectEntry.fromJson(Map<String, dynamic> json) =>
      _$AbilityEffectEntryFromJson(json);
}
