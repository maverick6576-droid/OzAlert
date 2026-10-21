// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get loginTitle => 'OzAlert';

  @override
  String get loginSubtitle =>
      'Il radar definitivo per il tuo visto Working Holiday in Australia.';

  @override
  String get loginError => 'Errore durante l\'accesso:';

  @override
  String get loginGoogle => 'Continua con Google';

  @override
  String get loginApple => 'Continua con Apple';

  @override
  String get welcomeTitle =>
      'La Tua Avventura in Australia,\nInizia e Cresce Qui';

  @override
  String get welcomeSubtitle =>
      'Il tuo copilota tutto-in-uno: dagli avvisi 24/7 di apertura visti alla tua vita in Australia con lavoro, CV ufficiale, 88 giorni e pratiche senza stress.';

  @override
  String get welcomeBullet1 =>
      'Radar 24/7: Notifiche istantanee per visti WHV aperti (462/417)';

  @override
  String get welcomeBullet2 =>
      'Checklist d\'Arrivo: Guida passo dopo passo (TFN, SIM, Banca)';

  @override
  String get welcomeBullet3 =>
      'Lavoro & CV Australiano: Formato recruiter in PDF e paga Fair Work';

  @override
  String get welcomeBullet4 =>
      'Giorni Regionali: Verifica codici postali e Form 1263 con firma';

  @override
  String get welcomeBullet5 =>
      'Hub Fiscale & Risparmio: Tax Return, esenzione Medicare 2% e DASP';

  @override
  String get welcomeButton => 'Inizia la Mia Avventura';

  @override
  String get onboardingTitle => 'Personalizza il tuo Radar';

  @override
  String get onboardingSubtitle =>
      'Configura il tuo profilo per ricevere avvisi sui visti compatibili con il tuo passaporto.';

  @override
  String get onboardingLanguage => 'Lingua preferita';

  @override
  String get onboardingPassports => 'Seleziona i tuoi passaporti';

  @override
  String get onboardingErrorEmpty => 'Seleziona almeno un passaporto';

  @override
  String get onboardingErrorSave => 'Errore durante il salvataggio:';

  @override
  String get onboardingNext => 'Passaggio successivo';

  @override
  String get paywallTitle => 'Attiva il Radar';

  @override
  String get paywallSubtitle =>
      'Ricevi notifiche immediate non appena il tuo visto è disponibile. Abbonati per accedere.';

  @override
  String paywallSubscribeMonthly(String price) {
    return 'Abbonati $price / mese';
  }

  @override
  String get paywallSubscribeOnly => 'Abbonati';

  @override
  String get paywallRestore => 'Ripristina acquisti';

  @override
  String get dashboardTitle => 'Radar OzVisa';

  @override
  String get dashboardSettings => 'Impostazioni';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsLanguage => 'Lingua dell\'applicazione';

  @override
  String get settingsLanguageEnglish => 'Inglese (English)';

  @override
  String get settingsLanguageSpanish => 'Spagnolo (Español)';

  @override
  String get settingsLanguageFrench => 'Francese (Français)';

  @override
  String get settingsLanguageItalian => 'Italiano';

  @override
  String get settingsLanguageChinese => 'Cinese (中文)';

  @override
  String get settingsLogout => 'Disconnetti';

  @override
  String get settingsDeleteAccount => 'Elimina account';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Sei sicuro?';

  @override
  String get settingsDeleteAccountConfirmMessage =>
      'Questa azione è irreversibile ed eliminerà tutti i tuoi dati. Vuoi continuare?';

  @override
  String get settingsDeleteAccountConfirmButton => 'Elimina';

  @override
  String get settingsDeleteAccountCancelButton => 'Annulla';

  @override
  String get visaStatusOpen => 'APERTO';

  @override
  String get visaStatusClosed => 'CHIUSO';

  @override
  String get visaStatusPaused => 'IN PAUSA';

  @override
  String get visaSourceButton => 'Vedi fonte ufficiale';

  @override
  String get settingsLegal => 'Note Legali';

  @override
  String get settingsPrivacyPolicy => 'Informativa sulla Privacy';

  @override
  String get settingsTerms => 'Termini e Condizioni';

  @override
  String get checklistTitle => 'Kit di Spedizione';

  @override
  String get checklistProgress => 'Progresso Equipaggiamento';

  @override
  String get checklistDescription =>
      'Prepara il tuo zaino (certificati e risparmi) in anticipo per farti trovare pronto all\'inizio dell\'avventura.';

  @override
  String get checklistKeyDocs => 'Documenti Chiave:';

  @override
  String get checklistInstructions =>
      'Spunta ogni elemento man mano che lo ottieni:';

  @override
  String get checklistTip =>
      'Consiglio dell\'Esploratore: I posti spariscono molto velocemente. Organizzare i tuoi PDF è fondamentale.';

  @override
  String get dashboardSafeExpedition => 'Spedizione Sicura';

  @override
  String get dashboardSafeExpeditionDesc =>
      'L\'orizzonte è limpido. Ti avviseremo con un segnale (notifica) non appena il Dipartimento aprirà posti per i tuoi passaporti.';

  @override
  String get newsTitle => 'Radar Notizie';

  @override
  String get newsTabOfficial => 'Fonti Ufficiali';

  @override
  String get newsTabAlerts => 'Google Alerts';

  @override
  String get newsEmptyState => 'Radar ufficiale silenzioso. Nessuna notizia.';

  @override
  String get newsGlobalAlerts => 'Avvisi globali monitorati.';

  @override
  String newsError(String errorText) {
    return 'Interferenza radar.\nImpossibile caricare le notizie.\n$errorText';
  }

  @override
  String get radarScanning =>
      'Server attivi sul sito ufficiale dell\'immigrazione australiana';

  @override
  String get passportSelectorTitle =>
      'Seleziona il tuo passaporto (WHV 417 & 462)';

  @override
  String passportSubclass(String subclass) {
    return 'Sottoclasse $subclass • WHV Australia';
  }

  @override
  String get paywallModalTitle => 'Sblocca il Radar Visti 24/7';

  @override
  String get paywallModalDesc =>
      'Ricevi un avviso Push immediato e un\'email esattamente nel secondo in cui il Dipartimento apre i posti per il tuo paese.';

  @override
  String get paywallPlanAnnualTitle => 'Pass Stagionale (Annuale)';

  @override
  String get paywallPlanAnnualDesc => 'Miglior valore • Risparmia il 37%';

  @override
  String get paywallPlanMonthlyTitle => 'Piano Mensile Flex';

  @override
  String get paywallPlanMonthlyDesc =>
      'Cancella in qualsiasi momento con 1 clic';

  @override
  String get paywallActivateAnnual => 'Attiva Pass Stagionale (\$14.99)';

  @override
  String get paywallActivateMonthly => 'Continua con Piano Mensile';

  @override
  String get paywallDisclaimer =>
      'Il pagamento verrà addebitato sul tuo account Apple o Google alla conferma dell\'acquisto. L\'abbonamento si rinnova automaticamente a meno che non venga annullato almeno 24 ore prima della fine del periodo corrente. Puoi gestire e annullare l\'abbonamento nelle impostazioni del tuo account dopo l\'acquisto.';

  @override
  String get paywallTermsOfUse => 'Termini di utilizzo';

  @override
  String get paywallPrivacyPolicy => 'Informativa sulla privacy';

  @override
  String get visaStatusOpenDesc => 'Visti disponibili. Inizia la spedizione!';

  @override
  String get visaStatusPausedDesc =>
      'In attesa. Elaborazione temporaneamente sospesa.';

  @override
  String get visaStatusClosedDesc => 'Accampamento chiuso. 0 posti al momento.';

  @override
  String get errorOpeningLink => 'Impossibile aprire il link.';

  @override
  String get tooltipScanRadar => 'Scansione radar in tempo reale';

  @override
  String get newsSourceOfficial => 'FONTE UFFICIALE';

  @override
  String get newsSourceMarket => 'MERCATO / VALUTA';

  @override
  String get partnerAffiliate => 'PARTNER • 15% DI SCONTO';

  @override
  String get partnerDescription =>
      'Essenziale per attivare il visto alla dogana di Sydney o Melbourne. Copertura COVID, sport e lavoro.';

  @override
  String get partnerActivate => 'Attiva Promo Assicurazione (-15%)';

  @override
  String testAlertSending(String countryNames) {
    return '⚡ Invio avviso di prova per $countryNames... Arrivo in 2 secondi.';
  }

  @override
  String get checklistCompletedDescription =>
      'Tutto pronto! Zaino preparato al 100%.';

  @override
  String get partnerTitle =>
      'Serve un\'assicurazione sanitaria per l\'Australia? Ottieni il 15% di sconto con Chapka / IATI';

  @override
  String get paywallSuccessMessage =>
      '✅ Accesso VIP Attivato! Notifiche 24/7 abilitate o acquisti ripristinati con successo.';

  @override
  String get navRadar => 'Radar';

  @override
  String get navEquipment => 'Equipaggiamento';

  @override
  String get navNews => 'Diario';

  @override
  String get checklistIdentityDocumentsTitle => 'Documenti d\'identità';

  @override
  String get checklistIdentityDocumentsDesc =>
      'Pagine del passaporto (foto, dati, scadenze). Certificato di nascita. Prova di cambio nome (se applicabile).';

  @override
  String get checklistEducationTitle => 'Istruzione e titoli';

  @override
  String get checklistEducationDesc =>
      'Prova delle qualifiche (laurea, anni universitari completati secondo i requisiti del tuo paese).';

  @override
  String get checklistEnglishLanguageTitle => 'Livello di inglese';

  @override
  String get checklistEnglishLanguageDesc =>
      'Attestato di studi in inglese o esame approvato negli ultimi 12 mesi (IELTS 4.5, PTE 30, Cambridge 147, TOEFL 32).';

  @override
  String get checklistGovernmentSupportTitle => 'Supporto governativo';

  @override
  String get checklistGovernmentSupportDesc =>
      'Lettera di supporto del governo (solo per alcuni paesi come Perù, Ecuador, ecc. Non richiesta per Italia o Spagna).';

  @override
  String get checklistEnoughMoneyTitle =>
      'Fondi sufficienti per soggiorno e rientro';

  @override
  String get checklistEnoughMoneyDesc =>
      'Prova di fondi per il soggiorno (circa \$5.000 AUD) e per un biglietto di ritorno dall\'Australia (o biglietto già acquistato).';

  @override
  String get checklistCharacterDocumentsTitle =>
      'Certificati penali (Fedina penale)';

  @override
  String get checklistCharacterDocumentsDesc =>
      'Certificato penale di ogni paese in cui hai vissuto per 12+ mesi negli ultimi 10 anni (a partire dai 16 anni).';

  @override
  String get checklistGettingHelpTitle => 'Assistenza di agenti';

  @override
  String get checklistGettingHelpDesc =>
      'Modulo 956A o 956 se ti affidi a un agente di migrazione o autorizzi un delegato.';

  @override
  String get checklistPrepareDocumentsTitle => 'Preparare i documenti';

  @override
  String get checklistPrepareDocumentsDesc =>
      'Traduci tutti i documenti in inglese tramite un traduttore certificato e scansiona/fotografa tutti gli originali a colori.';

  @override
  String radarLastChecked(String seconds) {
    return 'Ultima verifica: $seconds secondi fa (Frequenza: ogni 60 sec)';
  }

  @override
  String get newsExplore => 'Esplora';

  @override
  String get newsUpdated => 'AGGIORNATO';

  @override
  String get countryAR => 'Argentina';

  @override
  String get countryAT => 'Austria';

  @override
  String get countryBR => 'Brasile';

  @override
  String get countryCL => 'Cile';

  @override
  String get countryCN => 'Cina';

  @override
  String get countryCZ => 'Repubblica Ceca';

  @override
  String get countryEC => 'Ecuador';

  @override
  String get countryGR => 'Grecia';

  @override
  String get countryHU => 'Ungheria';

  @override
  String get countryIN => 'India';

  @override
  String get countryID => 'Indonesia';

  @override
  String get countryIL => 'Israele';

  @override
  String get countryLU => 'Lussemburgo';

  @override
  String get countryMY => 'Malesia';

  @override
  String get countryMN => 'Mongolia';

  @override
  String get countryPG => 'Papua Nuova Guinea';

  @override
  String get countryPE => 'Perù';

  @override
  String get countryPL => 'Polonia';

  @override
  String get countryPT => 'Portogallo';

  @override
  String get countrySM => 'San Marino';

  @override
  String get countrySG => 'Singapore';

  @override
  String get countrySK => 'Slovacchia';

  @override
  String get countrySI => 'Slovenia';

  @override
  String get countryES => 'Spagna';

  @override
  String get countryCH => 'Svizzera';

  @override
  String get countryTH => 'Thailandia';

  @override
  String get countryTR => 'Turchia';

  @override
  String get countryUY => 'Uruguay';

  @override
  String get countryVN => 'Vietnam';

  @override
  String notificationTestTitle(String countryName) {
    return '🔔 AVVISO TEST: Radar OzVisa Attivo ($countryName)';
  }

  @override
  String get notificationTestBody =>
      '✅ Connessione verificata: Server attivi per monitorare i visti 24/7 in tempo reale.';

  @override
  String notificationTestLongBody(String countryName) {
    return 'Il sistema di tracciamento OzVisa Alert è ora attivo per $countryName! Ti avviseremo esattamente nel secondo in cui il Dipartimento aprirà nuovi posti.';
  }

  @override
  String get notificationChannelName => 'Avvisi Apertura OzVisa';

  @override
  String get notificationChannelDesc =>
      'Notifiche immediate per apertura posti visti Work & Holiday';

  @override
  String get notificationTestTicker => 'Avviso Test OzVisa';

  @override
  String get settingsNotifications => 'Notifiche';

  @override
  String get settingsNewsNotifs => 'Ricevi notizie e consigli';

  @override
  String get referralTitle => 'Come ci hai trovati?';

  @override
  String get referralSubtitle => 'Ci aiuta molto a migliorare.';

  @override
  String get referralFriend => 'Passaparola da un amico';

  @override
  String get referralGroups => 'Gruppi WhatsApp';

  @override
  String get referralOthers => 'Altro';

  @override
  String get statsOfficialData => 'Dati Ufficiali (Work & Holiday)';

  @override
  String get statsVolume => 'Volume richieste';

  @override
  String get statsSourceTooltip => 'Vedi fonte ufficiale';

  @override
  String get dndNoticeTitle => 'Come sentire l\'allarme?';

  @override
  String get dndDialogTitle => 'Impostazioni Suono & Sveglia';

  @override
  String get dndDialogIntro =>
      'Affinché OzAlert possa svegliarti in tempo, devi configurare correttamente il telefono. Se il telefono è in modalità silenziosa o \'Non disturbare\', potresti perdere l\'apertura del visto.';

  @override
  String get dndDialogIosTitle => '🍏 Utenti iPhone (iOS)';

  @override
  String get dndDialogIosSteps =>
      '1. Vai su Impostazioni > OzAlert > Notifiche.\n2. Verifica che \'Consenti notifiche\' e \'Suoni\' siano attivi.\n3. Se usi le modalità \'Non disturbare\' o \'Riposo\', aggiungi OzAlert tra le app consentite.';

  @override
  String get dndDialogAndroidTitle => '🤖 Utenti Android';

  @override
  String get dndDialogAndroidSteps =>
      '1. Vai su Impostazioni > App > OzAlert > Notifiche.\n2. Tocca le categorie di notifica e imposta una suoneria forte.\n3. Se utilizzi la modalità \'Non disturbare\', aggiungi OzAlert come eccezione.';

  @override
  String get dndDialogClose => 'Ho capito';
}
