// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'OzAlert';

  @override
  String get loginSubtitle => 'The ultimate radar for your Australian Work & Holiday Visa.';

  @override
  String get loginError => 'Error signing in:';

  @override
  String get loginGoogle => 'Continue with Google';

  @override
  String get loginApple => 'Continue with Apple';

  @override
  String get welcomeTitle => 'Australian visas\nfly away\nin minutes.';

  @override
  String get welcomeSubtitle => 'Every year, thousands miss out because they don\'t find out in time when spots open. Our system tracks official sources 24/7 and alerts you instantly so you can be the first to apply.';

  @override
  String get welcomeBullet1 => 'Real instant notifications';

  @override
  String get welcomeBullet2 => 'Gain an advantage over other applicants';

  @override
  String get welcomeBullet3 => 'Official government sources (Immigration)';

  @override
  String get welcomeButton => 'Set up my Radar now';

  @override
  String get onboardingTitle => 'Customize your Radar';

  @override
  String get onboardingSubtitle => 'Set up your profile to receive notifications for visas that match your passport.';

  @override
  String get onboardingLanguage => 'Preferred Language';

  @override
  String get onboardingPassports => 'Select your Passports';

  @override
  String get onboardingErrorEmpty => 'Please select at least one passport';

  @override
  String get onboardingErrorSave => 'Error saving:';

  @override
  String get onboardingNext => 'Next step';

  @override
  String get paywallTitle => 'Turn on the Radar';

  @override
  String get paywallSubtitle => 'Receive immediate notifications as soon as your visa becomes available. Subscribe to access.';

  @override
  String paywallSubscribeMonthly(String price) {
    return 'Subscribe $price / month';
  }

  @override
  String get paywallSubscribeOnly => 'Subscribe';

  @override
  String get paywallRestore => 'Restore Purchases';

  @override
  String get paywallBypass => 'Bypass to Dashboard (Debug)';

  @override
  String get dashboardTitle => 'OzVisa Radar';

  @override
  String get dashboardTestAlert => 'Test Alert';

  @override
  String get dashboardSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'App Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get visaStatusOpen => 'OPEN';

  @override
  String get visaStatusClosed => 'CLOSED';

  @override
  String get visaStatusPaused => 'PAUSED';

  @override
  String get visaSourceButton => 'View official source';

  @override
  String get settingsLegal => 'Legal';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTerms => 'Terms and Conditions';
}
