import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:ozvisa_alert/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/paywall_provider.dart';

enum _SubscriptionPlan { annual, monthly }

class PaywallModal extends ConsumerStatefulWidget {
  const PaywallModal({super.key});

  @override
  ConsumerState<PaywallModal> createState() => _PaywallModalState();
}

class _PaywallModalState extends ConsumerState<PaywallModal> {
  _SubscriptionPlan _selectedPlan = _SubscriptionPlan.annual;
  bool _isLoading = false;

  Future<void> _handleSubscribe() async {
    setState(() => _isLoading = true);
    final notifier = ref.read(paywallProvider.notifier);

    final success = _selectedPlan == _SubscriptionPlan.annual
        ? await notifier.subscribeAnnual()
        : await notifier.subscribeMonthly();

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.paywallSuccessMessage,
          ),
          backgroundColor: AppColors.statusOpen,
        ),
      );
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
                  onPressed: () => ref.read(paywallProvider.notifier).restorePurchases(),
                  child: Text(
                    AppLocalizations.of(context)!.paywallRestore,
                    style: const TextStyle(color: AppColors.textSecondary),
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
            Text(
              AppLocalizations.of(context)!.paywallModalTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.paywallModalDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),

            _buildPlanTile(
              title: AppLocalizations.of(context)!.paywallPlanAnnualTitle,
              price: '\$14.99 / año',
              subtitle: AppLocalizations.of(context)!.paywallPlanAnnualDesc,
              isSelected: _selectedPlan == _SubscriptionPlan.annual,
              onTap: () => setState(() => _selectedPlan = _SubscriptionPlan.annual),
            ),
            const SizedBox(height: 12),
            _buildPlanTile(
              title: AppLocalizations.of(context)!.paywallPlanMonthlyTitle,
              price: '\$1.99 / mes',
              subtitle: AppLocalizations.of(context)!.paywallPlanMonthlyDesc,
              isSelected: _selectedPlan == _SubscriptionPlan.monthly,
              onTap: () => setState(() => _selectedPlan = _SubscriptionPlan.monthly),
            ),

            const SizedBox(height: 24),

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
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        _selectedPlan == _SubscriptionPlan.annual
                            ? AppLocalizations.of(context)!.paywallActivateAnnual
                            : AppLocalizations.of(context)!.paywallActivateMonthly,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context)!.paywallDisclaimer,
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
