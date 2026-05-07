import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product_item.dart';
import '../services/mission_storage_service.dart';
import '../widgets/progress_reward_bar.dart';
import 'success_screen.dart';

class ExplorerScreen extends StatefulWidget {
  final List<ProductItem> products;
  final String reward;

  const ExplorerScreen({
    super.key,
    required this.products,
    required this.reward,
  });

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final MissionStorageService _storageService = MissionStorageService();
  late List<ProductItem> products;
  Uint8List? _lastPhotoBytes;
  bool _isOpeningCamera = false;

  @override
  void initState() {
    super.initState();
    products = List.from(widget.products);
  }

  double get progress {
    if (widget.products.isEmpty) {
      return 0;
    }

    return foundProducts.length / widget.products.length;
  }

  List<ProductItem> get pendingProducts {
    return products.where((product) => !product.isFound).toList();
  }

  List<ProductItem> get foundProducts {
    return products.where((product) => product.isFound).toList();
  }

  Future<void> takePhoto() async {
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

      final photoBytes = await photo.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(() {
        _lastPhotoBytes = photoBytes;
      });

      showSimulatedDetection();
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

  Future<void> simulateProductFound(ProductItem product) async {
    if (!product.isFound) {
      setState(() {
        products = products
            .map(
              (item) => item.name == product.name
                  ? item.copyWith(isFound: true)
                  : item,
            )
            .toList();
      });

      await _storageService.saveMission(
        products: products,
        reward: widget.reward,
      );

      if (!mounted) {
        return;
      }

      if (foundProducts.length == widget.products.length) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) {
            return;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SuccessScreen(reward: widget.reward),
            ),
          );
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void showSimulatedDetection() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '¿Qué producto encontraste?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...products.map(
                  (product) => ListTile(
                    enabled: !product.isFound,
                    leading: Text(
                      product.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontSize: 18),
                    ),
                    trailing: !product.isFound
                        ? const Icon(Icons.radio_button_unchecked)
                        : const Icon(Icons.check_circle, color: Colors.green),
                    onTap: product.isFound
                        ? null
                        : () {
                            Navigator.pop(context);
                            simulateProductFound(product);
                          },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      appBar: AppBar(
        title: const Text('Modo Explorador'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              '🐼 Ayuda a Carty a encontrar los productos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ProgressRewardBar(progress: progress, reward: widget.reward),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Text(
                'Recompensa: ${widget.reward}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${foundProducts.length}/${widget.products.length} productos encontrados',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  if (_lastPhotoBytes != null) ...[
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.orange.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 4 / 3,
                            child: Image.memory(
                              _lastPhotoBytes!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(14),
                            child: Text(
                              'Última foto tomada',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  const Text(
                    'Productos pendientes:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (pendingProducts.isEmpty)
                    const Text('¡Ya encontraste todo!'),
                  ...pendingProducts.map(
                    (product) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.orange.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            product.emoji,
                            style: const TextStyle(fontSize: 46),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: pendingProducts.isEmpty || _isOpeningCamera
                    ? null
                    : takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  _isOpeningCamera ? 'Abriendo cámara...' : 'Sacar foto',
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
