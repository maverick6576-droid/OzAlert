import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozvisa_alert/l10n/app_localizations.dart';
import 'package:ozvisa_alert/presentation/widgets/phase2/official_sources_modal.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/news_notifications_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../widgets/phase2/visa_dates_survey_dialog.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/notification_service.dart';

class Phase2SettingsScreen extends ConsumerWidget {
  const Phase2SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider) ?? Localizations.localeOf(context);
    final lang = currentLocale.languageCode;
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(userProfileProvider).value;
    final currentSubclass = profile?.visaSubclass ?? '462';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          // 1. Idioma de la aplicación
          Text(
            l10n.settingsLanguage,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _SelectableSettingsTile(
            title: l10n.settingsLanguageSpanish,
            isSelected: currentLocale.languageCode == 'es',
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(const Locale('es'));
            },
          ),
          const SizedBox(height: 8),
          _SelectableSettingsTile(
            title: l10n.settingsLanguageEnglish,
            isSelected: currentLocale.languageCode == 'en',
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(const Locale('en'));
            },
          ),
          const SizedBox(height: 8),
          _SelectableSettingsTile(
            title: l10n.settingsLanguageFrench,
            isSelected: currentLocale.languageCode == 'fr',
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(const Locale('fr'));
            },
          ),
          const SizedBox(height: 8),
          _SelectableSettingsTile(
            title: l10n.settingsLanguageItalian,
            isSelected: currentLocale.languageCode == 'it',
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(const Locale('it'));
            },
          ),
          const SizedBox(height: 8),
          _SelectableSettingsTile(
            title: l10n.settingsLanguageChinese,
            isSelected: currentLocale.languageCode == 'zh',
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(const Locale('zh'));
            },
          ),

          const SizedBox(height: 32),
          // 2. Subclase de Visado (Específico de Fase 2)
          Text(
            AppStrings.visaSubclassTitle(lang),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _SelectableSettingsTile(
            title: AppStrings.visaSubclass462(lang),
            isSelected: currentSubclass == '462',
            onTap: () {
              if (profile != null && currentSubclass != '462') {
                ref.read(userRepositoryProvider).saveUserProfile(profile.copyWith(visaSubclass: '462'));
                ref.invalidate(userProfileProvider);
              }
            },
          ),
          const SizedBox(height: 8),
          _SelectableSettingsTile(
            title: AppStrings.visaSubclass417(lang),
            isSelected: currentSubclass == '417',
            onTap: () {
              if (profile != null && currentSubclass != '417') {
                ref.read(userRepositoryProvider).saveUserProfile(profile.copyWith(visaSubclass: '417'));
                ref.invalidate(userProfileProvider);
              }
            },
          ),

          const SizedBox(height: 32),
          // 3. Notificaciones
          Text(
            l10n.settingsNotifications,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final newsEnabled = ref.watch(newsNotificationsProvider);
              return SwitchListTile.adaptive(
                title: Text(l10n.settingsNewsNotifs),
                value: newsEnabled,
                activeTrackColor: AppColors.primary,
                tileColor: AppColors.surface,
                onChanged: (bool value) {
                  ref.read(newsNotificationsProvider.notifier).toggle(value);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
              );
            },
          ),

          const SizedBox(height: 32),
          // 4. Fase de la aplicación y Colaboración
          Text(
            AppStrings.appPhaseTitle(lang),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: AppColors.surface,
            title: Text(
              AppStrings.returnToPhase1Tile(lang),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            subtitle: Text(
              AppStrings.returnToPhase1Subtitle(lang),
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            trailing: const Icon(CupertinoIcons.chevron_forward, color: AppColors.textSecondary, size: 20),
            onTap: () => _confirmReturnToPhase1(context, ref, profile, lang),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          if (!(profile?.datesSurveyCompleted ?? false)) ...[
            const SizedBox(height: 8),
            ListTile(
              tileColor: AppColors.surface,
              title: Text(
                AppStrings.recordVisaDatesTile(lang),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: Text(
                AppStrings.recordVisaDatesSubtitle(lang),
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              trailing: const Icon(CupertinoIcons.chevron_forward, color: AppColors.textSecondary, size: 20),
              onTap: () => showVisaDatesSurveyDialogIfNeeded(context, ref),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
          ],

          const SizedBox(height: 32),
          // 5. Legal (Obligatorio por ley + Fuentes Oficiales)
          Text(
            l10n.settingsLegal,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: AppColors.surface,
            title: Text(l10n.settingsPrivacyPolicy),
            trailing: const Icon(CupertinoIcons.chevron_forward, color: AppColors.textSecondary, size: 20),
            onTap: () => _launchUrl('https://ozvisa-alert-prod.web.app/privacy.html'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            tileColor: AppColors.surface,
            title: Text(l10n.settingsTerms),
            trailing: const Icon(CupertinoIcons.chevron_forward, color: AppColors.textSecondary, size: 20),
            onTap: () => _launchUrl('https://ozvisa-alert-prod.web.app/terms.html'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            tileColor: AppColors.surface,
            title: Text(AppStrings.officialGovSources(lang)),
            trailing: const Icon(CupertinoIcons.chevron_forward, color: AppColors.textSecondary, size: 20),
            onTap: () => showOfficialSourcesModal(context, lang: lang, isEn: lang != 'es'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
          ),

          const SizedBox(height: 48),
          // 6. Cerrar sesión
          ElevatedButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              ref.invalidate(userProfileProvider);
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
            child: Text(
              l10n.settingsLogout,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          // 7. Eliminar cuenta (Obligatorio por ley en App Store / Google Play)
          ElevatedButton(
            onPressed: () {
              showCupertinoDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return CupertinoAlertDialog(
                    title: Text(l10n.settingsDeleteAccountConfirmTitle),
                    content: Text(l10n.settingsDeleteAccountConfirmMessage),
                    actions: [
                      CupertinoDialogAction(
                        child: Text(l10n.settingsDeleteAccountCancelButton),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          try {
                            await ref.read(authControllerProvider.notifier).deleteAccount();
                            ref.invalidate(userProfileProvider);
                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
                            }
                          } catch (e) {
                            debugPrint('Error borrando cuenta: $e');
                          }
                        },
                        child: Text(l10n.settingsDeleteAccountConfirmButton),
                      ),
                    ],
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: Colors.redAccent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
            ),
            child: Text(
              l10n.settingsDeleteAccount,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmReturnToPhase1(BuildContext context, WidgetRef ref, dynamic profile, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.returnToPhase1DialogTitle(lang)),
        content: Text(
          AppStrings.returnToPhase1DialogContent(lang),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.cancelButton(lang))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.of(context).maybePop();
              if (profile != null) {
                await ref.read(userRepositoryProvider).saveUserProfile(profile.copyWith(currentPhase: 1));
                NotificationService().syncPhaseNewsSubscription(1);
                if (profile.isPremium) {
                  final countryCodes = profile.passports.map((pName) {
                    return AppConstants.supportedCountries.firstWhere(
                      (c) => c.name == pName,
                      orElse: () => AppConstants.supportedCountries.first,
                    ).code;
                  }).toList();
                  NotificationService().syncPassportSubscriptions(countryCodes);
                }
              }
            },
            child: Text(
              AppStrings.switchPhase1Button(lang),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }
}

class _SelectableSettingsTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableSettingsTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.cardBorder,
          width: isSelected ? 2 : 1,
        ),
      ),
      tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(CupertinoIcons.checkmark_alt, color: AppColors.primary)
          : null,
    );
  }
}
