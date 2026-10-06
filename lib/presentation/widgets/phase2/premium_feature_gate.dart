import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';
import 'paywall_bottom_sheet.dart';

class PremiumFeatureGate extends ConsumerWidget {
  final Widget child;
  final String featureTitle;
  final String featureBenefit;
  final String? featureBenefitEn;
  final bool isActionOnly;

  const PremiumFeatureGate({
    super.key,
    required this.child,
    required this.featureTitle,
    required this.featureBenefit,
    this.featureBenefitEn,
    this.isActionOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final isPremium = profile?.isPremium ?? false;

    if (isPremium) {
      return child;
    }

    if (isActionOnly) {
      return GestureDetector(
        onTap: () => showPhase2PaywallBottomSheet(
          context: context,
          featureTitle: featureTitle,
          featureBenefit: featureBenefit,
          featureBenefitEn: featureBenefitEn,
        ),
        behavior: HitTestBehavior.opaque,
        child: child,
      );
    }

    // Modo Blur con candado de protección
    return Stack(
      children: [
        IgnorePointer(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: child,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: AppColors.background.withValues(alpha: 0.35),
            child: Center(
              child: GestureDetector(
                onTap: () => showPhase2PaywallBottomSheet(
                  context: context,
                  featureTitle: featureTitle,
                  featureBenefit: featureBenefit,
                  featureBenefitEn: featureBenefitEn,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.lock_fill, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Desbloquear $featureTitle',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
