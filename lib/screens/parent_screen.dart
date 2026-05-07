import 'package:flutter/material.dart';

import '../data/sample_mission.dart';
import '../models/product_item.dart';
import '../services/mission_storage_service.dart';
import 'explorer_screen.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final TextEditingController _customProductController =
      TextEditingController();
  final MissionStorageService _storageService = MissionStorageService();
  List<ProductItem> _missionProducts = List.from(sampleProducts);

  ProductCategory _selectedCategory = productCategories.first;
  String? _selectedReward;
  String? _savedReward;
  bool _missionSaved = false;

  @override
  void initState() {
    super.initState();
    _loadSavedMission();
  }

  @override
  void dispose() {
    _customProductController.dispose();
    super.dispose();
  }

  void _addProduct(ProductItem product) {
    final alreadyExists = _missionProducts.any(
      (item) =>
          item.name.trim().toLowerCase() == product.name.trim().toLowerCase(),
    );

    if (alreadyExists) {
      return;
    }

    setState(() {
      _missionProducts.add(product.copyWith(isFound: false));
      _missionSaved = false;
      _savedReward = null;
    });
  }

  void _addCustomProduct() {
    final productName = _customProductController.text.trim();

    if (productName.isEmpty) {
      return;
    }

    _addProduct(ProductItem(name: productName, emoji: _selectedCategory.emoji));
    _customProductController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _removeProduct(ProductItem product) {
    setState(() {
      _missionProducts.remove(product);
      _missionSaved = false;
      _savedReward = null;
    });
  }

  Future<void> _loadSavedMission() async {
    final savedMission = await _storageService.loadMission();

    if (!mounted || savedMission == null) {
      return;
    }

    setState(() {
      _missionProducts = savedMission.products;
      _selectedReward = savedMission.reward;
      _savedReward = savedMission.reward;
      _missionSaved =
          savedMission.products.isNotEmpty && savedMission.reward.isNotEmpty;
    });
  }

  void _selectReward(String reward) {
    setState(() {
      _selectedReward = reward;
      _missionSaved = false;
      _savedReward = null;
    });
  }

  Future<void> _saveMission() async {
    final reward = _selectedReward;

    if (reward == null) {
      return;
    }

    await _storageService.saveMission(
      products: _missionProducts,
      reward: reward,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _savedReward = reward;
      _missionSaved = true;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Misión guardada')));
  }

  Future<void> _clearMission() async {
    await _storageService.clearMission();

    if (!mounted) {
      return;
    }

    setState(() {
      _missionProducts = [];
      _selectedReward = null;
      _savedReward = null;
      _missionSaved = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Misión limpia')));
  }

  Future<void> _startExplorerMode() async {
    final reward = _savedReward;

    if (reward == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExplorerScreen(
          products: _missionProducts
              .map((product) => product.copyWith())
              .toList(),
          reward: reward,
        ),
      ),
    );

    await _loadSavedMission();
  }

  @override
  Widget build(BuildContext context) {
    final canSaveMission =
        _missionProducts.isNotEmpty && _selectedReward != null;
    final canStartMission = _missionSaved && _savedReward != null;
    final canClearMission =
        _missionProducts.isNotEmpty || _selectedReward != null || _missionSaved;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      appBar: AppBar(
        title: const Text('Modo Padre'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const Text(
              '🛒 Carty',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Arma una misión simple y visual para comprar jugando.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            _ParentPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(title: 'Productos sugeridos'),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: suggestedProducts.map((product) {
                      final isSelected = _missionProducts.any(
                        (item) =>
                            item.name.trim().toLowerCase() ==
                            product.name.trim().toLowerCase(),
                      );

                      return ActionChip(
                        avatar: Text(
                          product.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                        label: Text(product.name),
                        labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.green.shade800
                              : Colors.brown.shade800,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.green.shade200
                              : Colors.orange.shade100,
                        ),
                        backgroundColor: isSelected
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        onPressed: () => _addProduct(product),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ParentPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(title: 'Producto personalizado'),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<ProductCategory>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: productCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text('${category.emoji} ${category.name}'),
                      );
                    }).toList(),
                    onChanged: (category) {
                      if (category == null) {
                        return;
                      }

                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customProductController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del producto',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addCustomProduct(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          onPressed: _addCustomProduct,
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ParentPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lista actual (${_missionProducts.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_missionProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Agrega productos para empezar la misión.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  ..._missionProducts.map(
                    (product) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBF3),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.orange.shade100),
                      ),
                      child: ListTile(
                        leading: Text(
                          product.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: 'Eliminar',
                          onPressed: () => _removeProduct(product),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _ParentPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(title: 'Elige la recompensa'),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: missionRewards.map((reward) {
                      final isSelected = _selectedReward == reward;

                      return ChoiceChip(
                        selected: isSelected,
                        label: Text(reward),
                        labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.green.shade900
                              : Colors.brown.shade800,
                        ),
                        selectedColor: Colors.green.shade100,
                        backgroundColor: Colors.orange.shade50,
                        side: BorderSide(
                          color: isSelected
                              ? Colors.green.shade400
                              : Colors.orange.shade100,
                          width: isSelected ? 2 : 1,
                        ),
                        checkmarkColor: Colors.green.shade900,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        onSelected: (_) => _selectReward(reward),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: canSaveMission ? _saveMission : null,
                icon: const Icon(Icons.save_alt),
                label: const Text(
                  'Guardar misión',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: canStartMission ? _startExplorerMode : null,
                icon: const Icon(Icons.explore),
                label: const Text(
                  'Iniciar modo explorador',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: canClearMission ? _clearMission : null,
                icon: const Icon(Icons.restart_alt),
                label: const Text(
                  'Limpiar misión',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentPanel extends StatelessWidget {
  final Widget child;

  const _ParentPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}
