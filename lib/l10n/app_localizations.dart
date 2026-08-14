import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'OzAlert'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The ultimate radar for your Australian Work & Holiday Visa.'**
  String get loginSubtitle;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Error signing in:'**
  String get loginError;

  /// No description provided for @loginGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginGoogle;

  /// No description provided for @loginApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get loginApple;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Australian visas\nfly away\nin minutes.'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every year, thousands miss out because they don\'t find out in time when spots open. Our system tracks official sources 24/7 and alerts you instantly so you can be the first to apply.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeBullet1.
  ///
  /// In en, this message translates to:
  /// **'Real instant notifications'**
  String get welcomeBullet1;

  /// No description provided for @welcomeBullet2.
  ///
  /// In en, this message translates to:
  /// **'Gain an advantage over other applicants'**
  String get welcomeBullet2;

  /// No description provided for @welcomeBullet3.
  ///
  /// In en, this message translates to:
  /// **'Official government sources (Immigration)'**
  String get welcomeBullet3;

  /// No description provided for @welcomeButton.
  ///
  /// In en, this message translates to:
  /// **'Set up my Radar now'**
  String get welcomeButton;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your Radar'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile to receive notifications for visas that match your passport.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred Language'**
  String get onboardingLanguage;

  /// No description provided for @onboardingPassports.
  ///
  /// In en, this message translates to:
  /// **'Select your Passports'**
  String get onboardingPassports;

  /// No description provided for @onboardingErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one passport'**
  String get onboardingErrorEmpty;

  /// No description provided for @onboardingErrorSave.
  ///
  /// In en, this message translates to:
  /// **'Error saving:'**
  String get onboardingErrorSave;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get onboardingNext;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on the Radar'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive immediate notifications as soon as your visa becomes available. Subscribe to access.'**
  String get paywallSubtitle;

  /// No description provided for @paywallSubscribeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Subscribe {price} / month'**
  String paywallSubscribeMonthly(String price);

  /// No description provided for @paywallSubscribeOnly.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get paywallSubscribeOnly;

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get paywallRestore;

  /// No description provided for @paywallBypass.
  ///
  /// In en, this message translates to:
  /// **'Bypass to Dashboard (Debug)'**
  String get paywallBypass;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'OzVisa Radar'**
  String get dashboardTitle;

  /// No description provided for @dashboardTestAlert.
  ///
  /// In en, this message translates to:
  /// **'Test Alert'**
  String get dashboardTestAlert;

  /// No description provided for @dashboardSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get dashboardSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get settingsDeleteAccountConfirmTitle;

  /// No description provided for @settingsDeleteAccountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible and will delete all your data. Do you want to continue?'**
  String get settingsDeleteAccountConfirmMessage;

  /// No description provided for @settingsDeleteAccountConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsDeleteAccountConfirmButton;

  /// No description provided for @settingsDeleteAccountCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsDeleteAccountCancelButton;

  /// No description provided for @visaStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get visaStatusOpen;

  /// No description provided for @visaStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'CLOSED'**
  String get visaStatusClosed;

  /// No description provided for @visaStatusPaused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get visaStatusPaused;

  /// No description provided for @visaSourceButton.
  ///
  /// In en, this message translates to:
  /// **'View official source'**
  String get visaSourceButton;

  /// No description provided for @settingsLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsLegal;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get settingsTerms;

  /// No description provided for @checklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Expedition Kit'**
  String get checklistTitle;

  /// No description provided for @checklistProgress.
  ///
  /// In en, this message translates to:
  /// **'Equipment Progress'**
  String get checklistProgress;

  /// No description provided for @checklistDescription.
  ///
  /// In en, this message translates to:
  /// **'Prepare your backpack (certificates and savings) in advance so you are not left behind when the adventure begins.'**
  String get checklistDescription;

  /// No description provided for @checklistKeyDocs.
  ///
  /// In en, this message translates to:
  /// **'Key Documents:'**
  String get checklistKeyDocs;

  /// No description provided for @checklistInstructions.
  ///
  /// In en, this message translates to:
  /// **'Secure each item in your inventory as you get it:'**
  String get checklistInstructions;

  /// No description provided for @checklistTip.
  ///
  /// In en, this message translates to:
  /// **'Explorer Tip: Quotas tend to disappear like mirages in the desert. Having your PDFs organized is vital to survive the process.'**
  String get checklistTip;

  /// No description provided for @dashboardSafeExpedition.
  ///
  /// In en, this message translates to:
  /// **'Safe Expedition'**
  String get dashboardSafeExpedition;

  /// No description provided for @dashboardSafeExpeditionDesc.
  ///
  /// In en, this message translates to:
  /// **'The horizon is clear. We will notify you with a flare (notification) as soon as the Department enables places for your passports.'**
  String get dashboardSafeExpeditionDesc;

  /// No description provided for @newsTitle.
  ///
  /// In en, this message translates to:
  /// **'News Radar'**
  String get newsTitle;

  /// No description provided for @newsTabOfficial.
  ///
  /// In en, this message translates to:
  /// **'Official Sources'**
  String get newsTabOfficial;

  /// No description provided for @newsTabAlerts.
  ///
  /// In en, this message translates to:
  /// **'Google Alerts'**
  String get newsTabAlerts;

  /// No description provided for @newsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Official radar silent. No news.'**
  String get newsEmptyState;

  /// No description provided for @newsGlobalAlerts.
  ///
  /// In en, this message translates to:
  /// **'Global alerts monitored.'**
  String get newsGlobalAlerts;

  /// No description provided for @newsError.
  ///
  /// In en, this message translates to:
  /// **'Radar interference.\nCould not load news.\n{errorText}'**
  String newsError(String errorText);

  /// No description provided for @radarScanning.
  ///
  /// In en, this message translates to:
  /// **'Servers tracking the official Australian Immigration website'**
  String get radarScanning;

  /// No description provided for @passportSelectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Select your Passport (WHV 417 & 462)'**
  String get passportSelectorTitle;

  /// No description provided for @passportSubclass.
  ///
  /// In en, this message translates to:
  /// **'Subclass {subclass} • Australia WHV'**
  String passportSubclass(String subclass);

  /// No description provided for @paywallModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the 24/7 Visa Radar'**
  String get paywallModalTitle;

  /// No description provided for @paywallModalDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive an immediate Push Alert and Email the exact second the Department of Home Affairs opens spots for your country.'**
  String get paywallModalDesc;

  /// No description provided for @paywallPlanAnnualTitle.
  ///
  /// In en, this message translates to:
  /// **'Season Pass (Annual)'**
  String get paywallPlanAnnualTitle;

  /// No description provided for @paywallPlanAnnualDesc.
  ///
  /// In en, this message translates to:
  /// **'Best value • Save 37%'**
  String get paywallPlanAnnualDesc;

  /// No description provided for @paywallPlanMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Flex Monthly Plan'**
  String get paywallPlanMonthlyTitle;

  /// No description provided for @paywallPlanMonthlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime with 1 click'**
  String get paywallPlanMonthlyDesc;

  /// No description provided for @paywallActivateAnnual.
  ///
  /// In en, this message translates to:
  /// **'Activate Season Pass (\$14.99)'**
  String get paywallActivateAnnual;

  /// No description provided for @paywallActivateMonthly.
  ///
  /// In en, this message translates to:
  /// **'Activate Monthly Plan (\$1.99)'**
  String get paywallActivateMonthly;

  /// No description provided for @paywallDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'No trial period to ensure dedicated servers without saturation. Payment processed securely via RevenueCat / App Store / Google Play. You can cancel your subscription anytime in your account settings.'**
  String get paywallDisclaimer;

  /// No description provided for @visaStatusOpenDesc.
  ///
  /// In en, this message translates to:
  /// **'Visas available. Start the expedition!'**
  String get visaStatusOpenDesc;

  /// No description provided for @visaStatusPausedDesc.
  ///
  /// In en, this message translates to:
  /// **'On hold. Processing temporarily paused.'**
  String get visaStatusPausedDesc;

  /// No description provided for @visaStatusClosedDesc.
  ///
  /// In en, this message translates to:
  /// **'Camp closed. 0 places currently.'**
  String get visaStatusClosedDesc;

  /// No description provided for @errorOpeningLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get errorOpeningLink;

  /// No description provided for @tooltipScanRadar.
  ///
  /// In en, this message translates to:
  /// **'Scan live radar'**
  String get tooltipScanRadar;

  /// No description provided for @newsSourceOfficial.
  ///
  /// In en, this message translates to:
  /// **'OFFICIAL SOURCE'**
  String get newsSourceOfficial;

  /// No description provided for @newsSourceMarket.
  ///
  /// In en, this message translates to:
  /// **'MARKET / CURRENCY'**
  String get newsSourceMarket;

  /// No description provided for @partnerAffiliate.
  ///
  /// In en, this message translates to:
  /// **'AFFILIATE PARTNER • 15% OFF'**
  String get partnerAffiliate;

  /// No description provided for @partnerDescription.
  ///
  /// In en, this message translates to:
  /// **'Essential to activate your visa when passing customs in Sydney or Melbourne. Full COVID, sports and work coverage.'**
  String get partnerDescription;

  /// No description provided for @partnerActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate Insurance Promo (15% Off)'**
  String get partnerActivate;

  /// No description provided for @testAlertSending.
  ///
  /// In en, this message translates to:
  /// **'⚡ Sending test alert for {countryNames}... Will arrive in 2 seconds.'**
  String testAlertSending(String countryNames);

  /// No description provided for @checklistCompletedDescription.
  ///
  /// In en, this message translates to:
  /// **'All set! Backpack 100% prepared.'**
  String get checklistCompletedDescription;

  /// No description provided for @partnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Need health insurance for Australia? Get 15% off with Chapka / IATI Seguros'**
  String get partnerTitle;

  /// No description provided for @paywallSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'✅ VIP Access Activated! 24/7 immediate alerts enabled or purchases successfully restored.'**
  String get paywallSuccessMessage;

  /// No description provided for @navRadar.
  ///
  /// In en, this message translates to:
  /// **'Radar'**
  String get navRadar;

  /// No description provided for @navEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get navEquipment;

  /// No description provided for @navNews.
  ///
  /// In en, this message translates to:
  /// **'Logbook'**
  String get navNews;

  /// No description provided for @checklistIdentityDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity documents'**
  String get checklistIdentityDocumentsTitle;

  /// No description provided for @checklistIdentityDocumentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Pages of your passport (photo, data, dates). Birth certificate with parents\' names. Proof of name change (if applicable).'**
  String get checklistIdentityDocumentsDesc;

  /// No description provided for @checklistEducationTitle.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get checklistEducationTitle;

  /// No description provided for @checklistEducationDesc.
  ///
  /// In en, this message translates to:
  /// **'Evidence of your educational qualifications (university degree, years completed or equivalent, depending on your country\'s requirements).'**
  String get checklistEducationDesc;

  /// No description provided for @checklistEnglishLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'English level'**
  String get checklistEnglishLanguageTitle;

  /// No description provided for @checklistEnglishLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'Evidence of English studies, or approved exam in the last 12 months (IELTS 4.5, PTE 30, Cambridge C1 147, or TOEFL iBT 32).'**
  String get checklistEnglishLanguageDesc;

  /// No description provided for @checklistGovernmentSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Government support'**
  String get checklistGovernmentSupportTitle;

  /// No description provided for @checklistGovernmentSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Letter of support from your government (only for certain countries like Peru, Ecuador, etc. Not required for Spain, Argentina, Chile, etc.).'**
  String get checklistGovernmentSupportDesc;

  /// No description provided for @checklistEnoughMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Enough money for your stay and departure'**
  String get checklistEnoughMoneyTitle;

  /// No description provided for @checklistEnoughMoneyDesc.
  ///
  /// In en, this message translates to:
  /// **'Evidence of money for your stay (usually \$5,000 AUD) and money for a departure ticket from Australia (or the ticket already purchased).'**
  String get checklistEnoughMoneyDesc;

  /// No description provided for @checklistCharacterDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Character documents (Background checks)'**
  String get checklistCharacterDocumentsTitle;

  /// No description provided for @checklistCharacterDocumentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Police certificates from every country where you have spent 12+ months in the last 10 years (since age 16), and military record if applicable.'**
  String get checklistCharacterDocumentsDesc;

  /// No description provided for @checklistGettingHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting help (Agents)'**
  String get checklistGettingHelpTitle;

  /// No description provided for @checklistGettingHelpDesc.
  ///
  /// In en, this message translates to:
  /// **'Form 956A or 956 if you use a migration agent or authorize someone to receive your documents.'**
  String get checklistGettingHelpDesc;

  /// No description provided for @checklistPrepareDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare your documents'**
  String get checklistPrepareDocumentsTitle;

  /// No description provided for @checklistPrepareDocumentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Translate all documents into English by a qualified translator and scan/photograph all originals and translations in color.'**
  String get checklistPrepareDocumentsDesc;

  /// No description provided for @radarLastChecked.
  ///
  /// In en, this message translates to:
  /// **'Last checked: {seconds} seconds ago (Frequency: every 60 sec)'**
  String radarLastChecked(String seconds);

  /// No description provided for @newsExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get newsExplore;

  /// No description provided for @newsUpdated.
  ///
  /// In en, this message translates to:
  /// **'UPDATED'**
  String get newsUpdated;

  /// No description provided for @countryAR.
  ///
  /// In en, this message translates to:
  /// **'Argentina'**
  String get countryAR;

  /// No description provided for @countryAT.
  ///
  /// In en, this message translates to:
  /// **'Austria'**
  String get countryAT;

  /// No description provided for @countryBR.
  ///
  /// In en, this message translates to:
  /// **'Brazil'**
  String get countryBR;

  /// No description provided for @countryCL.
  ///
  /// In en, this message translates to:
  /// **'Chile'**
  String get countryCL;

  /// No description provided for @countryCN.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get countryCN;

  /// No description provided for @countryCZ.
  ///
  /// In en, this message translates to:
  /// **'Czech Republic'**
  String get countryCZ;

  /// No description provided for @countryEC.
  ///
  /// In en, this message translates to:
  /// **'Ecuador'**
  String get countryEC;

  /// No description provided for @countryGR.
  ///
  /// In en, this message translates to:
  /// **'Greece'**
  String get countryGR;

  /// No description provided for @countryHU.
  ///
  /// In en, this message translates to:
  /// **'Hungary'**
  String get countryHU;

  /// No description provided for @countryIN.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get countryIN;

  /// No description provided for @countryID.
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get countryID;

  /// No description provided for @countryIL.
  ///
  /// In en, this message translates to:
  /// **'Israel'**
  String get countryIL;

  /// No description provided for @countryLU.
  ///
  /// In en, this message translates to:
  /// **'Luxembourg'**
  String get countryLU;

  /// No description provided for @countryMY.
  ///
  /// In en, this message translates to:
  /// **'Malaysia'**
  String get countryMY;

  /// No description provided for @countryMN.
  ///
  /// In en, this message translates to:
  /// **'Mongolia'**
  String get countryMN;

  /// No description provided for @countryPG.
  ///
  /// In en, this message translates to:
  /// **'Papua New Guinea'**
  String get countryPG;

  /// No description provided for @countryPE.
  ///
  /// In en, this message translates to:
  /// **'Peru'**
  String get countryPE;

  /// No description provided for @countryPL.
  ///
  /// In en, this message translates to:
  /// **'Poland'**
  String get countryPL;

  /// No description provided for @countryPT.
  ///
  /// In en, this message translates to:
  /// **'Portugal'**
  String get countryPT;

  /// No description provided for @countrySM.
  ///
  /// In en, this message translates to:
  /// **'San Marino'**
  String get countrySM;

  /// No description provided for @countrySG.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get countrySG;

  /// No description provided for @countrySK.
  ///
  /// In en, this message translates to:
  /// **'Slovakia'**
  String get countrySK;

  /// No description provided for @countrySI.
  ///
  /// In en, this message translates to:
  /// **'Slovenia'**
  String get countrySI;

  /// No description provided for @countryES.
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get countryES;

  /// No description provided for @countryCH.
  ///
  /// In en, this message translates to:
  /// **'Switzerland'**
  String get countryCH;

  /// No description provided for @countryTH.
  ///
  /// In en, this message translates to:
  /// **'Thailand'**
  String get countryTH;

  /// No description provided for @countryTR.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get countryTR;

  /// No description provided for @countryUY.
  ///
  /// In en, this message translates to:
  /// **'Uruguay'**
  String get countryUY;

  /// No description provided for @countryVN.
  ///
  /// In en, this message translates to:
  /// **'Vietnam'**
  String get countryVN;

  /// No description provided for @notificationTestTitle.
  ///
  /// In en, this message translates to:
  /// **'🔔 TEST ALERT: OzVisa Radar Active ({countryName})'**
  String notificationTestTitle(String countryName);

  /// No description provided for @notificationTestBody.
  ///
  /// In en, this message translates to:
  /// **'✅ Connection verified: Servers monitoring visas 24/7 in real time.'**
  String get notificationTestBody;

  /// No description provided for @notificationTestLongBody.
  ///
  /// In en, this message translates to:
  /// **'OzVisa Alert\'s tracking system is now active for {countryName}! We will notify you the exact second the Department of Home Affairs opens new spots.'**
  String notificationTestLongBody(String countryName);

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'OzVisa Opening Alerts'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Immediate notifications for Work & Holiday visa spots openings'**
  String get notificationChannelDesc;

  /// No description provided for @notificationTestTicker.
  ///
  /// In en, this message translates to:
  /// **'OzVisa Test Alert'**
  String get notificationTestTicker;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
