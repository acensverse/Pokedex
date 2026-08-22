// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Item {

 int get id; String get name; int get cost;@JsonKey(name: 'effect_entries') List<ItemEffectEntry> get effectEntries; ItemSprites get sprites;
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemCopyWith<Item> get copyWith => _$ItemCopyWithImpl<Item>(this as Item, _$identity);

  /// Serializes this Item to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Item&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cost, cost) || other.cost == cost)&&const DeepCollectionEquality().equals(other.effectEntries, effectEntries)&&(identical(other.sprites, sprites) || other.sprites == sprites));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,cost,const DeepCollectionEquality().hash(effectEntries),sprites);

@override
String toString() {
  return 'Item(id: $id, name: $name, cost: $cost, effectEntries: $effectEntries, sprites: $sprites)';
}


}

/// @nodoc
abstract mixin class $ItemCopyWith<$Res>  {
  factory $ItemCopyWith(Item value, $Res Function(Item) _then) = _$ItemCopyWithImpl;
@useResult
$Res call({
 int id, String name, int cost,@JsonKey(name: 'effect_entries') List<ItemEffectEntry> effectEntries, ItemSprites sprites
});


$ItemSpritesCopyWith<$Res> get sprites;

}
/// @nodoc
class _$ItemCopyWithImpl<$Res>
    implements $ItemCopyWith<$Res> {
  _$ItemCopyWithImpl(this._self, this._then);

  final Item _self;
  final $Res Function(Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? cost = null,Object? effectEntries = null,Object? sprites = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as int,effectEntries: null == effectEntries ? _self.effectEntries : effectEntries // ignore: cast_nullable_to_non_nullable
as List<ItemEffectEntry>,sprites: null == sprites ? _self.sprites : sprites // ignore: cast_nullable_to_non_nullable
as ItemSprites,
  ));
}
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemSpritesCopyWith<$Res> get sprites {
  
  return $ItemSpritesCopyWith<$Res>(_self.sprites, (value) {
    return _then(_self.copyWith(sprites: value));
  });
}
}


/// Adds pattern-matching-related methods to [Item].
extension ItemPatterns on Item {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Item value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Item value)  $default,){
final _that = this;
switch (_that) {
case _Item():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Item value)?  $default,){
final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int cost, @JsonKey(name: 'effect_entries')  List<ItemEffectEntry> effectEntries,  ItemSprites sprites)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.name,_that.cost,_that.effectEntries,_that.sprites);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int cost, @JsonKey(name: 'effect_entries')  List<ItemEffectEntry> effectEntries,  ItemSprites sprites)  $default,) {final _that = this;
switch (_that) {
case _Item():
return $default(_that.id,_that.name,_that.cost,_that.effectEntries,_that.sprites);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int cost, @JsonKey(name: 'effect_entries')  List<ItemEffectEntry> effectEntries,  ItemSprites sprites)?  $default,) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.name,_that.cost,_that.effectEntries,_that.sprites);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Item implements Item {
  const _Item({required this.id, required this.name, required this.cost, @JsonKey(name: 'effect_entries') required final  List<ItemEffectEntry> effectEntries, required this.sprites}): _effectEntries = effectEntries;
  factory _Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

@override final  int id;
@override final  String name;
@override final  int cost;
 final  List<ItemEffectEntry> _effectEntries;
@override@JsonKey(name: 'effect_entries') List<ItemEffectEntry> get effectEntries {
  if (_effectEntries is EqualUnmodifiableListView) return _effectEntries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_effectEntries);
}

@override final  ItemSprites sprites;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemCopyWith<_Item> get copyWith => __$ItemCopyWithImpl<_Item>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Item&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cost, cost) || other.cost == cost)&&const DeepCollectionEquality().equals(other._effectEntries, _effectEntries)&&(identical(other.sprites, sprites) || other.sprites == sprites));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,cost,const DeepCollectionEquality().hash(_effectEntries),sprites);

@override
String toString() {
  return 'Item(id: $id, name: $name, cost: $cost, effectEntries: $effectEntries, sprites: $sprites)';
}


}

/// @nodoc
abstract mixin class _$ItemCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$ItemCopyWith(_Item value, $Res Function(_Item) _then) = __$ItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int cost,@JsonKey(name: 'effect_entries') List<ItemEffectEntry> effectEntries, ItemSprites sprites
});


@override $ItemSpritesCopyWith<$Res> get sprites;

}
/// @nodoc
class __$ItemCopyWithImpl<$Res>
    implements _$ItemCopyWith<$Res> {
  __$ItemCopyWithImpl(this._self, this._then);

  final _Item _self;
  final $Res Function(_Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? cost = null,Object? effectEntries = null,Object? sprites = null,}) {
  return _then(_Item(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as int,effectEntries: null == effectEntries ? _self._effectEntries : effectEntries // ignore: cast_nullable_to_non_nullable
as List<ItemEffectEntry>,sprites: null == sprites ? _self.sprites : sprites // ignore: cast_nullable_to_non_nullable
as ItemSprites,
  ));
}

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemSpritesCopyWith<$Res> get sprites {
  
  return $ItemSpritesCopyWith<$Res>(_self.sprites, (value) {
    return _then(_self.copyWith(sprites: value));
  });
}
}


/// @nodoc
mixin _$ItemEffectEntry {

 String get effect;@JsonKey(name: 'short_effect') String get shortEffect;
/// Create a copy of ItemEffectEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemEffectEntryCopyWith<ItemEffectEntry> get copyWith => _$ItemEffectEntryCopyWithImpl<ItemEffectEntry>(this as ItemEffectEntry, _$identity);

  /// Serializes this ItemEffectEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemEffectEntry&&(identical(other.effect, effect) || other.effect == effect)&&(identical(other.shortEffect, shortEffect) || other.shortEffect == shortEffect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,effect,shortEffect);

@override
String toString() {
  return 'ItemEffectEntry(effect: $effect, shortEffect: $shortEffect)';
}


}

/// @nodoc
abstract mixin class $ItemEffectEntryCopyWith<$Res>  {
  factory $ItemEffectEntryCopyWith(ItemEffectEntry value, $Res Function(ItemEffectEntry) _then) = _$ItemEffectEntryCopyWithImpl;
@useResult
$Res call({
 String effect,@JsonKey(name: 'short_effect') String shortEffect
});




}
/// @nodoc
class _$ItemEffectEntryCopyWithImpl<$Res>
    implements $ItemEffectEntryCopyWith<$Res> {
  _$ItemEffectEntryCopyWithImpl(this._self, this._then);

  final ItemEffectEntry _self;
  final $Res Function(ItemEffectEntry) _then;

/// Create a copy of ItemEffectEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? effect = null,Object? shortEffect = null,}) {
  return _then(_self.copyWith(
effect: null == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as String,shortEffect: null == shortEffect ? _self.shortEffect : shortEffect // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemEffectEntry].
extension ItemEffectEntryPatterns on ItemEffectEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemEffectEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemEffectEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemEffectEntry value)  $default,){
final _that = this;
switch (_that) {
case _ItemEffectEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemEffectEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ItemEffectEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String effect, @JsonKey(name: 'short_effect')  String shortEffect)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemEffectEntry() when $default != null:
return $default(_that.effect,_that.shortEffect);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String effect, @JsonKey(name: 'short_effect')  String shortEffect)  $default,) {final _that = this;
switch (_that) {
case _ItemEffectEntry():
return $default(_that.effect,_that.shortEffect);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String effect, @JsonKey(name: 'short_effect')  String shortEffect)?  $default,) {final _that = this;
switch (_that) {
case _ItemEffectEntry() when $default != null:
return $default(_that.effect,_that.shortEffect);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemEffectEntry implements ItemEffectEntry {
  const _ItemEffectEntry({required this.effect, @JsonKey(name: 'short_effect') required this.shortEffect});
  factory _ItemEffectEntry.fromJson(Map<String, dynamic> json) => _$ItemEffectEntryFromJson(json);

@override final  String effect;
@override@JsonKey(name: 'short_effect') final  String shortEffect;

/// Create a copy of ItemEffectEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemEffectEntryCopyWith<_ItemEffectEntry> get copyWith => __$ItemEffectEntryCopyWithImpl<_ItemEffectEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemEffectEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemEffectEntry&&(identical(other.effect, effect) || other.effect == effect)&&(identical(other.shortEffect, shortEffect) || other.shortEffect == shortEffect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,effect,shortEffect);

@override
String toString() {
  return 'ItemEffectEntry(effect: $effect, shortEffect: $shortEffect)';
}


}

/// @nodoc
abstract mixin class _$ItemEffectEntryCopyWith<$Res> implements $ItemEffectEntryCopyWith<$Res> {
  factory _$ItemEffectEntryCopyWith(_ItemEffectEntry value, $Res Function(_ItemEffectEntry) _then) = __$ItemEffectEntryCopyWithImpl;
@override @useResult
$Res call({
 String effect,@JsonKey(name: 'short_effect') String shortEffect
});




}
/// @nodoc
class __$ItemEffectEntryCopyWithImpl<$Res>
    implements _$ItemEffectEntryCopyWith<$Res> {
  __$ItemEffectEntryCopyWithImpl(this._self, this._then);

  final _ItemEffectEntry _self;
  final $Res Function(_ItemEffectEntry) _then;

/// Create a copy of ItemEffectEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? effect = null,Object? shortEffect = null,}) {
  return _then(_ItemEffectEntry(
effect: null == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as String,shortEffect: null == shortEffect ? _self.shortEffect : shortEffect // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ItemSprites {

 String get defaultSprite;
/// Create a copy of ItemSprites
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemSpritesCopyWith<ItemSprites> get copyWith => _$ItemSpritesCopyWithImpl<ItemSprites>(this as ItemSprites, _$identity);

  /// Serializes this ItemSprites to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemSprites&&(identical(other.defaultSprite, defaultSprite) || other.defaultSprite == defaultSprite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultSprite);

@override
String toString() {
  return 'ItemSprites(defaultSprite: $defaultSprite)';
}


}

/// @nodoc
abstract mixin class $ItemSpritesCopyWith<$Res>  {
  factory $ItemSpritesCopyWith(ItemSprites value, $Res Function(ItemSprites) _then) = _$ItemSpritesCopyWithImpl;
@useResult
$Res call({
 String defaultSprite
});




}
/// @nodoc
class _$ItemSpritesCopyWithImpl<$Res>
    implements $ItemSpritesCopyWith<$Res> {
  _$ItemSpritesCopyWithImpl(this._self, this._then);

  final ItemSprites _self;
  final $Res Function(ItemSprites) _then;

/// Create a copy of ItemSprites
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultSprite = null,}) {
  return _then(_self.copyWith(
defaultSprite: null == defaultSprite ? _self.defaultSprite : defaultSprite // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemSprites].
extension ItemSpritesPatterns on ItemSprites {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemSprites value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemSprites() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemSprites value)  $default,){
final _that = this;
switch (_that) {
case _ItemSprites():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemSprites value)?  $default,){
final _that = this;
switch (_that) {
case _ItemSprites() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String defaultSprite)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemSprites() when $default != null:
return $default(_that.defaultSprite);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String defaultSprite)  $default,) {final _that = this;
switch (_that) {
case _ItemSprites():
return $default(_that.defaultSprite);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String defaultSprite)?  $default,) {final _that = this;
switch (_that) {
case _ItemSprites() when $default != null:
return $default(_that.defaultSprite);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemSprites implements ItemSprites {
  const _ItemSprites({required this.defaultSprite});
  factory _ItemSprites.fromJson(Map<String, dynamic> json) => _$ItemSpritesFromJson(json);

@override final  String defaultSprite;

/// Create a copy of ItemSprites
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemSpritesCopyWith<_ItemSprites> get copyWith => __$ItemSpritesCopyWithImpl<_ItemSprites>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemSpritesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemSprites&&(identical(other.defaultSprite, defaultSprite) || other.defaultSprite == defaultSprite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultSprite);

@override
String toString() {
  return 'ItemSprites(defaultSprite: $defaultSprite)';
}


}

/// @nodoc
abstract mixin class _$ItemSpritesCopyWith<$Res> implements $ItemSpritesCopyWith<$Res> {
  factory _$ItemSpritesCopyWith(_ItemSprites value, $Res Function(_ItemSprites) _then) = __$ItemSpritesCopyWithImpl;
@override @useResult
$Res call({
 String defaultSprite
});




}
/// @nodoc
class __$ItemSpritesCopyWithImpl<$Res>
    implements _$ItemSpritesCopyWith<$Res> {
  __$ItemSpritesCopyWithImpl(this._self, this._then);

  final _ItemSprites _self;
  final $Res Function(_ItemSprites) _then;

/// Create a copy of ItemSprites
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultSprite = null,}) {
  return _then(_ItemSprites(
defaultSprite: null == defaultSprite ? _self.defaultSprite : defaultSprite // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
