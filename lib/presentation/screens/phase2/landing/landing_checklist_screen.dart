import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/phase2/phase2_providers.dart';
import '../../../providers/locale_provider.dart';
import '../../../../domain/models/phase2/landing_task.dart';
import 'package:ozvisa_alert/presentation/widgets/phase2/phase2_app_bar.dart';

class LandingChecklistScreen extends ConsumerStatefulWidget {
  const LandingChecklistScreen({super.key});

  @override
  ConsumerState<LandingChecklistScreen> createState() => _LandingChecklistScreenState();
}

class _LandingChecklistScreenState extends ConsumerState<LandingChecklistScreen> {
  int _selectedStageIndex = 0; // 0 = Pre-vuelo, 1 = Llegada, 2 = 88 Días, 3 = Salida

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(landingTasksProvider);
    final locale = ref.watch(localeProvider);
    final isEn = locale?.languageCode == 'en';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: Phase2AppBar(
        title: isEn ? 'Arrival Hub' : 'Guía de Aterrizaje',
        isEn: isEn,
        infoTopic: 'arrival',
      ),
      body: tasksAsync.when(
        data: (tasks) {
          final completedCount = tasks.where((t) => t.isCompleted).length;
          final totalCount = tasks.length;
          final progressPercent = totalCount > 0 ? (completedCount / totalCount) : 0.0;

          // Agrupación en 4 etapas ejecutivas
          final preDepartureTasks = tasks.where((t) => t.phase == 'pre_departure').toList();
          final arrivalTasks = tasks.where((t) => t.phase == 'first_48h' || t.phase == 'first_week').toList();
          final renewalTasks = tasks.where((t) => t.phase == 'first_month' || t.phase == 'visa_renewal').toList();
          final departureTasks = tasks.where((t) => t.phase == 'departure_exit').toList();

          final stages = [
            {
              'title': isEn ? '✈️ Pre-Flight' : '✈️ Pre-Vuelo',
              'shortTitle': isEn ? 'Pre-Flight' : 'Pre-Vuelo',
              'subtitle': isEn ? 'Before boarding' : 'Antes de despegar',
              'icon': '🛫',
              'landmark': isEn ? 'Departure Gate' : 'Despegue',
              'aussieTheme': isEn ? 'Passport, Visa & Akubra Hat' : 'Pasaporte, Visa & Sombrero Akubra',
              'tasks': preDepartureTasks,
            },
            {
              'title': isEn ? '🧳 Arrival' : '🧳 Llegada',
              'shortTitle': isEn ? 'Arrival' : 'Llegada',
              'subtitle': isEn ? 'First 48h & week' : 'Primeros días',
              'icon': '🏄',
              'landmark': isEn ? 'Bondi Beach' : 'Sydney & Costa',
              'aussieTheme': isEn ? 'TFN, SIM & Flat White' : 'TFN, SIM & Buen Flat White',
              'tasks': arrivalTasks,
            },
            {
              'title': isEn ? '🚜 88 Days' : '🚜 88 Días',
              'shortTitle': isEn ? '88 Days' : '88 Días',
              'subtitle': isEn ? 'Regional & 2nd visa' : 'Renovación de visa',
              'icon': '🚜',
              'landmark': isEn ? 'Red Dirt Farm' : 'Outback & Granja',
              'aussieTheme': isEn ? 'Red Dust & 88 Days Work Log' : 'Tierra Roja & Faena de 88 Días',
              'tasks': renewalTasks,
            },
            {
              'title': isEn ? '🛫 Departure' : '🛫 Salida',
              'shortTitle': isEn ? 'Departure' : 'Salida',
              'subtitle': isEn ? 'Reclaim DASP & cash' : 'Recuperar dinero',
              'icon': '🪸',
              'landmark': isEn ? 'Reef & Departure' : 'Gran Barrera & Salida',
              'aussieTheme': isEn ? 'DASP Super Reclaim & Tax Return' : 'Rescate Super (DASP) & Tax Return',
              'tasks': departureTasks,
            },
          ];

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              // 1. Camino Animado de Evolución Australiana (The Great Aussie S-Trail)
              _buildAustralianJourneyTrail(
                completedCount: completedCount,
                totalCount: totalCount,
                progressPercent: progressPercent,
                stages: stages,
                isEn: isEn,
              ),
              const SizedBox(height: 16),

              // 2. TODAS LAS FASES SIEMPRE VISIBLES EN FORMATO DESPLEGABLE / ACCORDION
              for (int stageIdx = 0; stageIdx < stages.length; stageIdx++) ...[
                _buildStageAccordionSection(
                  context: context,
                  ref: ref,
                  stageIndex: stageIdx,
                  stage: stages[stageIdx],
                  isExpanded: _selectedStageIndex == stageIdx,
                  isEn: isEn,
                  onHeaderTap: () {
                    setState(() {
                      if (_selectedStageIndex == stageIdx) {
                        _selectedStageIndex = -1;
                      } else {
                        _selectedStageIndex = stageIdx;
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
              ],

              const SizedBox(height: 36),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildAustralianJourneyTrail({
    required int completedCount,
    required int totalCount,
    required double progressPercent,
    required List<Map<String, dynamic>> stages,
    required bool isEn,
  }) {
    final isDone = completedCount == totalCount && totalCount > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cabecera de la Ruta: Insignia Australiana + Contador Porcentual
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('🦘', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? 'THE GREAT AUSSIE TRAIL' : 'LA GRAN RUTA AUSTRALIANA',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            isEn ? 'Your Journey in Australia' : 'Tu Camino en Australia',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.secondary.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDone
                        ? AppColors.secondary.withValues(alpha: 0.4)
                        : AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDone ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.flame_fill,
                      size: 13,
                      color: isDone ? AppColors.secondary : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$completedCount/$totalCount (${(progressPercent * 100).round()}%)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isDone ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2. Camino Animado en 'S' (The Great Aussie S-Trail)
          _buildAussieSTrail(
            progressPercent: progressPercent,
            stages: stages,
            isEn: isEn,
          ),
        ],
      ),
    );
  }

  Widget _buildAussieSTrail({
    required double progressPercent,
    required List<Map<String, dynamic>> stages,
    required bool isEn,
  }) {
    final stage0Tasks = stages[0]['tasks'] as List<LandingTask>;
    final stage0Done = stage0Tasks.where((t) => t.isCompleted).length;
    final stage0Ratio = stage0Tasks.isNotEmpty ? (stage0Done / stage0Tasks.length) : 0.0;

    final stage1Tasks = stages[1]['tasks'] as List<LandingTask>;
    final stage1Done = stage1Tasks.where((t) => t.isCompleted).length;
    final stage1Ratio = stage1Tasks.isNotEmpty ? (stage1Done / stage1Tasks.length) : 0.0;

    final stage2Tasks = stages[2]['tasks'] as List<LandingTask>;
    final stage2Done = stage2Tasks.where((t) => t.isCompleted).length;
    final stage2Ratio = stage2Tasks.isNotEmpty ? (stage2Done / stage2Tasks.length) : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        const canvasHeight = 146.0;
        const padX = 36.0;
        const y0 = 24.0;
        const y1 = 73.0;
        const y2 = 122.0;

        // Trayectoria en 'S' continua, elegante y fluida
        final path = Path();
        path.moveTo(padX, y0);
        path.lineTo(availableWidth - padX, y0);
        path.cubicTo(
          availableWidth - 2, y0,
          availableWidth - 2, y1,
          availableWidth - padX, y1,
        );
        path.lineTo(padX, y1);
        path.cubicTo(
          2, y1,
          2, y2,
          padX, y2,
        );
        path.lineTo(availableWidth - padX, y2);

        final metric = path.computeMetrics().first;
        final totalLength = metric.length;

        final subPathToW1 = Path()
          ..moveTo(padX, y0)
          ..lineTo(availableWidth - padX, y0);
        final lenW1 = subPathToW1.computeMetrics().first.length;

        final subPathToW2 = Path()
          ..moveTo(padX, y0)
          ..lineTo(availableWidth - padX, y0)
          ..cubicTo(availableWidth - 2, y0, availableWidth - 2, y1, availableWidth - padX, y1)
          ..lineTo(padX, y1);
        final lenW2 = subPathToW2.computeMetrics().first.length;

        final f1 = (lenW1 / totalLength).clamp(0.0, 1.0);
        final f2 = (lenW2 / totalLength).clamp(0.0, 1.0);

        // Progresión exacta: el canguro llega al icono de la siguiente fase cuando se completan todos los pasos de la fase anterior
        double effectiveProgress = 0.0;
        if (stage0Ratio < 1.0) {
          effectiveProgress = f1 * stage0Ratio;
        } else if (stage1Ratio < 1.0) {
          effectiveProgress = f1 + (f2 - f1) * stage1Ratio;
        } else if (stage2Ratio < 1.0) {
          effectiveProgress = f2 + (1.0 - f2) * stage2Ratio;
        } else {
          effectiveProgress = 1.0;
        }

        final waypoints = [
          const Offset(padX, y0),
          Offset(availableWidth - padX, y0),
          const Offset(padX, y1),
          Offset(availableWidth - padX, y2),
        ];

        return SizedBox(
          height: canvasHeight,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: effectiveProgress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
            builder: (context, animatedVal, _) {
              final tangent = metric.getTangentForOffset(totalLength * animatedVal);
              final kPos = tangent?.position ?? const Offset(padX, y0);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Capa 1 y 2: Carretera Outback base + Tramo activo animado + Waypoints
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _AussieSTrailPainter(
                        basePath: path,
                        metric: metric,
                        progress: animatedVal,
                        waypoints: waypoints,
                        selectedIndex: _selectedStageIndex,
                        stages: stages,
                      ),
                    ),
                  ),

                  // Capa 3: Botones interactivos con solo el icono/dibujo de las 4 etapas (sin texto en el camino)
                  // Etapa 0 (Pre-Vuelo): situado exactamente en Waypoint 0
                  Positioned(
                    left: padX - 17,
                    top: y0 - 17,
                    child: _buildStageIconNode(
                      index: 0,
                      stage: stages[0],
                      isSelected: _selectedStageIndex == 0,
                    ),
                  ),

                  // Etapa 1 (Llegada): situado exactamente en Waypoint 1
                  Positioned(
                    left: availableWidth - padX - 17,
                    top: y0 - 17,
                    child: _buildStageIconNode(
                      index: 1,
                      stage: stages[1],
                      isSelected: _selectedStageIndex == 1,
                    ),
                  ),

                  // Etapa 2 (88 Días): situado exactamente en Waypoint 2
                  Positioned(
                    left: padX - 17,
                    top: y1 - 17,
                    child: _buildStageIconNode(
                      index: 2,
                      stage: stages[2],
                      isSelected: _selectedStageIndex == 2,
                    ),
                  ),

                  // Etapa 3 (Salida): situado exactamente en Waypoint 3
                  Positioned(
                    left: availableWidth - padX - 17,
                    top: y2 - 17,
                    child: _buildStageIconNode(
                      index: 3,
                      stage: stages[3],
                      isSelected: _selectedStageIndex == 3,
                    ),
                  ),

                  // Capa 4: CANGURO VIAJERO (EN LA CAPA SUPERIOR, NUNCA TAPADO POR NADA)
                  Positioned(
                    left: (kPos.dx - 15).clamp(0.0, availableWidth - 30),
                    top: (kPos.dy - 15).clamp(0.0, canvasHeight - 30),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 7,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text('🦘', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStageIconNode({
    required int index,
    required Map<String, dynamic> stage,
    required bool isSelected,
  }) {
    final tasks = stage['tasks'] as List<LandingTask>;
    final doneCount = tasks.where((t) => t.isCompleted).length;
    final isDone = tasks.isNotEmpty && doneCount == tasks.length;

    return GestureDetector(
      onTap: () => setState(() => _selectedStageIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? (isDone ? AppColors.secondary : AppColors.primary)
              : (isDone ? AppColors.secondary.withValues(alpha: 0.15) : AppColors.surface),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : (isDone ? AppColors.secondary : AppColors.cardBorder),
            width: isSelected ? 2.4 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDone ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                ],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Text(
              stage['icon'] as String,
              style: const TextStyle(fontSize: 16),
            ),
            if (isDone && !isSelected)
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.checkmark, size: 8, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageAccordionSection({
    required BuildContext context,
    required WidgetRef ref,
    required int stageIndex,
    required Map<String, dynamic> stage,
    required bool isExpanded,
    required bool isEn,
    required VoidCallback onHeaderTap,
  }) {
    final tasks = stage['tasks'] as List<LandingTask>;
    final doneCount = tasks.where((t) => t.isCompleted).length;
    final isDone = tasks.isNotEmpty && doneCount == tasks.length;
    final pendingTasks = tasks.where((t) => !t.isCompleted).toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? (isDone ? AppColors.secondary : AppColors.primary)
              : (isDone ? AppColors.secondary.withValues(alpha: 0.45) : AppColors.cardBorder),
          width: isExpanded ? 1.6 : 1.0,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: (isDone ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : const [
                BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera interactiva del Accordion
          InkWell(
            onTap: onHeaderTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.secondary.withValues(alpha: 0.15)
                          : (isExpanded ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceElevated),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(stage['icon'] as String, style: const TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isExpanded ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stage['subtitle'] as String,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.secondary.withValues(alpha: 0.15)
                          : (isExpanded ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceElevated),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDone
                            ? AppColors.secondary.withValues(alpha: 0.4)
                            : (isExpanded ? AppColors.primary.withValues(alpha: 0.3) : AppColors.cardBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isDone)
                          const Icon(CupertinoIcons.checkmark_circle_fill, size: 12, color: AppColors.secondary)
                        else
                          Text(
                            '$doneCount/${tasks.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isExpanded ? AppColors.primary : AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                    size: 15,
                    color: isExpanded ? AppColors.primary : AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),

          // Contenido desplegable (Tareas de la fase)
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.cardBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pendingTasks.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.flame_fill, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isEn
                                  ? 'Priority: Complete pending tasks below.'
                                  : 'Prioridad: Completa estas tareas para avanzar de fase.',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  ...tasks.map((t) => _buildTaskTile(context, ref, t, isEn)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, WidgetRef ref, LandingTask task, bool isEn) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: task.isCompleted ? AppColors.secondary.withValues(alpha: 0.35) : AppColors.cardBorder,
          width: task.isCompleted ? 1.5 : 1.0,
        ),
      ),
      elevation: 0,
      color: task.isCompleted ? AppColors.surfaceElevated.withValues(alpha: 0.5) : AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            Transform.scale(
              scale: 1.05,
              child: Checkbox(
                value: task.isCompleted,
                activeColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                side: const BorderSide(color: AppColors.textMuted, width: 1.5),
                onChanged: (val) {
                  ref.read(landingTasksProvider.notifier).toggleTask(task.id, val ?? false);
                },
              ),
            ),
            const SizedBox(width: 4),
            // Textos y botón de acción rápida
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    isEn ? task.titleEn : task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: task.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEn ? task.subtitleEn : task.subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: task.isCompleted ? AppColors.textMuted : AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  if (task.targetGuideCategory != null) ...[
                    const SizedBox(height: 10),
                    // Botón interactivo Smart Link
                    InkWell(
                      onTap: () {
                        final target = task.targetGuideCategory!;
                        if (target == 'employment') {
                          ref.read(phase2NavigationProvider.notifier).setTabIndex(2);
                        } else if (target == 'fair_work') {
                          ref.read(phase2NavigationProvider.notifier).setTabIndex(2);
                        } else if (target == '88days' || target == 'regional_work') {
                          ref.read(phase2NavigationProvider.notifier).setTabIndex(3);
                        } else {
                          ref.read(phase2NavigationProvider.notifier).navigateToGuide(target);
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.arrow_right_circle_fill, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _getTaskActionLabel(task.targetGuideCategory!, isEn),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                            if (task.targetGuideCategory == 'savings' ||
                                task.targetGuideCategory == '88days' ||
                                task.targetGuideCategory == 'visa_renewal' ||
                                task.targetGuideCategory == 'departure') ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTaskActionLabel(String target, bool isEn) {
    switch (target) {
      case 'employment':
        return isEn ? 'Resume & Document Suite 📄' : 'Generador CV & Documentos 📄';
      case 'fair_work':
        return isEn ? 'Fair Work Pay Calculator 💰' : 'Calcular Sueldo Fair Work 💰';
      case '88days':
      case 'regional_work':
        return isEn ? 'Regional Map & 88-Day Log 📍' : 'Mapa Oficial & 88 Días 📍';
      case 'savings':
        return isEn ? 'Pro Money & Tax Hacks 💵' : 'Hacks Pro de Ahorro Masivo 💵';
      case 'visa_renewal':
        return isEn ? '2nd & 3rd Visa Guide 🦘' : 'Guía 2ª y 3ª Visa 🦘';
      case 'departure':
        return isEn ? 'Exit Protocol & Reclaim Cash 🛫' : 'Protocolo Salida & Recuperar Dinero 🛫';
      default:
        return isEn ? 'View Guide & Comparisons' : 'Ver Guía y Comparativa';
    }
  }
}

class _AussieSTrailPainter extends CustomPainter {
  final Path basePath;
  final PathMetric metric;
  final double progress;
  final List<Offset> waypoints;
  final int selectedIndex;
  final List<Map<String, dynamic>> stages;

  _AussieSTrailPainter({
    required this.basePath,
    required this.metric,
    required this.progress,
    required this.waypoints,
    required this.selectedIndex,
    required this.stages,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Carretera Outback Base
    final roadBorderPaint = Paint()
      ..color = AppColors.cardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    final roadInnerPaint = Paint()
      ..color = AppColors.surfaceElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(basePath, roadBorderPaint);
    canvas.drawPath(basePath, roadInnerPaint);

    // 2. Tramo activo completado con gradiente corporativo
    if (progress > 0.001) {
      final totalLen = metric.length;
      final activePath = metric.extractPath(0.0, totalLen * progress);

      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      final activePaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.0
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(activePath, activePaint);
    }

    // 3. Waypoints / Estaciones marcadas sobre la calzada
    for (int i = 0; i < waypoints.length; i++) {
      final pt = waypoints[i];
      final tasks = stages[i]['tasks'] as List<LandingTask>;
      final done = tasks.isNotEmpty && tasks.every((t) => t.isCompleted);
      final isSel = selectedIndex == i;

      // Halo o anillo exterior de estación
      final ringPaint = Paint()
        ..color = isSel
            ? (done ? AppColors.secondary : AppColors.primary)
            : (done ? AppColors.secondary : AppColors.cardBorder)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSel ? 2.5 : 1.8;

      final fillPaint = Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pt, 7.5, fillPaint);
      canvas.drawCircle(pt, 7.5, ringPaint);

      // Núcleo central
      final corePaint = Paint()
        ..color = done
            ? AppColors.secondary
            : (isSel ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.5))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pt, 3.5, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AussieSTrailPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
