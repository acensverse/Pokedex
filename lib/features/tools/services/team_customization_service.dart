import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// User customizations for a single Pokémon in a team party slot.
/// Allows full customizability of stats, level, nature, ability, held item, moves,
/// and Champions-format Stat Points (0-32 each, max 66 total).
class MemberCustomization {
  final String? nickname;
  final int level;
  final String? nature;
  final String? ability;
  final String? heldItem;
  final List<String> moves;
  final Map<String, int> customStats; // {'hp': X, 'attack': X, ...}
  final Map<String, int> statPoints;  // {'hp': SP, 'attack': SP, ...}

  const MemberCustomization({
    this.nickname,
    this.level = 50,
    this.nature,
    this.ability,
    this.heldItem,
    this.moves = const [],
    this.customStats = const {},
    this.statPoints = const {},
  });

  bool get hasCustomStats =>
      customStats.isNotEmpty || statPoints.values.any((v) => v > 0);

  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    'level': level,
    'nature': nature,
    'ability': ability,
    'heldItem': heldItem,
    'moves': moves,
    'customStats': customStats,
    'statPoints': statPoints,
  };

  factory MemberCustomization.fromJson(Map<String, dynamic> json) => MemberCustomization(
    nickname: json['nickname'] as String?,
    level: (json['level'] as num?)?.toInt() ?? 50,
    nature: json['nature'] as String?,
    ability: json['ability'] as String?,
    heldItem: json['heldItem'] as String?,
    moves: (json['moves'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    customStats: (json['customStats'] as Map<String, dynamic>?)?.map(
      (k, v) => MapEntry(k, (v as num).toInt()),
    ) ?? const {},
    statPoints: (json['statPoints'] as Map<String, dynamic>?)?.map(
      (k, v) => MapEntry(k, (v as num).toInt()),
    ) ?? const {},
  );

  MemberCustomization copyWith({
    String? nickname,
    int? level,
    String? nature,
    String? ability,
    String? heldItem,
    List<String>? moves,
    Map<String, int>? customStats,
    Map<String, int>? statPoints,
  }) {
    return MemberCustomization(
      nickname: nickname ?? this.nickname,
      level: level ?? this.level,
      nature: nature ?? this.nature,
      ability: ability ?? this.ability,
      heldItem: heldItem ?? this.heldItem,
      moves: moves ?? this.moves,
      customStats: customStats ?? this.customStats,
      statPoints: statPoints ?? this.statPoints,
    );
  }
}

class TeamCustomizationService {
  static const _keyPrefix = 'custom_team_';

  static Future<Map<int, MemberCustomization>> loadTeamCustomizations(int teamId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_keyPrefix$teamId');
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(
          int.parse(k),
          MemberCustomization.fromJson(v as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveTeamCustomizations(
    int teamId,
    Map<int, MemberCustomization> customizations,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(
      customizations.map((k, v) => MapEntry(k.toString(), v.toJson())),
    );
    await prefs.setString('$_keyPrefix$teamId', jsonStr);
  }

  static Future<void> deleteTeamCustomizations(int teamId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$teamId');
  }

  static Future<void> saveMemberCustomization(
    int teamId,
    int slotIndex,
    MemberCustomization customization,
  ) async {
    final all = await loadTeamCustomizations(teamId);
    all[slotIndex] = customization;
    await saveTeamCustomizations(teamId, all);
  }

  static Future<void> removeMemberCustomization({
    required int teamId,
    required int slotIndex,
  }) async {
    final all = await loadTeamCustomizations(teamId);
    all.remove(slotIndex);
    await saveTeamCustomizations(teamId, all);
  }

  static Future<void> clearTeamCustomizations(int teamId) async {
    await deleteTeamCustomizations(teamId);
  }
}
