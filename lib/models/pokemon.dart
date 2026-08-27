import 'package:freezed_annotation/freezed_annotation.dart';

part 'pokemon.freezed.dart';
part 'pokemon.g.dart';

@freezed
abstract class Pokemon with _$Pokemon {
  const factory Pokemon({
    required int id,
    required int speciesId,
    required String name,
    required int height,
    required int weight,
    @JsonKey(name: 'base_experience') int? baseExperience,
    required List<PokemonTypeSlot> types,
    required List<PokemonStatSlot> stats,
    required List<PokemonAbilitySlot> abilities,
    required List<PokemonMoveSlot> moves,
    String? forms,
    String? evolutionInfo,
  }) = _Pokemon;

  factory Pokemon.fromJson(Map<String, dynamic> json) =>
      _$PokemonFromJson(json);
}

@freezed
abstract class PokemonTypeSlot with _$PokemonTypeSlot {
  const factory PokemonTypeSlot({
    required int slot,
    required PokemonType type,
  }) = _PokemonTypeSlot;

  factory PokemonTypeSlot.fromJson(Map<String, dynamic> json) =>
      _$PokemonTypeSlotFromJson(json);
}

@freezed
abstract class PokemonType with _$PokemonType {
  const factory PokemonType({required String name, required String url}) =
      _PokemonType;

  factory PokemonType.fromJson(Map<String, dynamic> json) =>
      _$PokemonTypeFromJson(json);
}

@freezed
abstract class PokemonStatSlot with _$PokemonStatSlot {
  const factory PokemonStatSlot({
    @JsonKey(name: 'base_stat') required int baseStat,
    required int effort,
    required PokemonStat stat,
  }) = _PokemonStatSlot;

  factory PokemonStatSlot.fromJson(Map<String, dynamic> json) =>
      _$PokemonStatSlotFromJson(json);
}

@freezed
abstract class PokemonStat with _$PokemonStat {
  const factory PokemonStat({required String name, required String url}) =
      _PokemonStat;

  factory PokemonStat.fromJson(Map<String, dynamic> json) =>
      _$PokemonStatFromJson(json);
}

@freezed
abstract class PokemonAbilitySlot with _$PokemonAbilitySlot {
  const factory PokemonAbilitySlot({
    @JsonKey(name: 'is_hidden') required bool isHidden,
    required int slot,
    required PokemonAbilityInfo ability,
  }) = _PokemonAbilitySlot;

  factory PokemonAbilitySlot.fromJson(Map<String, dynamic> json) =>
      _$PokemonAbilitySlotFromJson(json);
}

@freezed
abstract class PokemonAbilityInfo with _$PokemonAbilityInfo {
  const factory PokemonAbilityInfo({
    required String name,
    required String url,
  }) = _PokemonAbilityInfo;

  factory PokemonAbilityInfo.fromJson(Map<String, dynamic> json) =>
      _$PokemonAbilityInfoFromJson(json);
}

@freezed
abstract class PokemonMoveSlot with _$PokemonMoveSlot {
  const factory PokemonMoveSlot({
    required PokemonMoveInfo move,
    @JsonKey(name: 'version_group_details')
    @Default([])
    List<PokemonMoveVersionDetail> versionGroupDetails,
  }) = _PokemonMoveSlot;

  factory PokemonMoveSlot.fromJson(Map<String, dynamic> json) =>
      _$PokemonMoveSlotFromJson(json);
}

@freezed
abstract class PokemonMoveVersionDetail with _$PokemonMoveVersionDetail {
  const factory PokemonMoveVersionDetail({
    @JsonKey(name: 'level_learned_at') required int levelLearnedAt,
    @JsonKey(name: 'move_learn_method')
    required NamedAPIResource moveLearnMethod,
    @JsonKey(name: 'version_group') NamedAPIResource? versionGroup,
  }) = _PokemonMoveVersionDetail;

  factory PokemonMoveVersionDetail.fromJson(Map<String, dynamic> json) =>
      _$PokemonMoveVersionDetailFromJson(json);
}

@freezed
abstract class NamedAPIResource with _$NamedAPIResource {
  const factory NamedAPIResource({required String name, required String url}) =
      _NamedAPIResource;

  factory NamedAPIResource.fromJson(Map<String, dynamic> json) =>
      _$NamedAPIResourceFromJson(json);
}

@freezed
abstract class PokemonMoveInfo with _$PokemonMoveInfo {
  const factory PokemonMoveInfo({required String name, required String url}) =
      _PokemonMoveInfo;

  factory PokemonMoveInfo.fromJson(Map<String, dynamic> json) =>
      _$PokemonMoveInfoFromJson(json);
}
