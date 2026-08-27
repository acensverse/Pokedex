import 'package:freezed_annotation/freezed_annotation.dart';

part 'item.freezed.dart';
part 'item.g.dart';

@freezed
abstract class Item with _$Item {
  const factory Item({
    required int id,
    required String name,
    required int cost,
    @JsonKey(name: 'effect_entries')
    required List<ItemEffectEntry> effectEntries,
    required ItemSprites sprites,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}

@freezed
abstract class ItemEffectEntry with _$ItemEffectEntry {
  const factory ItemEffectEntry({
    required String effect,
    @JsonKey(name: 'short_effect') required String shortEffect,
  }) = _ItemEffectEntry;

  factory ItemEffectEntry.fromJson(Map<String, dynamic> json) =>
      _$ItemEffectEntryFromJson(json);
}

@freezed
abstract class ItemSprites with _$ItemSprites {
  const factory ItemSprites({required String defaultSprite}) = _ItemSprites;

  factory ItemSprites.fromJson(Map<String, dynamic> json) =>
      _$ItemSpritesFromJson(json);
}
