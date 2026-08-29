import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/paywall_provider.dart';
import 'package:ozvisa_alert/l10n/app_localizations.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado del paywall por si se actualiza (ej: comprando)
    ref.watch(paywallProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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
              Text(
                AppLocalizations.of(context)!.paywallTitle,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.paywallSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 400.ms),
              const Spacer(),
              
              // Botón Suscripción Mensual
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Consumer(
                  builder: (context, ref, child) {
                    final priceAsync = ref.watch(monthlyPriceProvider);
                    
                    return ElevatedButton(
                      onPressed: () async {
                        await ref.read(paywallProvider.notifier).subscribeMonthly();
                        // app.dart nos enrutará automáticamente al Dashboard si es exitoso
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: priceAsync.when(
                        data: (priceStr) => Text(
                          priceStr != null 
                              ? AppLocalizations.of(context)!.paywallSubscribeMonthly(priceStr) 
                              : AppLocalizations.of(context)!.paywallSubscribeOnly,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        loading: () => const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                        error: (_, __) => Text(
                          AppLocalizations.of(context)!.paywallSubscribeOnly,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }
                ),
              ).animate().slideY(begin: 1.0, end: 0, delay: 600.ms),
              const SizedBox(height: 16),

              // Botón Restaurar Compras
              TextButton(
                onPressed: () async {
                  await ref.read(paywallProvider.notifier).restorePurchases();
                },
                child: Text(
                  AppLocalizations.of(context)!.paywallRestore,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: 16),
              
              Text(
                AppLocalizations.of(context)!.paywallDisclaimer,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ).animate().fadeIn(delay: 1000.ms),

              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      final url = Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.paywallTermsOfUse,
                      style: const TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                  const Text('•', style: TextStyle(color: AppColors.textSecondary)),
                  TextButton(
                    onPressed: () async {
                      final url = Uri.parse('https://tu-dominio.com/privacy'); // Idealmente actualizar con la real
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.paywallPrivacyPolicy,
                      style: const TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 1000.ms),

              const SizedBox(height: 24),
            ],
          ),
        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
