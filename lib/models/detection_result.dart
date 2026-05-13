class DetectionResult {
  final String productName;
  final double confidence;
  final bool isAutomatic;
  final String? imagePath;

  const DetectionResult({
    required this.productName,
    required this.confidence,
    required this.isAutomatic,
    this.imagePath,
  });

  DetectionResult copyWith({
    String? productName,
    double? confidence,
    bool? isAutomatic,
    String? imagePath,
  }) {
    return DetectionResult(
      productName: productName ?? this.productName,
      confidence: confidence ?? this.confidence,
      isAutomatic: isAutomatic ?? this.isAutomatic,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'productName': productName,
      'confidence': confidence,
      'isAutomatic': isAutomatic,
      'imagePath': imagePath,
    };
  }

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      productName: json['productName'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      isAutomatic: json['isAutomatic'] as bool? ?? false,
      imagePath: json['imagePath'] as String?,
    );
  }
}
