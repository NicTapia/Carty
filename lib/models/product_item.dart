class ProductItem {
  final String name;
  final String emoji;
  final bool isFound;

  const ProductItem({
    required this.name,
    required this.emoji,
    this.isFound = false,
  });

  ProductItem copyWith({String? name, String? emoji, bool? isFound}) {
    return ProductItem(
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      isFound: isFound ?? this.isFound,
    );
  }
}
