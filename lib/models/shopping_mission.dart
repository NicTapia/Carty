import 'product_item.dart';
import 'reward.dart';

class ShoppingMission {
  final String id;
  final String title;
  final List<ProductItem> products;
  final String rewardName;
  final String rewardEmoji;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool completed;
  final bool isActive;

  const ShoppingMission({
    required this.id,
    required this.title,
    required this.products,
    required this.rewardName,
    required this.rewardEmoji,
    required this.createdAt,
    required this.updatedAt,
    this.completed = false,
    this.isActive = false,
  });

  factory ShoppingMission.create({
    String title = 'Misión de compra',
    required List<ProductItem> products,
    required String rewardName,
    String rewardEmoji = '🎁',
    bool isActive = true,
  }) {
    final now = DateTime.now();

    return ShoppingMission(
      id: _createMissionId(),
      title: title,
      products: products
          .map((product) => product.withGeneratedIdIfNeeded())
          .toList(),
      rewardName: rewardName,
      rewardEmoji: rewardEmoji,
      createdAt: now,
      updatedAt: now,
      isActive: isActive,
    );
  }

  factory ShoppingMission.fromLegacy({
    required List<ProductItem> products,
    required String reward,
  }) {
    final parsedReward = Reward.fromDisplayText(reward);

    return ShoppingMission.create(
      products: products,
      rewardName: parsedReward.name,
      rewardEmoji: parsedReward.emoji,
    );
  }

  Reward get reward => Reward(name: rewardName, emoji: rewardEmoji);

  String get rewardDisplayText => reward.displayText;

  int get foundProductsCount {
    return products.where((product) => product.isFound).length;
  }

  bool get hasAllProductsFound {
    return products.isNotEmpty && foundProductsCount == products.length;
  }

  ShoppingMission markProductFound(String productId) {
    final updatedProducts = products
        .map(
          (product) => product.id == productId
              ? product.copyWith(isFound: true)
              : product,
        )
        .toList();

    return copyWith(
      products: updatedProducts,
      completed: updatedProducts.every((product) => product.isFound),
      updatedAt: DateTime.now(),
    );
  }

  ShoppingMission copyWith({
    String? id,
    String? title,
    List<ProductItem>? products,
    String? rewardName,
    String? rewardEmoji,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? completed,
    bool? isActive,
  }) {
    return ShoppingMission(
      id: id ?? this.id,
      title: title ?? this.title,
      products: products ?? this.products,
      rewardName: rewardName ?? this.rewardName,
      rewardEmoji: rewardEmoji ?? this.rewardEmoji,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completed: completed ?? this.completed,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'products': products.map((product) => product.toJson()).toList(),
      'rewardName': rewardName,
      'rewardEmoji': rewardEmoji,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completed': completed,
      'isActive': isActive,
    };
  }

  factory ShoppingMission.fromJson(Map<String, dynamic> json) {
    final products = _readProducts(json['products']);
    final rewardName = json['rewardName'] as String?;
    final rewardEmoji = json['rewardEmoji'] as String?;
    final legacyReward = json['reward'] as String?;
    final parsedLegacyReward = legacyReward == null
        ? null
        : Reward.fromDisplayText(legacyReward);
    final createdAt = _readDate(json['createdAt']) ?? DateTime.now();
    final updatedAt = _readDate(json['updatedAt']) ?? createdAt;

    return ShoppingMission(
      id: json['id'] as String? ?? _createMissionId(),
      title: json['title'] as String? ?? 'Misión de compra',
      products: products,
      rewardName: rewardName ?? parsedLegacyReward?.name ?? '',
      rewardEmoji: rewardEmoji ?? parsedLegacyReward?.emoji ?? '🎁',
      createdAt: createdAt,
      updatedAt: updatedAt,
      completed:
          json['completed'] as bool? ??
          (products.isNotEmpty && products.every((product) => product.isFound)),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static List<ProductItem> _readProducts(Object? productsJson) {
    if (productsJson is! List) {
      return [];
    }

    return productsJson
        .whereType<Map>()
        .map((productJson) {
          return ProductItem.fromJson(
            Map<String, dynamic>.from(productJson),
          ).withGeneratedIdIfNeeded();
        })
        .where((product) => product.name.trim().isNotEmpty)
        .toList();
  }

  static DateTime? _readDate(Object? value) {
    if (value is! String) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  static String _createMissionId() {
    return 'mission-${DateTime.now().microsecondsSinceEpoch}';
  }
}
