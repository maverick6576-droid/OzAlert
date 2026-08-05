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
      if (isOpen) return 'Visas disponibles. ¡Inicia la expedición!';
      if (isPaused) return 'A la espera. Procesamiento temporalmente detenido.';
      return 'Campamento cerrado. 0 plazas actualmente.';
    }

    IconData getIconData() {
      if (isOpen) return CupertinoIcons.location_solid;
      if (isPaused) return CupertinoIcons.pause_solid;
      return CupertinoIcons.xmark_circle_fill;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Concentric ripples for radar aesthetic (Only active if OPEN or scanning)
        if (isOpen) ...[
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.statusOpen.withOpacity(0.5), width: 2),
            ),
          ).animate(onPlay: (c) => c.repeat()).scaleXY(begin: 0.9, end: 1.15, duration: 2.seconds).fadeOut(duration: 2.seconds),
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.statusOpen.withOpacity(0.3), width: 1),
            ),
          ).animate(onPlay: (c) => c.repeat()).scaleXY(begin: 1.0, end: 1.25, duration: 2.seconds).fadeOut(duration: 2.seconds),
        ],

        // Main Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: getGradient(),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: getStatusColor().withOpacity(0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: getStatusColor().withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 10),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: getStatusColor().withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          getIconData(),
                          color: getStatusColor(),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'RADAR: ${getTitle()}',
                          style: TextStyle(
                            color: getStatusColor(),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Simular cambio de estado de exploración',
                    onPressed: () {
                      final newStatus = isOpen ? false : true;
                      ref
                          .read(visaRepositoryProvider)
                          .toggleDemoStatus(selectedCountry.code, newStatus);
                    },
                    icon: Icon(
                      CupertinoIcons.arrow_2_circlepath,
                      color: getStatusColor(),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                getTitle(),
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: getStatusColor().withOpacity(0.6),
                      blurRadius: 15,
                    ),
                  ],
                ),
              )
                  .animate(target: isOpen ? 1 : 0)
                  .shimmer(duration: 1500.ms, color: AppColors.statusOpen),
              const SizedBox(height: 8),
              Text(
                getSubtitle(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isOpen ? AppColors.statusOpen : AppColors.textPrimary.withOpacity(0.9),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${selectedCountry.flagEmoji} Ruta: ${selectedCountry.name} (Subclase ${selectedCountry.visaSubclass})',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
