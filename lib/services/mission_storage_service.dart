import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_item.dart';

class MissionStorageService {
  static const String _missionKey = 'carty_current_mission';

  Future<SavedMission?> loadMission() async {
    final preferences = await SharedPreferences.getInstance();
    final missionJson = preferences.getString(_missionKey);

    if (missionJson == null) {
      return null;
    }

    try {
      final decodedMission = jsonDecode(missionJson);

      if (decodedMission is! Map<String, dynamic>) {
        return null;
      }

      final reward = decodedMission['reward'] as String?;
      final productsJson = decodedMission['products'];

      if (reward == null || productsJson is! List) {
        return null;
      }

      final products = productsJson
          .whereType<Map>()
          .map((productJson) {
            return ProductItem.fromJson(Map<String, dynamic>.from(productJson));
          })
          .where((product) => product.name.trim().isNotEmpty)
          .toList();

      return SavedMission(products: products, reward: reward);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<void> saveMission({
    required List<ProductItem> products,
    required String reward,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final missionJson = jsonEncode({
      'products': products.map((product) => product.toJson()).toList(),
      'reward': reward,
    });

    await preferences.setString(_missionKey, missionJson);
  }

  Future<void> clearMission() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_missionKey);
  }
}

class SavedMission {
  final List<ProductItem> products;
  final String reward;

  const SavedMission({required this.products, required this.reward});
}
