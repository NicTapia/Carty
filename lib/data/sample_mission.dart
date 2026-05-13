import '../models/product_item.dart';

const sampleProducts = [
  ProductItem(id: 'sample-leche', name: 'Leche', emoji: '🥛'),
  ProductItem(id: 'sample-pan', name: 'Pan', emoji: '🍞'),
  ProductItem(id: 'sample-huevos', name: 'Huevos', emoji: '🥚'),
  ProductItem(id: 'sample-yogurt', name: 'Yogurt', emoji: '🥣'),
  ProductItem(id: 'sample-manzana', name: 'Manzana', emoji: '🍎'),
];

const suggestedProducts = [
  ProductItem(id: 'suggested-leche', name: 'Leche', emoji: '🥛'),
  ProductItem(id: 'suggested-pan', name: 'Pan', emoji: '🍞'),
  ProductItem(id: 'suggested-huevos', name: 'Huevos', emoji: '🥚'),
  ProductItem(id: 'suggested-manzana', name: 'Manzana', emoji: '🍎'),
  ProductItem(id: 'suggested-platano', name: 'Plátano', emoji: '🍌'),
  ProductItem(id: 'suggested-yogurt', name: 'Yogurt', emoji: '🥣'),
  ProductItem(id: 'suggested-arroz', name: 'Arroz', emoji: '🍚'),
  ProductItem(id: 'suggested-queso', name: 'Queso', emoji: '🧀'),
  ProductItem(id: 'suggested-pollo', name: 'Pollo', emoji: '🍗'),
  ProductItem(id: 'suggested-jugo', name: 'Jugo', emoji: '🥤'),
];

const productCategories = [
  ProductCategory(name: 'Otros', emoji: '🛒'),
  ProductCategory(name: 'Comida', emoji: '🍎'),
  ProductCategory(name: 'Bebida', emoji: '🥤'),
  ProductCategory(name: 'Limpieza', emoji: '🧼'),
  ProductCategory(name: 'Higiene', emoji: '🧴'),
  ProductCategory(name: 'Mascotas', emoji: '🐶'),
];

const missionRewards = [
  '🍫 Chocolate',
  '🍦 Helado',
  '🎬 Elegir película',
  '🎮 Tiempo de juego',
  '🛝 Salida al parque',
  '⭐ Sorpresa',
];

class ProductCategory {
  final String name;
  final String emoji;

  const ProductCategory({required this.name, required this.emoji});
}
