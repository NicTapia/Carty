import 'package:flutter/material.dart';

import '../data/sample_mission.dart';
import '../models/product_item.dart';
import '../models/reward.dart';
import '../models/shopping_mission.dart';
import '../services/mission_storage_service.dart';
import '../theme/product_visual_style.dart';
import '../widgets/app_background.dart';
import 'explorer_screen.dart';

class ParentScreen extends StatefulWidget {
  final bool createNewMission;
  final ShoppingMission? initialMission;

  const ParentScreen({
    super.key,
    this.createNewMission = false,
    this.initialMission,
  });

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final TextEditingController _missionTitleController = TextEditingController();
  final TextEditingController _customProductController =
      TextEditingController();
  final MissionStorageService _storageService = MissionStorageService();
  List<ProductItem> _missionProducts = List.from(sampleProducts);
  ShoppingMission? _activeMission;

  ProductCategory _selectedCategory = productCategories.first;
  String? _selectedReward;
  String? _savedReward;
  bool _missionSaved = false;
  bool _isUpdatingMissionTitle = false;

  bool get _isEditingMission => widget.initialMission != null;

  @override
  void initState() {
    super.initState();
    _missionTitleController.addListener(_handleMissionTitleChanged);
    final initialMission = widget.initialMission;

    if (initialMission != null) {
      _loadMissionIntoForm(initialMission);
    } else if (!widget.createNewMission) {
      _loadSavedMission();
    }
  }

  @override
  void dispose() {
    _missionTitleController.removeListener(_handleMissionTitleChanged);
    _missionTitleController.dispose();
    _customProductController.dispose();
    super.dispose();
  }

  void _handleMissionTitleChanged() {
    if (!mounted || _isUpdatingMissionTitle) {
      return;
    }

    setState(() {
      _missionSaved = false;
      _savedReward = null;
    });
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
      _missionProducts.add(
        product.copyWith(isFound: false).withGeneratedIdIfNeeded(),
      );
      _missionSaved = false;
      _savedReward = null;
    });
  }

  void _addCustomProduct() {
    final productName = _customProductController.text.trim();

    if (productName.isEmpty) {
      return;
    }

    _addProduct(
      ProductItem.create(
        name: productName,
        emoji: _selectedCategory.emoji,
        isCustom: true,
        colorKey: _selectedCategory.name.toLowerCase(),
      ),
    );
    _customProductController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _removeProduct(ProductItem product) {
    setState(() {
      _missionProducts.remove(product);
      _activeMission = _activeMission?.copyWith(products: _missionProducts);
      _missionSaved = false;
      _savedReward = null;
    });
  }

  void _setMissionTitleText(String title) {
    _isUpdatingMissionTitle = true;
    _missionTitleController.text = title;
    _isUpdatingMissionTitle = false;
  }

  void _loadMissionIntoForm(ShoppingMission mission) {
    _activeMission = mission;
    _setMissionTitleText(mission.displayTitle);
    _missionProducts = mission.products;
    _selectedReward = mission.rewardDisplayText;
    _savedReward = mission.rewardDisplayText;
    _missionSaved =
        mission.products.isNotEmpty && mission.rewardName.isNotEmpty;
  }

  Future<void> _loadSavedMission() async {
    final savedMission = await _storageService.loadMission();

    if (!mounted) {
      return;
    }

    if (savedMission == null) {
      setState(() {
        _activeMission = null;
        _setMissionTitleText('');
        _selectedReward = null;
        _savedReward = null;
        _missionSaved = false;
      });
      return;
    }

    setState(() {
      _loadMissionIntoForm(savedMission);
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
    final selectedReward = _selectedReward;
    final missionTitle = _missionTitleController.text.trim();

    if (missionTitle.isEmpty || selectedReward == null) {
      return;
    }

    final reward = Reward.fromDisplayText(selectedReward);
    final missionProducts = _missionProducts
        .map((product) => product.withGeneratedIdIfNeeded())
        .toList();
    final activeMission = _activeMission;
    final completed = missionProducts.every((product) => product.isFound);
    final mission = activeMission == null
        ? ShoppingMission.create(
            title: missionTitle,
            products: missionProducts,
            rewardName: reward.name,
            rewardEmoji: reward.emoji,
          )
        : activeMission.copyWith(
            title: missionTitle,
            products: missionProducts,
            rewardName: reward.name,
            rewardEmoji: reward.emoji,
            completed: completed,
            isActive: _isEditingMission ? activeMission.isActive : true,
            updatedAt: DateTime.now(),
          );

    await _storageService.saveMission(mission);

    if (!mounted) {
      return;
    }

    setState(() {
      _activeMission = mission;
      _missionProducts = mission.products;
      _savedReward = mission.rewardDisplayText;
      _missionSaved = true;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_savedMessage)));
  }

  Future<void> _clearMission() async {
    await _storageService.clearMission();

    if (!mounted) {
      return;
    }

    setState(() {
      _activeMission = null;
      _setMissionTitleText('');
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
    final activeMission = _activeMission;

    if (activeMission == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExplorerScreen(mission: activeMission)),
    );

    await _loadSavedMission();
  }

  @override
  Widget build(BuildContext context) {
    final availableSuggestedProducts = suggestedProducts.where((product) {
      return !_missionProducts.any(
        (item) =>
            item.name.trim().toLowerCase() == product.name.trim().toLowerCase(),
      );
    }).toList();
    final canSaveMission =
        _missionTitleController.text.trim().isNotEmpty &&
        _missionProducts.isNotEmpty &&
        _selectedReward != null;
    final canStartMission = _missionSaved && _savedReward != null;
    final canClearMission =
        _missionTitleController.text.trim().isNotEmpty ||
        _missionProducts.isNotEmpty ||
        _selectedReward != null ||
        _missionSaved;
    final saveLabel = _isEditingMission ? 'Guardar cambios' : 'Guardar misión';

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(178),
          child: _buildMissionHeader(),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            children: [
              _buildMissionNameSection(),
              const SizedBox(height: 16),
              _buildProductSelector(availableSuggestedProducts),
              const SizedBox(height: 16),
              _buildShoppingList(),
              const SizedBox(height: 16),
              _buildCustomProductSection(),
              const SizedBox(height: 16),
              _buildRewardSection(),
              const SizedBox(height: 20),
              _buildActions(
                canSaveMission,
                canStartMission,
                canClearMission,
                saveLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionNameSection() {
    return _ParentPanel(
      padding: const EdgeInsets.all(16),
      backgroundColor: const Color(0xEFFFF1E8),
      borderColor: const Color(0xFFFFB995),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF2E8), Color(0xFFFFDCCB)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Nombre de la misión',
            subtitle: 'Ponle un nombre fácil de reconocer',
            titleSize: 18,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _missionTitleController,
            decoration: _inputDecoration(
              label: 'Nombre de la misión',
              hint: 'Ej: Compra semanal',
              icon: Icons.flag_rounded,
              compact: true,
              fillColor: Colors.white,
              borderColor: const Color(0xFFFFB995),
              iconColor: const Color(0xFFFF7A3D),
            ),
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionHeader() {
    final modeLabel = _isEditingMission ? 'Editando misión' : 'Modo Padre';
    final title = _isEditingMission
        ? 'Edita la misión de compra'
        : 'Crea la misión de compra';

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
                width: 116,
                height: 116,
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
                      child: Text('🐼', style: TextStyle(fontSize: 56)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.26),
                        ),
                      ),
                      child: Text(
                        modeLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 23,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Agrega productos y prepara una aventura para tus hijos',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.22,
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

  Widget _buildProductSelector(List<ProductItem> availableSuggestedProducts) {
    return _ParentPanel(
      padding: const EdgeInsets.all(16),
      backgroundColor: const Color(0xEFFFF1E8),
      borderColor: const Color(0xFFFFB995),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF2E8), Color(0xFFFFDCCB)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Agregar productos',
            subtitle: 'Selecciona productos sugeridos para la misión',
            titleSize: 18,
          ),
          const SizedBox(height: 12),
          if (availableSuggestedProducts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF8EE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFB9DEB5)),
              ),
              child: const Text(
                'Ya agregaste todos los productos sugeridos.',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF35613A),
                ),
              ),
            )
          else
            DropdownButtonFormField<ProductItem>(
              key: ValueKey(
                availableSuggestedProducts
                    .map((product) => product.name)
                    .join('|'),
              ),
              decoration: _inputDecoration(
                label: 'Seleccionar producto',
                icon: Icons.shopping_basket_outlined,
                compact: true,
                fillColor: Colors.white,
                borderColor: const Color(0xFFFFB995),
                iconColor: const Color(0xFFFF7A3D),
              ),
              dropdownColor: Colors.white,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF7A3B24),
              ),
              items: availableSuggestedProducts.map((product) {
                return DropdownMenuItem(
                  value: product,
                  child: Text('${product.emoji} ${product.name}'),
                );
              }).toList(),
              onChanged: (product) {
                if (product == null) {
                  return;
                }

                _addProduct(product);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildShoppingList() {
    final productCount = _missionProducts.length;
    final subtitle = productCount == 1
        ? '1 producto agregado'
        : '$productCount productos agregados';

    return _ParentPanel(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      backgroundColor: const Color(0xEFF0F8FF),
      borderColor: const Color(0xFFB7D8FF),
      shadowOpacity: 0.12,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF3FAFF), Color(0xFFE3F1FF)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionHeader(
                  title: 'Lista de compra',
                  subtitle: '',
                  titleSize: 23,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF57D68D), Color(0xFF20BBD3)],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF20BBD3).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '$productCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7A624D),
            ),
          ),
          const SizedBox(height: 14),
          if (_missionProducts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF3),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFD9A3)),
              ),
              child: const Text(
                'Agrega productos para empezar la misión.',
                style: TextStyle(fontSize: 15.5, color: Colors.black54),
              ),
            )
          else
            ..._missionProducts.map(_buildShoppingListItem),
        ],
      ),
    );
  }

  Widget _buildShoppingListItem(ProductItem product) {
    final style = productVisualStyleFor(product);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(17),
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
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: style.emojiBackgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(product.emoji, style: const TextStyle(fontSize: 29)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Color(0xFF4F321B),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Eliminar',
            onPressed: () => _removeProduct(product),
            icon: const Icon(Icons.close_rounded),
            color: const Color(0xFF9A6A42),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.76),
              fixedSize: const Size(36, 36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomProductSection() {
    return _ParentPanel(
      padding: const EdgeInsets.all(14),
      backgroundColor: const Color(0xEFFFF1E8),
      borderColor: const Color(0xFFFFB995),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF2E8), Color(0xFFFFDCCB)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Producto personalizado',
            subtitle: 'Agrega algo que no esté en las sugerencias',
            titleSize: 17,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<ProductCategory>(
            initialValue: _selectedCategory,
            decoration: _inputDecoration(
              label: 'Categoría',
              icon: Icons.category_outlined,
              compact: true,
              fillColor: const Color(0xFFFFFFFF),
              borderColor: const Color(0xFFFFB995),
              iconColor: const Color(0xFFFF7A3D),
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
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customProductController,
                  decoration: _inputDecoration(
                    label: 'Nombre del producto',
                    icon: Icons.edit_outlined,
                    compact: true,
                    fillColor: const Color(0xFFFFFFFF),
                    borderColor: const Color(0xFFFFB995),
                    iconColor: const Color(0xFFFF7A3D),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addCustomProduct(),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _addCustomProduct,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A3D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Icon(Icons.add_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardSection() {
    final selectedReward = missionRewards.contains(_selectedReward)
        ? _selectedReward
        : null;

    return _ParentPanel(
      padding: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFFFFE8F6),
      borderColor: const Color(0xFFFF91CF),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFE8F6), Color(0xFFEFE8FF)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: '🎁 Recompensa',
            subtitle: 'Elige qué se desbloquea al completar la misión',
            titleSize: 18.5,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: selectedReward,
            decoration: _inputDecoration(
              label: 'Seleccionar recompensa',
              icon: Icons.card_giftcard_rounded,
              compact: true,
              fillColor: Colors.white,
              borderColor: const Color(0xFFFFA7D3),
              iconColor: const Color(0xFFE44EA7),
            ),
            dropdownColor: Colors.white,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6D2F66),
            ),
            items: missionRewards.map((reward) {
              return DropdownMenuItem(value: reward, child: Text(reward));
            }).toList(),
            onChanged: (reward) {
              if (reward == null) {
                return;
              }

              _selectReward(reward);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
    bool canSaveMission,
    bool canStartMission,
    bool canClearMission,
    String saveLabel,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 58,
          child: FilledButton.icon(
            onPressed: canSaveMission ? _saveMission : null,
            icon: const Icon(Icons.save_alt_rounded),
            label: Text(
              saveLabel,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: canStartMission ? _startExplorerMode : null,
            icon: const Icon(Icons.explore_rounded),
            label: const Text(
              'Iniciar modo explorador',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: canClearMission ? _clearMission : null,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text(
              'Limpiar misión',
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  String get _savedMessage {
    return _isEditingMission ? 'Cambios guardados' : 'Misión guardada';
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    bool compact = false,
    Color fillColor = const Color(0xFFFFFCF7),
    Color borderColor = const Color(0xFFFFD9A3),
    Color iconColor = const Color(0xFF9A6A42),
  }) {
    return InputDecoration(
      isDense: compact,
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: iconColor),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: iconColor, width: 2),
      ),
    );
  }
}

class _ParentPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final double shadowOpacity;

  const _ParentPanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.backgroundColor = const Color(0xDBFFFDF8),
    this.borderColor,
    this.gradient,
    this.shadowOpacity = 0.065,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor ?? const Color(0xFFFFD9A3).withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shadowOpacity),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double titleSize;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.titleSize = 19,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: titleSize,
            height: 1.05,
            color: const Color(0xFF4F321B),
            fontWeight: FontWeight.w900,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7A624D),
            ),
          ),
        ],
      ],
    );
  }
}
