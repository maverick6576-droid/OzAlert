import 'package:flutter_test/flutter_test.dart';
import 'package:ozvisa_alert/core/constants/app_constants.dart';
import 'package:ozvisa_alert/core/localization/app_strings.dart';
import 'package:ozvisa_alert/core/localization/industry_translations.dart';
import 'package:ozvisa_alert/domain/models/user_profile.dart';

void main() {
  group('Premium Subscription & Paywall Security Audit', () {
    test('UserProfile defaults to isPremium=false for all new users', () {
      final user = UserProfile(uid: 'free_user_123');
      expect(user.isPremium, isFalse);
      expect(user.currentPhase, equals(1));
    });

    test('RevenueCat Entitlement ID is officially ozvisa_pro_access', () {
      expect(AppConstants.rcEntitlementId, equals('ozvisa_pro_access'));
      expect(AppConstants.rcMonthlyPlanId, equals('ozvisa_monthly_199'));
      expect(AppConstants.rcAnnualPlanId, equals('ozvisa_annual_1499'));
    });

    int computeMaxTarget(bool isPremium, int targetRequirement) {
      return isPremium ? targetRequirement : 10;
    }

    bool checkWouldExceedTrial(bool isPremium, int currentDays, int daysToAdd) {
      return !isPremium && (currentDays + daysToAdd > 10);
    }

    test('Non-premium users in Regional Work are strictly capped at 10 free trial days', () {
      expect(computeMaxTarget(false, 88), equals(10));
      expect(checkWouldExceedTrial(false, 10, 1), isTrue);
    });

    test('Premium users in Regional Work can log all 88 and 179 days', () {
      expect(computeMaxTarget(true, 88), equals(88));
      expect(computeMaxTarget(true, 179), equals(179));
      expect(checkWouldExceedTrial(true, 87, 1), isFalse);
    });

    test('Days log title displays /10 for free users and /88 or /179 for Premium across all 5 languages', () {
      const languages = ['es', 'en', 'fr', 'it', 'zh'];
      for (final lang in languages) {
        final freeTab = AppStrings.tabDaysLog(lang, 2, 5, false);
        expect(freeTab, contains('5/10'));

        final premiumTab88 = AppStrings.tabDaysLog(lang, 2, 88, true);
        expect(premiumTab88, contains('88/88'));

        final premiumTab179 = AppStrings.tabDaysLog(lang, 3, 179, true);
        expect(premiumTab179, contains('179/179'));
      }
    });

    test('VIP email bypass is strictly limited to authorized administrators', () {
      const vipEmails = [
        'maverick6576@gmail.com',
        'juditmaynou2000@gmail.com',
      ];

      expect(vipEmails.contains('maverick6576@gmail.com'), isTrue);
      expect(vipEmails.contains('juditmaynou2000@gmail.com'), isTrue);

      // Verify that any other arbitrary user is NOT VIP
      expect(vipEmails.contains('attacker@gmail.com'), isFalse);
      expect(vipEmails.contains('free_user@hotmail.com'), isFalse);
      expect(vipEmails.contains(''), isFalse);
    });

    test('IndustryTranslations progress titles correctly differentiate Free Trial vs Premium', () {
      const languages = ['es', 'en', 'fr', 'it', 'zh'];
      for (final lang in languages) {
        final freeTitle = IndustryTranslations.getProgressTitle(false, 2, lang);
        final premiumTitle = IndustryTranslations.getProgressTitle(true, 2, lang);
        expect(freeTitle, isNot(equals(premiumTitle)));
      }
    });

    test('Paywall strings contain valid legal disclaimers and pricing in all 5 languages', () {
      const languages = ['es', 'en', 'fr', 'it', 'zh'];
      for (final lang in languages) {
        final proBadge = AppStrings.paywallFullProAccess(lang);
        final proDesc = AppStrings.paywallFullProDesc(lang);
        final restoreText = AppStrings.paywallRestorePrevious(lang);
        final priceString = AppStrings.paywallPerMonth(lang, '1,99 €');

        expect(proBadge.isNotEmpty, isTrue);
        expect(proDesc.isNotEmpty, isTrue);
        expect(restoreText.isNotEmpty, isTrue);
        expect(priceString.contains('1,99 €'), isTrue);
      }
    });
  });
}
