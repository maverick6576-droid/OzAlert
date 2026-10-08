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

          final currentStage = stages[_selectedStageIndex.clamp(0, stages.length - 1)];
          final currentStageTasks = currentStage['tasks'] as List<LandingTask>;
          final currentPendingTasks = currentStageTasks.where((t) => !t.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              // 1. Camino Animado de Evolución Australiana (The Great Aussie Trail)
              _buildAustralianJourneyTrail(
                completedCount: completedCount,
                totalCount: totalCount,
                progressPercent: progressPercent,
                stages: stages,
                isEn: isEn,
              ),
              const SizedBox(height: 14),

              // 2. MODO FOCO: Si hay tareas pendientes en la fase activa, destacar la próxima
              if (currentPendingTasks.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.flame_fill, size: 16, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isEn
                              ? 'Next up: Complete this step first to avoid delays.'
                              : 'Prioridad: Completa esta gestión primero para no retrasarte.',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 5. TÍTULO DE LA FASE ACTIVA
              _buildSectionHeader(
                currentStage['title'] as String,
                currentStage['subtitle'] as String,
              ),

              // 6. TAREAS DE LA FASE SELECCIONADA (SOLO 3 A 7 TAREAS EN PANTALLA)
              ...currentStageTasks.map((t) => _buildTaskTile(context, ref, t, isEn)),

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
    final currentStage = stages[_selectedStageIndex.clamp(0, stages.length - 1)];

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

          const SizedBox(height: 10),

          // 2. Micro-lore divertido y corporativo según el avance real
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                const Text('🧭', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    _getAussieLoreText(progressPercent, isEn),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. El Camino Animado con los 4 Hitos y el Canguro Viajero
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              const nodeWidth = 58.0;

              return SizedBox(
                height: 88,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // A) Carretera Base (Outback Track)
                    Positioned(
                      top: 22,
                      left: nodeWidth / 2,
                      right: nodeWidth / 2,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: AppColors.cardBorder, width: 0.8),
                        ),
                      ),
                    ),

                    // B) Tramo Recorrido Animado con Gradiente
                    Positioned(
                      top: 22,
                      left: nodeWidth / 2,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: progressPercent.clamp(0.0, 1.0)),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeInOutCubic,
                        builder: (context, val, _) {
                          final maxTrack = availableWidth - nodeWidth;
                          return Container(
                            height: 6,
                            width: maxTrack * val,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        },
                      ),
                    ),

                    // C) Canguro Viajero Animado que Avanza por el Camino
                    Positioned(
                      top: 7,
                      left: 0,
                      right: 0,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: progressPercent.clamp(0.0, 1.0)),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeInOutCubic,
                        builder: (context, val, _) {
                          final maxTrack = availableWidth - nodeWidth;
                          final leftPos = ((nodeWidth / 2) + (maxTrack * val) - 12).clamp(0.0, availableWidth - 24);
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: leftPos),
                              child: Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary, width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: const Text('🦘', style: TextStyle(fontSize: 13)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // D) Los 4 Hitos Interactivos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(stages.length, (idx) {
                        final st = stages[idx];
                        final stTasks = st['tasks'] as List<LandingTask>;
                        final stDone = stTasks.where((t) => t.isCompleted).length;
                        final isStageDone = stTasks.isNotEmpty && stDone == stTasks.length;
                        final isSelected = _selectedStageIndex == idx;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedStageIndex = idx),
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            width: nodeWidth,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Nodo circular del hito
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isStageDone
                                        ? AppColors.secondary
                                        : (isSelected ? AppColors.primary : AppColors.surface),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? (isStageDone ? AppColors.secondary : AppColors.primary)
                                          : (isStageDone ? AppColors.secondary : AppColors.cardBorder),
                                      width: isSelected ? 2.5 : 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: (isStageDone ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: isStageDone
                                      ? const Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 20)
                                      : Text(
                                          st['icon'] as String,
                                          style: const TextStyle(fontSize: 19),
                                        ),
                                ),
                                const SizedBox(height: 5),
                                // Nombre corto del hito
                                Text(
                                  st['shortTitle'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                                // Badge con gestiones listas
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withValues(alpha: 0.12)
                                        : AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$stDone/${stTasks.length}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // 4. Parada Activa Seleccionada con Landmark y Temática
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Text(currentStage['icon'] as String, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${currentStage['title']} • ${currentStage['landmark']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        currentStage['aussieTheme'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isEn ? 'Active Stop' : 'Parada Activa',
                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAussieLoreText(double percent, bool isEn) {
    if (percent == 0.0) {
      return isEn
          ? '🎒 Packing your Akubra hat, visa & passport for Down Under!'
          : '🎒 Empacando el sombrero Akubra, visa y pasaporte para Down Under!';
    } else if (percent < 0.30) {
      return isEn
          ? '✈️ Crossing 14,000 km across oceans towards Australia!'
          : '✈️ Cruzando 14.000 km sobre los océanos rumbo a Australia!';
    } else if (percent < 0.60) {
      return isEn
          ? '🏄 Coastal landing: flat white in hand, SIM, TFN & bank account ready!'
          : '🏄 Aterrizaje en la costa: flat white en mano, SIM, TFN y banco listos!';
    } else if (percent < 0.90) {
      return isEn
          ? '🚜 Conquering the Red Dirt Outback: 88 days logged and counting!'
          : '🚜 Conquistando la tierra roja del Outback: 88 días computando!';
    } else if (percent < 1.0) {
      return isEn
          ? '🦘 True Aussie mate: renewal locked, Super & tax return prepared!'
          : '🦘 Auténtico mate australiano: 2º año listo y tax return preparado!';
    } else {
      return isEn
          ? '🏆 Down Under Legend! All checklist points complete, zero dollars lost!'
          : '🏆 ¡Leyenda de Australia! Todo completado y ni un dólar perdido!';
    }
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
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
        return isEn ? 'Pro Resume & Document Suite 📄' : 'Generador CV Pro & Documentos 📄';
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
