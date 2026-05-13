import 'package:flutter/material.dart';

import '../models/shopping_mission.dart';
import '../services/mission_storage_service.dart';
import '../widgets/app_background.dart';
import 'explorer_screen.dart';
import 'parent_screen.dart';

class MissionListScreen extends StatefulWidget {
  const MissionListScreen({super.key});

  @override
  State<MissionListScreen> createState() => _MissionListScreenState();
}

class _MissionListScreenState extends State<MissionListScreen> {
  final MissionStorageService _storageService = MissionStorageService();
  late Future<List<ShoppingMission>> _missionsFuture;

  @override
  void initState() {
    super.initState();
    _missionsFuture = _loadMissions();
  }

  Future<List<ShoppingMission>> _loadMissions() async {
    final missions = await _storageService.loadAllMissions();
    missions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return missions;
  }

  void _refreshMissions() {
    setState(() {
      _missionsFuture = _loadMissions();
    });
  }

  Future<void> _createMission() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ParentScreen(createNewMission: true),
      ),
    );

    if (mounted) {
      _refreshMissions();
    }
  }

  Future<void> _continueMission(ShoppingMission mission) async {
    if (!mission.completed) {
      await _storageService.updateActiveMission(mission);
    }

    if (!mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExplorerScreen(mission: mission)),
    );

    if (mounted) {
      _refreshMissions();
    }
  }

  Future<void> _editMission(ShoppingMission mission) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ParentScreen(initialMission: mission)),
    );

    if (mounted) {
      _refreshMissions();
    }
  }

  Future<void> _deleteMission(ShoppingMission mission) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF8EA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Eliminar misión',
            style: TextStyle(
              color: Color(0xFF4F321B),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            '¿Quieres eliminar "${mission.displayTitle}"?',
            style: const TextStyle(
              color: Color(0xFF7A624D),
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE45DBF),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await _storageService.deleteMission(mission.id);

    if (!mounted) {
      return;
    }

    _refreshMissions();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Misión eliminada')));
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(170),
          child: _buildHeader(),
        ),
        body: SafeArea(
          top: false,
          child: FutureBuilder<List<ShoppingMission>>(
            future: _missionsFuture,
            builder: (context, snapshot) {
              final missions = snapshot.data ?? [];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE45DBF)),
                );
              }

              if (missions.isEmpty) {
                return _buildEmptyState();
              }

              return _buildMissionSections(missions);
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createMission,
          backgroundColor: const Color(0xFFFF7A3D),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Crear nueva misión',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  Widget _buildMissionSections(List<ShoppingMission> missions) {
    final activeMissions = missions
        .where((mission) => !mission.completed)
        .toList();
    final completedMissions = missions
        .where((mission) => mission.completed)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
      children: [
        _CreateMissionBanner(onCreate: _createMission),
        const SizedBox(height: 18),
        _MissionSectionHeader(
          title: 'Activas / pendientes',
          count: activeMissions.length,
          icon: Icons.explore_rounded,
          color: const Color(0xFF536DFE),
        ),
        const SizedBox(height: 10),
        if (activeMissions.isEmpty)
          const _SmallEmptyMessage(
            message: 'No tienes misiones activas por ahora.',
            icon: Icons.schedule_rounded,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final mission = activeMissions[index];

              return _MissionCard(
                mission: mission,
                onTap: () => _continueMission(mission),
                onEdit: () => _editMission(mission),
                onDelete: () => _deleteMission(mission),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemCount: activeMissions.length,
          ),
        if (completedMissions.isNotEmpty) ...[
          const SizedBox(height: 24),
          _MissionSectionHeader(
            title: 'Misiones completadas',
            count: completedMissions.length,
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF35A853),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final mission = completedMissions[index];

              return _MissionCard(
                mission: mission,
                onTap: () => _continueMission(mission),
                onEdit: () => _editMission(mission),
                onDelete: () => _deleteMission(mission),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemCount: completedMissions.length,
          ),
        ],
      ],
    );
  }

  Widget _buildHeader() {
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
                      'Mis misiones',
                      style: TextStyle(
                        fontSize: 27,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Continúa aventuras guardadas o crea una nueva',
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF2E8), Color(0xFFEFE8FF)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFFB995)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE45DBF).withValues(alpha: 0.12),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.76),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFFFFC982)),
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  size: 46,
                  color: Color(0xFFFF7A3D),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aún no tienes misiones guardadas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4F321B),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Crea tu primera aventura de compras',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7A624D),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _createMission,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Crear misión',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                    ),
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

class _CreateMissionBanner extends StatelessWidget {
  final VoidCallback onCreate;

  const _CreateMissionBanner({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF2E8), Color(0xFFEFE8FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFB995)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7A3D).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
              color: Colors.white.withValues(alpha: 0.74),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: const Color(0xFFFFC982)),
            ),
            child: const Icon(
              Icons.add_task_rounded,
              color: Color(0xFFFF7A3D),
              size: 30,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nueva aventura',
                  style: TextStyle(
                    color: Color(0xFF4F321B),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Crea una lista para la próxima compra.',
                  style: TextStyle(
                    color: Color(0xFF7A624D),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: onCreate,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A3D),
              foregroundColor: Colors.white,
              minimumSize: const Size(82, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Crear',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _MissionSectionHeader({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.24)),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              height: 1.05,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4F321B),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.24)),
          ),
          child: Text(
            '$count',
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _SmallEmptyMessage extends StatelessWidget {
  final String message;
  final IconData icon;

  const _SmallEmptyMessage({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD9A3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF7A3D), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF7A624D),
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final ShoppingMission mission;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MissionCard({
    required this.mission,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final foundCount = mission.foundProductsCount;
    final totalCount = mission.products.length;
    final progress = totalCount == 0 ? 0.0 : foundCount / totalCount;
    final status = _MissionStatus.fromMission(mission);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: status.cardGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: status.borderColor),
            boxShadow: [
              BoxShadow(
                color: status.borderColor.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.76),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Text(
                      mission.rewardEmoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mission.displayTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4F321B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _updatedLabel(mission.updatedAt),
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7A624D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _StatusPill(status: status),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_productCountLabel(totalCount)} · $foundCount / $totalCount encontrados',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4F321B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              _MissionProgressBar(progress: progress),
              const SizedBox(height: 13),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                child: Text(
                  'Recompensa: ${mission.rewardDisplayText}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6D2F66),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onTap,
                      icon: Icon(status.actionIcon),
                      label: Text(status.actionLabel),
                      style: FilledButton.styleFrom(
                        backgroundColor: status.pillColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 44),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Editar misión',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded),
                    color: const Color(0xFF536DFE),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.74),
                      fixedSize: const Size(44, 44),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: 'Eliminar misión',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: const Color(0xFF9A4A68),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.74),
                      fixedSize: const Size(44, 44),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _productCountLabel(int totalCount) {
    return totalCount == 1 ? '1 producto' : '$totalCount productos';
  }

  String _updatedLabel(DateTime updatedAt) {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inMinutes < 60) {
      return 'Actualizada recientemente';
    }

    if (difference.inHours < 24) {
      return 'Actualizada hoy';
    }

    if (difference.inDays == 1) {
      return 'Actualizada ayer';
    }

    return 'Actualizada ${_formatDate(updatedAt)}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _StatusPill extends StatelessWidget {
  final _MissionStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: status.pillColor,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: status.pillColor.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 15, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionProgressBar extends StatelessWidget {
  final double progress;

  const _MissionProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 14,
        color: Colors.white.withValues(alpha: 0.76),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
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

class _MissionStatus {
  final String label;
  final String actionLabel;
  final IconData icon;
  final IconData actionIcon;
  final Color pillColor;
  final Color borderColor;
  final Gradient cardGradient;

  const _MissionStatus({
    required this.label,
    required this.actionLabel,
    required this.icon,
    required this.actionIcon,
    required this.pillColor,
    required this.borderColor,
    required this.cardGradient,
  });

  factory _MissionStatus.fromMission(ShoppingMission mission) {
    if (mission.completed) {
      return const _MissionStatus(
        label: 'Completada',
        actionLabel: 'Ver misión',
        icon: Icons.check_circle_rounded,
        actionIcon: Icons.visibility_rounded,
        pillColor: Color(0xFF35A853),
        borderColor: Color(0xFF78D4C4),
        cardGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6F8F4), Color(0xFFEAF7FF)],
        ),
      );
    }

    if (mission.isActive) {
      return const _MissionStatus(
        label: 'Activa',
        actionLabel: 'Continuar',
        icon: Icons.explore_rounded,
        actionIcon: Icons.play_arrow_rounded,
        pillColor: Color(0xFF536DFE),
        borderColor: Color(0xFF92B9FF),
        cardGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE4EEFF), Color(0xFFEFE8FF)],
        ),
      );
    }

    return const _MissionStatus(
      label: 'Pendiente',
      actionLabel: 'Continuar',
      icon: Icons.schedule_rounded,
      actionIcon: Icons.play_arrow_rounded,
      pillColor: Color(0xFFFF7A3D),
      borderColor: Color(0xFFFFB995),
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF2E8), Color(0xFFFFE8F6)],
      ),
    );
  }
}
