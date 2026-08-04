import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/passport_provider.dart';
import '../../providers/paywall_provider.dart';
import '../../widgets/dashboard/live_radar_banner.dart';
import '../../widgets/dashboard/visa_status_card.dart';
import '../../widgets/dashboard/test_alert_button.dart';
import '../../widgets/dashboard/passport_selector.dart';
import '../../widgets/dashboard/paywall_modal.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showPaywallModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PaywallModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCountry = ref.watch(selectedPassportProvider);
    final isSubscribed = ref.watch(paywallProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.statusOpen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.dot_radiowaves_left_right,
                color: AppColors.statusOpen,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'OzVisa Alert',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          const PassportSelector(),
          const SizedBox(width: 8),
          // Botón VIP o Estado VIP
          GestureDetector(
            onTap: () => _showPaywallModal(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient:
                    isSubscribed
                        ? AppColors.vipGradient
                        : LinearGradient(
                          colors: [
                            AppColors.warning.withOpacity(0.8),
                            AppColors.warning.withOpacity(0.5),
                          ],
                        ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    isSubscribed
                        ? CupertinoIcons.star_circle_fill
                        : CupertinoIcons.lock_shield_fill,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isSubscribed ? 'VIP ACTIVO' : 'ACTIVAR VIP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Live Radar (Punto verde parpadeante + contador dinámico 60s)
            const LiveRadarBanner(),
            const SizedBox(height: 20),

            // 2. Tarjeta de Estado (CERRADA / ABIERTA) del pasaporte seleccionado
            const VisaStatusCard(),
            const SizedBox(height: 22),

            // 3. Botón "Probar Alerta" - Clave para generar confianza
            const TestAlertButton(),
            const SizedBox(height: 24),

            // 4. Panel de información de seguridad
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark_shield_fill,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monitoreo activo para ${selectedCountry.name}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'El servidor enviará una notificación sonora al instante en que el Departamento de Home Affairs habilite plazas de visa.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
