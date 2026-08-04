import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/paywall_provider.dart';

class PaywallModal extends ConsumerStatefulWidget {
  const PaywallModal({super.key});

  @override
  ConsumerState<PaywallModal> createState() => _PaywallModalState();
}

class _PaywallModalState extends ConsumerState<PaywallModal> {
  bool _isAnnualSelected = true;
  bool _isLoading = false;

  Future<void> _handleSubscribe() async {
    setState(() => _isLoading = true);
    final notifier = ref.read(paywallProvider.notifier);

    final success =
        _isAnnualSelected
            ? await notifier.subscribeAnnual()
            : await notifier.subscribeMonthly();

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ ¡Acceso VIP Activado! Alertas inmediatas 24/7 habilitadas.',
          ),
          backgroundColor: AppColors.statusOpen,
        ),
      );
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isLoading = true);
    final notifier = ref.read(paywallProvider.notifier);
    final success = await notifier.restorePurchases();
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Compras restauradas exitosamente.'
                : 'ℹ️ No se encontraron compras previas activas.',
          ),
          backgroundColor:
              success ? AppColors.statusOpen : AppColors.surfaceElevated,
        ),
      );
      if (success) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _handleRestore,
                  child: const Text(
                    'Restaurar Compras',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Icon(
              CupertinoIcons.shield_fill,
              size: 56,
              color: AppColors.statusOpen,
            ),
            const SizedBox(height: 14),
            const Text(
              'Desbloquea el Radar 24/7 de Visas Australia',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Recibe una Alerta Push y un Email inmediato en el segundo exacto en que el Departamento de Home Affairs abra plazas para tu país.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Opciones de plan
            _buildPlanTile(
              title: 'Pase de Temporada (Anual)',
              price: '\$14.99 / año',
              subtitle: 'Mejor valor • Ahorras 37%',
              isSelected: _isAnnualSelected,
              onTap: () => setState(() => _isAnnualSelected = true),
            ),
            const SizedBox(height: 12),
            _buildPlanTile(
              title: 'Plan Mensual Flex',
              price: '\$1.99 / mes',
              subtitle: 'Cancela en cualquier momento con 1 clic',
              isSelected: !_isAnnualSelected,
              onTap: () => setState(() => _isAnnualSelected = false),
            ),

            const SizedBox(height: 24),

            // Botón principal CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusOpen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                        : Text(
                          _isAnnualSelected
                              ? 'Activar Pase de Temporada (\$14.99)'
                              : 'Activar Plan Mensual (\$1.99)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 14),
            const Text(
              'Sin periodo de prueba para garantizar servidores dedicados sin saturación. '
              'Pago procesado de forma segura a través de RevenueCat / App Store / Google Play. '
              'Puedes cancelar tu suscripción en cualquier momento desde los ajustes de tu cuenta.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanTile({
    required String title,
    required String price,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.statusOpen.withOpacity(0.08)
                  : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.statusOpen : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              color: isSelected ? AppColors.statusOpen : AppColors.textMuted,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
