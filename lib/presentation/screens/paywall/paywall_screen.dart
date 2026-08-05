import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../navigation/main_navigation_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ESTA PANTALLA ES UN PLACEHOLDER PARA EL PASO 3 (RevenueCat)
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                CupertinoIcons.lock_shield_fill,
                size: 80,
                color: AppColors.statusClosed,
              ).animate().scale(duration: 500.ms),
              const SizedBox(height: 24),
              const Text(
                'Enciende el Radar',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
              const Text(
                'Recibe notificaciones inmediatas en cuanto tu visa esté disponible. Suscríbete para acceder.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 400.ms),
              const Spacer(),
              
              // Botón Mock de Suscripción
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Por ahora, simulamos el pago saltando al Dashboard Principal
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const MainNavigationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Suscribirse (Mock)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ).animate().slideY(begin: 1.0, end: 0, delay: 600.ms),
              const SizedBox(height: 16),
              
              // Botón Mock Restaurar Compras
              TextButton(
                onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const MainNavigationScreen(),
                      ),
                    );
                },
                child: const Text(
                  'Saltar al Dashboard (Debug)',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
