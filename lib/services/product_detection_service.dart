import '../models/detection_result.dart';
import '../models/product_item.dart';

class ProductDetectionService {
  const ProductDetectionService();

  Future<DetectionResult?> detectProductFromImage({
    required String imagePath,
    required List<ProductItem> pendingProducts,
  }) async {
    // TODO: Integrar TensorFlow Lite cuando exista el modelo:
    // - cargar el modelo .tflite y sus etiquetas
    // - preprocesar la imagen capturada
    // - ejecutar inferencia
    // - mapear la etiqueta detectada a un ProductItem pendiente
    // - validar una confianza mínima antes de devolver DetectionResult
    return null;
  }
}
