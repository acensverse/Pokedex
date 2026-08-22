// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ability.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Ability {

 int get id; String get name;@JsonKey(name: 'effect_entries') List<AbilityEffectEntry> get effectEntries;
/// Create a copy of Ability
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AbilityCopyWith<Ability> get copyWith => _$AbilityCopyWithImpl<Ability>(this as Ability, _$identity);

  /// Serializes this Ability to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ability&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.effectEntries, effectEntries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(effectEntries));

@override
String toString() {
  return 'Ability(id: $id, name: $name, effectEntries: $effectEntries)';
}


}

/// @nodoc
abstract mixin class $AbilityCopyWith<$Res>  {
  factory $AbilityCopyWith(Ability value, $Res Function(Ability) _then) = _$AbilityCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'effect_entries') List<AbilityEffectEntry> effectEntries
});




}
/// @nodoc
class _$AbilityCopyWithImpl<$Res>
    implements $AbilityCopyWith<$Res> {
  _$AbilityCopyWithImpl(this._self, this._then);

  final Ability _self;
  final $Res Function(Ability) _then;

/// Create a copy of Ability
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? effectEntries = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,effectEntries: null == effectEntries ? _self.effectEntries : effectEntries // ignore: cast_nullable_to_non_nullable
as List<AbilityEffectEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [Ability].
extension AbilityPatterns on Ability {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ability value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ability() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ability value)  $default,){
final _that = this;
switch (_that) {
case _Ability():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ability value)?  $default,){
final _that = this;
switch (_that) {
case _Ability() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'effect_entries')  List<AbilityEffectEntry> effectEntries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ability() when $default != null:
return $default(_that.id,_that.name,_that.effectEntries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'effect_entries')  List<AbilityEffectEntry> effectEntries)  $default,) {final _that = this;
switch (_that) {
case _Ability():
return $default(_that.id,_that.name,_that.effectEntries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'effect_entries')  List<AbilityEffectEntry> effectEntries)?  $default,) {final _that = this;
switch (_that) {
case _Ability() when $default != null:
return $default(_that.id,_that.name,_that.effectEntries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Ability implements Ability {
  const _Ability({required this.id, required this.name, @JsonKey(name: 'effect_entries') required final  List<AbilityEffectEntry> effectEntries}): _effectEntries = effectEntries;
  factory _Ability.fromJson(Map<String, dynamic> json) => _$AbilityFromJson(json);

@override final  int id;
@override final  String name;
 final  List<AbilityEffectEntry> _effectEntries;
@override@JsonKey(name: 'effect_entries') List<AbilityEffectEntry> get effectEntries {
  if (_effectEntries is EqualUnmodifiableListView) return _effectEntries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_effectEntries);
}


/// Create a copy of Ability
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AbilityCopyWith<_Ability> get copyWith => __$AbilityCopyWithImpl<_Ability>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AbilityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ability&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._effectEntries, _effectEntries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_effectEntries));

@override
String toString() {
  return 'Ability(id: $id, name: $name, effectEntries: $effectEntries)';
}


}

/// @nodoc
abstract mixin class _$AbilityCopyWith<$Res> implements $AbilityCopyWith<$Res> {
  factory _$AbilityCopyWith(_Ability value, $Res Function(_Ability) _then) = __$AbilityCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'effect_entries') List<AbilityEffectEntry> effectEntries
});




}
/// @nodoc
class __$AbilityCopyWithImpl<$Res>
    implements _$AbilityCopyWith<$Res> {
  __$AbilityCopyWithImpl(this._self, this._then);

  final _Ability _self;
  final $Res Function(_Ability) _then;

/// Create a copy of Ability
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? effectEntries = null,}) {
  return _then(_Ability(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,effectEntries: null == effectEntries ? _self._effectEntries : effectEntries // ignore: cast_nullable_to_non_nullable
as List<AbilityEffectEntry>,
  ));
}


}


/// @nodoc
mixin _$AbilityEffectEntry {

 String get effect;@JsonKey(name: 'short_effect') String get shortEffect;
/// Create a copy of AbilityEffectEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AbilityEffectEntryCopyWith<AbilityEffectEntry> get copyWith => _$AbilityEffectEntryCopyWithImpl<AbilityEffectEntry>(this as AbilityEffectEntry, _$identity);

  /// Serializes this AbilityEffectEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AbilityEffectEntry&&(identical(other.effect, effect) || other.effect == effect)&&(identical(other.shortEffect, shortEffect) || other.shortEffect == shortEffect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,effect,shortEffect);

@override
String toString() {
  return 'AbilityEffectEntry(effect: $effect, shortEffect: $shortEffect)';
}


}

/// @nodoc
abstract mixin class $AbilityEffectEntryCopyWith<$Res>  {
  factory $AbilityEffectEntryCopyWith(AbilityEffectEntry value, $Res Function(AbilityEffectEntry) _then) = _$AbilityEffectEntryCopyWithImpl;
@useResult
$Res call({
 String effect,@JsonKey(name: 'short_effect') String shortEffect
});




}
/// @nodoc
class _$AbilityEffectEntryCopyWithImpl<$Res>
    implements $AbilityEffectEntryCopyWith<$Res> {
  _$AbilityEffectEntryCopyWithImpl(this._self, this._then);

  final AbilityEffectEntry _self;
  final $Res Function(AbilityEffectEntry) _then;

/// Create a copy of AbilityEffectEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? effect = null,Object? shortEffect = null,}) {
  return _then(_self.copyWith(
effect: null == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as String,shortEffect: null == shortEffect ? _self.shortEffect : shortEffect // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AbilityEffectEntry].
extension AbilityEffectEntryPatterns on AbilityEffectEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AbilityEffectEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AbilityEffectEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AbilityEffectEntry value)  $default,){
final _that = this;
switch (_that) {
case _AbilityEffectEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AbilityEffectEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AbilityEffectEntry() when $default != null:
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
case _AbilityEffectEntry() when $default != null:
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
case _AbilityEffectEntry():
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
case _AbilityEffectEntry() when $default != null:
return $default(_that.effect,_that.shortEffect);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AbilityEffectEntry implements AbilityEffectEntry {
  const _AbilityEffectEntry({required this.effect, @JsonKey(name: 'short_effect') required this.shortEffect});
  factory _AbilityEffectEntry.fromJson(Map<String, dynamic> json) => _$AbilityEffectEntryFromJson(json);

@override final  String effect;
@override@JsonKey(name: 'short_effect') final  String shortEffect;

/// Create a copy of AbilityEffectEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AbilityEffectEntryCopyWith<_AbilityEffectEntry> get copyWith => __$AbilityEffectEntryCopyWithImpl<_AbilityEffectEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AbilityEffectEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AbilityEffectEntry&&(identical(other.effect, effect) || other.effect == effect)&&(identical(other.shortEffect, shortEffect) || other.shortEffect == shortEffect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,effect,shortEffect);

@override
String toString() {
  return 'AbilityEffectEntry(effect: $effect, shortEffect: $shortEffect)';
}


}

/// @nodoc
abstract mixin class _$AbilityEffectEntryCopyWith<$Res> implements $AbilityEffectEntryCopyWith<$Res> {
  factory _$AbilityEffectEntryCopyWith(_AbilityEffectEntry value, $Res Function(_AbilityEffectEntry) _then) = __$AbilityEffectEntryCopyWithImpl;
@override @useResult
$Res call({
 String effect,@JsonKey(name: 'short_effect') String shortEffect
});




}
/// @nodoc
class __$AbilityEffectEntryCopyWithImpl<$Res>
    implements _$AbilityEffectEntryCopyWith<$Res> {
  __$AbilityEffectEntryCopyWithImpl(this._self, this._then);

  final _AbilityEffectEntry _self;
  final $Res Function(_AbilityEffectEntry) _then;

/// Create a copy of AbilityEffectEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? effect = null,Object? shortEffect = null,}) {
  return _then(_AbilityEffectEntry(
effect: null == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as String,shortEffect: null == shortEffect ? _self.shortEffect : shortEffect // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
