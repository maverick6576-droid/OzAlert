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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient:
            isOpen
                ? AppColors.openCardGradient
                : AppColors.closedCardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isOpen
                  ? AppColors.statusOpen.withOpacity(0.8)
                  : AppColors.statusClosed.withOpacity(0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isOpen
                    ? AppColors.statusOpen.withOpacity(0.2)
                    : AppColors.statusClosed.withOpacity(0.2),
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
                  color:
                      isOpen
                          ? AppColors.statusOpen.withOpacity(0.2)
                          : AppColors.statusClosed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOpen
                          ? CupertinoIcons.check_mark_circled_solid
                          : CupertinoIcons.clear_circled_solid,
                      color:
                          isOpen ? AppColors.statusOpen : AppColors.statusClosed,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOpen ? 'ESTADO: ABIERTA' : 'ESTADO: CERRADA',
                      style: TextStyle(
                        color:
                            isOpen
                                ? AppColors.statusOpen
                                : AppColors.statusClosed,
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
                    'Simular cambio de estado (Abierta/Cerrada) en entorno de desarrollo',
                onPressed: () {
                  final newStatus = !isOpen;
                  ref
                      .read(visaRepositoryProvider)
                      .toggleDemoStatus(selectedCountry.code, newStatus);
                },
                icon: Icon(
                  CupertinoIcons.arrow_2_circlepath,
                  color:
                      isOpen ? AppColors.statusOpen : AppColors.statusClosed,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            isOpen ? '¡ABIERTA!' : 'CERRADA',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
              shadows: [
                Shadow(
                  color:
                      isOpen
                          ? AppColors.statusOpen.withOpacity(0.5)
                          : AppColors.statusClosed.withOpacity(0.5),
                  blurRadius: 12,
                ),
              ],
            ),
          )
              .animate(target: isOpen ? 1 : 0)
              .shimmer(duration: 1200.ms, color: AppColors.statusOpen),
          const SizedBox(height: 8),
          Text(
            isOpen
                ? '¡ATENCIÓN! Visas disponibles - Aplicar ahora'
                : '0 plazas disponibles actualmente',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color:
                  isOpen ? AppColors.statusOpen : AppColors.textPrimary,
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
