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
  bool _showAllTasks = false;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(landingTasksProvider);
    final locale = ref.watch(localeProvider);
    final isEn = locale?.languageCode == 'en';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: Phase2AppBar(
        title: isEn ? 'Arrival Hub' : 'Aterrizaje en Australia',
        isEn: isEn,
        infoTopic: 'arrival',
      ),
      body: tasksAsync.when(
        data: (tasks) {
          final completedCount = tasks.where((t) => t.isCompleted).length;
          final totalCount = tasks.length;
          final progressPercent = totalCount > 0 ? (completedCount / totalCount) : 0.0;
          final pendingTasks = tasks.where((t) => !t.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              // 1. Tarjeta de progreso visual
              _buildProgressCard(completedCount, totalCount, progressPercent, isEn),
              const SizedBox(height: 14),

              // 2. Banner de Psicología Financiera: Dinero en Riesgo
              _buildSavingsTeaserBanner(isEn),
              const SizedBox(height: 18),

              // 3. MODO FOCO: Si hay tareas pendientes, mostrar solo las 2 prioritarias
              if (pendingTasks.isNotEmpty) ...[
                _buildSectionHeader(
                  isEn ? '🎯 Your Next 2 Priority Steps' : '🎯 Tus Próximas 2 Gestiones Clave',
                  isEn ? 'Focus only on these today to avoid overwhelm' : 'Céntrate solo en esto hoy sin agobios',
                ),
                ...pendingTasks.take(2).map((t) => _buildTaskTile(context, ref, t, isEn)),
                const SizedBox(height: 14),

                // Botón interactivo para ver el resto de fases
                Center(
                  child: OutlinedButton.icon(
                    icon: Icon(_showAllTasks ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down, size: 14),
                    label: Text(
                      _showAllTasks
                          ? (isEn ? 'Hide other phases' : 'Ocultar resto de gestiones')
                          : (isEn ? 'View all steps & phases ($totalCount)' : 'Ver todas las fases y gestiones ($totalCount)'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                    onPressed: () => setState(() => _showAllTasks = !_showAllTasks),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // 4. LISTADO COMPLETO POR FASES (Solo si _showAllTasks o todo completado)
              if (_showAllTasks || pendingTasks.isEmpty) ...[
                const SizedBox(height: 10),
                // Sección: Antes de Volar
                _buildSectionHeader(
                  isEn ? '✈️ Pre-Departure Tasks' : '✈️ Antes de Volar',
                  isEn ? 'Complete before your flight' : 'Gestiones previas al despegue',
                ),
                ...tasks.where((t) => t.phase == 'pre_departure').map((t) => _buildTaskTile(context, ref, t, isEn)),

                const SizedBox(height: 20),
                // Sección: Primeras 48 Horas
                _buildSectionHeader(
                  isEn ? '🧳 First 48 Hours in Australia' : '🧳 Primeras 48 Horas en Australia',
                  isEn ? 'Urgent arrival setup' : 'Prioritario nada más aterrizar',
                ),
                ...tasks.where((t) => t.phase == 'first_48h').map((t) => _buildTaskTile(context, ref, t, isEn)),

                const SizedBox(height: 20),
                // Sección: Primera Semana
                _buildSectionHeader(
                  isEn ? '📄 First Week: Work & Bureaucracy' : '📄 Primera Semana: Trabajo & Papeleos',
                  isEn ? 'Essential setup for your first jobs' : 'Prepara todo para empezar a trabajar',
                ),
                ...tasks.where((t) => t.phase == 'first_week').map((t) => _buildTaskTile(context, ref, t, isEn)),

                if (tasks.any((t) => t.phase == 'first_month')) ...[
                  const SizedBox(height: 20),
                  // Sección: Primer Mes & Estancia
                  _buildSectionHeader(
                    isEn ? '🦘 First Month: Regional Work & Pro Savings' : '🦘 Primer Mes: Trabajo Regional & Ahorro',
                    isEn ? 'Extend your visa and optimize your income' : 'Renovación de visado y optimización financiera',
                  ),
                  ...tasks.where((t) => t.phase == 'first_month').map((t) => _buildTaskTile(context, ref, t, isEn)),
                ],
              ],

              const SizedBox(height: 40),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildProgressCard(int completed, int total, double percent, bool isEn) {
    final isDone = completed == total && total > 0;

    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 62,
                height: 62,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 6,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDone ? AppColors.secondary : AppColors.primary,
                  ),
                ),
              ),
              Text(
                '${(percent * 100).round()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isEn ? 'Arrival Readiness' : 'Preparación de Llegada',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isDone) ...[
                      const SizedBox(width: 6),
                      const Icon(CupertinoIcons.checkmark_seal_fill, color: AppColors.secondary, size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isEn
                      ? '$completed of $total tasks completed'
                      : '$completed de $total gestiones completadas',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsTeaserBanner(bool isEn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(CupertinoIcons.money_dollar, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? '⚠️ Lost Money Audit' : '⚠️ ¿Dinero en Riesgo en Australia?',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  isEn
                      ? 'Reclaim up to \$3,850 AUD in tax deductions, DASP super and bond security.'
                      : 'Descubre cómo salvar hasta \$3.850 AUD en impuestos, súper y fianza.',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              ref.read(phase2NavigationProvider.notifier).navigateToGuide('savings');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(
              isEn ? 'Audit ➔' : 'Calcular ➔',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
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
                            if (task.targetGuideCategory == 'savings' || task.targetGuideCategory == '88days') ...[
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
      default:
        return isEn ? 'View Guide & Comparisons' : 'Ver Guía y Comparativa';
    }
  }
}
