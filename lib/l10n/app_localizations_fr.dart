// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get loginTitle => 'OzAlert';

  @override
  String get loginSubtitle =>
      'Le radar ultime pour votre visa Working Holiday en Australie.';

  @override
  String get loginError => 'Erreur lors de la connexion :';

  @override
  String get loginGoogle => 'Continuer avec Google';

  @override
  String get loginApple => 'Continuer avec Apple';

  @override
  String get welcomeTitle =>
      'Votre Aventure en Australie,\nCommence et Grandit Ici';

  @override
  String get welcomeSubtitle =>
      'Votre copilote tout-en-un : des alertes 24/7 d\'ouverture de visas à votre vie en Australie avec emploi, CV officiel, 88 jours et démarches sans stress.';

  @override
  String get welcomeBullet1 =>
      'Radar 24/7 : Alertes officielles pour visas WHV ouverts (462/417)';

  @override
  String get welcomeBullet2 =>
      'Checklist d\'Arrivée : Guide pas à pas (TFN, SIM, Banque)';

  @override
  String get welcomeBullet3 =>
      'Emploi & CV Australien : Format recruteur en PDF et salaire Fair Work';

  @override
  String get welcomeBullet4 =>
      'Jours Régionaux : Validateur de code postal et Form 1263 avec signature';

  @override
  String get welcomeBullet5 =>
      'Pôle Fiscal & Épargne : Déclaration d\'impôts, exonération Medicare 2% et DASP';

  @override
  String get welcomeButton => 'Commencer Mon Aventure';

  @override
  String get onboardingTitle => 'Personnalisez votre Radar';

  @override
  String get onboardingSubtitle =>
      'Configurez votre profil pour recevoir des alertes de visas correspondant à votre passeport.';

  @override
  String get onboardingLanguage => 'Langue préférée';

  @override
  String get onboardingPassports => 'Sélectionnez vos passeports';

  @override
  String get onboardingErrorEmpty =>
      'Veuillez sélectionner au moins un passeport';

  @override
  String get onboardingErrorSave => 'Erreur lors de l\'enregistrement :';

  @override
  String get onboardingNext => 'Étape suivante';

  @override
  String get paywallTitle => 'Activez le Radar';

  @override
  String get paywallSubtitle =>
      'Recevez des notifications immédiates dès que votre visa est disponible. Abonnez-vous pour y accéder.';

  @override
  String paywallSubscribeMonthly(String price) {
    return 'S\'abonner $price / mois';
  }

  @override
  String get paywallSubscribeOnly => 'S\'abonner';

  @override
  String get paywallRestore => 'Restaurer les achats';

  @override
  String get dashboardTitle => 'Radar OzVisa';

  @override
  String get dashboardSettings => 'Paramètres';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguage => 'Langue de l\'application';

  @override
  String get settingsLanguageEnglish => 'Anglais (English)';

  @override
  String get settingsLanguageSpanish => 'Espagnol (Español)';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageItalian => 'Italien (Italiano)';

  @override
  String get settingsLanguageChinese => 'Chinois (中文)';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Êtes-vous sûr ?';

  @override
  String get settingsDeleteAccountConfirmMessage =>
      'Cette action est irréversible et supprimera toutes vos données. Voulez-vous continuer ?';

  @override
  String get settingsDeleteAccountConfirmButton => 'Supprimer';

  @override
  String get settingsDeleteAccountCancelButton => 'Annuler';

  @override
  String get visaStatusOpen => 'OUVERT';

  @override
  String get visaStatusClosed => 'FERMÉ';

  @override
  String get visaStatusPaused => 'EN PAUSE';

  @override
  String get visaSourceButton => 'Voir la source officielle';

  @override
  String get settingsLegal => 'Mentions Légales';

  @override
  String get settingsPrivacyPolicy => 'Politique de Confidentialité';

  @override
  String get settingsTerms => 'Conditions Générales';

  @override
  String get checklistTitle => 'Kit d\'Expédition';

  @override
  String get checklistProgress => 'Progression de l\'Équipement';

  @override
  String get checklistDescription =>
      'Préparez votre sac (certificats et économies) à l\'avance pour être prêt dès le début de l\'aventure.';

  @override
  String get checklistKeyDocs => 'Documents Clés :';

  @override
  String get checklistInstructions =>
      'Cochez chaque élément au fur et à mesure que vous l\'obtenez :';

  @override
  String get checklistTip =>
      'Conseil d\'Explorateur : Les quotas disparaissent très vite. Organiser vos PDF est essentiel.';

  @override
  String get dashboardSafeExpedition => 'Expédition Sécurisée';

  @override
  String get dashboardSafeExpeditionDesc =>
      'L\'horizon est dégagé. Nous vous enverrons une alerte dès que le Ministère ouvrira des places pour vos passeports.';

  @override
  String get newsTitle => 'Radar d\'Actualités';

  @override
  String get newsTabOfficial => 'Sources Officielles';

  @override
  String get newsTabAlerts => 'Alertes Google';

  @override
  String get newsEmptyState => 'Radar officiel silencieux. Aucune actualité.';

  @override
  String get newsGlobalAlerts => 'Alertes mondiales surveillées.';

  @override
  String newsError(String errorText) {
    return 'Interférence radar.\nImpossible de charger les actualités.\n$errorText';
  }

  @override
  String get radarScanning =>
      'Serveurs surveillant le site officiel de l\'immigration australienne';

  @override
  String get passportSelectorTitle =>
      'Sélectionnez votre passeport (WHV 417 & 462)';

  @override
  String passportSubclass(String subclass) {
    return 'Sous-classe $subclass • WHV Australie';
  }

  @override
  String get paywallModalTitle => 'Débloquez le Radar Visa 24/7';

  @override
  String get paywallModalDesc =>
      'Recevez une alerte Push immédiate et un e-mail à la seconde exacte où le Ministère ouvre des places pour votre pays.';

  @override
  String get paywallPlanAnnualTitle => 'Passe Saison (Annuel)';

  @override
  String get paywallPlanAnnualDesc => 'Meilleure offre • Économisez 37%';

  @override
  String get paywallPlanMonthlyTitle => 'Forfait Mensuel Flex';

  @override
  String get paywallPlanMonthlyDesc => 'Résiliez à tout moment en 1 clic';

  @override
  String get paywallActivateAnnual => 'Activer le Passe Saison (14,99 \$)';

  @override
  String get paywallActivateMonthly => 'Continuer avec le forfait mensuel';

  @override
  String get paywallDisclaimer =>
      'Le paiement sera débité de votre compte Apple ou Google lors de la confirmation d\'achat. L\'abonnement se renouvelle automatiquement sauf annulation au moins 24 heures avant la fin de la période en cours. Vous pouvez gérer et résilier votre abonnement dans les paramètres de votre compte après l\'achat.';

  @override
  String get paywallTermsOfUse => 'Conditions d\'utilisation';

  @override
  String get paywallPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get visaStatusOpenDesc =>
      'Visas disponibles. Commencez l\'expédition !';

  @override
  String get visaStatusPausedDesc =>
      'En attente. Traitement temporairement suspendu.';

  @override
  String get visaStatusClosedDesc => 'Camp fermé. 0 place actuellement.';

  @override
  String get errorOpeningLink => 'Impossible d\'ouvrir le lien.';

  @override
  String get tooltipScanRadar => 'Scanner le radar en direct';

  @override
  String get newsSourceOfficial => 'SOURCE OFFICIELLE';

  @override
  String get newsSourceMarket => 'MARCHÉ / DEVISES';

  @override
  String get partnerAffiliate => 'PARTENAIRE • -15%';

  @override
  String get partnerDescription =>
      'Indispensable pour activer votre visa aux douanes de Sydney ou Melbourne. Couverture COVID, sports et travail.';

  @override
  String get partnerActivate => 'Activer la promo assurance (-15%)';

  @override
  String testAlertSending(String countryNames) {
    return '⚡ Envoi de l\'alerte test pour $countryNames... Arrivée dans 2 secondes.';
  }

  @override
  String get checklistCompletedDescription =>
      'Tout est prêt ! Sac à dos 100% préparé.';

  @override
  String get partnerTitle =>
      'Besoin d\'une assurance santé pour l\'Australie ? Obtenez -15% avec Chapka / IATI';

  @override
  String get paywallSuccessMessage =>
      '✅ Accès VIP activé ! Alertes immédiates 24/7 activées ou achats restaurés avec succès.';

  @override
  String get navRadar => 'Radar';

  @override
  String get navEquipment => 'Équipement';

  @override
  String get navNews => 'Journal';

  @override
  String get checklistIdentityDocumentsTitle => 'Documents d\'identité';

  @override
  String get checklistIdentityDocumentsDesc =>
      'Pages du passeport (photo, données, validité). Acte de naissance. Justificatif de changement de nom (le cas échéant).';

  @override
  String get checklistEducationTitle => 'Études et diplômes';

  @override
  String get checklistEducationDesc =>
      'Preuve de qualifications (diplôme universitaire, années validées selon les exigences de votre pays).';

  @override
  String get checklistEnglishLanguageTitle => 'Niveau d\'anglais';

  @override
  String get checklistEnglishLanguageDesc =>
      'Preuve d\'études en anglais ou test certifié datant de moins de 12 mois (IELTS 4.5, PTE 30, Cambridge 147, TOEFL 32).';

  @override
  String get checklistGovernmentSupportTitle => 'Soutien gouvernemental';

  @override
  String get checklistGovernmentSupportDesc =>
      'Lettre de soutien de votre gouvernement (requis pour certains pays comme le Pérou, l\'Équateur, etc.).';

  @override
  String get checklistEnoughMoneyTitle =>
      'Fonds suffisants pour le séjour et le retour';

  @override
  String get checklistEnoughMoneyDesc =>
      'Preuve de fonds pour votre séjour (environ 5 000 \$ AUD) et pour un billet de sortie d\'Australie (ou billet déjà réservé).';

  @override
  String get checklistCharacterDocumentsTitle =>
      'Documents de bonne conduite (Casier judiciaire)';

  @override
  String get checklistCharacterDocumentsDesc =>
      'Extraits de casier judiciaire de chaque pays où vous avez séjourné 12+ mois depuis l\'âge de 16 ans.';

  @override
  String get checklistGettingHelpTitle => 'Recours à un agent';

  @override
  String get checklistGettingHelpDesc =>
      'Formulaire 956A ou 956 si vous faites appel à un agent d\'immigration ou autorisez un tiers.';

  @override
  String get checklistPrepareDocumentsTitle => 'Préparer vos documents';

  @override
  String get checklistPrepareDocumentsDesc =>
      'Traduire tous les documents en anglais par un traducteur certifié et numériser originaux et traductions en couleur.';

  @override
  String radarLastChecked(String seconds) {
    return 'Dernière vérification : il y a $seconds secondes (Fréquence : toutes les 60s)';
  }

  @override
  String get newsExplore => 'Explorer';

  @override
  String get newsUpdated => 'ACTUALISÉ';

  @override
  String get countryAR => 'Argentine';

  @override
  String get countryAT => 'Autriche';

  @override
  String get countryBR => 'Brésil';

  @override
  String get countryCL => 'Chili';

  @override
  String get countryCN => 'Chine';

  @override
  String get countryCZ => 'République tchèque';

  @override
  String get countryEC => 'Équateur';

  @override
  String get countryGR => 'Grèce';

  @override
  String get countryHU => 'Hongrie';

  @override
  String get countryIN => 'Inde';

  @override
  String get countryID => 'Indonésie';

  @override
  String get countryIL => 'Israël';

  @override
  String get countryLU => 'Luxembourg';

  @override
  String get countryMY => 'Malaisie';

  @override
  String get countryMN => 'Mongolie';

  @override
  String get countryPG => 'Papouasie-Nouvelle-Guinée';

  @override
  String get countryPE => 'Pérou';

  @override
  String get countryPL => 'Pologne';

  @override
  String get countryPT => 'Portugal';

  @override
  String get countrySM => 'Saint-Marin';

  @override
  String get countrySG => 'Singapour';

  @override
  String get countrySK => 'Slovaquie';

  @override
  String get countrySI => 'Slovénie';

  @override
  String get countryES => 'Espagne';

  @override
  String get countryCH => 'Suisse';

  @override
  String get countryTH => 'Thaïlande';

  @override
  String get countryTR => 'Turquie';

  @override
  String get countryUY => 'Uruguay';

  @override
  String get countryVN => 'Vietnam';

  @override
  String notificationTestTitle(String countryName) {
    return '🔔 ALERTE TEST : Radar OzVisa Actif ($countryName)';
  }

  @override
  String get notificationTestBody =>
      '✅ Connexion vérifiée : Serveurs surveillant les visas 24/7 en temps réel.';

  @override
  String notificationTestLongBody(String countryName) {
    return 'Le système de suivi OzVisa Alert est maintenant actif pour $countryName ! Nous vous alerterons à la seconde exacte où le Ministère ouvrira de nouvelles places.';
  }

  @override
  String get notificationChannelName => 'Alertes d\'Ouverture OzVisa';

  @override
  String get notificationChannelDesc =>
      'Notifications immédiates d\'ouverture de places pour le visa Work & Holiday';

  @override
  String get notificationTestTicker => 'Alerte Test OzVisa';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNewsNotifs => 'Recevoir actualités et conseils';

  @override
  String get referralTitle => 'Où nous avez-vous trouvés ?';

  @override
  String get referralSubtitle => 'Cela nous aide beaucoup à nous améliorer.';

  @override
  String get referralFriend => 'Recommandation d\'un ami';

  @override
  String get referralGroups => 'Groupes WhatsApp';

  @override
  String get referralOthers => 'Autre';

  @override
  String get statsOfficialData => 'Données Officielles (Work & Holiday)';

  @override
  String get statsVolume => 'Volume de demandes';

  @override
  String get statsSourceTooltip => 'Voir la source officielle';

  @override
  String get dndNoticeTitle => 'Comment entendre l\'alarme ?';

  @override
  String get dndDialogTitle => 'Configuration du son et de l\'alarme';

  @override
  String get dndDialogIntro =>
      'Pour qu\'OzAlert puisse vous réveiller à temps, vous devez configurer correctement votre téléphone. En mode silencieux ou \'Ne pas déranger\', vous risquez de manquer l\'ouverture.';

  @override
  String get dndDialogIosTitle => '🍏 Utilisateurs iPhone (iOS)';

  @override
  String get dndDialogIosSteps =>
      '1. Allez dans Réglages > OzAlert > Notifications.\n2. Assurez-vous que \'Autoriser les notifications\' et \'Sons\' sont activés.\n3. Si vous utilisez le mode \'Ne pas déranger\' ou \'Sommeil\', ajoutez OzAlert aux applications autorisées.';

  @override
  String get dndDialogAndroidTitle => '🤖 Utilisateurs Android';

  @override
  String get dndDialogAndroidSteps =>
      '1. Allez dans Paramètres > Applications > OzAlert > Notifications.\n2. Appuyez sur les catégories de notification et sélectionnez une sonnerie forte.\n3. Si vous utilisez le mode \'Ne pas déranger\', ajoutez OzAlert comme exception.';

  @override
  String get dndDialogClose => 'Compris';
}
