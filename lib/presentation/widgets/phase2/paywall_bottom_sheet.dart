import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/locale_provider.dart';
import '../../providers/paywall_provider.dart';

void showPhase2PaywallBottomSheet({
  required BuildContext context,
  required String featureTitle,
  required String featureBenefit,
  String? featureBenefitEn,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _Phase2PaywallSheet(
      featureTitle: featureTitle,
      featureBenefit: featureBenefit,
      featureBenefitEn: featureBenefitEn,
    ),
  );
}

class _Phase2PaywallSheet extends ConsumerStatefulWidget {
  final String featureTitle;
  final String featureBenefit;
  final String? featureBenefitEn;

  const _Phase2PaywallSheet({
    required this.featureTitle,
    required this.featureBenefit,
    this.featureBenefitEn,
  });

  @override
  ConsumerState<_Phase2PaywallSheet> createState() => _Phase2PaywallSheetState();
}

class _Phase2PaywallSheetState extends ConsumerState<_Phase2PaywallSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final monthlyPriceAsync = ref.watch(monthlyPriceProvider);
    final priceText = monthlyPriceAsync.value ?? '1,99 €';
    final locale = ref.watch(localeProvider);
    final isEn = locale?.languageCode == 'en';
    final benefitText = (isEn && widget.featureBenefitEn != null && widget.featureBenefitEn!.isNotEmpty)
        ? widget.featureBenefitEn!
        : widget.featureBenefit;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de arrastre superior
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Icono con aura dorada
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.lock_shield_fill,
              color: AppColors.primary,
              size: 44,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            widget.featureTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            benefitText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Tarjeta de oferta destacada
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'Full OzAlert Pro Access' : 'Acceso Completo OzAlert Pro',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                      ),
                      Text(
                        isEn
                            ? 'Unlimited PDF CVs, payslip audits & Form 1263'
                            : 'CVs ilimitados en PDF, auditoría de nóminas y Formulario 1263',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  isEn ? '$priceText/mo' : '$priceText/mes',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Botón de suscripción
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      setState(() => _isLoading = true);
                      try {
                        final success = await ref.read(paywallProvider.notifier).subscribeMonthly();
                        if (success && mounted) {
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.secondary,
                              content: Text(
                                isEn
                                    ? 'Welcome to OzAlert Pro! All features unlocked.'
                                    : '¡Bienvenido a OzAlert Pro! Todas las funciones están desbloqueadas.',
                              ),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      isEn ? 'Unlock for $priceText / month' : 'Desbloquear por $priceText / mes',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Restaurar compras
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final active = await ref.read(paywallProvider.notifier).restorePurchases();
              if (active && mounted) {
                navigator.pop();
              }
            },
            child: Text(
              isEn ? 'Restore previous purchases' : 'Restaurar compras previas',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
