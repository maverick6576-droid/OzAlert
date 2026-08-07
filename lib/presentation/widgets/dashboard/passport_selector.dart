import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:ozvisa_alert/l10n/app_localizations.dart';
import '../../providers/passport_provider.dart';

class PassportSelector extends ConsumerWidget {
  const PassportSelector({super.key});

  void _showCountryPickerModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.passportSelectorTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: AppConstants.supportedCountries.length,
                    itemBuilder: (context, index) {
                      final country = AppConstants.supportedCountries[index];
                      final selected =
                          ref.watch(selectedPassportProvider).code ==
                          country.code;
                      return ListTile(
                        leading: Text(
                          country.flagEmoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                        title: Text(
                          country.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight:
                                selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          AppLocalizations.of(context)!.passportSubclass(country.visaSubclass),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing:
                            selected
                                ? const Icon(
                                  CupertinoIcons.checkmark_alt_circle_fill,
                                  color: AppColors.statusOpen,
                                )
                                : null,
                        onTap: () {
                          ref
                              .read(selectedPassportProvider.notifier)
                              .selectPassport(country.code);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCountry = ref.watch(selectedPassportProvider);

    return GestureDetector(
      onTap: () => _showCountryPickerModal(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCountry.flagEmoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              selectedCountry.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              CupertinoIcons.chevron_down,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
