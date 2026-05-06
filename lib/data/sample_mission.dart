import '../models/product_item.dart';

const sampleProducts = [
  ProductItem(name: 'Leche', emoji: '🥛'),
  ProductItem(name: 'Pan', emoji: '🍞'),
  ProductItem(name: 'Huevos', emoji: '🥚'),
  ProductItem(name: 'Yogurt', emoji: '🥣'),
  ProductItem(name: 'Manzana', emoji: '🍎'),
];

const sampleReward = 'Chocolate 🍫';

const suggestedProducts = [
  ProductItem(name: 'Leche', emoji: '🥛'),
  ProductItem(name: 'Pan', emoji: '🍞'),
  ProductItem(name: 'Huevos', emoji: '🥚'),
  ProductItem(name: 'Manzana', emoji: '🍎'),
  ProductItem(name: 'Plátano', emoji: '🍌'),
  ProductItem(name: 'Yogurt', emoji: '🥣'),
  ProductItem(name: 'Arroz', emoji: '🍚'),
  ProductItem(name: 'Queso', emoji: '🧀'),
  ProductItem(name: 'Pollo', emoji: '🍗'),
  ProductItem(name: 'Jugo', emoji: '🥤'),
];

const productCategories = [
  ProductCategory(name: 'Otros', emoji: '🛒'),
  ProductCategory(name: 'Comida', emoji: '🍎'),
  ProductCategory(name: 'Bebida', emoji: '🥤'),
  ProductCategory(name: 'Limpieza', emoji: '🧼'),
  ProductCategory(name: 'Higiene', emoji: '🧴'),
  ProductCategory(name: 'Mascotas', emoji: '🐶'),
];

class ProductCategory {
  final String name;
  final String emoji;

  const ProductCategory({required this.name, required this.emoji});
}
