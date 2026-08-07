import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/passport_provider.dart';
import '../../providers/paywall_provider.dart';
import '../../providers/user_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../widgets/dashboard/live_radar_banner.dart';
import '../../widgets/dashboard/visa_status_card.dart';
import '../../widgets/dashboard/test_alert_button.dart';
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
    final isSubscribed = ref.watch(paywallProvider);
    final userProfileState = ref.watch(userProfileProvider);
    final userProfile = userProfileState.value;
    final passports = userProfile?.passports ?? [];
    
    // Convertir los nombres de pasaportes a objetos CountryConfig
    final selectedCountries = passports.map((p) {
      return AppConstants.supportedCountries.firstWhere(
        (c) => c.name == p,
        orElse: () => AppConstants.supportedCountries.first,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('assets/images/app_icon.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'OzAlert',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          // Se eliminó el PassportSelector para mostrar todos en el feed
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Fondo temático abstracto
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.05),
              ),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Live Radar Explorer
                const LiveRadarBanner(),
                const SizedBox(height: 20),

                // 2. Tarjetas de Estado para cada pasaporte seleccionado
                if (selectedCountries.isEmpty)
                  const Center(child: Text('No has seleccionado pasaportes.'))
                else
                  ...selectedCountries.map((country) => Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: VisaStatusCard(country: country),
                  )),

                const SizedBox(height: 10),

                // 3. Botón "Probar Alerta" - Clave para generar confianza
                const TestAlertButton(),
                const SizedBox(height: 24),

                // 4. Panel de información de seguridad
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.map_pin_ellipse,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Expedición Segura',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'El horizonte está despejado. Te avisaremos con un destello de bengala (notificación) en cuanto el Departamento habilite plazas para tus pasaportes.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.4,
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
        ],
      ),
    );
  }
}
