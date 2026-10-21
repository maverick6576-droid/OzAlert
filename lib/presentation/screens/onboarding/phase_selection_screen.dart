import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_strings.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';

class PhaseSelectionScreen extends ConsumerStatefulWidget {
  const PhaseSelectionScreen({super.key});

  @override
  ConsumerState<PhaseSelectionScreen> createState() => _PhaseSelectionScreenState();
}

class _PhaseSelectionScreenState extends ConsumerState<PhaseSelectionScreen> {
  int? _selectedPhase;
  bool _isSaving = false;

  Future<void> _handleChoosePhase(int phase) async {
    if (_isSaving) return;
    setState(() {
      _selectedPhase = phase;
      _isSaving = true;
    });

    try {
      await ref.read(phaseSelectionControllerProvider.notifier).selectInitialPhase(phase);
      // Riverpod stream actualizará automáticamente el estado en app.dart
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar fase: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final lang = locale?.languageCode ?? Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // 1. Etiqueta de paso final del Onboarding
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.sparkles, size: 13, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.phaseSelectionBadge(lang),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),

              const SizedBox(height: 16),

              // 2. Título Principal
              Text(
                AppStrings.phaseSelectionTitle(lang),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ).animate().fadeIn(delay: 150.ms).slideY(begin: -0.1, end: 0),

              const SizedBox(height: 10),

              // 3. Subtítulo Explicativo
              Text(
                AppStrings.phaseSelectionSubtitle(lang),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 24),

              // 4. Tarjeta Opción 1: Fase 1 (Buscando / Preparando Visado)
              _buildPhaseCard(
                phase: 1,
                badgeLabel: AppStrings.phase1Badge(lang),
                badgeColor: Colors.amber,
                title: AppStrings.phase1Title(lang),
                subtitle: AppStrings.phase1Subtitle(lang),
                icon: CupertinoIcons.compass_fill,
                iconColor: Colors.amber,
                features: AppStrings.phase1Features(lang),
                buttonLabel: AppStrings.phase1Button(lang),
                buttonColor: AppColors.primary,
                delayMs: 350,
              ),

              const SizedBox(height: 18),

              // 5. Tarjeta Opción 2: Fase 2 (Visado Concedido / Rumbo a Australia)
              _buildPhaseCard(
                phase: 2,
                badgeLabel: AppStrings.phase2Badge(lang),
                badgeColor: AppColors.secondary,
                title: AppStrings.phase2Title(lang),
                subtitle: AppStrings.phase2Subtitle(lang),
                icon: CupertinoIcons.airplane,
                iconColor: AppColors.secondary,
                features: AppStrings.phase2Features(lang),
                buttonLabel: AppStrings.phase2Button(lang),
                buttonColor: AppColors.secondary,
                delayMs: 450,
              ),

              const SizedBox(height: 24),

              // 6. Mensaje de tranquilidad al pie
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.arrow_2_circlepath, size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppStrings.phaseSelectionFooter(lang),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 550.ms),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseCard({
    required int phase,
    required String badgeLabel,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<String> features,
    required String buttonLabel,
    required Color buttonColor,
    required int delayMs,
  }) {
    final isSelected = _selectedPhase == phase;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSelected ? buttonColor : AppColors.cardBorder,
          width: isSelected ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _isSaving ? null : () => _handleChoosePhase(phase),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila Superior: Badge + Icono
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                          color: badgeColor is MaterialColor ? badgeColor.shade800 : badgeColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 20, color: iconColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Título y Subtítulo
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),

                // Lista de características clave
                for (final feat in features)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(CupertinoIcons.checkmark_alt_circle_fill, size: 15, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feat,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Botón de Selección
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _handleChoosePhase(phase),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSaving && isSelected
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            buttonLabel,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delayMs.ms).slideY(begin: 0.1, end: 0);
  }
}
