// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'move.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Move {

 int get id; String get name; int? get accuracy; int? get power; int get pp; MoveType get type;@JsonKey(name: 'damage_class') MoveDamageClass? get damageClass;@JsonKey(name: 'effect_entries') List<MoveEffectEntry> get effectEntries;
/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveCopyWith<Move> get copyWith => _$MoveCopyWithImpl<Move>(this as Move, _$identity);

  /// Serializes this Move to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Move&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.power, power) || other.power == power)&&(identical(other.pp, pp) || other.pp == pp)&&(identical(other.type, type) || other.type == type)&&(identical(other.damageClass, damageClass) || other.damageClass == damageClass)&&const DeepCollectionEquality().equals(other.effectEntries, effectEntries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,accuracy,power,pp,type,damageClass,const DeepCollectionEquality().hash(effectEntries));

@override
String toString() {
  return 'Move(id: $id, name: $name, accuracy: $accuracy, power: $power, pp: $pp, type: $type, damageClass: $damageClass, effectEntries: $effectEntries)';
}


}

/// @nodoc
abstract mixin class $MoveCopyWith<$Res>  {
  factory $MoveCopyWith(Move value, $Res Function(Move) _then) = _$MoveCopyWithImpl;
@useResult
$Res call({
 int id, String name, int? accuracy, int? power, int pp, MoveType type,@JsonKey(name: 'damage_class') MoveDamageClass? damageClass,@JsonKey(name: 'effect_entries') List<MoveEffectEntry> effectEntries
});


$MoveTypeCopyWith<$Res> get type;$MoveDamageClassCopyWith<$Res>? get damageClass;

}
/// @nodoc
class _$MoveCopyWithImpl<$Res>
    implements $MoveCopyWith<$Res> {
  _$MoveCopyWithImpl(this._self, this._then);

  final Move _self;
  final $Res Function(Move) _then;

/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? accuracy = freezed,Object? power = freezed,Object? pp = null,Object? type = null,Object? damageClass = freezed,Object? effectEntries = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,accuracy: freezed == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as int?,power: freezed == power ? _self.power : power // ignore: cast_nullable_to_non_nullable
as int?,pp: null == pp ? _self.pp : pp // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MoveType,damageClass: freezed == damageClass ? _self.damageClass : damageClass // ignore: cast_nullable_to_non_nullable
as MoveDamageClass?,effectEntries: null == effectEntries ? _self.effectEntries : effectEntries // ignore: cast_nullable_to_non_nullable
as List<MoveEffectEntry>,
  ));
}
/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoveTypeCopyWith<$Res> get type {
  
  return $MoveTypeCopyWith<$Res>(_self.type, (value) {
    return _then(_self.copyWith(type: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoveDamageClassCopyWith<$Res>? get damageClass {
    if (_self.damageClass == null) {
    return null;
  }

  return $MoveDamageClassCopyWith<$Res>(_self.damageClass!, (value) {
    return _then(_self.copyWith(damageClass: value));
  });
}
}


/// Adds pattern-matching-related methods to [Move].
extension MovePatterns on Move {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Move value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Move() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Move value)  $default,){
final _that = this;
switch (_that) {
case _Move():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Move value)?  $default,){
final _that = this;
switch (_that) {
case _Move() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int? accuracy,  int? power,  int pp,  MoveType type, @JsonKey(name: 'damage_class')  MoveDamageClass? damageClass, @JsonKey(name: 'effect_entries')  List<MoveEffectEntry> effectEntries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Move() when $default != null:
return $default(_that.id,_that.name,_that.accuracy,_that.power,_that.pp,_that.type,_that.damageClass,_that.effectEntries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int? accuracy,  int? power,  int pp,  MoveType type, @JsonKey(name: 'damage_class')  MoveDamageClass? damageClass, @JsonKey(name: 'effect_entries')  List<MoveEffectEntry> effectEntries)  $default,) {final _that = this;
switch (_that) {
case _Move():
return $default(_that.id,_that.name,_that.accuracy,_that.power,_that.pp,_that.type,_that.damageClass,_that.effectEntries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int? accuracy,  int? power,  int pp,  MoveType type, @JsonKey(name: 'damage_class')  MoveDamageClass? damageClass, @JsonKey(name: 'effect_entries')  List<MoveEffectEntry> effectEntries)?  $default,) {final _that = this;
switch (_that) {
case _Move() when $default != null:
return $default(_that.id,_that.name,_that.accuracy,_that.power,_that.pp,_that.type,_that.damageClass,_that.effectEntries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Move implements Move {
  const _Move({required this.id, required this.name, this.accuracy, this.power, required this.pp, required this.type, @JsonKey(name: 'damage_class') this.damageClass, @JsonKey(name: 'effect_entries') required final  List<MoveEffectEntry> effectEntries}): _effectEntries = effectEntries;
  factory _Move.fromJson(Map<String, dynamic> json) => _$MoveFromJson(json);

@override final  int id;
@override final  String name;
@override final  int? accuracy;
@override final  int? power;
@override final  int pp;
@override final  MoveType type;
@override@JsonKey(name: 'damage_class') final  MoveDamageClass? damageClass;
 final  List<MoveEffectEntry> _effectEntries;
@override@JsonKey(name: 'effect_entries') List<MoveEffectEntry> get effectEntries {
  if (_effectEntries is EqualUnmodifiableListView) return _effectEntries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_effectEntries);
}


/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoveCopyWith<_Move> get copyWith => __$MoveCopyWithImpl<_Move>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Move&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.power, power) || other.power == power)&&(identical(other.pp, pp) || other.pp == pp)&&(identical(other.type, type) || other.type == type)&&(identical(other.damageClass, damageClass) || other.damageClass == damageClass)&&const DeepCollectionEquality().equals(other._effectEntries, _effectEntries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,accuracy,power,pp,type,damageClass,const DeepCollectionEquality().hash(_effectEntries));

@override
String toString() {
  return 'Move(id: $id, name: $name, accuracy: $accuracy, power: $power, pp: $pp, type: $type, damageClass: $damageClass, effectEntries: $effectEntries)';
}


}

/// @nodoc
abstract mixin class _$MoveCopyWith<$Res> implements $MoveCopyWith<$Res> {
  factory _$MoveCopyWith(_Move value, $Res Function(_Move) _then) = __$MoveCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int? accuracy, int? power, int pp, MoveType type,@JsonKey(name: 'damage_class') MoveDamageClass? damageClass,@JsonKey(name: 'effect_entries') List<MoveEffectEntry> effectEntries
});


@override $MoveTypeCopyWith<$Res> get type;@override $MoveDamageClassCopyWith<$Res>? get damageClass;

}
/// @nodoc
class __$MoveCopyWithImpl<$Res>
    implements _$MoveCopyWith<$Res> {
  __$MoveCopyWithImpl(this._self, this._then);

  final _Move _self;
  final $Res Function(_Move) _then;

/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? accuracy = freezed,Object? power = freezed,Object? pp = null,Object? type = null,Object? damageClass = freezed,Object? effectEntries = null,}) {
  return _then(_Move(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,accuracy: freezed == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as int?,power: freezed == power ? _self.power : power // ignore: cast_nullable_to_non_nullable
as int?,pp: null == pp ? _self.pp : pp // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MoveType,damageClass: freezed == damageClass ? _self.damageClass : damageClass // ignore: cast_nullable_to_non_nullable
as MoveDamageClass?,effectEntries: null == effectEntries ? _self._effectEntries : effectEntries // ignore: cast_nullable_to_non_nullable
as List<MoveEffectEntry>,
  ));
}

/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoveTypeCopyWith<$Res> get type {
  
  return $MoveTypeCopyWith<$Res>(_self.type, (value) {
    return _then(_self.copyWith(type: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoveDamageClassCopyWith<$Res>? get damageClass {
    if (_self.damageClass == null) {
    return null;
  }

  return $MoveDamageClassCopyWith<$Res>(_self.damageClass!, (value) {
    return _then(_self.copyWith(damageClass: value));
  });
}
}


/// @nodoc
mixin _$MoveDamageClass {

 String get name; String get url;
/// Create a copy of MoveDamageClass
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveDamageClassCopyWith<MoveDamageClass> get copyWith => _$MoveDamageClassCopyWithImpl<MoveDamageClass>(this as MoveDamageClass, _$identity);

  /// Serializes this MoveDamageClass to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveDamageClass&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'MoveDamageClass(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class $MoveDamageClassCopyWith<$Res>  {
  factory $MoveDamageClassCopyWith(MoveDamageClass value, $Res Function(MoveDamageClass) _then) = _$MoveDamageClassCopyWithImpl;
@useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class _$MoveDamageClassCopyWithImpl<$Res>
    implements $MoveDamageClassCopyWith<$Res> {
  _$MoveDamageClassCopyWithImpl(this._self, this._then);

  final MoveDamageClass _self;
  final $Res Function(MoveDamageClass) _then;

/// Create a copy of MoveDamageClass
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? url = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MoveDamageClass].
extension MoveDamageClassPatterns on MoveDamageClass {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoveDamageClass value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoveDamageClass() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoveDamageClass value)  $default,){
final _that = this;
switch (_that) {
case _MoveDamageClass():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoveDamageClass value)?  $default,){
final _that = this;
switch (_that) {
case _MoveDamageClass() when $default != null:
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
case _MoveDamageClass() when $default != null:
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
case _MoveDamageClass():
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
case _MoveDamageClass() when $default != null:
return $default(_that.name,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoveDamageClass implements MoveDamageClass {
  const _MoveDamageClass({required this.name, required this.url});
  factory _MoveDamageClass.fromJson(Map<String, dynamic> json) => _$MoveDamageClassFromJson(json);

@override final  String name;
@override final  String url;

/// Create a copy of MoveDamageClass
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoveDamageClassCopyWith<_MoveDamageClass> get copyWith => __$MoveDamageClassCopyWithImpl<_MoveDamageClass>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveDamageClassToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoveDamageClass&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'MoveDamageClass(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class _$MoveDamageClassCopyWith<$Res> implements $MoveDamageClassCopyWith<$Res> {
  factory _$MoveDamageClassCopyWith(_MoveDamageClass value, $Res Function(_MoveDamageClass) _then) = __$MoveDamageClassCopyWithImpl;
@override @useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class __$MoveDamageClassCopyWithImpl<$Res>
    implements _$MoveDamageClassCopyWith<$Res> {
  __$MoveDamageClassCopyWithImpl(this._self, this._then);

  final _MoveDamageClass _self;
  final $Res Function(_MoveDamageClass) _then;

/// Create a copy of MoveDamageClass
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? url = null,}) {
  return _then(_MoveDamageClass(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MoveType {

 String get name; String get url;
/// Create a copy of MoveType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveTypeCopyWith<MoveType> get copyWith => _$MoveTypeCopyWithImpl<MoveType>(this as MoveType, _$identity);

  /// Serializes this MoveType to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveType&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'MoveType(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class $MoveTypeCopyWith<$Res>  {
  factory $MoveTypeCopyWith(MoveType value, $Res Function(MoveType) _then) = _$MoveTypeCopyWithImpl;
@useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class _$MoveTypeCopyWithImpl<$Res>
    implements $MoveTypeCopyWith<$Res> {
  _$MoveTypeCopyWithImpl(this._self, this._then);

  final MoveType _self;
  final $Res Function(MoveType) _then;

/// Create a copy of MoveType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? url = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MoveType].
extension MoveTypePatterns on MoveType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoveType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoveType() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoveType value)  $default,){
final _that = this;
switch (_that) {
case _MoveType():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoveType value)?  $default,){
final _that = this;
switch (_that) {
case _MoveType() when $default != null:
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
case _MoveType() when $default != null:
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
case _MoveType():
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
case _MoveType() when $default != null:
return $default(_that.name,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoveType implements MoveType {
  const _MoveType({required this.name, required this.url});
  factory _MoveType.fromJson(Map<String, dynamic> json) => _$MoveTypeFromJson(json);

@override final  String name;
@override final  String url;

/// Create a copy of MoveType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoveTypeCopyWith<_MoveType> get copyWith => __$MoveTypeCopyWithImpl<_MoveType>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveTypeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoveType&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'MoveType(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class _$MoveTypeCopyWith<$Res> implements $MoveTypeCopyWith<$Res> {
  factory _$MoveTypeCopyWith(_MoveType value, $Res Function(_MoveType) _then) = __$MoveTypeCopyWithImpl;
@override @useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class __$MoveTypeCopyWithImpl<$Res>
    implements _$MoveTypeCopyWith<$Res> {
  __$MoveTypeCopyWithImpl(this._self, this._then);

  final _MoveType _self;
  final $Res Function(_MoveType) _then;

/// Create a copy of MoveType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? url = null,}) {
  return _then(_MoveType(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MoveEffectEntry {

 String get effect;@JsonKey(name: 'short_effect') String get shortEffect;
/// Create a copy of MoveEffectEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveEffectEntryCopyWith<MoveEffectEntry> get copyWith => _$MoveEffectEntryCopyWithImpl<MoveEffectEntry>(this as MoveEffectEntry, _$identity);

  /// Serializes this MoveEffectEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveEffectEntry&&(identical(other.effect, effect) || other.effect == effect)&&(identical(other.shortEffect, shortEffect) || other.shortEffect == shortEffect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,effect,shortEffect);

@override
String toString() {
  return 'MoveEffectEntry(effect: $effect, shortEffect: $shortEffect)';
}


}

/// @nodoc
abstract mixin class $MoveEffectEntryCopyWith<$Res>  {
  factory $MoveEffectEntryCopyWith(MoveEffectEntry value, $Res Function(MoveEffectEntry) _then) = _$MoveEffectEntryCopyWithImpl;
@useResult
$Res call({
 String effect,@JsonKey(name: 'short_effect') String shortEffect
});




}
/// @nodoc
class _$MoveEffectEntryCopyWithImpl<$Res>
    implements $MoveEffectEntryCopyWith<$Res> {
  _$MoveEffectEntryCopyWithImpl(this._self, this._then);

  final MoveEffectEntry _self;
  final $Res Function(MoveEffectEntry) _then;

/// Create a copy of MoveEffectEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? effect = null,Object? shortEffect = null,}) {
  return _then(_self.copyWith(
effect: null == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as String,shortEffect: null == shortEffect ? _self.shortEffect : shortEffect // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MoveEffectEntry].
extension MoveEffectEntryPatterns on MoveEffectEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoveEffectEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoveEffectEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoveEffectEntry value)  $default,){
final _that = this;
switch (_that) {
case _MoveEffectEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoveEffectEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MoveEffectEntry() when $default != null:
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
case _MoveEffectEntry() when $default != null:
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
case _MoveEffectEntry():
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
case _MoveEffectEntry() when $default != null:
return $default(_that.effect,_that.shortEffect);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoveEffectEntry implements MoveEffectEntry {
  const _MoveEffectEntry({required this.effect, @JsonKey(name: 'short_effect') required this.shortEffect});
  factory _MoveEffectEntry.fromJson(Map<String, dynamic> json) => _$MoveEffectEntryFromJson(json);

@override final  String effect;
@override@JsonKey(name: 'short_effect') final  String shortEffect;

/// Create a copy of MoveEffectEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoveEffectEntryCopyWith<_MoveEffectEntry> get copyWith => __$MoveEffectEntryCopyWithImpl<_MoveEffectEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveEffectEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoveEffectEntry&&(identical(other.effect, effect) || other.effect == effect)&&(identical(other.shortEffect, shortEffect) || other.shortEffect == shortEffect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,effect,shortEffect);

@override
String toString() {
  return 'MoveEffectEntry(effect: $effect, shortEffect: $shortEffect)';
}


}

/// @nodoc
abstract mixin class _$MoveEffectEntryCopyWith<$Res> implements $MoveEffectEntryCopyWith<$Res> {
  factory _$MoveEffectEntryCopyWith(_MoveEffectEntry value, $Res Function(_MoveEffectEntry) _then) = __$MoveEffectEntryCopyWithImpl;
@override @useResult
$Res call({
 String effect,@JsonKey(name: 'short_effect') String shortEffect
});




}
/// @nodoc
class __$MoveEffectEntryCopyWithImpl<$Res>
    implements _$MoveEffectEntryCopyWith<$Res> {
  __$MoveEffectEntryCopyWithImpl(this._self, this._then);

  final _MoveEffectEntry _self;
  final $Res Function(_MoveEffectEntry) _then;

/// Create a copy of MoveEffectEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? effect = null,Object? shortEffect = null,}) {
  return _then(_MoveEffectEntry(
effect: null == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as String,shortEffect: null == shortEffect ? _self.shortEffect : shortEffect // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
