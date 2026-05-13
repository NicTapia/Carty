import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/shopping_mission.dart';

class MissionStorageService {
  static const String _activeMissionKey = 'carty_current_mission';
  static const String _missionsKey = 'carty_saved_missions';

  Future<ShoppingMission?> loadMission() {
    return loadActiveMission();
  }

  Future<ShoppingMission?> loadActiveMission() async {
    final preferences = await SharedPreferences.getInstance();
    final missionJson = preferences.getString(_activeMissionKey);

    if (missionJson == null) {
      final missions = await loadAllMissions();
      return _activeMissionFrom(missions);
    }

    final activeMission = _decodeMission(missionJson);

    if (activeMission == null || activeMission.completed) {
      final missions = await loadAllMissions();
      return _activeMissionFrom(missions);
    }

    return activeMission;
  }

  Future<List<ShoppingMission>> loadAllMissions() async {
    final preferences = await SharedPreferences.getInstance();
    final missionsJson = preferences.getString(_missionsKey);

    if (missionsJson == null) {
      final activeMission = _loadActiveMissionFromPreferences(preferences);

      return activeMission == null ? [] : [activeMission];
    }

    try {
      final decodedMissions = jsonDecode(missionsJson);

      if (decodedMissions is! List) {
        return [];
      }

      return decodedMissions.whereType<Map>().map((missionJson) {
        return ShoppingMission.fromJson(Map<String, dynamic>.from(missionJson));
      }).toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> saveMission(ShoppingMission mission) async {
    final normalizedMission = mission.copyWith(
      products: mission.products
          .map((product) => product.withGeneratedIdIfNeeded())
          .toList(),
      updatedAt: DateTime.now(),
    );
    final missions = await loadAllMissions();
    final existingIndex = missions.indexWhere(
      (savedMission) => savedMission.id == normalizedMission.id,
    );
    final updatedMissions = normalizedMission.isActive
        ? missions.map((mission) => mission.copyWith(isActive: false)).toList()
        : [...missions];

    if (existingIndex == -1) {
      updatedMissions.add(normalizedMission);
    } else {
      updatedMissions[existingIndex] = normalizedMission;
    }

    await saveMissions(updatedMissions);
  }

  Future<void> saveMissions(List<ShoppingMission> missions) async {
    final preferences = await SharedPreferences.getInstance();
    final normalizedMissions = _normalizeActiveMissions(missions);
    final activeMission = _activeMissionFrom(normalizedMissions);
    final encodedMissions = jsonEncode(
      normalizedMissions.map((mission) => mission.toJson()).toList(),
    );

    await preferences.setString(_missionsKey, encodedMissions);

    if (activeMission == null) {
      await preferences.remove(_activeMissionKey);
    } else {
      await preferences.setString(
        _activeMissionKey,
        jsonEncode(activeMission.toJson()),
      );
    }
  }

  Future<void> updateActiveMission(ShoppingMission mission) async {
    await saveMission(mission.copyWith(isActive: true));
  }

  Future<ShoppingMission?> markProductFound(String productId) async {
    final activeMission = await loadActiveMission();

    if (activeMission == null) {
      return null;
    }

    final updatedMission = activeMission.markProductFound(productId);
    await updateActiveMission(updatedMission);

    return updatedMission;
  }

  Future<void> clearMission() {
    return clearActiveMission();
  }

  Future<void> clearActiveMission() async {
    final preferences = await SharedPreferences.getInstance();
    final missions = await loadAllMissions();
    final updatedMissions = missions
        .map((mission) => mission.copyWith(isActive: false))
        .toList();

    await preferences.remove(_activeMissionKey);
    await preferences.setString(
      _missionsKey,
      jsonEncode(updatedMissions.map((mission) => mission.toJson()).toList()),
    );
  }

  Future<void> deleteMission(String missionId) async {
    final missions = await loadAllMissions();
    final updatedMissions = missions
        .where((mission) => mission.id != missionId)
        .toList();

    await saveMissions(updatedMissions);
  }

  Future<ShoppingMission?> completeMission(String missionId) async {
    final missions = await loadAllMissions();
    ShoppingMission? completedMission;
    final updatedMissions = missions.map((mission) {
      if (mission.id != missionId) {
        return mission;
      }

      completedMission = mission.copyWith(
        completed: true,
        isActive: false,
        updatedAt: DateTime.now(),
      );

      return completedMission!;
    }).toList();

    await saveMissions(updatedMissions);

    return completedMission;
  }

  ShoppingMission? _loadActiveMissionFromPreferences(
    SharedPreferences preferences,
  ) {
    final missionJson = preferences.getString(_activeMissionKey);

    if (missionJson == null) {
      return null;
    }

    return _decodeMission(missionJson);
  }

  ShoppingMission? _decodeMission(String missionJson) {
    try {
      final decodedMission = jsonDecode(missionJson);

      if (decodedMission is! Map<String, dynamic>) {
        return null;
      }

      return ShoppingMission.fromJson(decodedMission);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  List<ShoppingMission> _normalizeActiveMissions(
    List<ShoppingMission> missions,
  ) {
    final activeMission = _activeMissionFrom(missions);

    if (activeMission == null) {
      return missions;
    }

    return missions
        .map(
          (mission) =>
              mission.copyWith(isActive: mission.id == activeMission.id),
        )
        .toList();
  }

  ShoppingMission? _activeMissionFrom(List<ShoppingMission> missions) {
    for (final mission in missions) {
      if (mission.isActive && !mission.completed) {
        return mission;
      }
    }

    return null;
  }
}
