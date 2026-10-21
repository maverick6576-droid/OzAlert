import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/phase2/phase2_providers.dart';
import '../../../providers/locale_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../domain/models/phase2/landing_task.dart';
import 'package:ozvisa_alert/presentation/widgets/phase2/phase2_app_bar.dart';
import '../../../widgets/phase2/tax_and_vehicle_hub_modal.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../providers/user_provider.dart';
import '../../../../core/services/community_telemetry_service.dart';

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
    final lang = locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    final isEn = lang != 'es';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: Phase2AppBar(
        title: AppStrings.landingAppBarTitle(lang),
        isEn: isEn,
        infoTopic: 'arrival',
      ),
      body: tasksAsync.when(
        data: (tasks) {
          final completedCount = tasks.where((t) => t.isCompleted).length;
          final totalCount = tasks.length;
          final progressPercent = totalCount > 0 ? (completedCount / totalCount) : 0.0;

          // Agrupación en 5 etapas ejecutivas
          final preDepartureTasks = tasks.where((t) => t.phase == 'pre_departure').toList();
          final arrivalTasks = tasks.where((t) => t.phase == 'first_48h' || t.phase == 'first_week').toList();
          final renewal88Tasks = tasks.where((t) => t.phase == 'first_month' || t.phase == 'visa_renewal_88' || (t.phase == 'visa_renewal' && !t.id.contains('179') && !t.id.contains('third'))).toList();
          final renewal179Tasks = tasks.where((t) => t.phase == 'visa_renewal_179' || t.id.contains('179') || t.id.contains('third')).toList();
          final departureTasks = tasks.where((t) => t.phase == 'departure_exit').toList();

          String tr(String es, String en, {String? fr, String? it, String? zh}) {
            switch (lang.toLowerCase()) {
              case 'zh': return zh ?? en;
              case 'fr': return fr ?? en;
              case 'it': return it ?? en;
              case 'es': return es;
              case 'en':
              default: return en;
            }
          }

          final stages = [
            {
              'title': AppStrings.stageTitle(lang, 0),
              'shortTitle': AppStrings.stageShortTitle(lang, 0),
              'subtitle': AppStrings.stageSubtitle(lang, 0),
              'icon': '🛫',
              'landmark': tr('Despegue', 'Departure Gate', fr: 'Porte d’embarquement', it: 'Partenza', zh: '登机启程'),
              'aussieTheme': tr('Pasaporte, Visa & Sombrero Akubra', 'Passport, Visa & Akubra Hat', fr: 'Passeport, Visa & Chapeau Akubra', it: 'Passaporto, Visto & Cappello Akubra', zh: '护照、下签信与澳洲探险帽'),
              'tasks': preDepartureTasks,
            },
            {
              'title': AppStrings.stageTitle(lang, 1),
              'shortTitle': AppStrings.stageShortTitle(lang, 1),
              'subtitle': AppStrings.stageSubtitle(lang, 1),
              'icon': '🏄',
              'landmark': tr('Sydney & Costa', 'Bondi Beach', fr: 'Plage de Bondi', it: 'Bondi Beach & Costa', zh: '邦迪海滩与东海岸'),
              'aussieTheme': tr('TFN, SIM & Buen Flat White', 'TFN, SIM & Flat White', fr: 'TFN, Carte SIM & Flat White', it: 'TFN, SIM & Caffè Flat White', zh: '税号TFN、电话卡与澳白咖啡'),
              'tasks': arrivalTasks,
            },
            {
              'title': AppStrings.stageTitle(lang, 2),
              'shortTitle': AppStrings.stageShortTitle(lang, 2),
              'subtitle': AppStrings.stageSubtitle(lang, 2),
              'icon': '🚜',
              'landmark': tr('Outback & Granja', 'Red Dirt Farm', fr: 'Ferme des Terres Rouges', it: 'Fattoria Terra Rossa', zh: '红土地农场与内陆'),
              'aussieTheme': tr('Tierra Roja & Faena de 88 Días', 'Red Dust & 88 Days Work Log', fr: 'Poussière Rouge & Journal de 88 Jours', it: 'Polvere Rossa & Registro 88 Giorni', zh: '红土地与88天二签集签日志'),
              'tasks': renewal88Tasks,
            },
            {
              'title': AppStrings.stageTitle(lang, 3),
              'shortTitle': AppStrings.stageShortTitle(lang, 3),
              'subtitle': AppStrings.stageSubtitle(lang, 3),
              'icon': '🌾',
              'landmark': tr('Top End & Outback Profundo', 'Top End & Far North', fr: 'Top End & Grand Nord', it: 'Top End & Grande Nord', zh: '北领地 Top End 与偏远极北'),
              'aussieTheme': tr('Registro 179 Días & Auditoría 1263', '179 Days Log & Form 1263 Audit', fr: 'Suivi 179 Jours & Audit Formulaire 1263', it: 'Registro 179 Giorni & Audit Modulo 1263', zh: '179天三签日志与1263表格核查'),
              'tasks': renewal179Tasks,
            },
            {
              'title': AppStrings.stageTitle(lang, 4),
              'shortTitle': AppStrings.stageShortTitle(lang, 4),
              'subtitle': AppStrings.stageSubtitle(lang, 4),
              'icon': '🪸',
              'landmark': tr('Gran Barrera & Salida', 'Reef & Departure', fr: 'Récif & Départ', it: 'Grande Barriera & Partenza', zh: '大堡礁与圆满离澳'),
              'aussieTheme': tr('Rescate Super (DASP) & Tax Return', 'DASP Super Reclaim & Tax Return', fr: 'Rapatriement Super (DASP) & Tax Return', it: 'Recupero Super (DASP) & Dichiarazione Fiscale', zh: '离境退休金 (DASP) 退还与年度退税'),
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
                  lang: lang,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            isEn ? 'Your Journey in Australia' : 'Tu Camino en Australia',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
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

    final stage3Tasks = stages[3]['tasks'] as List<LandingTask>;
    final stage3Done = stage3Tasks.where((t) => t.isCompleted).length;
    final stage3Ratio = stage3Tasks.isNotEmpty ? (stage3Done / stage3Tasks.length) : 0.0;

    final stage4Tasks = stages[4]['tasks'] as List<LandingTask>;
    final stage4Done = stage4Tasks.where((t) => t.isCompleted).length;
    final stage4Ratio = stage4Tasks.isNotEmpty ? (stage4Done / stage4Tasks.length) : 0.0;

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
          ..lineTo(availableWidth * 0.58, y1);
        final lenW2 = subPathToW2.computeMetrics().first.length;

        final subPathToW3 = Path()
          ..moveTo(padX, y0)
          ..lineTo(availableWidth - padX, y0)
          ..cubicTo(availableWidth - 2, y0, availableWidth - 2, y1, availableWidth - padX, y1)
          ..lineTo(padX, y1);
        final lenW3 = subPathToW3.computeMetrics().first.length;

        final f1 = (lenW1 / totalLength).clamp(0.0, 1.0);
        final f2 = (lenW2 / totalLength).clamp(0.0, 1.0);
        final f3 = (lenW3 / totalLength).clamp(0.0, 1.0);

        // Progresión exacta: el canguro avanza de forma fluida y continua etapa por etapa
        double effectiveProgress = 0.0;
        if (stage0Ratio < 1.0) {
          effectiveProgress = f1 * stage0Ratio;
        } else if (stage1Ratio < 1.0) {
          effectiveProgress = f1 + (f2 - f1) * stage1Ratio;
        } else if (stage2Ratio < 1.0) {
          effectiveProgress = f2 + (f3 - f2) * stage2Ratio;
        } else if (stage3Ratio < 1.0) {
          effectiveProgress = f3 + (1.0 - f3) * stage3Ratio;
        } else if (stage4Ratio < 1.0) {
          effectiveProgress = 0.96 + (0.04 * stage4Ratio);
        } else {
          effectiveProgress = 1.0;
        }

        final waypoints = [
          const Offset(padX, y0),
          Offset(availableWidth - padX, y0),
          Offset(availableWidth * 0.58, y1),
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

                  // Capa 3: Botones interactivos con solo el icono/dibujo de las 5 etapas
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

                  // Etapa 2 (88 Días): situado en Waypoint 2
                  Positioned(
                    left: availableWidth * 0.58 - 17,
                    top: y1 - 17,
                    child: _buildStageIconNode(
                      index: 2,
                      stage: stages[2],
                      isSelected: _selectedStageIndex == 2,
                    ),
                  ),

                  // Etapa 3 (179 Días): situado en Waypoint 3
                  Positioned(
                    left: padX - 17,
                    top: y1 - 17,
                    child: _buildStageIconNode(
                      index: 3,
                      stage: stages[3],
                      isSelected: _selectedStageIndex == 3,
                    ),
                  ),

                  // Etapa 4 (Salida): situado exactamente en Waypoint 4
                  Positioned(
                    left: availableWidth - padX - 17,
                    top: y2 - 17,
                    child: _buildStageIconNode(
                      index: 4,
                      stage: stages[4],
                      isSelected: _selectedStageIndex == 4,
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
    required String lang,
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
                  if (stageIndex == 3) ...[
                    InkWell(
                      onTap: () => TaxAndVehicleHubModal.show(context, lang: lang, isEn: isEn),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.12),
                              AppColors.secondary.withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(CupertinoIcons.money_dollar_circle_fill, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isEn ? 'Tax Return, MES & DASP Hub' : 'Hub Fiscal, MES 2% & Retiro DASP',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isEn
                                        ? 'Simulate your super refund and tax deductions before leaving.'
                                        : 'Calcula tu devolución DASP del 12% y exención Medicare antes de salir.',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isEn ? 'Open' : 'Abrir',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                  ...tasks.map((t) => _buildTaskTile(context, ref, t, lang, isEn)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, WidgetRef ref, LandingTask task, String lang, bool isEn) {
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
                  final isDone = val ?? false;
                  ref.read(landingTasksProvider.notifier).toggleTask(task.id, isDone);
                  if (isDone && (task.id == 'apply_second_visa_immi' || task.id == 'apply_third_visa_immi')) {
                    try {
                      final profile = ref.read(userProfileProvider).value;
                      final country = profile?.passports.isNotEmpty == true ? profile!.passports.first : 'Spain';
                      final countryCode = AppConstants.supportedCountries.firstWhere(
                        (c) => c.name == country,
                        orElse: () => AppConstants.supportedCountries.first,
                      ).code;
                      CommunityTelemetryService().logVisaProcessing(
                        countryCode: countryCode,
                        subclass: '462',
                        visaYear: task.id == 'apply_third_visa_immi' ? 3 : 2,
                        processingDays: 0,
                        hadS56: false,
                      );
                    } catch (_) {}
                  }
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
                    AppStrings.getTaskTitle(lang, task.id, task.title, task.titleEn),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: task.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.getTaskSubtitle(lang, task.id, task.subtitle, task.subtitleEn),
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
                        if (task.id == 'early_tax_return_ato' ||
                            task.id == 'dasp_super_refund_claim' ||
                            task.id == 'sell_car_rwc_rego' ||
                            task.id == 'medicare_levy_exemption') {
                          TaxAndVehicleHubModal.show(context, lang: lang, isEn: isEn);
                          return;
                        }
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
                                _getTaskActionLabel(task.targetGuideCategory!, lang, isEn, taskId: task.id),
                                softWrap: true,
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
                                task.targetGuideCategory == 'visa_renewal_179' ||
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

  String _getTaskActionLabel(String target, String lang, bool isEn, {String? taskId}) {
    String tr(String es, String en, {String? fr, String? it, String? zh}) {
      switch (lang.toLowerCase()) {
        case 'zh': return zh ?? en;
        case 'fr': return fr ?? en;
        case 'it': return it ?? en;
        case 'es': return es;
        case 'en':
        default: return en;
      }
    }

    if (taskId == 'early_tax_return_ato') {
      return tr('Simulador Tax Return & MES 2% 💵', 'Tax Return & MES 2% Calculator 💵', fr: 'Simulateur Tax Return & MES 2% 💵', it: 'Simulatore Tax Return & MES 2% 💵', zh: '个人所得税退税与 2% 医疗税减免模拟器 💵');
    }
    if (taskId == 'dasp_super_refund_claim') {
      return tr('Simulador Devolución DASP (12%) 💰', 'DASP Super Refund Simulator 💰', fr: 'Simulateur Remboursement DASP (12%) 💰', it: 'Simulatore Rimborso Super DASP (12%) 💰', zh: '离澳养老金 DASP (12%) 退款测算 💰');
    }
    if (taskId == 'sell_car_rwc_rego') {
      return tr('Guía Rego WA & Chequeo PPSR 🚗', 'WA Rego & PPSR Check 🚗', fr: 'Guide Rego WA & Contrôle PPSR 🚗', it: 'Guida Rego WA & Verifica PPSR 🚗', zh: '西澳车辆登记指南与 PPSR 产权债务查验 🚗');
    }
    if (taskId == 'medicare_levy_exemption') {
      return tr('Calculadora Exención MES 2% 💵', 'Medicare MES 2% Calculator 💵', fr: 'Calculateur Exemption MES 2% 💵', it: 'Calcolatore Esenzione MES 2% 💵', zh: '2% 医疗附加税豁免计算器 💵');
    }
    if (taskId == 'sham_contracting_shield') {
      return tr('Test Falso Autónomo & Reclamación 🛡️', 'Sham Contracting Test & Claim 🛡️', fr: 'Test Faux Indépendant & Réclamation 🛡️', it: 'Test Falso Autonomo & Reclamo 🛡️', zh: '虚假自雇防骗审查与申诉 🛡️');
    }
    if (taskId == 'condition_8547_work_extension') {
      return tr('Memo Exención Condición 8547 📄', 'Condition 8547 Exemption Memo 📄', fr: 'Mémo d’Exemption Condition 8547 📄', it: 'Memo Esenzione Condizione 8547 📄', zh: '8547工作条款豁免备忘录 📄');
    }
    if (taskId == 'rental_bond_receipt') {
      return tr('Generador Recibo de Fianza 🏠', 'Rental Bond Receipt Generator 🏠', fr: 'Générateur de Reçu de Caution 🏠', it: 'Generatore Ricevuta Cauzione 🏠', zh: '房屋押金正式收据生成器 🏠');
    }
    if (taskId == 'verify_88_days_second_visa' || taskId == 'sign_form_1263_third_visa') {
      return tr('Form 1263 & Firma en Pantalla ✍️', 'Form 1263 & Touch Signature ✍️', fr: 'Formulaire 1263 & Signature Tactile ✍️', it: 'Modulo 1263 & Firma su Schermo ✍️', zh: '1263表格与电子屏幕签名 ✍️');
    }
    if (taskId == 'plan_third_visa_regional' || taskId == 'verify_179_days_postcodes_industry') {
      return tr('Contador 179 Días & Mapa 🌾', '179-Day Tracker & Map 🌾', fr: 'Suivi 179 Jours & Carte 🌾', it: 'Tracciatore 179 Giorni & Mappa 🌾', zh: '179天二续三集签追踪与地图 🌾');
    }
    if (taskId == 'audit_179_days_payslips_bank') {
      return tr('Auditor de Nóminas & Fair Work 🧾', 'Payslip Scanner & Auditor 🧾', fr: 'Scanner & Audit Fiches de Paie 🧾', it: 'Scanner Buste Paga & Fair Work 🧾', zh: '工资单智能审查与公平工作核验 🧾');
    }
    switch (target) {
      case 'employment':
        return tr('Generador CV & Documentos 📄', 'Resume & Document Suite 📄', fr: 'Générateur CV & Documents 📄', it: 'Generatore CV & Documenti 📄', zh: '澳规简历与工作文档套件 📄');
      case 'fair_work':
        return tr('Calcular Sueldo Fair Work 💰', 'Fair Work Pay Calculator 💰', fr: 'Calculateur Salarial Fair Work 💰', it: 'Calcolo Stipendio Fair Work 💰', zh: '公平工作法定薪资计算器 💰');
      case '88days':
      case 'regional_work':
        return tr('Mapa Oficial & 88 Días 📍', 'Regional Map & 88-Day Log 📍', fr: 'Carte Régionale & 88 Jours 📍', it: 'Mappa Regionale & 88 Giorni 📍', zh: '官方偏远地区地图与88天日志 📍');
      case 'savings':
        return tr('Hacks Pro de Ahorro Masivo 💵', 'Pro Money & Tax Hacks 💵', fr: 'Astuces Pro d’Épargne & Fiscalité 💵', it: 'Trucchi Pro di Risparmio & Fisco 💵', zh: '省钱与税务实操技巧 💵');
      case 'visa_renewal':
        return tr('Guía 2ª Visa (88 Días) 🚜', '2nd Year Visa Guide (88 Days) 🚜', fr: 'Guide 2e Visa (88 Jours) 🚜', it: 'Guida 2° Visto (88 Giorni) 🚜', zh: '二签指南（88天） 🚜');
      case 'visa_renewal_179':
        return tr('Guía 3ª Visa (179 Días) 🌾', '3rd Year Visa Guide (179 Days) 🌾', fr: 'Guide 3e Visa (179 Jours) 🌾', it: 'Guida 3° Visto (179 Giorni) 🌾', zh: '三签指南（179天） 🌾');
      case 'international_license':
        return tr('Guía Carnet Internacional & NAATI 🪪', 'International Permit & NAATI Guide 🪪', fr: 'Permis International & Guide NAATI 🪪', it: 'Patente Internazionale & Guida NAATI 🪪', zh: '国际驾照与 NAATI 翻译指南 🪪');
      case 'australian_license':
        return tr('Guía Carnet Australiano 🚗', 'Australian Driver Licence Guide 🚗', fr: 'Permis de Conduire Australien 🚗', it: 'Guida Patente Australiana 🚗', zh: '澳洲本土正式驾照指南 🚗');
      case 'departure':
        return tr('Protocolo Salida & Recuperar Dinero 🛫', 'Exit Protocol & Reclaim Cash 🛫', fr: 'Protocole de Départ & Récupération 🛫', it: 'Protocollo Partenza & Recupero Soldi 🛫', zh: '离澳流程与资金全额退回 🛫');
      default:
        return tr('Ver Guía y Comparativa', 'View Guide & Comparisons', fr: 'Voir le Guide & Comparatif', it: 'Visualizza Guida & Confronti', zh: '查看指南与方案对比');
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
