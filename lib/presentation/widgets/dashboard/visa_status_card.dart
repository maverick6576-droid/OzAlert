import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/passport_provider.dart';
import '../../providers/repository_providers.dart';

class VisaStatusCard extends ConsumerWidget {
  const VisaStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCountry = ref.watch(selectedPassportProvider);
    final statusAsync = ref.watch(visaStatusStreamProvider);

    final status = statusAsync.when(
      data: (val) => val,
      loading: () => selectedCountry.defaultStatus,
      error: (_, __) => selectedCountry.defaultStatus,
    );

    final isOpen = status == 'OPEN';
    final isPaused = status == 'PAUSED';

    // Helper functions for dynamic styling based on the 3 states
    LinearGradient getGradient() {
      if (isOpen) return AppColors.openCardGradient;
      if (isPaused) return AppColors.pausedCardGradient;
      return AppColors.closedCardGradient;
    }

    Color getStatusColor() {
      if (isOpen) return AppColors.statusOpen;
      if (isPaused) return AppColors.statusPaused;
      return AppColors.statusClosed;
    }

    String getTitle() {
      if (isOpen) return '¡ABIERTA!';
      if (isPaused) return 'PAUSADA';
      return 'CERRADA';
    }

    String getSubtitle() {
      if (isOpen) return '¡ATENCIÓN! Visas disponibles - Aplicar ahora';
      if (isPaused) return 'Procesamiento temporalmente detenido';
      return '0 plazas disponibles actualmente';
    }

    IconData getIconData() {
      if (isOpen) return CupertinoIcons.check_mark_circled_solid;
      if (isPaused) return CupertinoIcons.pause_circle_fill;
      return CupertinoIcons.clear_circled_solid;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: getGradient(),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: getStatusColor().withValues(alpha: 0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: getStatusColor().withValues(alpha: 0.2),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: getStatusColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      getIconData(),
                      color: getStatusColor(),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ESTADO: ${getTitle()}',
                      style: TextStyle(
                        color: getStatusColor(),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              // Botón rápido Modo Simulador para que el usuario pueda alternar y probar ambos estados visuales
              IconButton(
                tooltip:
                    'Simular cambio de estado (Abierta/Cerrada/Pausada) en entorno de desarrollo',
                onPressed: () {
                  final newStatus = isOpen ? false : true;
                  ref
                      .read(visaRepositoryProvider)
                      .toggleDemoStatus(selectedCountry.code, newStatus);
                },
                icon: Icon(
                  CupertinoIcons.arrow_2_circlepath,
                  color: getStatusColor(),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            getTitle(),
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
              shadows: [
                Shadow(
                  color: getStatusColor().withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ],
            ),
          )
              .animate(target: isOpen ? 1 : 0)
              .shimmer(duration: 1200.ms, color: AppColors.statusOpen),
          const SizedBox(height: 8),
          Text(
            getSubtitle(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isOpen ? AppColors.statusOpen : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${selectedCountry.flagEmoji} Pasaporte ${selectedCountry.name} (Subclase ${selectedCountry.visaSubclass})',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
