import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show compute;
import '../../models/pokemon.dart';
import '../../models/move.dart';
import '../../models/ability.dart';
import '../../models/item.dart';

class PokeApi {
  final Dio _dio;

  PokeApi(this._dio);

  // Fetch list of Pokemon (returns list of Map containing name and url)
  Future<List<Map<String, dynamic>>> fetchPokemonList({int limit = 20, int offset = 0}) async {
    final response = await _dio.get('pokemon', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
    final results = response.data['results'] as List;
    return results.map((item) => item as Map<String, dynamic>).toList();
  }

  // Fetch individual Pokemon details
  Future<Pokemon> fetchPokemonDetails(String nameOrId) async {
    // Payloads run 100-400 KB (mostly the moves array); decode them off the
    // main isolate so the profile screen never janks while parsing.
    final response = await _dio.get<String>(
      'pokemon/$nameOrId',
      options: Options(responseType: ResponseType.plain),
    );
    final raw = response.data;
    if (raw == null || raw.isEmpty) {
      throw StateError('Empty response for pokemon/$nameOrId');
    }
    final Map<String, dynamic> data =
        await compute((String s) => jsonDecode(s) as Map<String, dynamic>, raw);

    // Transform PokeAPI response to match our freezed model
    if (data['species'] != null && data['species']['url'] != null) {
      final url = data['species']['url'] as String;
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final idString = segments.lastWhere((s) => s.isNotEmpty);
      data['speciesId'] = int.tryParse(idString) ?? data['id'];
    } else {
      data['speciesId'] = data['id'];
    }

    // Our model expects forms and evolutionInfo to be String? (JSON strings or null)
    // PokeAPI returns lists or objects, so we need to stringify them or drop them
    if (data['forms'] != null) {
      data['forms'] = null; // Ignore complex forms parsing for now
    }
    
    return Pokemon.fromJson(data);
  }

  // Fetch Move details
  Future<Move> fetchMoveDetails(int id) async {
    final response = await _dio.get('move/$id');
    return Move.fromJson(response.data);
  }

  // Fetch Ability details
  Future<Ability> fetchAbilityDetails(int id) async {
    final response = await _dio.get('ability/$id');
    return Ability.fromJson(response.data);
  }

  // Fetch Item details
  Future<Item> fetchItemDetails(int id) async {
    final response = await _dio.get('item/$id');
    return Item.fromJson(response.data);
  }
}
