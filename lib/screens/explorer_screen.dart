import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/detection_result.dart';
import '../models/product_item.dart';
import '../models/shopping_mission.dart';
import '../services/mission_storage_service.dart';
import '../services/product_detection_service.dart';
import '../theme/product_visual_style.dart';
import '../widgets/app_background.dart';
import 'success_screen.dart';

class ExplorerScreen extends StatefulWidget {
  final ShoppingMission mission;

  const ExplorerScreen({super.key, required this.mission});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final MissionStorageService _storageService = MissionStorageService();
  final ProductDetectionService _detectionService =
      const ProductDetectionService();
  late ShoppingMission mission;
  late List<ProductItem> products;
  bool _isOpeningCamera = false;

  @override
  void initState() {
    super.initState();
    mission = widget.mission;
    products = List.from(widget.mission.products);
  }

  double get progress {
    if (mission.products.isEmpty) {
      return 0;
    }

    return foundProducts.length / mission.products.length;
  }

  List<ProductItem> get pendingProducts {
    return products.where((product) => !product.isFound).toList();
  }

  List<ProductItem> get foundProducts {
    return products.where((product) => product.isFound).toList();
  }

  Future<void> _handleTakePhoto() async {
    if (_isOpeningCamera) {
      return;
    }

    setState(() {
      _isOpeningCamera = true;
    });

    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1400,
      );

      if (!mounted) {
        return;
      }

      if (photo == null) {
        _showMessage('Cámara cancelada');
        return;
      }

      await _processCapturedImage(photo.path);
    } on PlatformException {
      if (mounted) {
        _showMessage('No se pudo abrir la cámara');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('No se pudo tomar la foto');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningCamera = false;
        });
      }
    }
  }

  Future<void> _processCapturedImage(String imagePath) async {
    final detectionResult = await _detectionService.detectProductFromImage(
      imagePath: imagePath,
      pendingProducts: pendingProducts,
    );

    if (!mounted) {
      return;
    }

    if (detectionResult == null) {
      _showManualDetectionPicker(imagePath: imagePath);
      return;
    }

    final appliedResult = await _applyDetectionResult(detectionResult);

    if (!appliedResult && mounted) {
      _showManualDetectionPicker(imagePath: imagePath);
    }
  }

  Future<bool> _applyDetectionResult(DetectionResult result) async {
    final detectedProduct = _productForDetection(result);

    if (detectedProduct == null) {
      return false;
    }

    final updatedProducts = products
        .map(
          (item) => item.id == detectedProduct.id
              ? item.copyWith(isFound: true)
              : item,
        )
        .toList();
    final completed = updatedProducts.every((product) => product.isFound);
    final updatedMission = mission.copyWith(
      products: updatedProducts,
      completed: completed,
      updatedAt: DateTime.now(),
    );

    setState(() {
      products = updatedProducts;
      mission = updatedMission;
    });

    await _storageService.updateActiveMission(updatedMission);

    if (!mounted) {
      return true;
    }

    if (completed) {
      await _storageService.completeMission(mission.id);

      if (!mounted) {
        return true;
      }

      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) {
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SuccessScreen(reward: mission.rewardDisplayText),
          ),
        );
      });
    }

    return true;
  }

  ProductItem? _productForDetection(DetectionResult result) {
    final detectedName = result.productName.trim().toLowerCase();

    for (final product in products) {
      if (!product.isFound &&
          product.name.trim().toLowerCase() == detectedName) {
        return product;
      }
    }

    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showManualDetectionPicker({String? imagePath}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8EA),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFFFC982)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Qué producto encontraste?',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4F321B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Elige el producto que apareció en la foto.',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7A624D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...products.map(
                    (product) =>
                        _buildDetectionOption(product, imagePath: imagePath),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(170),
          child: _buildExplorerHeader(),
        ),
        body: mission.products.isEmpty
            ? _buildEmptyMission()
            : Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                child: Column(
                  children: [
                    _buildRewardProgressCard(),
                    const SizedBox(height: 14),
                    Expanded(child: _buildPendingProductsSection()),
                    const SizedBox(height: 14),
                    _buildCameraButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildExplorerHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16C7D9), Color(0xFF536DFE), Color(0xFFE45DBF)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF536DFE).withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Row(
            children: [
              Container(
                width: 108,
                height: 108,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.54),
                  ),
                ),
                child: Image.asset(
                  'assets/images/carty_panda_2.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text('🐼', style: TextStyle(fontSize: 54)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modo Explorador',
                      style: TextStyle(
                        fontSize: 24,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ayuda a Carty a encontrar los productos',
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.24,
                        color: Color(0xFFFDF2FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE8F6), Color(0xFFEFE8FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFF91CF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE45DBF).withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎁 Recompensa',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4F321B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mission.rewardDisplayText,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6D2F66),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${foundProducts.length} de ${mission.products.length} productos encontrados',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7A624D),
            ),
          ),
          const SizedBox(height: 9),
          _GradientProgressBar(progress: progress),
        ],
      ),
    );
  }

  Widget _buildPendingProductsSection() {
    return ListView(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Productos pendientes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4F321B),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF57D68D), Color(0xFF20BBD3)],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${pendingProducts.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (pendingProducts.isEmpty)
          _buildAllFoundMessage()
        else
          ...pendingProducts.map(_buildPendingProductCard),
      ],
    );
  }

  Widget _buildAllFoundMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F8F4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF78D4C4)),
      ),
      child: const Text(
        '¡Encontraste todo!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: Color(0xFF267264),
        ),
      ),
    );
  }

  Widget _buildEmptyMission() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8EA),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFC982)),
          ),
          child: const Text(
            'Pídele a un adulto que cree una misión primero.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4F321B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraButton() {
    final isDisabled = pendingProducts.isEmpty || _isOpeningCamera;

    return GestureDetector(
      onTap: isDisabled ? null : _handleTakePhoto,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isDisabled ? 0.58 : 1,
        child: Container(
          width: double.infinity,
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7A3D), Color(0xFFE45DBF)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7A3D).withValues(alpha: 0.24),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_rounded, color: Colors.white),
              const SizedBox(width: 9),
              Text(
                _isOpeningCamera ? 'Abriendo cámara...' : '📸 Sacar foto',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingProductCard(ProductItem product) {
    final style = productVisualStyleFor(product);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.borderColor),
        boxShadow: [
          BoxShadow(
            color: style.borderColor.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: style.emojiBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(product.emoji, style: const TextStyle(fontSize: 34)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              product.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F321B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionOption(ProductItem product, {String? imagePath}) {
    final style = productVisualStyleFor(product);
    final isFound = product.isFound;

    return Opacity(
      opacity: isFound ? 0.58 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: style.borderColor),
        ),
        child: ListTile(
          enabled: !isFound,
          leading: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: style.emojiBackgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(product.emoji, style: const TextStyle(fontSize: 28)),
          ),
          title: Text(
            product.name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4F321B),
            ),
          ),
          trailing: isFound
              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF35A853))
              : const Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: Color(0xFF7A624D),
                ),
          onTap: isFound
              ? null
              : () {
                  Navigator.pop(context);
                  _applyDetectionResult(
                    DetectionResult(
                      productName: product.name,
                      confidence: 1,
                      isAutomatic: false,
                      imagePath: imagePath,
                    ),
                  );
                },
        ),
      ),
    );
  }
}

class _GradientProgressBar extends StatelessWidget {
  final double progress;

  const _GradientProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 16,
        color: Colors.white.withValues(alpha: 0.76),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: clampedProgress,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF57D68D), Color(0xFF20BBD3)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
