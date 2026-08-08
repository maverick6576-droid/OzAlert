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

  @override
  String get checklistTitle => 'Expedition Kit';

  @override
  String get checklistProgress => 'Equipment Progress';

  @override
  String get checklistDescription => 'Prepare your backpack (certificates and savings) in advance so you are not left behind when the adventure begins.';

  @override
  String get checklistKeyDocs => 'Key Documents:';

  @override
  String get checklistInstructions => 'Secure each item in your inventory as you get it:';

  @override
  String get checklistTip => 'Explorer Tip: Quotas tend to disappear like mirages in the desert. Having your PDFs organized is vital to survive the process.';

  @override
  String get dashboardSafeExpedition => 'Safe Expedition';

  @override
  String get dashboardSafeExpeditionDesc => 'The horizon is clear. We will notify you with a flare (notification) as soon as the Department enables places for your passports.';

  @override
  String get newsTitle => 'News Radar';

  @override
  String get newsTabOfficial => 'Official Sources';

  @override
  String get newsTabAlerts => 'Google Alerts';

  @override
  String get newsEmptyState => 'Official radar silent. No news.';

  @override
  String get newsGlobalAlerts => 'Global alerts monitored.';

  @override
  String newsError(String errorText) {
    return 'Radar interference.\nCould not load news.\n$errorText';
  }

  @override
  String get radarScanning => 'Servers tracking the official Australian Immigration website';

  @override
  String get passportSelectorTitle => 'Select your Passport (WHV 417 & 462)';

  @override
  String passportSubclass(String subclass) {
    return 'Subclass $subclass • Australia WHV';
  }

  @override
  String get paywallModalTitle => 'Unlock the 24/7 Visa Radar';

  @override
  String get paywallModalDesc => 'Receive an immediate Push Alert and Email the exact second the Department of Home Affairs opens spots for your country.';

  @override
  String get paywallPlanAnnualTitle => 'Season Pass (Annual)';

  @override
  String get paywallPlanAnnualDesc => 'Best value • Save 37%';

  @override
  String get paywallPlanMonthlyTitle => 'Flex Monthly Plan';

  @override
  String get paywallPlanMonthlyDesc => 'Cancel anytime with 1 click';

  @override
  String get paywallActivateAnnual => 'Activate Season Pass (\$14.99)';

  @override
  String get paywallActivateMonthly => 'Activate Monthly Plan (\$1.99)';

  @override
  String get paywallDisclaimer => 'No trial period to ensure dedicated servers without saturation. Payment processed securely via RevenueCat / App Store / Google Play. You can cancel your subscription anytime in your account settings.';

  @override
  String get visaStatusOpenDesc => 'Visas available. Start the expedition!';

  @override
  String get visaStatusPausedDesc => 'On hold. Processing temporarily paused.';

  @override
  String get visaStatusClosedDesc => 'Camp closed. 0 places currently.';

  @override
  String get errorOpeningLink => 'Could not open the link.';

  @override
  String get tooltipScanRadar => 'Scan live radar';

  @override
  String get newsSourceOfficial => 'OFFICIAL SOURCE';

  @override
  String get newsSourceMarket => 'MARKET / CURRENCY';

  @override
  String get partnerAffiliate => 'AFFILIATE PARTNER • 15% OFF';

  @override
  String get partnerDescription => 'Essential to activate your visa when passing customs in Sydney or Melbourne. Full COVID, sports and work coverage.';

  @override
  String get partnerActivate => 'Activate Insurance Promo (15% Off)';

  @override
  String testAlertSending(String countryNames) {
    return '⚡ Sending test alert for $countryNames... Will arrive in 2 seconds.';
  }

  @override
  String get checklistCompletedDescription => 'All set! Backpack 100% prepared.';

  @override
  String get partnerTitle => 'Need health insurance for Australia? Get 15% off with Chapka / IATI Seguros';

  @override
  String get paywallSuccessMessage => '✅ VIP Access Activated! 24/7 immediate alerts enabled or purchases successfully restored.';

  @override
  String get navRadar => 'Radar';

  @override
  String get navEquipment => 'Equipment';

  @override
  String get navNews => 'Logbook';

  @override
  String get checklistIdentityDocumentsTitle => 'Identity documents';

  @override
  String get checklistIdentityDocumentsDesc => 'Pages of your passport (photo, data, dates). Birth certificate with parents\' names. Proof of name change (if applicable).';

  @override
  String get checklistEducationTitle => 'Education';

  @override
  String get checklistEducationDesc => 'Evidence of your educational qualifications (university degree, years completed or equivalent, depending on your country\'s requirements).';

  @override
  String get checklistEnglishLanguageTitle => 'English level';

  @override
  String get checklistEnglishLanguageDesc => 'Evidence of English studies, or approved exam in the last 12 months (IELTS 4.5, PTE 30, Cambridge C1 147, or TOEFL iBT 32).';

  @override
  String get checklistGovernmentSupportTitle => 'Government support';

  @override
  String get checklistGovernmentSupportDesc => 'Letter of support from your government (only for certain countries like Peru, Ecuador, etc. Not required for Spain, Argentina, Chile, etc.).';

  @override
  String get checklistEnoughMoneyTitle => 'Enough money for your stay and departure';

  @override
  String get checklistEnoughMoneyDesc => 'Evidence of money for your stay (usually \$5,000 AUD) and money for a departure ticket from Australia (or the ticket already purchased).';

  @override
  String get checklistCharacterDocumentsTitle => 'Character documents (Background checks)';

  @override
  String get checklistCharacterDocumentsDesc => 'Police certificates from every country where you have spent 12+ months in the last 10 years (since age 16), and military record if applicable.';

  @override
  String get checklistGettingHelpTitle => 'Getting help (Agents)';

  @override
  String get checklistGettingHelpDesc => 'Form 956A or 956 if you use a migration agent or authorize someone to receive your documents.';

  @override
  String get checklistPrepareDocumentsTitle => 'Prepare your documents';

  @override
  String get checklistPrepareDocumentsDesc => 'Translate all documents into English by a qualified translator and scan/photograph all originals and translations in color.';

  @override
  String radarLastChecked(String seconds) {
    return 'Last checked: $seconds seconds ago (Frequency: every 60 sec)';
  }

  @override
  String get newsExplore => 'Explore';

  @override
  String get newsUpdated => 'UPDATED';
}
