import 'package:flutter/material.dart';

import '../models/product_item.dart';

class ProductVisualStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color emojiBackgroundColor;

  const ProductVisualStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.emojiBackgroundColor,
  });
}

const List<ProductVisualStyle> _productPalette = [
  ProductVisualStyle(
    backgroundColor: Color(0xFFE6F8F4),
    borderColor: Color(0xFF78D4C4),
    emojiBackgroundColor: Color(0xFFBEEFE5),
  ),
  ProductVisualStyle(
    backgroundColor: Color(0xFFFFF0C9),
    borderColor: Color(0xFFFFC657),
    emojiBackgroundColor: Color(0xFFFFDE7D),
  ),
  ProductVisualStyle(
    backgroundColor: Color(0xFFFFE4EF),
    borderColor: Color(0xFFFF9CC4),
    emojiBackgroundColor: Color(0xFFFFC4DA),
  ),
  ProductVisualStyle(
    backgroundColor: Color(0xFFE4EEFF),
    borderColor: Color(0xFF92B9FF),
    emojiBackgroundColor: Color(0xFFC5D9FF),
  ),
  ProductVisualStyle(
    backgroundColor: Color(0xFFFFE3D7),
    borderColor: Color(0xFFFFA080),
    emojiBackgroundColor: Color(0xFFFFC1AD),
  ),
];

const Map<String, int> _knownProductColorIndexes = {
  'leche': 0,
  'pan': 1,
  'huevos': 2,
  'yogurt': 3,
  'manzana': 4,
  'platano': 0,
  'arroz': 1,
  'queso': 2,
  'pollo': 3,
  'jugo': 4,
};

ProductVisualStyle productVisualStyleFor(ProductItem product) {
  final normalizedName = _normalizeProductName(product.name);
  final knownIndex = _knownProductColorIndexes[normalizedName];

  if (knownIndex != null) {
    return _productPalette[knownIndex];
  }

  final hashIndex = normalizedName.codeUnits.fold<int>(
    0,
    (hash, codeUnit) => hash + codeUnit,
  );

  return _productPalette[hashIndex % _productPalette.length];
}

String _normalizeProductName(String name) {
  return name
      .trim()
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n');
}
