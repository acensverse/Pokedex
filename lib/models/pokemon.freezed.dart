// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pokemon.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Pokemon {

 int get id; int get speciesId; String get name; int get height; int get weight;@JsonKey(name: 'base_experience') int? get baseExperience; List<PokemonTypeSlot> get types; List<PokemonStatSlot> get stats; List<PokemonAbilitySlot> get abilities; List<PokemonMoveSlot> get moves; String? get forms; String? get evolutionInfo;
/// Create a copy of Pokemon
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PokemonCopyWith<Pokemon> get copyWith => _$PokemonCopyWithImpl<Pokemon>(this as Pokemon, _$identity);

  /// Serializes this Pokemon to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pokemon&&(identical(other.id, id) || other.id == id)&&(identical(other.speciesId, speciesId) || other.speciesId == speciesId)&&(identical(other.name, name) || other.name == name)&&(identical(other.height, height) || other.height == height)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.baseExperience, baseExperience) || other.baseExperience == baseExperience)&&const DeepCollectionEquality().equals(other.types, types)&&const DeepCollectionEquality().equals(other.stats, stats)&&const DeepCollectionEquality().equals(other.abilities, abilities)&&const DeepCollectionEquality().equals(other.moves, moves)&&(identical(other.forms, forms) || other.forms == forms)&&(identical(other.evolutionInfo, evolutionInfo) || other.evolutionInfo == evolutionInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,speciesId,name,height,weight,baseExperience,const DeepCollectionEquality().hash(types),const DeepCollectionEquality().hash(stats),const DeepCollectionEquality().hash(abilities),const DeepCollectionEquality().hash(moves),forms,evolutionInfo);

@override
String toString() {
  return 'Pokemon(id: $id, speciesId: $speciesId, name: $name, height: $height, weight: $weight, baseExperience: $baseExperience, types: $types, stats: $stats, abilities: $abilities, moves: $moves, forms: $forms, evolutionInfo: $evolutionInfo)';
}


}

/// @nodoc
abstract mixin class $PokemonCopyWith<$Res>  {
  factory $PokemonCopyWith(Pokemon value, $Res Function(Pokemon) _then) = _$PokemonCopyWithImpl;
@useResult
$Res call({
 int id, int speciesId, String name, int height, int weight,@JsonKey(name: 'base_experience') int? baseExperience, List<PokemonTypeSlot> types, List<PokemonStatSlot> stats, List<PokemonAbilitySlot> abilities, List<PokemonMoveSlot> moves, String? forms, String? evolutionInfo
});




}
/// @nodoc
class _$PokemonCopyWithImpl<$Res>
    implements $PokemonCopyWith<$Res> {
  _$PokemonCopyWithImpl(this._self, this._then);

  final Pokemon _self;
  final $Res Function(Pokemon) _then;

/// Create a copy of Pokemon
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? speciesId = null,Object? name = null,Object? height = null,Object? weight = null,Object? baseExperience = freezed,Object? types = null,Object? stats = null,Object? abilities = null,Object? moves = null,Object? forms = freezed,Object? evolutionInfo = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,speciesId: null == speciesId ? _self.speciesId : speciesId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as int,baseExperience: freezed == baseExperience ? _self.baseExperience : baseExperience // ignore: cast_nullable_to_non_nullable
as int?,types: null == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<PokemonTypeSlot>,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as List<PokemonStatSlot>,abilities: null == abilities ? _self.abilities : abilities // ignore: cast_nullable_to_non_nullable
as List<PokemonAbilitySlot>,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as List<PokemonMoveSlot>,forms: freezed == forms ? _self.forms : forms // ignore: cast_nullable_to_non_nullable
as String?,evolutionInfo: freezed == evolutionInfo ? _self.evolutionInfo : evolutionInfo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Pokemon].
extension PokemonPatterns on Pokemon {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pokemon value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pokemon() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pokemon value)  $default,){
final _that = this;
switch (_that) {
case _Pokemon():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pokemon value)?  $default,){
final _that = this;
switch (_that) {
case _Pokemon() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int speciesId,  String name,  int height,  int weight, @JsonKey(name: 'base_experience')  int? baseExperience,  List<PokemonTypeSlot> types,  List<PokemonStatSlot> stats,  List<PokemonAbilitySlot> abilities,  List<PokemonMoveSlot> moves,  String? forms,  String? evolutionInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pokemon() when $default != null:
return $default(_that.id,_that.speciesId,_that.name,_that.height,_that.weight,_that.baseExperience,_that.types,_that.stats,_that.abilities,_that.moves,_that.forms,_that.evolutionInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int speciesId,  String name,  int height,  int weight, @JsonKey(name: 'base_experience')  int? baseExperience,  List<PokemonTypeSlot> types,  List<PokemonStatSlot> stats,  List<PokemonAbilitySlot> abilities,  List<PokemonMoveSlot> moves,  String? forms,  String? evolutionInfo)  $default,) {final _that = this;
switch (_that) {
case _Pokemon():
return $default(_that.id,_that.speciesId,_that.name,_that.height,_that.weight,_that.baseExperience,_that.types,_that.stats,_that.abilities,_that.moves,_that.forms,_that.evolutionInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int speciesId,  String name,  int height,  int weight, @JsonKey(name: 'base_experience')  int? baseExperience,  List<PokemonTypeSlot> types,  List<PokemonStatSlot> stats,  List<PokemonAbilitySlot> abilities,  List<PokemonMoveSlot> moves,  String? forms,  String? evolutionInfo)?  $default,) {final _that = this;
switch (_that) {
case _Pokemon() when $default != null:
return $default(_that.id,_that.speciesId,_that.name,_that.height,_that.weight,_that.baseExperience,_that.types,_that.stats,_that.abilities,_that.moves,_that.forms,_that.evolutionInfo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Pokemon implements Pokemon {
  const _Pokemon({required this.id, required this.speciesId, required this.name, required this.height, required this.weight, @JsonKey(name: 'base_experience') this.baseExperience, required final  List<PokemonTypeSlot> types, required final  List<PokemonStatSlot> stats, required final  List<PokemonAbilitySlot> abilities, required final  List<PokemonMoveSlot> moves, this.forms, this.evolutionInfo}): _types = types,_stats = stats,_abilities = abilities,_moves = moves;
  factory _Pokemon.fromJson(Map<String, dynamic> json) => _$PokemonFromJson(json);

@override final  int id;
@override final  int speciesId;
@override final  String name;
@override final  int height;
@override final  int weight;
@override@JsonKey(name: 'base_experience') final  int? baseExperience;
 final  List<PokemonTypeSlot> _types;
@override List<PokemonTypeSlot> get types {
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_types);
}

 final  List<PokemonStatSlot> _stats;
@override List<PokemonStatSlot> get stats {
  if (_stats is EqualUnmodifiableListView) return _stats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stats);
}

 final  List<PokemonAbilitySlot> _abilities;
@override List<PokemonAbilitySlot> get abilities {
  if (_abilities is EqualUnmodifiableListView) return _abilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_abilities);
}

 final  List<PokemonMoveSlot> _moves;
@override List<PokemonMoveSlot> get moves {
  if (_moves is EqualUnmodifiableListView) return _moves;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_moves);
}

@override final  String? forms;
@override final  String? evolutionInfo;

/// Create a copy of Pokemon
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PokemonCopyWith<_Pokemon> get copyWith => __$PokemonCopyWithImpl<_Pokemon>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PokemonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pokemon&&(identical(other.id, id) || other.id == id)&&(identical(other.speciesId, speciesId) || other.speciesId == speciesId)&&(identical(other.name, name) || other.name == name)&&(identical(other.height, height) || other.height == height)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.baseExperience, baseExperience) || other.baseExperience == baseExperience)&&const DeepCollectionEquality().equals(other._types, _types)&&const DeepCollectionEquality().equals(other._stats, _stats)&&const DeepCollectionEquality().equals(other._abilities, _abilities)&&const DeepCollectionEquality().equals(other._moves, _moves)&&(identical(other.forms, forms) || other.forms == forms)&&(identical(other.evolutionInfo, evolutionInfo) || other.evolutionInfo == evolutionInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,speciesId,name,height,weight,baseExperience,const DeepCollectionEquality().hash(_types),const DeepCollectionEquality().hash(_stats),const DeepCollectionEquality().hash(_abilities),const DeepCollectionEquality().hash(_moves),forms,evolutionInfo);

@override
String toString() {
  return 'Pokemon(id: $id, speciesId: $speciesId, name: $name, height: $height, weight: $weight, baseExperience: $baseExperience, types: $types, stats: $stats, abilities: $abilities, moves: $moves, forms: $forms, evolutionInfo: $evolutionInfo)';
}


}

/// @nodoc
abstract mixin class _$PokemonCopyWith<$Res> implements $PokemonCopyWith<$Res> {
  factory _$PokemonCopyWith(_Pokemon value, $Res Function(_Pokemon) _then) = __$PokemonCopyWithImpl;
@override @useResult
$Res call({
 int id, int speciesId, String name, int height, int weight,@JsonKey(name: 'base_experience') int? baseExperience, List<PokemonTypeSlot> types, List<PokemonStatSlot> stats, List<PokemonAbilitySlot> abilities, List<PokemonMoveSlot> moves, String? forms, String? evolutionInfo
});




}
/// @nodoc
class __$PokemonCopyWithImpl<$Res>
    implements _$PokemonCopyWith<$Res> {
  __$PokemonCopyWithImpl(this._self, this._then);

  final _Pokemon _self;
  final $Res Function(_Pokemon) _then;

/// Create a copy of Pokemon
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? speciesId = null,Object? name = null,Object? height = null,Object? weight = null,Object? baseExperience = freezed,Object? types = null,Object? stats = null,Object? abilities = null,Object? moves = null,Object? forms = freezed,Object? evolutionInfo = freezed,}) {
  return _then(_Pokemon(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,speciesId: null == speciesId ? _self.speciesId : speciesId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as int,baseExperience: freezed == baseExperience ? _self.baseExperience : baseExperience // ignore: cast_nullable_to_non_nullable
as int?,types: null == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<PokemonTypeSlot>,stats: null == stats ? _self._stats : stats // ignore: cast_nullable_to_non_nullable
as List<PokemonStatSlot>,abilities: null == abilities ? _self._abilities : abilities // ignore: cast_nullable_to_non_nullable
as List<PokemonAbilitySlot>,moves: null == moves ? _self._moves : moves // ignore: cast_nullable_to_non_nullable
as List<PokemonMoveSlot>,forms: freezed == forms ? _self.forms : forms // ignore: cast_nullable_to_non_nullable
as String?,evolutionInfo: freezed == evolutionInfo ? _self.evolutionInfo : evolutionInfo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PokemonTypeSlot {

 int get slot; PokemonType get type;
/// Create a copy of PokemonTypeSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PokemonTypeSlotCopyWith<PokemonTypeSlot> get copyWith => _$PokemonTypeSlotCopyWithImpl<PokemonTypeSlot>(this as PokemonTypeSlot, _$identity);

  /// Serializes this PokemonTypeSlot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PokemonTypeSlot&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slot,type);

@override
String toString() {
  return 'PokemonTypeSlot(slot: $slot, type: $type)';
}


}

/// @nodoc
abstract mixin class $PokemonTypeSlotCopyWith<$Res>  {
  factory $PokemonTypeSlotCopyWith(PokemonTypeSlot value, $Res Function(PokemonTypeSlot) _then) = _$PokemonTypeSlotCopyWithImpl;
@useResult
$Res call({
 int slot, PokemonType type
});


$PokemonTypeCopyWith<$Res> get type;

}
/// @nodoc
class _$PokemonTypeSlotCopyWithImpl<$Res>
    implements $PokemonTypeSlotCopyWith<$Res> {
  _$PokemonTypeSlotCopyWithImpl(this._self, this._then);

  final PokemonTypeSlot _self;
  final $Res Function(PokemonTypeSlot) _then;

/// Create a copy of PokemonTypeSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slot = null,Object? type = null,}) {
  return _then(_self.copyWith(
slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PokemonType,
  ));
}
/// Create a copy of PokemonTypeSlot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PokemonTypeCopyWith<$Res> get type {
  
  return $PokemonTypeCopyWith<$Res>(_self.type, (value) {
    return _then(_self.copyWith(type: value));
  });
}
}


/// Adds pattern-matching-related methods to [PokemonTypeSlot].
extension PokemonTypeSlotPatterns on PokemonTypeSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PokemonTypeSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PokemonTypeSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PokemonTypeSlot value)  $default,){
final _that = this;
switch (_that) {
case _PokemonTypeSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PokemonTypeSlot value)?  $default,){
final _that = this;
switch (_that) {
case _PokemonTypeSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int slot,  PokemonType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PokemonTypeSlot() when $default != null:
return $default(_that.slot,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int slot,  PokemonType type)  $default,) {final _that = this;
switch (_that) {
case _PokemonTypeSlot():
return $default(_that.slot,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int slot,  PokemonType type)?  $default,) {final _that = this;
switch (_that) {
case _PokemonTypeSlot() when $default != null:
return $default(_that.slot,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PokemonTypeSlot implements PokemonTypeSlot {
  const _PokemonTypeSlot({required this.slot, required this.type});
  factory _PokemonTypeSlot.fromJson(Map<String, dynamic> json) => _$PokemonTypeSlotFromJson(json);

@override final  int slot;
@override final  PokemonType type;

/// Create a copy of PokemonTypeSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PokemonTypeSlotCopyWith<_PokemonTypeSlot> get copyWith => __$PokemonTypeSlotCopyWithImpl<_PokemonTypeSlot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PokemonTypeSlotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PokemonTypeSlot&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slot,type);

@override
String toString() {
  return 'PokemonTypeSlot(slot: $slot, type: $type)';
}


}

/// @nodoc
abstract mixin class _$PokemonTypeSlotCopyWith<$Res> implements $PokemonTypeSlotCopyWith<$Res> {
  factory _$PokemonTypeSlotCopyWith(_PokemonTypeSlot value, $Res Function(_PokemonTypeSlot) _then) = __$PokemonTypeSlotCopyWithImpl;
@override @useResult
$Res call({
 int slot, PokemonType type
});


@override $PokemonTypeCopyWith<$Res> get type;

}
/// @nodoc
class __$PokemonTypeSlotCopyWithImpl<$Res>
    implements _$PokemonTypeSlotCopyWith<$Res> {
  __$PokemonTypeSlotCopyWithImpl(this._self, this._then);

  final _PokemonTypeSlot _self;
  final $Res Function(_PokemonTypeSlot) _then;

/// Create a copy of PokemonTypeSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slot = null,Object? type = null,}) {
  return _then(_PokemonTypeSlot(
slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PokemonType,
  ));
}

/// Create a copy of PokemonTypeSlot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PokemonTypeCopyWith<$Res> get type {
  
  return $PokemonTypeCopyWith<$Res>(_self.type, (value) {
    return _then(_self.copyWith(type: value));
  });
}
}


/// @nodoc
mixin _$PokemonType {

 String get name; String get url;
/// Create a copy of PokemonType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PokemonTypeCopyWith<PokemonType> get copyWith => _$PokemonTypeCopyWithImpl<PokemonType>(this as PokemonType, _$identity);

  /// Serializes this PokemonType to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PokemonType&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'PokemonType(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class $PokemonTypeCopyWith<$Res>  {
  factory $PokemonTypeCopyWith(PokemonType value, $Res Function(PokemonType) _then) = _$PokemonTypeCopyWithImpl;
@useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class _$PokemonTypeCopyWithImpl<$Res>
    implements $PokemonTypeCopyWith<$Res> {
  _$PokemonTypeCopyWithImpl(this._self, this._then);

  final PokemonType _self;
  final $Res Function(PokemonType) _then;

/// Create a copy of PokemonType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? url = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PokemonType].
extension PokemonTypePatterns on PokemonType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PokemonType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PokemonType() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PokemonType value)  $default,){
final _that = this;
switch (_that) {
case _PokemonType():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PokemonType value)?  $default,){
final _that = this;
switch (_that) {
case _PokemonType() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PokemonType() when $default != null:
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String url)  $default,) {final _that = this;
switch (_that) {
case _PokemonType():
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String url)?  $default,) {final _that = this;
switch (_that) {
case _PokemonType() when $default != null:
return $default(_that.name,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PokemonType implements PokemonType {
  const _PokemonType({required this.name, required this.url});
  factory _PokemonType.fromJson(Map<String, dynamic> json) => _$PokemonTypeFromJson(json);

@override final  String name;
@override final  String url;

/// Create a copy of PokemonType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PokemonTypeCopyWith<_PokemonType> get copyWith => __$PokemonTypeCopyWithImpl<_PokemonType>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PokemonTypeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PokemonType&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'PokemonType(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class _$PokemonTypeCopyWith<$Res> implements $PokemonTypeCopyWith<$Res> {
  factory _$PokemonTypeCopyWith(_PokemonType value, $Res Function(_PokemonType) _then) = __$PokemonTypeCopyWithImpl;
@override @useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class __$PokemonTypeCopyWithImpl<$Res>
    implements _$PokemonTypeCopyWith<$Res> {
  __$PokemonTypeCopyWithImpl(this._self, this._then);

  final _PokemonType _self;
  final $Res Function(_PokemonType) _then;

/// Create a copy of PokemonType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? url = null,}) {
  return _then(_PokemonType(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PokemonStatSlot {

@JsonKey(name: 'base_stat') int get baseStat; int get effort; PokemonStat get stat;
/// Create a copy of PokemonStatSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PokemonStatSlotCopyWith<PokemonStatSlot> get copyWith => _$PokemonStatSlotCopyWithImpl<PokemonStatSlot>(this as PokemonStatSlot, _$identity);

  /// Serializes this PokemonStatSlot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PokemonStatSlot&&(identical(other.baseStat, baseStat) || other.baseStat == baseStat)&&(identical(other.effort, effort) || other.effort == effort)&&(identical(other.stat, stat) || other.stat == stat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,baseStat,effort,stat);

@override
String toString() {
  return 'PokemonStatSlot(baseStat: $baseStat, effort: $effort, stat: $stat)';
}


}

/// @nodoc
abstract mixin class $PokemonStatSlotCopyWith<$Res>  {
  factory $PokemonStatSlotCopyWith(PokemonStatSlot value, $Res Function(PokemonStatSlot) _then) = _$PokemonStatSlotCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'base_stat') int baseStat, int effort, PokemonStat stat
});


$PokemonStatCopyWith<$Res> get stat;

}
/// @nodoc
class _$PokemonStatSlotCopyWithImpl<$Res>
    implements $PokemonStatSlotCopyWith<$Res> {
  _$PokemonStatSlotCopyWithImpl(this._self, this._then);

  final PokemonStatSlot _self;
  final $Res Function(PokemonStatSlot) _then;

/// Create a copy of PokemonStatSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? baseStat = null,Object? effort = null,Object? stat = null,}) {
  return _then(_self.copyWith(
baseStat: null == baseStat ? _self.baseStat : baseStat // ignore: cast_nullable_to_non_nullable
as int,effort: null == effort ? _self.effort : effort // ignore: cast_nullable_to_non_nullable
as int,stat: null == stat ? _self.stat : stat // ignore: cast_nullable_to_non_nullable
as PokemonStat,
  ));
}
/// Create a copy of PokemonStatSlot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PokemonStatCopyWith<$Res> get stat {
  
  return $PokemonStatCopyWith<$Res>(_self.stat, (value) {
    return _then(_self.copyWith(stat: value));
  });
}
}


/// Adds pattern-matching-related methods to [PokemonStatSlot].
extension PokemonStatSlotPatterns on PokemonStatSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PokemonStatSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PokemonStatSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PokemonStatSlot value)  $default,){
final _that = this;
switch (_that) {
case _PokemonStatSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PokemonStatSlot value)?  $default,){
final _that = this;
switch (_that) {
case _PokemonStatSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'base_stat')  int baseStat,  int effort,  PokemonStat stat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PokemonStatSlot() when $default != null:
return $default(_that.baseStat,_that.effort,_that.stat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'base_stat')  int baseStat,  int effort,  PokemonStat stat)  $default,) {final _that = this;
switch (_that) {
case _PokemonStatSlot():
return $default(_that.baseStat,_that.effort,_that.stat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'base_stat')  int baseStat,  int effort,  PokemonStat stat)?  $default,) {final _that = this;
switch (_that) {
case _PokemonStatSlot() when $default != null:
return $default(_that.baseStat,_that.effort,_that.stat);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PokemonStatSlot implements PokemonStatSlot {
  const _PokemonStatSlot({@JsonKey(name: 'base_stat') required this.baseStat, required this.effort, required this.stat});
  factory _PokemonStatSlot.fromJson(Map<String, dynamic> json) => _$PokemonStatSlotFromJson(json);

@override@JsonKey(name: 'base_stat') final  int baseStat;
@override final  int effort;
@override final  PokemonStat stat;

/// Create a copy of PokemonStatSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PokemonStatSlotCopyWith<_PokemonStatSlot> get copyWith => __$PokemonStatSlotCopyWithImpl<_PokemonStatSlot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PokemonStatSlotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PokemonStatSlot&&(identical(other.baseStat, baseStat) || other.baseStat == baseStat)&&(identical(other.effort, effort) || other.effort == effort)&&(identical(other.stat, stat) || other.stat == stat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,baseStat,effort,stat);

@override
String toString() {
  return 'PokemonStatSlot(baseStat: $baseStat, effort: $effort, stat: $stat)';
}


}

/// @nodoc
abstract mixin class _$PokemonStatSlotCopyWith<$Res> implements $PokemonStatSlotCopyWith<$Res> {
  factory _$PokemonStatSlotCopyWith(_PokemonStatSlot value, $Res Function(_PokemonStatSlot) _then) = __$PokemonStatSlotCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'base_stat') int baseStat, int effort, PokemonStat stat
});


@override $PokemonStatCopyWith<$Res> get stat;

}
/// @nodoc
class __$PokemonStatSlotCopyWithImpl<$Res>
    implements _$PokemonStatSlotCopyWith<$Res> {
  __$PokemonStatSlotCopyWithImpl(this._self, this._then);

  final _PokemonStatSlot _self;
  final $Res Function(_PokemonStatSlot) _then;

/// Create a copy of PokemonStatSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? baseStat = null,Object? effort = null,Object? stat = null,}) {
  return _then(_PokemonStatSlot(
baseStat: null == baseStat ? _self.baseStat : baseStat // ignore: cast_nullable_to_non_nullable
as int,effort: null == effort ? _self.effort : effort // ignore: cast_nullable_to_non_nullable
as int,stat: null == stat ? _self.stat : stat // ignore: cast_nullable_to_non_nullable
as PokemonStat,
  ));
}

/// Create a copy of PokemonStatSlot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PokemonStatCopyWith<$Res> get stat {
  
  return $PokemonStatCopyWith<$Res>(_self.stat, (value) {
    return _then(_self.copyWith(stat: value));
  });
}
}


/// @nodoc
mixin _$PokemonStat {

 String get name; String get url;
/// Create a copy of PokemonStat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PokemonStatCopyWith<PokemonStat> get copyWith => _$PokemonStatCopyWithImpl<PokemonStat>(this as PokemonStat, _$identity);

  /// Serializes this PokemonStat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PokemonStat&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'PokemonStat(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class $PokemonStatCopyWith<$Res>  {
  factory $PokemonStatCopyWith(PokemonStat value, $Res Function(PokemonStat) _then) = _$PokemonStatCopyWithImpl;
@useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class _$PokemonStatCopyWithImpl<$Res>
    implements $PokemonStatCopyWith<$Res> {
  _$PokemonStatCopyWithImpl(this._self, this._then);

  final PokemonStat _self;
  final $Res Function(PokemonStat) _then;

/// Create a copy of PokemonStat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? url = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PokemonStat].
extension PokemonStatPatterns on PokemonStat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PokemonStat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PokemonStat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PokemonStat value)  $default,){
final _that = this;
switch (_that) {
case _PokemonStat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PokemonStat value)?  $default,){
final _that = this;
switch (_that) {
case _PokemonStat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PokemonStat() when $default != null:
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String url)  $default,) {final _that = this;
switch (_that) {
case _PokemonStat():
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String url)?  $default,) {final _that = this;
switch (_that) {
case _PokemonStat() when $default != null:
return $default(_that.name,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PokemonStat implements PokemonStat {
  const _PokemonStat({required this.name, required this.url});
  factory _PokemonStat.fromJson(Map<String, dynamic> json) => _$PokemonStatFromJson(json);

@override final  String name;
@override final  String url;

/// Create a copy of PokemonStat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PokemonStatCopyWith<_PokemonStat> get copyWith => __$PokemonStatCopyWithImpl<_PokemonStat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PokemonStatToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PokemonStat&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'PokemonStat(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class _$PokemonStatCopyWith<$Res> implements $PokemonStatCopyWith<$Res> {
  factory _$PokemonStatCopyWith(_PokemonStat value, $Res Function(_PokemonStat) _then) = __$PokemonStatCopyWithImpl;
@override @useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class __$PokemonStatCopyWithImpl<$Res>
    implements _$PokemonStatCopyWith<$Res> {
  __$PokemonStatCopyWithImpl(this._self, this._then);

  final _PokemonStat _self;
  final $Res Function(_PokemonStat) _then;

/// Create a copy of PokemonStat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? url = null,}) {
  return _then(_PokemonStat(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PokemonAbilitySlot {

@JsonKey(name: 'is_hidden') bool get isHidden; int get slot; PokemonAbilityInfo get ability;
/// Create a copy of PokemonAbilitySlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PokemonAbilitySlotCopyWith<PokemonAbilitySlot> get copyWith => _$PokemonAbilitySlotCopyWithImpl<PokemonAbilitySlot>(this as PokemonAbilitySlot, _$identity);

  /// Serializes this PokemonAbilitySlot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PokemonAbilitySlot&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.ability, ability) || other.ability == ability));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isHidden,slot,ability);

@override
String toString() {
  return 'PokemonAbilitySlot(isHidden: $isHidden, slot: $slot, ability: $ability)';
}


}

/// @nodoc
abstract mixin class $PokemonAbilitySlotCopyWith<$Res>  {
  factory $PokemonAbilitySlotCopyWith(PokemonAbilitySlot value, $Res Function(PokemonAbilitySlot) _then) = _$PokemonAbilitySlotCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'is_hidden') bool isHidden, int slot, PokemonAbilityInfo ability
});


$PokemonAbilityInfoCopyWith<$Res> get ability;

}
/// @nodoc
class _$PokemonAbilitySlotCopyWithImpl<$Res>
    implements $PokemonAbilitySlotCopyWith<$Res> {
  _$PokemonAbilitySlotCopyWithImpl(this._self, this._then);

  final PokemonAbilitySlot _self;
  final $Res Function(PokemonAbilitySlot) _then;

/// Create a copy of PokemonAbilitySlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isHidden = null,Object? slot = null,Object? ability = null,}) {
  return _then(_self.copyWith(
isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as int,ability: null == ability ? _self.ability : ability // ignore: cast_nullable_to_non_nullable
as PokemonAbilityInfo,
  ));
}
/// Create a copy of PokemonAbilitySlot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PokemonAbilityInfoCopyWith<$Res> get ability {
  
  return $PokemonAbilityInfoCopyWith<$Res>(_self.ability, (value) {
    return _then(_self.copyWith(ability: value));
  });
}
}


/// Adds pattern-matching-related methods to [PokemonAbilitySlot].
extension PokemonAbilitySlotPatterns on PokemonAbilitySlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PokemonAbilitySlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PokemonAbilitySlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PokemonAbilitySlot value)  $default,){
final _that = this;
switch (_that) {
case _PokemonAbilitySlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PokemonAbilitySlot value)?  $default,){
final _that = this;
switch (_that) {
case _PokemonAbilitySlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'is_hidden')  bool isHidden,  int slot,  PokemonAbilityInfo ability)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PokemonAbilitySlot() when $default != null:
return $default(_that.isHidden,_that.slot,_that.ability);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'is_hidden')  bool isHidden,  int slot,  PokemonAbilityInfo ability)  $default,) {final _that = this;
switch (_that) {
case _PokemonAbilitySlot():
return $default(_that.isHidden,_that.slot,_that.ability);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'is_hidden')  bool isHidden,  int slot,  PokemonAbilityInfo ability)?  $default,) {final _that = this;
switch (_that) {
case _PokemonAbilitySlot() when $default != null:
return $default(_that.isHidden,_that.slot,_that.ability);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PokemonAbilitySlot implements PokemonAbilitySlot {
  const _PokemonAbilitySlot({@JsonKey(name: 'is_hidden') required this.isHidden, required this.slot, required this.ability});
  factory _PokemonAbilitySlot.fromJson(Map<String, dynamic> json) => _$PokemonAbilitySlotFromJson(json);

@override@JsonKey(name: 'is_hidden') final  bool isHidden;
@override final  int slot;
@override final  PokemonAbilityInfo ability;

/// Create a copy of PokemonAbilitySlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PokemonAbilitySlotCopyWith<_PokemonAbilitySlot> get copyWith => __$PokemonAbilitySlotCopyWithImpl<_PokemonAbilitySlot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PokemonAbilitySlotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PokemonAbilitySlot&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.ability, ability) || other.ability == ability));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isHidden,slot,ability);

@override
String toString() {
  return 'PokemonAbilitySlot(isHidden: $isHidden, slot: $slot, ability: $ability)';
}


}

/// @nodoc
abstract mixin class _$PokemonAbilitySlotCopyWith<$Res> implements $PokemonAbilitySlotCopyWith<$Res> {
  factory _$PokemonAbilitySlotCopyWith(_PokemonAbilitySlot value, $Res Function(_PokemonAbilitySlot) _then) = __$PokemonAbilitySlotCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'is_hidden') bool isHidden, int slot, PokemonAbilityInfo ability
});


@override $PokemonAbilityInfoCopyWith<$Res> get ability;

}
/// @nodoc
class __$PokemonAbilitySlotCopyWithImpl<$Res>
    implements _$PokemonAbilitySlotCopyWith<$Res> {
  __$PokemonAbilitySlotCopyWithImpl(this._self, this._then);

  final _PokemonAbilitySlot _self;
  final $Res Function(_PokemonAbilitySlot) _then;

/// Create a copy of PokemonAbilitySlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isHidden = null,Object? slot = null,Object? ability = null,}) {
  return _then(_PokemonAbilitySlot(
isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as int,ability: null == ability ? _self.ability : ability // ignore: cast_nullable_to_non_nullable
as PokemonAbilityInfo,
  ));
}

/// Create a copy of PokemonAbilitySlot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PokemonAbilityInfoCopyWith<$Res> get ability {
  
  return $PokemonAbilityInfoCopyWith<$Res>(_self.ability, (value) {
    return _then(_self.copyWith(ability: value));
  });
}
}


/// @nodoc
mixin _$PokemonAbilityInfo {

 String get name; String get url;
/// Create a copy of PokemonAbilityInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PokemonAbilityInfoCopyWith<PokemonAbilityInfo> get copyWith => _$PokemonAbilityInfoCopyWithImpl<PokemonAbilityInfo>(this as PokemonAbilityInfo, _$identity);

  /// Serializes this PokemonAbilityInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PokemonAbilityInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'PokemonAbilityInfo(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class $PokemonAbilityInfoCopyWith<$Res>  {
  factory $PokemonAbilityInfoCopyWith(PokemonAbilityInfo value, $Res Function(PokemonAbilityInfo) _then) = _$PokemonAbilityInfoCopyWithImpl;
@useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class _$PokemonAbilityInfoCopyWithImpl<$Res>
    implements $PokemonAbilityInfoCopyWith<$Res> {
  _$PokemonAbilityInfoCopyWithImpl(this._self, this._then);

  final PokemonAbilityInfo _self;
  final $Res Function(PokemonAbilityInfo) _then;

/// Create a copy of PokemonAbilityInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? url = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PokemonAbilityInfo].
extension PokemonAbilityInfoPatterns on PokemonAbilityInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PokemonAbilityInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PokemonAbilityInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PokemonAbilityInfo value)  $default,){
final _that = this;
switch (_that) {
case _PokemonAbilityInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PokemonAbilityInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PokemonAbilityInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PokemonAbilityInfo() when $default != null:
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String url)  $default,) {final _that = this;
switch (_that) {
case _PokemonAbilityInfo():
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String url)?  $default,) {final _that = this;
switch (_that) {
case _PokemonAbilityInfo() when $default != null:
return $default(_that.name,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PokemonAbilityInfo implements PokemonAbilityInfo {
  const _PokemonAbilityInfo({required this.name, required this.url});
  factory _PokemonAbilityInfo.fromJson(Map<String, dynamic> json) => _$PokemonAbilityInfoFromJson(json);

@override final  String name;
@override final  String url;

/// Create a copy of PokemonAbilityInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PokemonAbilityInfoCopyWith<_PokemonAbilityInfo> get copyWith => __$PokemonAbilityInfoCopyWithImpl<_PokemonAbilityInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PokemonAbilityInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PokemonAbilityInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'PokemonAbilityInfo(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class _$PokemonAbilityInfoCopyWith<$Res> implements $PokemonAbilityInfoCopyWith<$Res> {
  factory _$PokemonAbilityInfoCopyWith(_PokemonAbilityInfo value, $Res Function(_PokemonAbilityInfo) _then) = __$PokemonAbilityInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class __$PokemonAbilityInfoCopyWithImpl<$Res>
    implements _$PokemonAbilityInfoCopyWith<$Res> {
  __$PokemonAbilityInfoCopyWithImpl(this._self, this._then);

  final _PokemonAbilityInfo _self;
  final $Res Function(_PokemonAbilityInfo) _then;

/// Create a copy of PokemonAbilityInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? url = null,}) {
  return _then(_PokemonAbilityInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PokemonMoveSlot {

 PokemonMoveInfo get move;@JsonKey(name: 'version_group_details') List<PokemonMoveVersionDetail> get versionGroupDetails;
/// Create a copy of PokemonMoveSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PokemonMoveSlotCopyWith<PokemonMoveSlot> get copyWith => _$PokemonMoveSlotCopyWithImpl<PokemonMoveSlot>(this as PokemonMoveSlot, _$identity);

  /// Serializes this PokemonMoveSlot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PokemonMoveSlot&&(identical(other.move, move) || other.move == move)&&const DeepCollectionEquality().equals(other.versionGroupDetails, versionGroupDetails));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,move,const DeepCollectionEquality().hash(versionGroupDetails));

@override
String toString() {
  return 'PokemonMoveSlot(move: $move, versionGroupDetails: $versionGroupDetails)';
}


}

/// @nodoc
abstract mixin class $PokemonMoveSlotCopyWith<$Res>  {
  factory $PokemonMoveSlotCopyWith(PokemonMoveSlot value, $Res Function(PokemonMoveSlot) _then) = _$PokemonMoveSlotCopyWithImpl;
@useResult
$Res call({
 PokemonMoveInfo move,@JsonKey(name: 'version_group_details') List<PokemonMoveVersionDetail> versionGroupDetails
});


$PokemonMoveInfoCopyWith<$Res> get move;

}
/// @nodoc
class _$PokemonMoveSlotCopyWithImpl<$Res>
    implements $PokemonMoveSlotCopyWith<$Res> {
  _$PokemonMoveSlotCopyWithImpl(this._self, this._then);

  final PokemonMoveSlot _self;
  final $Res Function(PokemonMoveSlot) _then;

/// Create a copy of PokemonMoveSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? move = null,Object? versionGroupDetails = null,}) {
  return _then(_self.copyWith(
move: null == move ? _self.move : move // ignore: cast_nullable_to_non_nullable
as PokemonMoveInfo,versionGroupDetails: null == versionGroupDetails ? _self.versionGroupDetails : versionGroupDetails // ignore: cast_nullable_to_non_nullable
as List<PokemonMoveVersionDetail>,
  ));
}
/// Create a copy of PokemonMoveSlot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PokemonMoveInfoCopyWith<$Res> get move {
  
  return $PokemonMoveInfoCopyWith<$Res>(_self.move, (value) {
    return _then(_self.copyWith(move: value));
  });
}
}


/// Adds pattern-matching-related methods to [PokemonMoveSlot].
extension PokemonMoveSlotPatterns on PokemonMoveSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PokemonMoveSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PokemonMoveSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PokemonMoveSlot value)  $default,){
final _that = this;
switch (_that) {
case _PokemonMoveSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PokemonMoveSlot value)?  $default,){
final _that = this;
switch (_that) {
case _PokemonMoveSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PokemonMoveInfo move, @JsonKey(name: 'version_group_details')  List<PokemonMoveVersionDetail> versionGroupDetails)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PokemonMoveSlot() when $default != null:
return $default(_that.move,_that.versionGroupDetails);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PokemonMoveInfo move, @JsonKey(name: 'version_group_details')  List<PokemonMoveVersionDetail> versionGroupDetails)  $default,) {final _that = this;
switch (_that) {
case _PokemonMoveSlot():
return $default(_that.move,_that.versionGroupDetails);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PokemonMoveInfo move, @JsonKey(name: 'version_group_details')  List<PokemonMoveVersionDetail> versionGroupDetails)?  $default,) {final _that = this;
switch (_that) {
case _PokemonMoveSlot() when $default != null:
return $default(_that.move,_that.versionGroupDetails);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PokemonMoveSlot implements PokemonMoveSlot {
  const _PokemonMoveSlot({required this.move, @JsonKey(name: 'version_group_details') final  List<PokemonMoveVersionDetail> versionGroupDetails = const []}): _versionGroupDetails = versionGroupDetails;
  factory _PokemonMoveSlot.fromJson(Map<String, dynamic> json) => _$PokemonMoveSlotFromJson(json);

@override final  PokemonMoveInfo move;
 final  List<PokemonMoveVersionDetail> _versionGroupDetails;
@override@JsonKey(name: 'version_group_details') List<PokemonMoveVersionDetail> get versionGroupDetails {
  if (_versionGroupDetails is EqualUnmodifiableListView) return _versionGroupDetails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_versionGroupDetails);
}


/// Create a copy of PokemonMoveSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PokemonMoveSlotCopyWith<_PokemonMoveSlot> get copyWith => __$PokemonMoveSlotCopyWithImpl<_PokemonMoveSlot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PokemonMoveSlotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PokemonMoveSlot&&(identical(other.move, move) || other.move == move)&&const DeepCollectionEquality().equals(other._versionGroupDetails, _versionGroupDetails));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,move,const DeepCollectionEquality().hash(_versionGroupDetails));

@override
String toString() {
  return 'PokemonMoveSlot(move: $move, versionGroupDetails: $versionGroupDetails)';
}


}

/// @nodoc
abstract mixin class _$PokemonMoveSlotCopyWith<$Res> implements $PokemonMoveSlotCopyWith<$Res> {
  factory _$PokemonMoveSlotCopyWith(_PokemonMoveSlot value, $Res Function(_PokemonMoveSlot) _then) = __$PokemonMoveSlotCopyWithImpl;
@override @useResult
$Res call({
 PokemonMoveInfo move,@JsonKey(name: 'version_group_details') List<PokemonMoveVersionDetail> versionGroupDetails
});


@override $PokemonMoveInfoCopyWith<$Res> get move;

}
/// @nodoc
class __$PokemonMoveSlotCopyWithImpl<$Res>
    implements _$PokemonMoveSlotCopyWith<$Res> {
  __$PokemonMoveSlotCopyWithImpl(this._self, this._then);

  final _PokemonMoveSlot _self;
  final $Res Function(_PokemonMoveSlot) _then;

/// Create a copy of PokemonMoveSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? move = null,Object? versionGroupDetails = null,}) {
  return _then(_PokemonMoveSlot(
move: null == move ? _self.move : move // ignore: cast_nullable_to_non_nullable
as PokemonMoveInfo,versionGroupDetails: null == versionGroupDetails ? _self._versionGroupDetails : versionGroupDetails // ignore: cast_nullable_to_non_nullable
as List<PokemonMoveVersionDetail>,
  ));
}

/// Create a copy of PokemonMoveSlot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PokemonMoveInfoCopyWith<$Res> get move {
  
  return $PokemonMoveInfoCopyWith<$Res>(_self.move, (value) {
    return _then(_self.copyWith(move: value));
  });
}
}


/// @nodoc
mixin _$PokemonMoveVersionDetail {

@JsonKey(name: 'level_learned_at') int get levelLearnedAt;@JsonKey(name: 'move_learn_method') NamedAPIResource get moveLearnMethod;@JsonKey(name: 'version_group') NamedAPIResource? get versionGroup;
/// Create a copy of PokemonMoveVersionDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PokemonMoveVersionDetailCopyWith<PokemonMoveVersionDetail> get copyWith => _$PokemonMoveVersionDetailCopyWithImpl<PokemonMoveVersionDetail>(this as PokemonMoveVersionDetail, _$identity);

  /// Serializes this PokemonMoveVersionDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PokemonMoveVersionDetail&&(identical(other.levelLearnedAt, levelLearnedAt) || other.levelLearnedAt == levelLearnedAt)&&(identical(other.moveLearnMethod, moveLearnMethod) || other.moveLearnMethod == moveLearnMethod)&&(identical(other.versionGroup, versionGroup) || other.versionGroup == versionGroup));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,levelLearnedAt,moveLearnMethod,versionGroup);

@override
String toString() {
  return 'PokemonMoveVersionDetail(levelLearnedAt: $levelLearnedAt, moveLearnMethod: $moveLearnMethod, versionGroup: $versionGroup)';
}


}

/// @nodoc
abstract mixin class $PokemonMoveVersionDetailCopyWith<$Res>  {
  factory $PokemonMoveVersionDetailCopyWith(PokemonMoveVersionDetail value, $Res Function(PokemonMoveVersionDetail) _then) = _$PokemonMoveVersionDetailCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'level_learned_at') int levelLearnedAt,@JsonKey(name: 'move_learn_method') NamedAPIResource moveLearnMethod,@JsonKey(name: 'version_group') NamedAPIResource? versionGroup
});


$NamedAPIResourceCopyWith<$Res> get moveLearnMethod;$NamedAPIResourceCopyWith<$Res>? get versionGroup;

}
/// @nodoc
class _$PokemonMoveVersionDetailCopyWithImpl<$Res>
    implements $PokemonMoveVersionDetailCopyWith<$Res> {
  _$PokemonMoveVersionDetailCopyWithImpl(this._self, this._then);

  final PokemonMoveVersionDetail _self;
  final $Res Function(PokemonMoveVersionDetail) _then;

/// Create a copy of PokemonMoveVersionDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? levelLearnedAt = null,Object? moveLearnMethod = null,Object? versionGroup = freezed,}) {
  return _then(_self.copyWith(
levelLearnedAt: null == levelLearnedAt ? _self.levelLearnedAt : levelLearnedAt // ignore: cast_nullable_to_non_nullable
as int,moveLearnMethod: null == moveLearnMethod ? _self.moveLearnMethod : moveLearnMethod // ignore: cast_nullable_to_non_nullable
as NamedAPIResource,versionGroup: freezed == versionGroup ? _self.versionGroup : versionGroup // ignore: cast_nullable_to_non_nullable
as NamedAPIResource?,
  ));
}
/// Create a copy of PokemonMoveVersionDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedAPIResourceCopyWith<$Res> get moveLearnMethod {
  
  return $NamedAPIResourceCopyWith<$Res>(_self.moveLearnMethod, (value) {
    return _then(_self.copyWith(moveLearnMethod: value));
  });
}/// Create a copy of PokemonMoveVersionDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedAPIResourceCopyWith<$Res>? get versionGroup {
    if (_self.versionGroup == null) {
    return null;
  }

  return $NamedAPIResourceCopyWith<$Res>(_self.versionGroup!, (value) {
    return _then(_self.copyWith(versionGroup: value));
  });
}
}


/// Adds pattern-matching-related methods to [PokemonMoveVersionDetail].
extension PokemonMoveVersionDetailPatterns on PokemonMoveVersionDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PokemonMoveVersionDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PokemonMoveVersionDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PokemonMoveVersionDetail value)  $default,){
final _that = this;
switch (_that) {
case _PokemonMoveVersionDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PokemonMoveVersionDetail value)?  $default,){
final _that = this;
switch (_that) {
case _PokemonMoveVersionDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'level_learned_at')  int levelLearnedAt, @JsonKey(name: 'move_learn_method')  NamedAPIResource moveLearnMethod, @JsonKey(name: 'version_group')  NamedAPIResource? versionGroup)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PokemonMoveVersionDetail() when $default != null:
return $default(_that.levelLearnedAt,_that.moveLearnMethod,_that.versionGroup);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'level_learned_at')  int levelLearnedAt, @JsonKey(name: 'move_learn_method')  NamedAPIResource moveLearnMethod, @JsonKey(name: 'version_group')  NamedAPIResource? versionGroup)  $default,) {final _that = this;
switch (_that) {
case _PokemonMoveVersionDetail():
return $default(_that.levelLearnedAt,_that.moveLearnMethod,_that.versionGroup);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'level_learned_at')  int levelLearnedAt, @JsonKey(name: 'move_learn_method')  NamedAPIResource moveLearnMethod, @JsonKey(name: 'version_group')  NamedAPIResource? versionGroup)?  $default,) {final _that = this;
switch (_that) {
case _PokemonMoveVersionDetail() when $default != null:
return $default(_that.levelLearnedAt,_that.moveLearnMethod,_that.versionGroup);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PokemonMoveVersionDetail implements PokemonMoveVersionDetail {
  const _PokemonMoveVersionDetail({@JsonKey(name: 'level_learned_at') required this.levelLearnedAt, @JsonKey(name: 'move_learn_method') required this.moveLearnMethod, @JsonKey(name: 'version_group') this.versionGroup});
  factory _PokemonMoveVersionDetail.fromJson(Map<String, dynamic> json) => _$PokemonMoveVersionDetailFromJson(json);

@override@JsonKey(name: 'level_learned_at') final  int levelLearnedAt;
@override@JsonKey(name: 'move_learn_method') final  NamedAPIResource moveLearnMethod;
@override@JsonKey(name: 'version_group') final  NamedAPIResource? versionGroup;

/// Create a copy of PokemonMoveVersionDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PokemonMoveVersionDetailCopyWith<_PokemonMoveVersionDetail> get copyWith => __$PokemonMoveVersionDetailCopyWithImpl<_PokemonMoveVersionDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PokemonMoveVersionDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PokemonMoveVersionDetail&&(identical(other.levelLearnedAt, levelLearnedAt) || other.levelLearnedAt == levelLearnedAt)&&(identical(other.moveLearnMethod, moveLearnMethod) || other.moveLearnMethod == moveLearnMethod)&&(identical(other.versionGroup, versionGroup) || other.versionGroup == versionGroup));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,levelLearnedAt,moveLearnMethod,versionGroup);

@override
String toString() {
  return 'PokemonMoveVersionDetail(levelLearnedAt: $levelLearnedAt, moveLearnMethod: $moveLearnMethod, versionGroup: $versionGroup)';
}


}

/// @nodoc
abstract mixin class _$PokemonMoveVersionDetailCopyWith<$Res> implements $PokemonMoveVersionDetailCopyWith<$Res> {
  factory _$PokemonMoveVersionDetailCopyWith(_PokemonMoveVersionDetail value, $Res Function(_PokemonMoveVersionDetail) _then) = __$PokemonMoveVersionDetailCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'level_learned_at') int levelLearnedAt,@JsonKey(name: 'move_learn_method') NamedAPIResource moveLearnMethod,@JsonKey(name: 'version_group') NamedAPIResource? versionGroup
});


@override $NamedAPIResourceCopyWith<$Res> get moveLearnMethod;@override $NamedAPIResourceCopyWith<$Res>? get versionGroup;

}
/// @nodoc
class __$PokemonMoveVersionDetailCopyWithImpl<$Res>
    implements _$PokemonMoveVersionDetailCopyWith<$Res> {
  __$PokemonMoveVersionDetailCopyWithImpl(this._self, this._then);

  final _PokemonMoveVersionDetail _self;
  final $Res Function(_PokemonMoveVersionDetail) _then;

/// Create a copy of PokemonMoveVersionDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? levelLearnedAt = null,Object? moveLearnMethod = null,Object? versionGroup = freezed,}) {
  return _then(_PokemonMoveVersionDetail(
levelLearnedAt: null == levelLearnedAt ? _self.levelLearnedAt : levelLearnedAt // ignore: cast_nullable_to_non_nullable
as int,moveLearnMethod: null == moveLearnMethod ? _self.moveLearnMethod : moveLearnMethod // ignore: cast_nullable_to_non_nullable
as NamedAPIResource,versionGroup: freezed == versionGroup ? _self.versionGroup : versionGroup // ignore: cast_nullable_to_non_nullable
as NamedAPIResource?,
  ));
}

/// Create a copy of PokemonMoveVersionDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedAPIResourceCopyWith<$Res> get moveLearnMethod {
  
  return $NamedAPIResourceCopyWith<$Res>(_self.moveLearnMethod, (value) {
    return _then(_self.copyWith(moveLearnMethod: value));
  });
}/// Create a copy of PokemonMoveVersionDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedAPIResourceCopyWith<$Res>? get versionGroup {
    if (_self.versionGroup == null) {
    return null;
  }

  return $NamedAPIResourceCopyWith<$Res>(_self.versionGroup!, (value) {
    return _then(_self.copyWith(versionGroup: value));
  });
}
}


/// @nodoc
mixin _$NamedAPIResource {

 String get name; String get url;
/// Create a copy of NamedAPIResource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NamedAPIResourceCopyWith<NamedAPIResource> get copyWith => _$NamedAPIResourceCopyWithImpl<NamedAPIResource>(this as NamedAPIResource, _$identity);

  /// Serializes this NamedAPIResource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NamedAPIResource&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'NamedAPIResource(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class $NamedAPIResourceCopyWith<$Res>  {
  factory $NamedAPIResourceCopyWith(NamedAPIResource value, $Res Function(NamedAPIResource) _then) = _$NamedAPIResourceCopyWithImpl;
@useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class _$NamedAPIResourceCopyWithImpl<$Res>
    implements $NamedAPIResourceCopyWith<$Res> {
  _$NamedAPIResourceCopyWithImpl(this._self, this._then);

  final NamedAPIResource _self;
  final $Res Function(NamedAPIResource) _then;

/// Create a copy of NamedAPIResource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? url = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NamedAPIResource].
extension NamedAPIResourcePatterns on NamedAPIResource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NamedAPIResource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NamedAPIResource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NamedAPIResource value)  $default,){
final _that = this;
switch (_that) {
case _NamedAPIResource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NamedAPIResource value)?  $default,){
final _that = this;
switch (_that) {
case _NamedAPIResource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NamedAPIResource() when $default != null:
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String url)  $default,) {final _that = this;
switch (_that) {
case _NamedAPIResource():
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String url)?  $default,) {final _that = this;
switch (_that) {
case _NamedAPIResource() when $default != null:
return $default(_that.name,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NamedAPIResource implements NamedAPIResource {
  const _NamedAPIResource({required this.name, required this.url});
  factory _NamedAPIResource.fromJson(Map<String, dynamic> json) => _$NamedAPIResourceFromJson(json);

@override final  String name;
@override final  String url;

/// Create a copy of NamedAPIResource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NamedAPIResourceCopyWith<_NamedAPIResource> get copyWith => __$NamedAPIResourceCopyWithImpl<_NamedAPIResource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NamedAPIResourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NamedAPIResource&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'NamedAPIResource(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class _$NamedAPIResourceCopyWith<$Res> implements $NamedAPIResourceCopyWith<$Res> {
  factory _$NamedAPIResourceCopyWith(_NamedAPIResource value, $Res Function(_NamedAPIResource) _then) = __$NamedAPIResourceCopyWithImpl;
@override @useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class __$NamedAPIResourceCopyWithImpl<$Res>
    implements _$NamedAPIResourceCopyWith<$Res> {
  __$NamedAPIResourceCopyWithImpl(this._self, this._then);

  final _NamedAPIResource _self;
  final $Res Function(_NamedAPIResource) _then;

/// Create a copy of NamedAPIResource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? url = null,}) {
  return _then(_NamedAPIResource(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PokemonMoveInfo {

 String get name; String get url;
/// Create a copy of PokemonMoveInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PokemonMoveInfoCopyWith<PokemonMoveInfo> get copyWith => _$PokemonMoveInfoCopyWithImpl<PokemonMoveInfo>(this as PokemonMoveInfo, _$identity);

  /// Serializes this PokemonMoveInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PokemonMoveInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'PokemonMoveInfo(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class $PokemonMoveInfoCopyWith<$Res>  {
  factory $PokemonMoveInfoCopyWith(PokemonMoveInfo value, $Res Function(PokemonMoveInfo) _then) = _$PokemonMoveInfoCopyWithImpl;
@useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class _$PokemonMoveInfoCopyWithImpl<$Res>
    implements $PokemonMoveInfoCopyWith<$Res> {
  _$PokemonMoveInfoCopyWithImpl(this._self, this._then);

  final PokemonMoveInfo _self;
  final $Res Function(PokemonMoveInfo) _then;

/// Create a copy of PokemonMoveInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? url = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PokemonMoveInfo].
extension PokemonMoveInfoPatterns on PokemonMoveInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PokemonMoveInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PokemonMoveInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PokemonMoveInfo value)  $default,){
final _that = this;
switch (_that) {
case _PokemonMoveInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PokemonMoveInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PokemonMoveInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PokemonMoveInfo() when $default != null:
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String url)  $default,) {final _that = this;
switch (_that) {
case _PokemonMoveInfo():
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String url)?  $default,) {final _that = this;
switch (_that) {
case _PokemonMoveInfo() when $default != null:
return $default(_that.name,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PokemonMoveInfo implements PokemonMoveInfo {
  const _PokemonMoveInfo({required this.name, required this.url});
  factory _PokemonMoveInfo.fromJson(Map<String, dynamic> json) => _$PokemonMoveInfoFromJson(json);

@override final  String name;
@override final  String url;

/// Create a copy of PokemonMoveInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PokemonMoveInfoCopyWith<_PokemonMoveInfo> get copyWith => __$PokemonMoveInfoCopyWithImpl<_PokemonMoveInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PokemonMoveInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PokemonMoveInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'PokemonMoveInfo(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class _$PokemonMoveInfoCopyWith<$Res> implements $PokemonMoveInfoCopyWith<$Res> {
  factory _$PokemonMoveInfoCopyWith(_PokemonMoveInfo value, $Res Function(_PokemonMoveInfo) _then) = __$PokemonMoveInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class __$PokemonMoveInfoCopyWithImpl<$Res>
    implements _$PokemonMoveInfoCopyWith<$Res> {
  __$PokemonMoveInfoCopyWithImpl(this._self, this._then);

  final _PokemonMoveInfo _self;
  final $Res Function(_PokemonMoveInfo) _then;

/// Create a copy of PokemonMoveInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? url = null,}) {
  return _then(_PokemonMoveInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
