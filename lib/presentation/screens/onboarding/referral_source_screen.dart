import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';
import 'package:ozvisa_alert/l10n/app_localizations.dart';

class ReferralSourceScreen extends ConsumerStatefulWidget {
  final VoidCallback onCompleted;
  
  const ReferralSourceScreen({super.key, required this.onCompleted});

  @override
  ConsumerState<ReferralSourceScreen> createState() => _ReferralSourceScreenState();
}

class _ReferralSourceScreenState extends ConsumerState<ReferralSourceScreen> {
  bool isSaving = false;

  Future<void> _selectSource(String source) async {
    setState(() => isSaving = true);
    try {
      await ref.read(referralControllerProvider.notifier).updateReferralSource(source);
      widget.onCompleted();
    } catch (e) {
      debugPrint('Error saving referral source: $e');
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final List<String> sources = [
      'TikTok',
      'Instagram',
      'Telegram',
      l10n.referralFriend,
      l10n.referralGroups,
      'Twitter X',
      l10n.referralOthers,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                l10n.referralTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.referralSubtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (isSaving)
                const Center(child: CircularProgressIndicator(color: AppColors.primary))
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: sources.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final source = sources[index];
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceElevated,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.cardBorder),
                          ),
                        ),
                        onPressed: () => _selectSource(source),
                        child: Text(
                          source,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
