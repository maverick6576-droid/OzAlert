import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/phase2/phase2_providers.dart';
import '../../../providers/locale_provider.dart';
import '../../../../domain/models/phase2/landing_task.dart';

class LandingChecklistScreen extends ConsumerWidget {
  const LandingChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(landingTasksProvider);
    final locale = ref.watch(localeProvider);
    final isEn = locale?.languageCode == 'en';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          isEn ? 'Arrival Checklist' : 'Checklist de Aterrizaje',
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 22),
        ),
        centerTitle: false,
      ),
      body: tasksAsync.when(
        data: (tasks) {
          final completedCount = tasks.where((t) => t.isCompleted).length;
          final totalCount = tasks.length;
          final progressPercent = totalCount > 0 ? (completedCount / totalCount) : 0.0;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // Tarjeta de progreso gamificada
              _buildProgressCard(completedCount, totalCount, progressPercent, isEn),
              const SizedBox(height: 20),

              // Sección: Antes de Volar
              _buildSectionHeader(isEn ? '✈️ Pre-Departure (Before Flying)' : '✈️ Antes de Volar'),
              ...tasks.where((t) => t.phase == 'pre_departure').map((t) => _buildTaskTile(context, ref, t, isEn)),

              const SizedBox(height: 20),
              // Sección: Primeras 48 Horas
              _buildSectionHeader(isEn ? '🧳 First 48 Hours in Australia' : '🧳 Primeras 48 Horas en Australia'),
              ...tasks.where((t) => t.phase == 'first_48h').map((t) => _buildTaskTile(context, ref, t, isEn)),

              const SizedBox(height: 20),
              // Sección: Primera Semana
              _buildSectionHeader(isEn ? '📄 First Week & Job Prep' : '📄 Primera Semana & Burocracia'),
              ...tasks.where((t) => t.phase == 'first_week').map((t) => _buildTaskTile(context, ref, t, isEn)),

              const SizedBox(height: 40),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildProgressCard(int completed, int total, double percent, bool isEn) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 6,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                ),
              ),
              Text(
                '${(percent * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Landing Progress' : 'Progreso de Llegada',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  isEn
                      ? '$completed of $total essential steps ready'
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, WidgetRef ref, LandingTask task, bool isEn) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.isCompleted ? AppColors.secondary.withValues(alpha: 0.4) : AppColors.cardBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: task.isCompleted,
              activeColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              onChanged: (val) {
                ref.read(landingTasksProvider.notifier).toggleTask(task.id, val ?? false);
              },
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEn ? task.titleEn : task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: task.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEn ? task.subtitleEn : task.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: task.isCompleted ? AppColors.textMuted : AppColors.textSecondary,
                    ),
                  ),
                  if (task.targetGuideCategory != null) ...[
                    const SizedBox(height: 8),
                    // SMART LINK hacia la Guía
                    GestureDetector(
                      onTap: () {
                        ref.read(phase2NavigationProvider.notifier).navigateToGuide(task.targetGuideCategory!);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.arrow_right_circle_fill, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 6),
                          Text(
                            isEn ? 'View guide & comparisons' : 'Ver guía y comparativa',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
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
}
