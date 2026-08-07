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
