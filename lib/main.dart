import 'package:flutter/material.dart';

void main() {
  runApp(const CartyApp());
}

class CartyApp extends StatelessWidget {
  const CartyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<String> products = const [
    'Leche',
    'Pan',
    'Huevos',
    'Yogurt',
    'Manzana',
  ];

  final String reward = 'Chocolate 🍫';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              const Text(
                '🛒 Carty',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Convierte las compras en una aventura familiar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 50),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Misión de compra',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      '${products.length} productos por encontrar',
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Recompensa: $reward',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExplorerScreen(
                                products: products,
                                reward: reward,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Iniciar modo explorador',
                          style: TextStyle(fontSize: 17),
                        ),
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
}

class ExplorerScreen extends StatefulWidget {
  final List<String> products;
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
  late List<String> pendingProducts;
  late List<String> foundProducts;

  @override
  void initState() {
    super.initState();
    pendingProducts = List.from(widget.products);
    foundProducts = [];
  }

  double get progress {
    return foundProducts.length / widget.products.length;
  }

  void simulateProductFound(String product) {
    if (pendingProducts.contains(product)) {
      setState(() {
        pendingProducts.remove(product);
        foundProducts.add(product);
      });

      if (foundProducts.length == widget.products.length) {
        Future.delayed(const Duration(milliseconds: 400), () {
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
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Qué producto detectó la IA?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              ...widget.products.map(
                (product) => ListTile(
                  title: Text(product),
                  trailing: pendingProducts.contains(product)
                      ? const Icon(Icons.radio_button_unchecked)
                      : const Icon(Icons.check_circle, color: Colors.green),
                  onTap: () {
                    Navigator.pop(context);
                    simulateProductFound(product);
                  },
                ),
              ),
            ],
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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 16,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.reward,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (pendingProducts.isEmpty)
                    const Text('¡Ya encontraste todo!'),

                  ...pendingProducts.map(
                    (product) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.shopping_basket),
                        title: Text(product),
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
                icon: const Icon(Icons.camera_alt),
                label: const Text(
                  'Simular producto encontrado',
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

class SuccessScreen extends StatelessWidget {
  final String reward;

  const SuccessScreen({
    super.key,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 90),
              ),

              const SizedBox(height: 20),

              const Text(
                '¡Misión completada!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Has desbloqueado tu recompensa:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 12),

              Text(
                reward,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Volver al inicio',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}