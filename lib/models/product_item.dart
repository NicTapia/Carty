class ProductItem {
  final String id;
  final String name;
  final String emoji;
  final bool isFound;
  final bool isCustom;
  final String? colorKey;

  const ProductItem({
    this.id = '',
    required this.name,
    required this.emoji,
    this.isFound = false,
    this.isCustom = false,
    this.colorKey,
  });

  factory ProductItem.create({
    required String name,
    required String emoji,
    bool isFound = false,
    bool isCustom = false,
    String? colorKey,
  }) {
    return ProductItem(
      id: createId(name),
      name: name,
      emoji: emoji,
      isFound: isFound,
      isCustom: isCustom,
      colorKey: colorKey,
    );
  }

  static String createId(String seed) {
    final normalizedSeed = seed
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final suffix = DateTime.now().microsecondsSinceEpoch.toString();

    if (normalizedSeed.isEmpty) {
      return 'product-$suffix';
    }

    return '$normalizedSeed-$suffix';
  }

  ProductItem withGeneratedIdIfNeeded() {
    if (id.trim().isNotEmpty) {
      return this;
    }

    return copyWith(id: createId(name));
  }

  ProductItem copyWith({
    String? id,
    String? name,
    String? emoji,
    bool? isFound,
    bool? isCustom,
    String? colorKey,
  }) {
    return ProductItem(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      isFound: isFound ?? this.isFound,
      isCustom: isCustom ?? this.isCustom,
      colorKey: colorKey ?? this.colorKey,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'isFound': isFound,
      'isCustom': isCustom,
      'colorKey': colorKey,
    };
  }

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🛒',
      isFound: json['isFound'] as bool? ?? false,
      isCustom: json['isCustom'] as bool? ?? false,
      colorKey: json['colorKey'] as String?,
    );
  }
}
