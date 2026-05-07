import 'package:flutter/material.dart';

import '../models/product_item.dart';
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
  late List<ProductItem> products;

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

  void simulateProductFound(ProductItem product) {
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
                  '¿Qué producto apareció en la foto?',
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
                onPressed: showSimulatedDetection,
                icon: const Icon(Icons.search),
                label: const Text(
                  'Simular hallazgo',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
