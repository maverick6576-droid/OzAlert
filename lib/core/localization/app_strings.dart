/// Centralized Multilingual Strings Dictionary for OzAlert
/// Supports 5 languages natively:
/// - es: Español
/// - en: English
/// - fr: Français
/// - it: Italiano
/// - zh: 中文 (Simplified Chinese)
class AppStrings {
  static String _cleanLang(String? lang) {
    if (lang == null) return 'en';
    final l = lang.toLowerCase();
    if (l.startsWith('es')) return 'es';
    if (l.startsWith('fr')) return 'fr';
    if (l.startsWith('it')) return 'it';
    if (l.startsWith('zh')) return 'zh';
    return 'en';
  }

  // ===========================================================================
  // 1. ONBOARDING & PHASE SELECTION
  // ===========================================================================
  static String phaseSelectionBadge(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'PASO FINAL: TU AVENTURA';
      case 'fr': return 'DERNIÈRE ÉTAPE : VOTRE AVENTURE';
      case 'it': return 'ULTIMO PASSO: LA TUA AVVENTURA';
      case 'zh': return '最后一步：开启你的澳洲旅程';
      case 'en':
      default: return 'FINAL STEP: YOUR JOURNEY';
    }
  }

  static String phaseSelectionTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '¿En qué momento te encuentras?';
      case 'fr': return 'Où en êtes-vous dans votre projet ?';
      case 'it': return 'A che punto sei con il tuo visto?';
      case 'zh': return '你目前处于哪个阶段？';
      case 'en':
      default: return 'Where are you in your visa journey?';
    }
  }

  static String phaseSelectionSubtitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es':
        return 'Selecciona cómo quieres empezar en OzAlert. Ambas fases son gratuitas y podrás alternar cuando quieras desde Ajustes.';
      case 'fr':
        return 'Choisissez votre expérience de départ. Les deux phases sont gratuites et modifiables à tout moment.';
      case 'it':
        return 'Scegli la tua esperienza iniziale. Entrambe le fasi sono gratuite e modificabili in qualsiasi momento.';
      case 'zh':
        return '选择你的初始体验。两个阶段均免费开放，你可以在设置中随时切换。';
      case 'en':
      default:
        return 'Select your starting experience. Both phases are 100% free and you can switch anytime from Settings.';
    }
  }

  static String phase1Badge(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '🟡 BUSCANDO O PREPARANDO VISADO';
      case 'fr': return '🟡 EN RECHERCHE OU PRÉPARATION';
      case 'it': return '🟡 IN CERCA O PREPARAZIONE VISTO';
      case 'zh': return '🟡 准备申请 / 蹲守名额';
      case 'en':
      default: return '🟡 LOOKING FOR VISA';
    }
  }

  static String phase1Title(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Fase 1: Radar de Cupos & Requisitos';
      case 'fr': return 'Phase 1 : Radar des Quotas & Checklist';
      case 'it': return 'Fase 1: Radar Quote & Requisiti';
      case 'zh': return '第一阶段：签证名额雷达与申请准备';
      case 'en':
      default: return 'Phase 1: Quota Radar & Prep';
    }
  }

  static String phase1Subtitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es':
        return 'Aún no tengo mi visado. Quiero vigilar la apertura de cupos en tiempo real y preparar mis documentos.';
      case 'fr':
        return 'Je n\'ai pas encore mon visa. Je veux surveiller l\'ouverture des quotas en direct et préparer mes documents.';
      case 'it':
        return 'Non ho ancora il visto. Voglio monitorare le quote in tempo reale e preparare i documenti.';
      case 'zh':
        return '我还没有签证。我想实时监控签证配额开放，并提前备齐申请材料。';
      case 'en':
      default:
        return 'I don\'t have my visa yet. I want to monitor country caps and prepare my application.';
    }
  }

  static List<String> phase1Features(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es':
        return [
          'Radar oficial de cupos de Inmigración 24/7',
          'Checklist interactivo de documentos y requisitos',
          'Guías paso a paso para solicitar en ImmiAccount',
        ];
      case 'fr':
        return [
          'Radar officiel des quotas de l\'Immigration 24/7',
          'Checklist interactive des documents et critères',
          'Guides pas à pas pour postuler sur ImmiAccount',
        ];
      case 'it':
        return [
          'Radar ufficiale quote Immigrazione 24/7',
          'Checklist interattiva di documenti e requisiti',
          'Guide passo passo per richiedere su ImmiAccount',
        ];
      case 'zh':
        return [
          '24/7 官方移民局签证配额监控雷达',
          '申请所需材料与资质交互式清单',
          'ImmiAccount 官方递签步骤全攻略',
        ];
      case 'en':
      default:
        return [
          '24/7 Official Immigration Quota Radar',
          'Interactive Step-by-Step Requirements Checklist',
          'Official ImmiAccount Application Guides',
        ];
    }
  }

  static String phase1Button(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Empezar en Fase 1 (Gratis)';
      case 'fr': return 'Commencer en Phase 1 (Gratuit)';
      case 'it': return 'Inizia in Fase 1 (Gratis)';
      case 'zh': return '开启第一阶段（免费）';
      case 'en':
      default: return 'Start in Phase 1 (Free)';
    }
  }

  static String phase2Badge(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '🟢 ¡YA TENGO MI VISADO CONCEDIDO!';
      case 'fr': return '🟢 VISA ACCORDÉ !';
      case 'it': return '🟢 VISTO CONCESSO!';
      case 'zh': return '🟢 签证已下签 / 已在澳洲';
      case 'en':
      default: return '🟢 VISA GRANTED';
    }
  }

  static String phase2Title(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Fase 2: Llegada a Australia & 88 Días';
      case 'fr': return 'Phase 2 : Arrivée en Australie & 88 Jours';
      case 'it': return 'Fase 2: Arrivo in Australia & 88 Giorni';
      case 'zh': return '第二阶段：抵澳指南与偏远地区工时';
      case 'en':
      default: return 'Phase 2: Australia Arrival & 88 Days';
    }
  }

  static String phase2Subtitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es':
        return '¡Ya tengo mi visado concedido! Viajo pronto o ya estoy viviendo en Australia.';
      case 'fr':
        return 'Mon visa est accordé ! Je pars bientôt ou je vis déjà en Australie.';
      case 'it':
        return 'Ho già il visto! Parto a breve o vivo già in Australia.';
      case 'zh':
        return '我的签证已下签！我即将出发或已经在澳洲境内生活。';
      case 'en':
      default:
        return 'I already have my visa! I am flying soon or already living in Australia.';
    }
  }

  static List<String> phase2Features(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es':
        return [
          'Checklist de aterrizaje (TFN, bancos, Medicare, SIM)',
          'Generador de CV en formato australiano y Cover Letter (PDF)',
          'Validador oficial de 88 días por código postal y Sueldo Fair Work',
        ];
      case 'fr':
        return [
          'Checklist d\'arrivée (TFN, banques, Medicare, carte SIM)',
          'Générateur de CV australien et lettre de motivation (PDF)',
          'Validation 88 jours par code postal et salaire Fair Work',
        ];
      case 'it':
        return [
          'Checklist d\'arrivo (TFN, banche, Medicare, SIM)',
          'Generatore di CV australiano e Cover Letter (PDF)',
          'Validatore ufficiale 88 giorni per codice postale e paga Fair Work',
        ];
      case 'zh':
        return [
          '抵澳48小时关键清单（TFN税号、开户、医保、SIM卡）',
          '澳洲招聘标准简历与求职信生成器（PDF）',
          '偏远地区邮编资格查询与 Fair Work 法定薪资计算器',
        ];
      case 'en':
      default:
        return [
          'Landing Checklist (TFN, Aussie Banks, Medicare, SIM)',
          'Aussie Standard CV & Cover Letter Generator (PDF)',
          '88-Day Regional Work Validator & Fair Work Calculator',
        ];
    }
  }

  static String phase2Button(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Empezar en Fase 2 (Gratis)';
      case 'fr': return 'Commencer en Phase 2 (Gratuit)';
      case 'it': return 'Inizia in Fase 2 (Gratis)';
      case 'zh': return '开启第二阶段（免费）';
      case 'en':
      default: return 'Start in Phase 2 (Free)';
    }
  }

  static String phaseSelectionFooter(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es':
        return 'Podrás alternar entre la Fase 1 y la Fase 2 en cualquier momento desde Ajustes o el Radar.';
      case 'fr':
        return 'Vous pouvez basculer facilement entre la Phase 1 et la Phase 2 à tout moment dans les Paramètres.';
      case 'it':
        return 'Puoi passare facilmente dalla Fase 1 alla Fase 2 in qualsiasi momento dalle Impostazioni.';
      case 'zh':
        return '你可以随时在“设置”或“雷达”页面中自由切换第一阶段和第二阶段。';
      case 'en':
      default:
        return 'You can easily switch back and forth between Phase 1 and Phase 2 anytime inside Settings.';
    }
  }

  // ===========================================================================
  // 2. PHASE 2 NAVIGATION & APP BAR
  // ===========================================================================
  static String navArrival(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Aterrizaje';
      case 'fr': return 'Arrivée';
      case 'it': return 'Arrivo';
      case 'zh': return '抵澳指南';
      case 'en':
      default: return 'Arrival';
    }
  }

  static String navGuides(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Guías';
      case 'fr': return 'Guides';
      case 'it': return 'Guide';
      case 'zh': return '实用攻略';
      case 'en':
      default: return 'Guides';
    }
  }

  static String navJobs(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Empleo';
      case 'fr': return 'Emploi';
      case 'it': return 'Lavoro';
      case 'zh': return '求职就业';
      case 'en':
      default: return 'Jobs';
    }
  }

  static String navRegional(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '88/179 Días';
      case 'fr': return '88/179 Jours';
      case 'it': return '88/179 Giorni';
      case 'zh': return '88/179天';
      case 'en':
      default: return '88/179 Days';
    }
  }

  static String officialSourcesTooltip(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Fuentes Oficiales y Marco Legal';
      case 'fr': return 'Sources Légales Officielles';
      case 'it': return 'Fonti Legali Ufficiali';
      case 'zh': return '官方权威法规来源';
      case 'en':
      default: return 'Official Legal Sources';
    }
  }

  static String settingsTooltip(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Ajustes';
      case 'fr': return 'Paramètres';
      case 'it': return 'Impostazioni';
      case 'zh': return '设置';
      case 'en':
      default: return 'Settings';
    }
  }

  // ===========================================================================
  // 3. PHASE 2: LANDING CHECKLIST SCREEN
  // ===========================================================================
  static String landingAppBarTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Guía de Aterrizaje';
      case 'fr': return 'Hub d\'Arrivée';
      case 'it': return 'Hub d\'Arrivo';
      case 'zh': return '抵澳全指南';
      case 'en':
      default: return 'Arrival Hub';
    }
  }

  static String stageTitle(String? lang, int index) {
    final clean = _cleanLang(lang);
    switch (index) {
      case 0:
        switch (clean) {
          case 'es': return '✈️ Pre-Vuelo';
          case 'fr': return '✈️ Avant le Départ';
          case 'it': return '✈️ Prima del Volo';
          case 'zh': return '✈️ 行前准备';
          default: return '✈️ Pre-Flight';
        }
      case 1:
        switch (clean) {
          case 'es': return '🧳 Llegada';
          case 'fr': return '🧳 Arrivée';
          case 'it': return '🧳 Arrivo';
          case 'zh': return '🧳 落地抵澳';
          default: return '🧳 Arrival';
        }
      case 2:
        switch (clean) {
          case 'es': return '🚜 88 Días (2ª Visa)';
          case 'fr': return '🚜 88 Jours (2e Visa)';
          case 'it': return '🚜 88 Giorni (2° Visto)';
          case 'zh': return '🚜 88天二签工时';
          default: return '🚜 88 Days (2nd Visa)';
        }
      case 3:
        switch (clean) {
          case 'es': return '🌾 179 Días (3ª Visa)';
          case 'fr': return '🌾 179 Jours (3e Visa)';
          case 'it': return '🌾 179 Giorni (3° Visto)';
          case 'zh': return '🌾 179天三签工时';
          default: return '🌾 179 Days (3rd Visa)';
        }
      case 4:
      default:
        switch (clean) {
          case 'es': return '🛫 Salida';
          case 'fr': return '🛫 Départ';
          case 'it': return '🛫 Partenza';
          case 'zh': return '🛫 离澳退税';
          default: return '🛫 Departure';
        }
    }
  }

  static String stageShortTitle(String? lang, int index) {
    final clean = _cleanLang(lang);
    switch (index) {
      case 0:
        switch (clean) {
          case 'es': return 'Pre-Vuelo';
          case 'fr': return 'Avant-Vol';
          case 'it': return 'Prima del Volo';
          case 'zh': return '行前准备';
          default: return 'Pre-Flight';
        }
      case 1:
        switch (clean) {
          case 'es': return 'Llegada';
          case 'fr': return 'Arrivée';
          case 'it': return 'Arrivo';
          case 'zh': return '落地抵澳';
          default: return 'Arrival';
        }
      case 2:
        switch (clean) {
          case 'es': return '88 Días';
          case 'fr': return '88 Jours';
          case 'it': return '88 Giorni';
          case 'zh': return '88天二签';
          default: return '88 Days';
        }
      case 3:
        switch (clean) {
          case 'es': return '179 Días';
          case 'fr': return '179 Jours';
          case 'it': return '179 Giorni';
          case 'zh': return '179天三签';
          default: return '179 Days';
        }
      case 4:
      default:
        switch (clean) {
          case 'es': return 'Salida';
          case 'fr': return 'Départ';
          case 'it': return 'Partenza';
          case 'zh': return '离境退税';
          default: return 'Departure';
        }
    }
  }

  static String stageSubtitle(String? lang, int index) {
    final clean = _cleanLang(lang);
    switch (index) {
      case 0:
        switch (clean) {
          case 'es': return 'Antes de despegar';
          case 'fr': return 'Avant l\'embarquement';
          case 'it': return 'Prima di partire';
          case 'zh': return '登机行前必办';
          default: return 'Before boarding';
        }
      case 1:
        switch (clean) {
          case 'es': return 'Primeros días';
          case 'fr': return 'Premières 48h & semaine';
          case 'it': return 'Prime 48 ore & settimana';
          case 'zh': return '落地48小时及首周';
          default: return 'First 48h & week';
        }
      case 2:
        switch (clean) {
          case 'es': return 'Trabajo regional 2º año';
          case 'fr': return 'Travail régional 2e année';
          case 'it': return 'Lavoro regionale 2° anno';
          case 'zh': return '偏远地区工时累积';
          default: return 'Regional work & 2nd year';
        }
      case 3:
        switch (clean) {
          case 'es': return '6 meses & 3r año';
          case 'fr': return '6 mois & 3e année';
          case 'it': return '6 mesi & 3° anno';
          case 'zh': return '累积6个月申请第三年';
          default: return '6 months & 3rd year';
        }
      case 4:
      default:
        switch (clean) {
          case 'es': return 'Recuperar dinero';
          case 'fr': return 'Récupérer son argent';
          case 'it': return 'Recupera denaro';
          case 'zh': return '申领养老金与退税';
          default: return 'Reclaim DASP & cash';
        }
    }
  }

  // ===========================================================================
  // 4. PHASE 2: GUIDES SCREEN THEMES & CATEGORIES
  // ===========================================================================
  static String guidesAppBarTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Guías Oficiales';
      case 'fr': return 'Guides Officiels';
      case 'it': return 'Guide Ufficiali';
      case 'zh': return '官方权威攻略';
      case 'en':
      default: return 'Official Guides';
    }
  }

  static String guideThemeTitle(String? lang, String themeId) {
    final clean = _cleanLang(lang);
    switch (themeId) {
      case 'arrival':
        switch (clean) {
          case 'es': return '🧳 1. Llegada y Trámites Iniciales';
          case 'fr': return '🧳 1. Arrivée & Démarches Essentielles';
          case 'it': return '🧳 1. Arrivo & Pratiche Essenziali';
          case 'zh': return '🧳 1. 抵澳与初期关键手续';
          default: return '🧳 1. Arrival & Essential Setup';
        }
      case 'employment':
      case 'work':
        switch (clean) {
          case 'es': return '💼 2. Empleo, Certificados y Derechos';
          case 'fr': return '💼 2. Emploi, Certificats & Droits';
          case 'it': return '💼 2. Lavoro, Certificati & Diritti';
          case 'zh': return '💼 2. 求职、上岗证书与法定权益';
          default: return '💼 2. Jobs, Certificates & Rights';
        }
      case 'tax_medicare':
        switch (clean) {
          case 'es': return '🏛️ 3. Hub Fiscal, Ahorro & Conducción';
          case 'fr': return '🏛️ 3. Pôle Fiscal, Épargne & Conduite';
          case 'it': return '🏛️ 3. Hub Fiscale, Risparmio & Guida';
          case 'zh': return '🏛️ 3. 税务、省钱与驾照出行';
          default: return '🏛️ 3. Tax Hub, Savings & Driving';
        }
      case 'regional_work':
      case 'visa_departure':
      default:
        switch (clean) {
          case 'es': return '🚜 4. Días Regionales (2º y 3r Año) & Salida';
          case 'fr': return '🚜 4. Travail Régional (88 & 179 Jours) & Départ';
          case 'it': return '🚜 4. Lavoro Regionale (88 & 179 Giorni) & Rientro';
          case 'zh': return '🚜 4. 偏远地区工时（88天/179天）与离澳';
          default: return '🚜 4. Regional Work (88 & 179 Days) & Exit';
        }
    }
  }

  static String guideCategoryLabel(String? lang, String categoryId) {
    final clean = _cleanLang(lang);
    switch (categoryId) {
      case 'banking':
        switch (clean) {
          case 'es': return '🏦 Bancos y Transferencias (Wise)';
          case 'fr': return '🏦 Banques & Transferts Wise';
          case 'it': return '🏦 Banche & Bonifici Wise';
          case 'zh': return '🏦 澳洲银行开户与 Wise 跨境汇款';
          default: return '🏦 Aussie Banks & Wise Transfers';
        }
      case 'telecom':
        switch (clean) {
          case 'es': return '📱 Tarjeta SIM y Telefonía Móvil';
          case 'fr': return '📱 Carte SIM & Téléphonie';
          case 'it': return '📱 Scheda SIM & Telefonia Mobile';
          case 'zh': return '📱 SIM卡与澳洲手机套餐';
          default: return '📱 SIM Card & Mobile Plans';
        }
      case 'housing':
        switch (clean) {
          case 'es': return '🏠 Alojamiento, Hostels y Fianza';
          case 'fr': return '🏠 Logement, Auberges & Caution';
          case 'it': return '🏠 Alloggio, Ostelli & Cauzione';
          case 'zh': return '🏠 抵澳初期住宿与租房押金';
          default: return '🏠 Housing, Hostels & Rental Bond';
        }
      case 'insurance':
        switch (clean) {
          case 'es': return '🩺 Seguro Médico (OVHC) y Salud';
          case 'fr': return '🩺 Assurance Santé & OVHC';
          case 'it': return '🩺 Assicurazione Sanitaria OVHC';
          case 'zh': return '🩺 医疗健康保险（OVHC）';
          default: return '🩺 Health Cover & OVHC Insurance';
        }
      case 'certifications':
      case 'white_card_rsa':
        switch (clean) {
          case 'es': return '📜 Certificados: White Card y RSA';
          case 'fr': return '📜 Certificats : White Card & RSA';
          case 'it': return '📜 Patentini: White Card & RSA';
          case 'zh': return '📜 上岗必备证书（白卡与RSA酒牌）';
          default: return '📜 Mandatory Tickets: White Card & RSA';
        }
      case 'tax':
      case 'tfn':
        switch (clean) {
          case 'es': return '🧾 Impuestos: TFN, ABN y Super (12%)';
          case 'fr': return '🧾 Fiscalité : TFN, ABN & Retraite (12%)';
          case 'it': return '🧾 Fisco: TFN, ABN & Pensione Super (12%)';
          case 'zh': return '🧾 澳洲税务：TFN、ABN 与养老金（12%）';
          default: return '🧾 Taxes: TFN, ABN & Super (12%)';
        }
      case 'savings':
      case 'discounts':
        switch (clean) {
          case 'es': return '💰 Hacks de Ahorro y Deducciones ATO';
          case 'fr': return '💰 Astuces Épargne & Déductions ATO';
          case 'it': return '💰 Trucchi di Risparmio & Deduzioni ATO';
          case 'zh': return '💰 省钱攻略与 ATO 税务抵扣技巧';
          default: return '💰 Money Hacks & ATO Deductions';
        }
      case 'international_license':
        switch (clean) {
          case 'es': return '🪪 Permiso Internacional (IDP) y NAATI';
          case 'fr': return '🪪 Permis International (IDP) & NAATI';
          case 'it': return '🪪 Patente Internazionale (IDP) & NAATI';
          case 'zh': return '🪪 国际驾照（IDP）与 NAATI 翻译认证';
          default: return '🪪 International Driving Permit & NAATI';
        }
      case 'australian_license':
      case 'vehicle':
        switch (clean) {
          case 'es': return '🚗 Carnet de Conducir Australiano';
          case 'fr': return '🚗 Permis de Conduire Australien';
          case 'it': return '🚗 Patente di Guida Australiana';
          case 'zh': return '🚗 换领澳洲本地驾照与18+身份证';
          default: return '🚗 Australian Driver Licence (State by State)';
        }
      case 'visa_renewal':
      case 'regional_88':
        switch (clean) {
          case 'es': return '🌾 88 Días: Extensión 2ª Visa';
          case 'fr': return '🌾 88 Jours : Renouvellement 2e Visa';
          case 'it': return '🌾 88 Giorni: Rinnovo 2° Anno Visto';
          case 'zh': return '🌾 88天偏远地区工时（二签续签）';
          default: return '🌾 88 Days: 2nd Year Visa Extension';
        }
      case 'visa_renewal_179':
      case 'regional_179':
        switch (clean) {
          case 'es': return '⭐ 179 Días: Extensión 3ª Visa (6 Meses)';
          case 'fr': return '⭐ 179 Jours : Renouvellement 3e Visa (6 Mois)';
          case 'it': return '⭐ 179 Giorni: Rinnovo 3° Anno Visto (6 Mesi)';
          case 'zh': return '⭐ 179天工时（三签续签，6个月）';
          default: return '⭐ 179 Days: 3rd Year Visa Extension (6 Months)';
        }
      case 'departure':
        switch (clean) {
          case 'es': return '🛫 Vuelta a Casa y Rescate de Super (DASP)';
          case 'fr': return '🛫 Retour & Récupération Super (DASP)';
          case 'it': return '🛫 Rientro a Casa & Rimborso Super (DASP)';
          case 'zh': return '🛫 离澳告别与养老金退款（DASP）';
          default: return '🛫 Departure & Super Claim (DASP)';
        }
      case 'job_search':
        switch (clean) {
          case 'es': return '🔍 Búsqueda de Empleo y Portales';
          case 'fr': return '🔍 Recherche d\'Emploi & Plateformes';
          case 'it': return '🔍 Ricerca Lavoro & Portali';
          case 'zh': return '🔍 求职平台与求职渠道';
          default: return '🔍 Job Search Platforms';
        }
      case 'cv_cover_letter':
        switch (clean) {
          case 'es': return '📄 CV Australiano y Cover Letter';
          case 'fr': return '📄 CV Australien & Lettre';
          case 'it': return '📄 CV Australiano & Cover Letter';
          case 'zh': return '📄 澳洲标准简历与求职信规范';
          default: return '📄 Aussie Resume & Cover Letter';
        }
      case 'fair_work':
        switch (clean) {
          case 'es': return '⚖️ Derechos Laborales (Fair Work)';
          case 'fr': return '⚖️ Droits du Travail (Fair Work)';
          case 'it': return '⚖️ Diritti dei Lavoratori Fair Work';
          case 'zh': return '⚖️ 劳工权益与 Fair Work 保护';
          default: return '⚖️ Fair Work & Worker Rights';
        }
      case 'superannuation':
        switch (clean) {
          case 'es': return '💰 Jubilación Australiana (Super)';
          case 'fr': return '💰 Retraite Australienne (Super)';
          case 'it': return '💰 Pensione Australiana (Super)';
          case 'zh': return '💰 澳洲法定养老金（Super）';
          default: return '💰 Superannuation (Super)';
        }
      case 'medicare':
        switch (clean) {
          case 'es': return '🏥 Exención 2% de Medicare';
          case 'fr': return '🏥 Exemption de la Taxe Medicare 2%';
          case 'it': return '🏥 Esenzione 2% Medicare Levy';
          case 'zh': return '🏥 Medicare 2% 医保免征申领';
          default: return '🏥 Medicare 2% Levy Exemption';
        }
      case 'tax_return':
        switch (clean) {
          case 'es': return '📊 Declaración Renta (Tax Return)';
          case 'fr': return '📊 Déclaration Fiscale Annuelle';
          case 'it': return '📊 Dichiarazione Redditi (Tax Return)';
          case 'zh': return '📊 年度个人退税（Tax Return）申报';
          default: return '📊 Annual Tax Return Lodge';
        }
      case 'form_1263':
        switch (clean) {
          case 'es': return '📝 Formulario 1263 y Nóminas';
          case 'fr': return '📝 Formulaire 1263 & Fiches de Paie';
          case 'it': return '📝 Modulo 1263 & Buste Paga';
          case 'zh': return '📝 1263 表格与薪资单证据';
          default: return '📝 Form 1263 & Payslips Proof';
        }
      default:
        switch (clean) {
          case 'es': return '📘 Guía Oficial de Trámite';
          case 'fr': return '📘 Guide Officiel';
          case 'it': return '📘 Guida Ufficiale';
          case 'zh': return '📘 官方办事指南';
          default: return '📘 Official Guide';
        }
    }
  }

  // ===========================================================================
  // 5. EMPLOYMENT HUB & REGIONAL WORK
  // ===========================================================================
  static String employmentAppBarTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Empleo & Formatos';
      case 'fr': return 'Emploi & Documents';
      case 'it': return 'Lavoro & Documenti';
      case 'zh': return '求职与核心文档';
      case 'en':
      default: return 'Jobs & Documents';
    }
  }

  static String tabResumeBuilder(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '📄 Generador CV';
      case 'fr': return '📄 Générateur CV';
      case 'it': return '📄 Generatore CV';
      case 'zh': return '📄 智能简历';
      case 'en':
      default: return '📄 Smart Resume';
    }
  }

  static String tabFairWork(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '💰 Calculadora Sueldo';
      case 'fr': return '💰 Calculateur Salaires';
      case 'it': return '💰 Calcolatore Stipendio';
      case 'zh': return '💰 法定薪资计算';
      case 'en':
      default: return '💰 Fair Work Pay';
    }
  }

  static String regionalAppBarTitle(String? lang, int year) {
    final clean = _cleanLang(lang);
    if (year == 3) {
      switch (clean) {
        case 'es': return '179 Días Regionales';
        case 'fr': return '179 Jours Régionaux';
        case 'it': return '179 Giorni Regionali';
        case 'zh': return '179天偏远地区工时';
        default: return '179 Days Regional';
      }
    } else {
      switch (clean) {
        case 'es': return '88 Días Regionales';
        case 'fr': return '88 Jours Régionaux';
        case 'it': return '88 Giorni Regionali';
        case 'zh': return '88天偏远地区工时';
        default: return '88 Days Regional';
      }
    }
  }

  static String tabPostcodeMap(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '📍 Mapa & Códigos';
      case 'fr': return '📍 Carte & Codes';
      case 'it': return '📍 Mappa & Codici';
      case 'zh': return '📍 邮编与地图';
      case 'en':
      default: return '📍 Postcode & Map';
    }
  }

  static String tabDaysLog(String? lang, int year, int totalDays, bool isPremium) {
    final prefix = year == 3 ? '179' : '88';
    final daysStr = isPremium ? '$totalDays/${year == 3 ? 179 : 88}' : '$totalDays/10';
    switch (_cleanLang(lang)) {
      case 'es': return '🗓️ $prefix Días ($daysStr)';
      case 'fr': return '🗓️ $prefix Jours ($daysStr)';
      case 'it': return '🗓️ $prefix Giorni ($daysStr)';
      case 'zh': return '🗓️ $prefix天 ($daysStr)';
      case 'en':
      default: return '🗓️ $prefix Days ($daysStr)';
    }
  }

  static String tabForm1263(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '📝 Form 1263 & Firma';
      case 'fr': return '📝 Form 1263 & Signature';
      case 'it': return '📝 Form 1263 & Firma';
      case 'zh': return '📝 1263表格与签名';
      case 'en':
      default: return '📝 Form 1263 & Sign';
    }
  }

  // ===========================================================================
  // 6. PHASE 1: CHECKLIST & VISA STATUS
  // ===========================================================================
  static String visaOpenNotification(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Notificación de Visado Abierto';
      case 'fr': return 'Notification de Visa Ouvert';
      case 'it': return 'Notifica Visto Aperto';
      case 'zh': return '名额开放即时推送';
      case 'en':
      default: return 'Visa Open Notification';
    }
  }

  static String subscribeProAlert(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Suscríbete como PRO para recibir la notificación al abrirse';
      case 'fr': return 'Abonnez-vous à PRO pour recevoir l\'alerte dès l\'ouverture';
      case 'it': return 'Abbonati a PRO per ricevere l\'avviso non appena si apre';
      case 'zh': return '订阅 PRO 会员即可在名额开放瞬间接收强提醒';
      case 'en':
      default: return 'Subscribe to PRO to receive instant alert when visa opens';
    }
  }

  static String visaNotificationActive(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Notificación de Visado Abierto Activa (Canal 24/7)';
      case 'fr': return 'Notification de Visa Ouvert Active (Canal 24/7)';
      case 'it': return 'Notifica Visto Aperto Attiva (Canale 24/7)';
      case 'zh': return '签证开放提醒已开启（24/7 专属通道）';
      case 'en':
      default: return 'Visa Open Notification Active (24/7 Channel)';
    }
  }

  static String paywallAlreadyGotVisa(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '¿Ya tienes tu visado o viajas pronto a Australia?';
      case 'fr': return 'Vous avez déjà votre visa ou partez bientôt en Australie ?';
      case 'it': return 'Hai già il visto o parti presto per l\'Australia?';
      case 'zh': return '已经拿到签证或即将前往澳大利亚？';
      case 'en':
      default: return 'Already got your visa or traveling soon to Australia?';
    }
  }

  static String paywallGoToPhase2(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Acceder a Fase 2: Llegada a Australia (Gratis)';
      case 'fr': return 'Accéder à la Phase 2 : Arrivée en Australie (Gratuit)';
      case 'it': return 'Accedi alla Fase 2: Arrivo in Australia (Gratis)';
      case 'zh': return '前往第二阶段：抵澳全指南（免费）';
      case 'en':
      default: return 'Go to Phase 2: Australia Arrival (Free)';
    }
  }

  // ===========================================================================
  // 7. TASK TITLES & SUBTITLES (PHASE 2 LANDING CHECKLIST)
  // ===========================================================================
  static String getTaskTitle(String? lang, String taskId, String defaultEs, String defaultEn) {
    final clean = _cleanLang(lang);
    if (clean == 'es') return defaultEs;
    if (clean == 'en') return defaultEn;

    switch (taskId) {
      case 'open_bank_account':
        switch (clean) {
          case 'fr': return 'Ouvrir un compte bancaire australien';
          case 'it': return 'Aprire conto bancario australiano';
          case 'zh': return '提前在线开立澳洲银行账户';
        }
        break;
      case 'medical_insurance':
        switch (clean) {
          case 'fr': return 'Souscrire une assurance voyage ou santé OVHC';
          case 'it': return 'Stipulare assicurazione sanitaria o OVHC';
          case 'zh': return '购买澳洲打工度假医疗健康险（OVHC）';
        }
        break;
      case 'book_initial_stay':
        switch (clean) {
          case 'fr': return 'Réserver une auberge ou hébergement initial';
          case 'it': return 'Prenotare ostello o alloggio iniziale';
          case 'zh': return '预订首站青旅或过渡住所';
        }
        break;
      case 'get_international_driving_permit':
        switch (clean) {
          case 'fr': return 'Obtenir un permis de conduire international';
          case 'it': return 'Ottenere patente internazionale di guida';
          case 'zh': return '办理国际驾照与官方翻译认证件';
        }
        break;
      case 'buy_sim_card':
        switch (clean) {
          case 'fr': return 'Acheter une SIM ou activer une eSIM australienne';
          case 'it': return 'Acquistare SIM o attivare eSIM australiana';
          case 'zh': return '办理澳洲当地电话卡（实体SIM或eSIM）';
        }
        break;
      case 'activate_bank_in_branch':
        switch (clean) {
          case 'fr': return 'Valider votre compte bancaire en agence';
          case 'it': return 'Attivare conto bancario in filiale';
          case 'zh': return '前往银行网点线下核身并领取银行卡';
        }
        break;
      case 'apply_tfn':
        switch (clean) {
          case 'fr': return 'Demander votre Tax File Number (TFN)';
          case 'it': return 'Richiedere il Tax File Number (TFN)';
          case 'zh': return '登录 ATO 官方系统申请个人税号（TFN）';
        }
        break;
      case 'apply_medicare_exemption':
        switch (clean) {
          case 'fr': return 'Demander l\'exemption de la taxe Medicare 2%';
          case 'it': return 'Richiedere esenzione Medicare Levy 2%';
          case 'zh': return '申请 Medicare 2% 医保免征退还信（MES）';
        }
        break;
      case 'prepare_aussie_cv':
        switch (clean) {
          case 'fr': return 'Créer votre CV et lettre au format australien';
          case 'it': return 'Creare CV australiano e lettera di presentazione';
          case 'zh': return '按照澳洲招聘规范生成标准英文简历与求职信';
        }
        break;
      case 'find_regional_job':
        switch (clean) {
          case 'fr': return 'Vérifier le code postal et emploi éligible';
          case 'it': return 'Verificare codice postale e lavoro regionale';
          case 'zh': return '查询偏远地区邮编资格与合规行业';
        }
        break;
      case 'log_88_days':
        switch (clean) {
          case 'fr': return 'Enregistrer vos journées et fiches de paie';
          case 'it': return 'Registrare giornate e buste paga (88/179)';
          case 'zh': return '逐笔登记偏远地区工时并归档薪资单';
        }
        break;
      case 'claim_dasp_super':
        switch (clean) {
          case 'fr': return 'Récupérer votre retraite (DASP) en partant';
          case 'it': return 'Recuperare la pensione (DASP) alla partenza';
          case 'zh': return '离澳回国后申请申领退回养老金（DASP）';
        }
        break;
      case 'lodge_tax_return':
        switch (clean) {
          case 'fr': return 'Déclarer vos impôts et maximiser le remboursement';
          case 'it': return 'Presentare Tax Return e recuperare ritenute';
          case 'zh': return '办理年度个人退税（Tax Return）并申领多缴税款';
        }
        break;
    }
    return defaultEn;
  }

  static String getTaskSubtitle(String? lang, String taskId, String defaultEs, String defaultEn) {
    final clean = _cleanLang(lang);
    if (clean == 'es') return defaultEs;
    if (clean == 'en') return defaultEn;

    switch (taskId) {
      case 'open_bank_account':
        switch (clean) {
          case 'fr': return 'Ouvrez-le en ligne jusqu\'à 14 jours avant le vol pour transférer vos premiers fonds via Wise sans frais.';
          case 'it': return 'Aprilo online fino a 14 giorni prima del volo per trasferire i tuoi risparmi tramite Wise senza commissioni.';
          case 'zh': return '行前14天内即可在线提交开户申请，落地后前往网点快速核验身份并激活实体卡。';
        }
        break;
      case 'medical_insurance':
        switch (clean) {
          case 'fr': return 'Une urgence médicale en Australie peut coûter plusieurs milliers de dollars sans couverture.';
          case 'it': return 'Le spese mediche in Australia possono ammontare a migliaia di dollari senza polizza.';
          case 'zh': return '澳洲救护车与住院自费极其昂贵，抵澳前备齐合规健康险可全面保障意外与工伤。';
        }
        break;
      case 'book_initial_stay':
        switch (clean) {
          case 'fr': return 'Réservez au moins 7 à 10 jours en auberge centrale pour vos démarches en personne.';
          case 'it': return 'Prenota almeno 7-10 giorni in ostello centrale per sbrigare le pratiche di persona.';
          case 'zh': return '建议提前预订市区交通便利青旅7-10天，便于就近跑银行网点与租房看房。';
        }
        break;
      case 'get_international_driving_permit':
        switch (clean) {
          case 'fr': return 'Obtenez votre permis international ou faites traduire votre permis par un traducteur NAATI.';
          case 'it': return 'Richiedi la patente internazionale o predisponi una traduzione certificata NAATI.';
          case 'zh': return '提前备齐驾照原件与符合各州交规的官方翻译件，以便在澳自驾、二手车过户及偏远地区通勤。';
        }
        break;
      case 'buy_sim_card':
        switch (clean) {
          case 'fr': return 'Vous aurez besoin d\'un numéro +61 pour votre banque, votre CV et votre demande de TFN.';
          case 'it': return 'Avrai bisogno di un numero +61 per la banca, il tuo CV e la richiesta del TFN.';
          case 'zh': return '尽快获取以+61开头的澳洲手机号码，这是激活银行账户、投递澳洲简历与申请TFN的刚需凭证。';
        }
        break;
      case 'activate_bank_in_branch':
        switch (clean) {
          case 'fr': return 'Rendez-vous dans une agence avec votre passeport pour récupérer votre carte bancaire.';
          case 'it': return 'Recati in una filiale con il passaporto per ritirare la tua carta di debito.';
          case 'zh': return '携带护照原件就近前往指定支行完成面对面身份核实，现场领取实体银行借记卡。';
        }
        break;
      case 'apply_tfn':
        switch (clean) {
          case 'fr': return 'Gratuit sur le site de l\'ATO dès votre arrivée en Australie pour éviter une retenue de 47%.';
          case 'it': return 'Gratuito sul sito dell\'ATO una volta in Australia per evitare la ritenuta al 47%.';
          case 'zh': return '入境澳洲后即可在税务局官网免费申请，有了税号雇主才不会按最高47%的顶格税率扣税。';
        }
        break;
      case 'apply_medicare_exemption':
        switch (clean) {
          case 'fr': return 'Récupérez 2% de vos revenus imposables en demandant une attestation MES si non éligible.';
          case 'it': return 'Se il tuo paese non ha accordi, risparmia il 2% del reddito richiedendo il certificato MES.';
          case 'zh': return '打工度假签证持有人由于不享受国民医保待遇，退税时凭该证明可免除2%全额医保附加税。';
        }
        break;
      case 'prepare_aussie_cv':
        switch (clean) {
          case 'fr': return 'Sans photo ni date de naissance, orienté compétences et concis (1-2 pages).';
          case 'it': return 'Senza foto, senza data di nascita, concentrato sui risultati (massimo 1-2 pagine).';
          case 'zh': return '澳洲求职严格禁止附带个人照片和出生年月，需突出相关经验、本地证书与求职信格式。';
        }
        break;
      case 'find_regional_job':
        switch (clean) {
          case 'fr': return 'Utilisez notre vérificateur de code postal pour confirmer l\'éligibilité de votre emploi.';
          case 'it': return 'Usa il nostro validatore prima di iniziare per assicurarti che il lavoro sia idoneo.';
          case 'zh': return '在入职前务必使用内置邮编雷达核对农场、款待或建筑业是否属于移民局指定偏远地区。';
        }
        break;
      case 'log_88_days':
        switch (clean) {
          case 'fr': return 'Conservez chaque fiche de paie et faites signer le Formulaire 1263 par votre employeur.';
          case 'it': return 'Conserva ogni busta paga e fai firmare il Modulo 1263 al tuo datore di lavoro.';
          case 'zh': return '实时记录工作天数并生成带电子签名的 1263 证明表格，是顺利二签或三签的最核心凭据。';
        }
        break;
      case 'claim_dasp_super':
        switch (clean) {
          case 'fr': return 'Récupérez vos cotisations de retraite une fois votre visa expiré et hors d\'Australie.';
          case 'it': return 'Richiedi il rimborso dei tuoi fondi pensione accumulati una volta scaduto il visto e fuori dal paese.';
          case 'zh': return '签证到期且永久离境澳洲后，可直接向税务局和养老金公司在线申请退回雇主缴纳的养老金。';
        }
        break;
      case 'lodge_tax_return':
        switch (clean) {
          case 'fr': return 'Déclarez vos revenus entre le 1er juillet et le 31 octobre pour récupérer le trop-perçu d\'impôts.';
          case 'it': return 'Presenta la dichiarazione tra il 1 luglio e il 31 ottobre per recuperare le imposte versate in eccesso.';
          case 'zh': return '每年7月1日至10月31日通过 myGov 关联 ATO 申报上一财年收入，依法申领多扣的个人所得税。';
        }
        break;
    }
    return defaultEn;
  }

  // ===========================================================================
  // 8. GUIDES SUB-TABS & DIRECTORY MODAL
  // ===========================================================================
  static String guideSubTab(String? lang, int index) {
    switch (_cleanLang(lang)) {
      case 'es':
        return index == 0 ? '📘 Pasos' : (index == 1 ? '⚖️ Comparar' : '🎁 Descuentos');
      case 'fr':
        return index == 0 ? '📘 Étapes' : (index == 1 ? '⚖️ Comparatif' : '🎁 Réductions');
      case 'it':
        return index == 0 ? '📘 Passaggi' : (index == 1 ? '⚖️ Confronta' : '🎁 Sconti');
      case 'zh':
        return index == 0 ? '📘 攻略步骤' : (index == 1 ? '⚖️ 服务对比' : '🎁 专属福利');
      case 'en':
      default:
        return index == 0 ? '📘 Steps' : (index == 1 ? '⚖️ Compare' : '🎁 Deals');
    }
  }

  static String guideStagePrefix(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'ETAPA: ';
      case 'fr': return 'ÉTAPE : ';
      case 'it': return 'TAPPA: ';
      case 'zh': return '阶段：';
      case 'en':
      default: return 'STAGE: ';
    }
  }

  static String guideAllTopics(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Ver todas (11)';
      case 'fr': return 'Voir tout (11)';
      case 'it': return 'Vedi tutte (11)';
      case 'zh': return '全部攻略 (11)';
      case 'en':
      default: return 'All (11)';
    }
  }

  static String guideActiveBadge(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'ACTIVA';
      case 'fr': return 'ACTIF';
      case 'it': return 'ATTIVA';
      case 'zh': return '当前查看';
      case 'en':
      default: return 'ACTIVE';
    }
  }

  static String guideDirectoryTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Catálogo de Guías & Revisiones';
      case 'fr': return 'Répertoire des Guides & Dossiers';
      case 'it': return 'Catalogo Guide & Approfondimenti';
      case 'zh': return '权威攻略与指南总览';
      case 'en':
      default: return 'Guides & Reviews Directory';
    }
  }

  static String guideDirectorySubtitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '11 temas esenciales ordenados por etapa de tu estancia';
      case 'fr': return '11 thèmes essentiels organisés par étape de votre voyage';
      case 'it': return '11 temi essenziali organizzati per tappa del tuo viaggio';
      case 'zh': return '按澳洲旅程不同阶段整理的11大核心实用指南';
      case 'en':
      default: return '11 essential topics organized by your journey stage';
    }
  }

  static String guideReturnChecklist(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Volver al checklist para marcar la tarea';
      case 'fr': return 'Retourner à la checklist pour valider l\'étape';
      case 'it': return 'Torna alla checklist per completare il passaggio';
      case 'zh': return '返回待办清单勾选已完成任务';
      case 'en':
      default: return 'Return to checklist to mark step done';
    }
  }

  static String guideComingSoon(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Información en preparación';
      case 'fr': return 'Informations bientôt disponibles';
      case 'it': return 'Informazioni presto disponibili';
      case 'zh': return '内容整理中，即将上线';
      case 'en':
      default: return 'Information coming soon';
    }
  }

  static String guideConsultLegal(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Consultar Normativa Oficial y Fuentes Legales';
      case 'fr': return 'Consulter les Réglementations Officielles';
      case 'it': return 'Consulta le Fonti Legali Ufficiali';
      case 'zh': return '查阅官方权威法规与法条依据';
      case 'en':
      default: return 'Consult Official Legal Regulations';
    }
  }

  static String guideCategoryDescription(String? lang, String catId) {
    final clean = _cleanLang(lang);
    switch (catId) {
      case 'banking':
        switch (clean) {
          case 'es': return 'Cuentas bancarias sin comisiones de apertura y transferencias con Wise.';
          case 'fr': return 'Comptes australiens sans frais et transferts Wise au taux réel.';
          case 'it': return 'Conti australiani a zero canone e bonifici Wise al tasso reale.';
          case 'zh': return '澳洲主流免年费银行账户开立，与极低汇损 Wise 跨境转账。';
          default: return 'Fee-free Australian bank accounts and low-spread Wise international transfers.';
        }
      case 'telecom':
        switch (clean) {
          case 'es': return 'Comparativa de cobertura entre Telstra, Optus y SIMs prepago.';
          case 'fr': return 'Couverture Telstra vs Optus, eSIM et forfaits prépayés pour arrivants.';
          case 'it': return 'Confronto copertura Telstra vs Optus, eSIM e piani prepagati.';
          case 'zh': return '澳洲 Telstra 与 Optus 信号覆盖对比，抵澳预付费卡与 eSIM。';
          default: return 'Telstra vs Optus mobile coverage, eSIMs and prepaid newcomer plans.';
        }
      case 'insurance':
        switch (clean) {
          case 'es': return 'Tarjeta Medicare gratuita (convenio RHCA) y seguros de salud.';
          case 'fr': return 'Carte Medicare gratuite (accords réciproques RHCA) et assurance OVHC.';
          case 'it': return 'Tessera Medicare gratuita (accordo bilaterale) e assicurazione OVHC.';
          case 'zh': return '互惠医疗协议（RHCA）与打工度假专项健康保险（OVHC）。';
          default: return 'Reciprocal Medicare free healthcare card and OVHC private insurance.';
        }
      case 'housing':
        switch (clean) {
          case 'es': return 'Buscar habitación en Flatmates, contratos e ingreso oficial de fianza.';
          case 'fr': return 'Trouver une chambre sur Flatmates, baux et dépôt de garantie officiel.';
          case 'it': return 'Trovare stanza su Flatmates, contratti e deposito cauzionale statale.';
          case 'zh': return 'Flatmates 租房技巧、防骗指南与官方押金（Bond）托管机制。';
          default: return 'Finding rooms on Flatmates, lease agreements and official state bond lodgement.';
        }
      case 'international_license':
        switch (clean) {
          case 'es': return 'Guía para todos los países: cómo sacar el Permiso Internacional (IDP) o traducción NAATI.';
          case 'fr': return 'Guide complet : Permis International (IDP) ou traduction NAATI officielle.';
          case 'it': return 'Guida completa: Patente Internazionale (IDP) o traduzione NAATI.';
          case 'zh': return '国际驾照（IDP）申办全流程与 NAATI 官方三级驾照翻译件认证。';
          default: return 'Country-by-country guide to get your International Driving Permit (IDP) or NAATI translation.';
        }
      case 'australian_license':
        switch (clean) {
          case 'es': return 'Canje por el carnet australiano en cada estado (NSW, VIC, QLD, WA) para tener ID local y conducir.';
          case 'fr': return 'Conversion de permis australien par État (NSW, VIC, QLD, WA) pour ID locale.';
          case 'it': return 'Conversione patente australiana per Stato (NSW, VIC, QLD, WA) come ID locale.';
          case 'zh': return '在各州（NSW、VIC、QLD、WA）直接换领澳洲驾照及18+身份证。';
          default: return 'Direct state licence conversion (Service NSW, VicRoads, TMR, DoT) for local +18 ID and driving.';
        }
      case 'tax':
        switch (clean) {
          case 'es': return 'Solicitud de TFN, ABN, retenciones IRPF y el 12% de Superannuation.';
          case 'fr': return 'Demande de TFN, ABN, retenues à la source et les 12% de retraite Super.';
          case 'it': return 'Richiesta TFN, ABN, scaglioni fiscali e il 12% di pensione Super.';
          case 'zh': return '个人税号 TFN、ABN 申请，所得税阶梯与 12% 雇主法定养老金。';
          default: return 'TFN & ABN registration, tax withholding rates and statutory 12% super.';
        }
      case 'certifications':
        switch (clean) {
          case 'es': return 'Cursos obligatorios oficiales: White Card de obra y RSA de hostelería.';
          case 'fr': return 'Certificats obligatoires : White Card pour le BTP et RSA pour l\'hôtellerie/bar.';
          case 'it': return 'Corsi obbligatori: White Card per l\'edilizia e RSA per ristorazione e bar.';
          case 'zh': return '法定上岗必修证书：建筑工地白卡（White Card）与餐饮酒牌（RSA）。';
          default: return 'Mandatory certificates: White Card for construction and state RSA for bar/cafe.';
        }
      case 'savings':
        switch (clean) {
          case 'es': return 'Estrategias y deducciones de impuestos ATO para ahorrar miles de dólares.';
          case 'fr': return 'Déductions fiscales ATO, bons plans courses et stratégies d\'économies massives.';
          case 'it': return 'Deduzioni fiscali ATO, trucchi per la spesa e strategie di risparmio massiccio.';
          case 'zh': return 'ATO 税务抵扣技巧、超市省钱秘籍与在澳省下数千澳元的财务攻略。';
          default: return 'ATO tax deduction tricks, grocery hacks and massive cash-saving strategies.';
        }
      case 'visa_renewal':
        switch (clean) {
          case 'es': return 'Requisitos para 2º y 3r año: 88 días regionales y expediente blindado.';
          case 'fr': return 'Critères pour la 2e année : 88 jours régionaux et dossier anti-contrôle.';
          case 'it': return 'Requisiti 2° anno: 88 giorni regionali e dossier a prova di verifica.';
          case 'zh': return '二签核心条件：88天偏远地区合规工时累积与防抽查证据链。';
          default: return '2nd year requirements: 88 regional days and audit-proof dossier.';
        }
      case 'visa_renewal_179':
        switch (clean) {
          case 'es': return 'Requisitos para el 3r año: 179 días regionales (6 meses) y Formulario 1263.';
          case 'fr': return 'Critères 3e année : 179 jours régionaux (6 mois) et Formulaire 1263.';
          case 'it': return 'Requisiti 3° anno: 179 giorni regionali (6 mesi) e Modulo 1263.';
          case 'zh': return '三签核心条件：179天偏远地区工时（6个月）与 1263 证明表格。';
          default: return '3rd year requirements: 179 regional days (6 months) and Form 1263.';
        }
      case 'departure':
      default:
        switch (clean) {
          case 'es': return 'Protocolo de salida: reclamar Superannuation (DASP), fianza e impuestos.';
          case 'fr': return 'Procédure de départ : réclamer la retraite DASP, récupérer la caution et taxes.';
          case 'it': return 'Protocollo di partenza: rimborso pensione DASP, cauzione e tasse anticipate.';
          case 'zh': return '离澳回国清算：申领退回养老金（DASP）、租房押金与离境退税。';
          default: return 'Exit checklist: DASP Superannuation refund, bond recovery and early tax return.';
        }
    }
  }

  // ===========================================================================
  // 9. MONEY AUDIT & CALCULATOR
  // ===========================================================================
  static String calcBannerTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Dinero en juego en Australia';
      case 'fr': return 'Argent en jeu en Australie';
      case 'it': return 'Denaro a rischio in Australia';
      case 'zh': return '在澳洲你可能损失或省下的资金';
      case 'en':
      default: return 'Money at Risk in Australia';
    }
  }

  static String calcBannerSubtitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Super, Fianza, Tax y Medicare';
      case 'fr': return 'Retraite, Caution, Impôts & Medicare';
      case 'it': return 'Pensione, Cauzione, Tasse & Medicare';
      case 'zh': return '涵盖养老金、租房押金、退税与医保';
      case 'en':
      default: return 'Super, Bond, Taxes & Medicare';
    }
  }

  static String calcAuditButton(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Auditar';
      case 'fr': return 'Auditer';
      case 'it': return 'Verifica';
      case 'zh': return '测算核对';
      case 'en':
      default: return 'Audit';
    }
  }

  static String calcModalTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Auditoría & Simulador de Dinero';
      case 'fr': return 'Audit & Simulateur Financier';
      case 'it': return 'Verifica & Simulatore Finanziario';
      case 'zh': return '资金风险核对与测算器';
      case 'en':
      default: return 'Money Audit & Simulator';
    }
  }

  static String calcTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '⚠️ Calculadora de Dinero en Juego';
      case 'fr': return '⚠️ Simulateur d\'Argent en Jeu';
      case 'it': return '⚠️ Calcolatore Denaro a Rischio';
      case 'zh': return '⚠️ 资金保障与挽回测算器';
      case 'en':
      default: return '⚠️ Money at Risk Calculator';
    }
  }

  static String calcSubtitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Dinero que se suele perder por desconocimiento';
      case 'fr': return 'Fonds souvent perdus par méconnaissance des règles';
      case 'it': return 'Denaro spesso perso per disinformazione';
      case 'zh': return 'WHV新手常因不了解法规而损失的真金白银';
      case 'en':
      default: return 'Cash often lost by WHV newcomers';
    }
  }

  static String calcTotalReclaimable(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'TOTAL RECLAMABLE / PROTEGIDO';
      case 'fr': return 'TOTAL RÉCUPÉRABLE / PROTÉGÉ';
      case 'it': return 'TOTALE RECUPERABILE / PROTETTO';
      case 'zh': return '可申领退回 / 依法保护的总金额';
      case 'en':
      default: return 'TOTAL RECLAIMABLE / SHIELDED';
    }
  }

  static String calcBasedOn(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Según las opciones marcadas debajo';
      case 'fr': return 'Selon les options sélectionnées ci-dessous';
      case 'it': return 'In base alle opzioni selezionate qui sotto';
      case 'zh': return '根据下方所勾选的个人实际情况';
      case 'en':
      default: return 'Based on your selected options';
    }
  }

  static String calcSelectSituations(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Marca tu situación para auditar tu caso:';
      case 'fr': return 'Sélectionnez votre situation pour calculer :';
      case 'it': return 'Seleziona la tua situazione per il calcolo:';
      case 'zh': return '勾选对应选项计算你的潜在收益：';
      case 'en':
      default: return 'Select your situations to calculate:';
    }
  }

  static String calcDaspTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'DASP: Devolución 12% Superannuation al salir';
      case 'fr': return 'DASP : Remboursement 12% retraite au départ';
      case 'it': return 'DASP: Rimborso 12% pensione alla partenza';
      case 'zh': return 'DASP：离澳时退回12%雇主缴纳的养老金';
      case 'en':
      default: return 'DASP: 12% Superannuation Exit Refund';
    }
  }

  static String calcBondTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Fianza blindada en organismo oficial estatal';
      case 'fr': return 'Caution sécurisée auprès de l\'organisme d\'État';
      case 'it': return 'Deposito cauzionale registrato presso l\'ente statale';
      case 'zh': return '押金依法存管于州政府官方租金托管机构';
      case 'en':
      default: return 'Official Bond Lodgement (Bond Board)';
    }
  }

  static String calcMedicareTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Medicare Recíproco (Médico GP público gratis)';
      case 'fr': return 'Medicare Réciproque (Médecin traitant public gratuit)';
      case 'it': return 'Medicare Reciproco (Visite mediche GP gratuite)';
      case 'zh': return '互惠医疗协议（公立诊所免费看诊）';
      case 'en':
      default: return 'Reciprocal Medicare (Free GP bulk-billing)';
    }
  }

  static String calcDeductBoots(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Deducciones ATO (Botas, cursos y ropa)';
      case 'fr': return 'Déductions ATO (Bottes, formations, tenue)';
      case 'it': return 'Deduzioni fiscali ATO (Scarpe, corsi, divisa)';
      case 'zh': return 'ATO抵税申报（工装鞋、考证与防护装备）';
      case 'en':
      default: return 'ATO Tax Deductions (Boots, gear, RSA)';
    }
  }

  static String calcEarlyTax(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Early Tax Return: Devolución IRPF anticipada';
      case 'fr': return 'Early Tax Return : Remboursement d\'impôt anticipé';
      case 'it': return 'Early Tax Return: Rimborso anticipato ritenute';
      case 'zh': return '提前离境退税：在7月前提前结算退回多缴税款';
      case 'en':
      default: return 'Early Tax Return: Claim withholdings before July';
    }
  }

  static String calcWiseTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Transferencia Wise: Evita el 4% de spread bancario';
      case 'fr': return 'Transfert Wise : Évitez les 4% de marge bancaire';
      case 'it': return 'Bonifico Wise: Evita il 4% di spread bancario';
      case 'zh': return '使用Wise汇款：免除传统银行高达4%的隐形汇差';
      case 'en':
      default: return 'Wise Transfer: Avoid 4% hidden bank SWIFT markup';
    }
  }

  static String calcProTip(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Las guías Pro te explican con precisión cómo blindar y recuperar cada dólar.';
      case 'fr': return 'Les guides Pro vous expliquent comment sécuriser et récupérer chaque dollar.';
      case 'it': return 'Le guide Pro ti spiegano esattamente come tutelare e recuperare ogni dollaro.';
      case 'zh': return 'Pro会员攻略将手把手带你依法维权，全额拿回属于你的每一分钱。';
      case 'en':
      default: return 'Pro guides explain exactly how to claim and shield every single dollar.';
    }
  }

  static String calcConsultOfficial(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Consultar Fuentes Oficiales (ATO e Inmigración)';
      case 'fr': return 'Consulter les Sources Officielles (ATO & Immigration)';
      case 'it': return 'Consulta le Fonti Ufficiali (ATO & Immigrazione)';
      case 'zh': return '查阅官方权威法规（税局ATO与移民局）';
      case 'en':
      default: return 'Consult Official Sources (ATO & Home Affairs)';
    }
  }

  static String compBestFor(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'IDEAL PARA:';
      case 'fr': return 'IDÉAL POUR :';
      case 'it': return 'IDEALE PER:';
      case 'zh': return '最适合人群：';
      case 'en':
      default: return 'BEST FOR:';
    }
  }

  static String compStrengths(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'PUNTOS FUERTES:';
      case 'fr': return 'POINTS FORTS :';
      case 'it': return 'PUNTI DI FORZA:';
      case 'zh': return '核心优势：';
      case 'en':
      default: return 'STRENGTHS:';
    }
  }

  static String compWeaknesses(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'A TENER EN CUENTA:';
      case 'fr': return 'POINTS FAIBLES :';
      case 'it': return 'PUNTI DEBOLI:';
      case 'zh': return '潜在短板：';
      case 'en':
      default: return 'WEAKNESSES:';
    }
  }

  static String compVerdict(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'VEREDICTO OZALERT:';
      case 'fr': return 'VERDICT OZALERT :';
      case 'it': return 'VERDETTO OZALERT:';
      case 'zh': return 'OZALERT 综合评价：';
      case 'en':
      default: return 'OZALERT VERDICT:';
    }
  }

  static String dealsExclusiveTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Próximamente: Acuerdos y Descuentos Exclusivos';
      case 'fr': return 'Bientôt : Accords & Réductions Exclusives';
      case 'it': return 'Prossimamente: Accordi & Sconti Esclusivi';
      case 'zh': return '敬请期待：OzAlert 独家商务合作与福利折扣';
      case 'en':
      default: return 'Coming Soon: Exclusive Deals & Partnerships';
    }
  }

  static String dealsExclusiveSubtitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Estamos negociando acuerdos directos con los mejores partners australianos para la comunidad OzAlert.';
      case 'fr': return 'Nous négocions des accords directs avec les meilleurs partenaires australiens pour la communauté OzAlert.';
      case 'it': return 'Stiamo negoziando accordi diretti con i migliori partner australiani per la community OzAlert.';
      case 'zh': return '我们正与澳洲本土优质服务商洽谈独家专属协议，为 OzAlert 社区用户争取最大优惠与保障。';
      case 'en':
      default: return 'We are currently negotiating direct partnerships and deals with premier Australian partners for the OzAlert community.';
    }
  }

  // ===========================================================================
  // 10. APP SETTINGS & PHASE SWITCH
  // ===========================================================================
  static String appPhaseTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Fase de la aplicación';
      case 'fr': return 'Phase de l\'application';
      case 'it': return 'Fase dell\'applicazione';
      case 'zh': return '应用阶段体验';
      case 'en':
      default: return 'App Phase';
    }
  }

  static String switchToPhase2Tile(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Pasar a la Fase 2 (¡Ya tengo mi visado!)';
      case 'fr': return 'Passer en Phase 2 (Visa accordé !)';
      case 'it': return 'Passa alla Fase 2 (Ho il visto!)';
      case 'zh': return '切换至第二阶段（签证已下签！）';
      case 'en':
      default: return 'Switch to Phase 2 (I got my visa!)';
    }
  }

  static String switchToPhase2Subtitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Desbloquea Checklist de Aterrizaje, Guías en Australia, 88 Días, Sueldo y CV';
      case 'fr': return 'Débloquez la Checklist d\'Arrivée, Guides, 88 Jours, Salaire et CV';
      case 'it': return 'Sblocca Checklist d\'Arrivo, Guide, 88 Giorni, Calcolo Stipendio e CV';
      case 'zh': return '解锁抵澳待办、实用攻略、88天偏远地区工时、法定薪资与简历';
      case 'en':
      default: return 'Unlock Arrival Checklist, Guides, 88-Day Validator, Pay Calculator & Aussie CV';
    }
  }

  static String returnToPhase1Tile(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Volver a Fase 1 (Radar de Visados)';
      case 'fr': return 'Retourner en Phase 1 (Radar des Visas)';
      case 'it': return 'Torna alla Fase 1 (Radar Visti)';
      case 'zh': return '返回第一阶段（签证名额雷达）';
      case 'en':
      default: return 'Return to Phase 1 (Visa Radar)';
    }
  }

  static String returnToPhase1Subtitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Consultar el radar de cupos y las guías de solicitud del visado';
      case 'fr': return 'Consulter le radar des quotas et les guides de demande de visa';
      case 'it': return 'Consulta il radar delle quote e le guide per la richiesta del visto';
      case 'zh': return '监控移民局签证名额并查阅签证申请材料清单';
      case 'en':
      default: return 'Check open quota spots and visa application guides';
    }
  }

  static String switchToPhase2DialogTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '¿Pasar a la Fase 2? 🎉';
      case 'fr': return 'Passer en Phase 2 ? 🎉';
      case 'it': return 'Passare alla Fase 2? 🎉';
      case 'zh': return '切换至第二阶段？🎉';
      case 'en':
      default: return 'Switch to Phase 2! 🎉';
    }
  }

  static String switchToPhase2DialogContent(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Al pasar a la Fase 2, accederás al Checklist de Aterrizaje en Australia, Guías paso a paso, Validador de los 88 días, Calculadora de Sueldo Fair Work y generador de CV australiano. Además, apagaremos las alarmas push de apertura de cupos.';
      case 'fr': return 'En passant en Phase 2, vous débloquerez la Checklist d\'arrivée en Australie, les guides pas à pas, le validateur 88 jours, le calculateur Fair Work et le créateur de CV australien. Les alertes de quotas seront désactivées.';
      case 'it': return 'Passando alla Fase 2, sbloccherai la Checklist d\'arrivo in Australia, le guide dettagliate, il validatore 88 giorni, il calcolatore Fair Work e il generatore di CV australiano. Gli allarmi quote saranno disattivati.';
      case 'zh': return '切换至第二阶段后，你将解锁抵澳48小时待办、实用攻略、88天偏远地区工时核算、Fair Work 法定薪资计算器与澳洲标准简历生成器，同时关闭名额强提醒。';
      case 'en':
      default: return 'By switching to Phase 2, you will unlock the Australia Arrival Checklist, Step-by-Step Guides, 88-Day Regional Validator, Fair Work Pay Calculator, and Aussie CV Maker. Quota push alerts will be turned off.';
    }
  }

  static String returnToPhase1DialogTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '¿Volver al Buscador de Visa?';
      case 'fr': return 'Retourner à la recherche de visa ?';
      case 'it': return 'Tornare alla ricerca del visto?';
      case 'zh': return '返回签证蹲守模式？';
      case 'en':
      default: return 'Return to Visa Search?';
    }
  }

  static String returnToPhase1DialogContent(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Tu pantalla volverá al Radar de cupos de la Fase 1. Podrás volver a la Fase 2 en cualquier momento.';
      case 'fr': return 'Votre écran reviendra au Radar des quotas de la Phase 1. Vous pourrez revenir en Phase 2 à tout moment.';
      case 'it': return 'La tua schermata tornerà al Radar delle quote della Fase 1. Potrai tornare alla Fase 2 in qualsiasi momento.';
      case 'zh': return '应用界面将切回第一阶段配额监控雷达。你可以随时再次切换回第二阶段。';
      case 'en':
      default: return 'Your interface will switch back to Phase 1 (Quota Radar). You can return to Phase 2 at any time.';
    }
  }

  static String enterPhase2Button(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Entrar a la Fase 2';
      case 'fr': return 'Accéder à la Phase 2';
      case 'it': return 'Entra in Fase 2';
      case 'zh': return '进入第二阶段';
      case 'en':
      default: return 'Enter Phase 2';
    }
  }

  static String switchPhase1Button(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Cambiar a Fase 1';
      case 'fr': return 'Basculer en Phase 1';
      case 'it': return 'Passa a Fase 1';
      case 'zh': return '切回第一阶段';
      case 'en':
      default: return 'Switch to Phase 1';
    }
  }

  static String cancelButton(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Cancelar';
      case 'fr': return 'Annuler';
      case 'it': return 'Annulla';
      case 'zh': return '取消';
      case 'en':
      default: return 'Cancel';
    }
  }

  // ===========================================================================
  // 11. DOCUMENT SUITE (EMPLOYMENT HUB)
  // ===========================================================================
  static String docSuiteTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Suite Documental de Australia';
      case 'fr': return 'Suite Documentaire Australie';
      case 'it': return 'Suite Documenti Australiani';
      case 'zh': return '澳洲职场与生活核心文书套件';
      case 'en':
      default: return 'Australian Document Suite';
    }
  }

  static String docSuiteSubtitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Selecciona una herramienta para configurar y exportar documentos PDF con formato oficial.';
      case 'fr': return 'Sélectionnez un document à configurer et exporter au format PDF officiel.';
      case 'it': return 'Seleziona uno strumento per configurare ed esportare documenti PDF ufficiali.';
      case 'zh': return '选择文书工具在线配置，一键生成符合本地招聘与法律规范的官方PDF。';
      case 'en':
      default: return 'Select a tool to configure and export recruiter-ready & legally compliant PDF documents.';
    }
  }

  static String docConfigure(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Configurar';
      case 'fr': return 'Configurer';
      case 'it': return 'Configura';
      case 'zh': return '在线配置';
      case 'en':
      default: return 'Configure';
    }
  }

  static String docModalTitle(String? lang, String docId) {
    final clean = _cleanLang(lang);
    switch (docId) {
      case 'resume':
        switch (clean) {
          case 'es': return 'Currículum Australiano (ATS)';
          case 'fr': return 'CV Australien (ATS)';
          case 'it': return 'CV Australiano (ATS)';
          case 'zh': return '澳洲标准英文简历（ATS友好）';
          default: return 'Australian Resume (ATS)';
        }
      case 'cover_letter':
        switch (clean) {
          case 'es': return 'Cover Letter Australiana';
          case 'fr': return 'Lettre de Motivation (Cover Letter)';
          case 'it': return 'Cover Letter Australiana';
          case 'zh': return '澳洲求职自荐信（Cover Letter）';
          default: return 'Australian Cover Letter';
        }
      case 'rental_bio':
        switch (clean) {
          case 'es': return 'Perfil de Alquiler en Australia';
          case 'fr': return 'Profil de Location & Colocation';
          case 'it': return 'Profilo Affitto & Coinquilini';
          case 'zh': return '澳洲租房求租与室友介绍档案';
          default: return 'Rental & Flatmate Bio';
        }
      case 'fair_work_claim':
        switch (clean) {
          case 'es': return 'Reclamación Salarial Fair Work';
          case 'fr': return 'Réclamation Salariale Fair Work';
          case 'it': return 'Reclamo Salariale Fair Work';
          case 'zh': return 'Fair Work 欠薪与少缴法定追索函';
          default: return 'Fair Work Formal Claim';
        }
      case 'resignation':
        switch (clean) {
          case 'es': return 'Carta de Renuncia (2 Semanas)';
          case 'fr': return 'Lettre de Démission (Préavis 2 Semaines)';
          case 'it': return 'Lettera di Dimissioni (2 Settimane)';
          case 'zh': return '澳洲法定2周提前辞职信（获好评凭证）';
          default: return '2-Week Resignation Letter';
        }
      case 'rental_bond':
        switch (clean) {
          case 'es': return 'Recibo Legal de Fianza (Share-House)';
          case 'fr': return 'Reçu de Caution Officiel (Share-House)';
          case 'it': return 'Ricevuta Cauzione Legale (Share-House)';
          case 'zh': return '合租租房押金法律收据凭证';
          default: return 'Rental Bond Receipt & Shield';
        }
      case 'vehicle_sale':
        switch (clean) {
          case 'es': return 'Contrato Compraventa Coche/Camper';
          case 'fr': return 'Contrat de Vente Véhicule / Van';
          case 'it': return 'Contratto Compravendita Auto / Camper';
          case 'zh': return '二手车/露营车中英文双语买卖合同';
          default: return 'Vehicle & Camper Bill of Sale';
        }
      case 'condition_8547':
      default:
        switch (clean) {
          case 'es': return 'Memorando Exención Condición 8547';
          case 'fr': return 'Mémorandum Exemption Condition 8547';
          case 'it': return 'Memorandum Esenzione Condizione 8547';
          case 'zh': return '8547条款工作超6个月免除备忘录';
          default: return 'Condition 8547 Exemption Memo';
        }
    }
  }

  // ===========================================================================
  // 12. REGIONAL WORK HEADERS & POSTCODE
  // ===========================================================================
  static String regionalWhyCheckTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '¿Por qué comprobar el código postal?';
      case 'fr': return 'Pourquoi vérifier le code postal ?';
      case 'it': return 'Perché verificare il codice postale?';
      case 'zh': return '为什么必须在入职前核对邮编？';
      case 'en':
      default: return 'Why check the postcode?';
    }
  }

  static String regionalWhyCheckDesc(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Inmigración rechaza las solicitudes de 2ª o 3ª visa si el código postal no está en la lista oficial de zonas regionales.';
      case 'fr': return 'L\'Immigration refuse les visas si le code postal du travail n\'est pas dans la liste officielle des zones régionales éligibles.';
      case 'it': return 'L\'Immigrazione rifiuta le domande di rinnovo se il codice postale non rientra nell\'elenco ufficiale delle aree regionali idonee.';
      case 'zh': return '澳洲移民局对偏远地区二签三签审查极其严格，若工作地邮编不在官方指定区域，全部工时将被直接作废。';
      case 'en':
      default: return 'Home Affairs rejects 2nd and 3rd visa renewals if the work postcode is not on the official regional eligible list.';
    }
  }

  // ===========================================================================
  // 13. PHASE 1 CHECKLIST SCREEN
  // ===========================================================================
  static String checklistMainTabChecklist(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Checklist de Visado';
      case 'fr': return 'Checklist de Visa';
      case 'it': return 'Checklist Visto';
      case 'zh': return '签证申请清单';
      case 'en':
      default: return 'Visa Checklist';
    }
  }

  static String checklistMainTabGuides(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Guías de Solicitud';
      case 'fr': return 'Guides de Demande';
      case 'it': return 'Guide di Richiesta';
      case 'zh': return '递签全攻略';
      case 'en':
      default: return 'Application Guides';
    }
  }

  static String checklistGuideThemeTitle(String? lang, String themeId) {
    final clean = _cleanLang(lang);
    switch (themeId) {
      case 'preparation':
        switch (clean) {
          case 'es': return '🛂 1. Cuenta, Identidad y Elegibilidad';
          case 'fr': return '🛂 1. Compte, Identité & Éligibilité';
          case 'it': return '🛂 1. Account, Identità & Idoneità';
          case 'zh': return '🛂 1. 账户、身份与申请资格';
          default: return '🛂 1. Account, Identity & Eligibility';
        }
      case 'academic_english':
        switch (clean) {
          case 'es': return '🎓 2. Inglés y Requisitos de Estudios';
          case 'fr': return '🎓 2. Anglais & Critères d\'Études';
          case 'it': return '🎓 2. Inglese & Requisiti di Studio';
          case 'zh': return '🎓 2. 英语成绩与学历资质';
          default: return '🎓 2. English & Education Requirements';
        }
      case 'funds_legal':
      default:
        switch (clean) {
          case 'es': return '🏦 3. Fondos, Antecedentes y Traducciones';
          case 'fr': return '🏦 3. Fonds, Casier & Traductions';
          case 'it': return '🏦 3. Fondi, Casellario & Traduzioni';
          case 'zh': return '🏦 3. 资金证明、无犯罪与翻译件';
          default: return '🏦 3. Funds, Police Check & Translations';
        }
    }
  }

  static String checklistGuideCategoryLabel(String? lang, String categoryId) {
    final clean = _cleanLang(lang);
    switch (categoryId) {
      case 'immiaccount_apply':
        switch (clean) {
          case 'es': return '💻 Solicitud en ImmiAccount Paso a Paso';
          case 'fr': return '💻 Demande sur ImmiAccount Étape par Étape';
          case 'it': return '💻 Domanda su ImmiAccount Passo dopo Passo';
          case 'zh': return '💻 ImmiAccount 官方递签步骤全攻略';
          default: return '💻 ImmiAccount Step-by-Step Application';
        }
      case 'identity_documents':
        switch (clean) {
          case 'es': return '🛂 Pasaporte y Documentos de Identidad';
          case 'fr': return '🛂 Passeport & Documents d\'Identité';
          case 'it': return '🛂 Passaporto & Documenti d\'Identità';
          case 'zh': return '🛂 护照与个人身份证明材料';
          default: return '🛂 Passport & Identity Documents';
        }
      case 'english_language':
        switch (clean) {
          case 'es': return '🗣️ Nivel de Inglés (PTE, IELTS, TOEFL, CAE)';
          case 'fr': return '🗣️ Niveau d\'Anglais (PTE, IELTS, TOEFL, CAE)';
          case 'it': return '🗣️ Livello d\'Inglese (PTE, IELTS, TOEFL, CAE)';
          case 'zh': return '🗣️ 英语水平考试（PTE、雅思、托福、CAE）';
          default: return '🗣️ Functional English (PTE, IELTS, TOEFL, CAE)';
        }
      case 'education':
        switch (clean) {
          case 'es': return '🎓 Títulos y Estudios Exigidos por País';
          case 'fr': return '🎓 Diplômes Requis par Pays';
          case 'it': return '🎓 Titoli di Studio Richiesti per Paese';
          case 'zh': return '🎓 各国学历与在读证明要求';
          default: return '🎓 Education Requirements by Country';
        }
      case 'enough_money':
        switch (clean) {
          case 'es': return '💰 Demostrar Fondos (\$5.000 AUD + Vuelo)';
          case 'fr': return '💰 Justificatif de Fonds (5 000 \$ AUD + Billet)';
          case 'it': return '💰 Dimostrazione Fondi (\$5.000 AUD + Volo)';
          case 'zh': return '💰 资金存款证明（5000澳元+返程机票）';
          default: return '💰 Proof of Funds (\$5,000 AUD + Flight)';
        }
      case 'character_health':
        switch (clean) {
          case 'es': return '🛡️ Antecedentes Penales y Exámenes Médicos';
          case 'fr': return '🛡️ Casier Judiciaire & Visite Médicale';
          case 'it': return '🛡️ Certificati Penali & Visite Mediche';
          case 'zh': return '🛡️ 无犯罪公证书与出国体检';
          default: return '🛡️ Police Certificates & Health Exams';
        }
      case 'translations_support':
      default:
        switch (clean) {
          case 'es': return '📑 Traducciones Oficiales, Carta de Apoyo y 956A';
          case 'fr': return '📑 Traductions Officielles, Lettre d\'Appui & 956A';
          case 'it': return '📑 Traduzioni Ufficiali, Lettera & Modulo 956A';
          case 'zh': return '📑 官方翻译认证、政府支持信与956A表';
          default: return '📑 Official Translations, Gov Letter & Form 956A';
        }
    }
  }

  // ===========================================================================
  // 14. VISA PRO ALERTS & NOTIFICATIONS
  // ===========================================================================
  static String instantVisaAlertTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Notificación de Visado Abierto 🔔';
      case 'fr': return 'Notification de Visa Ouvert 🔔';
      case 'it': return 'Notifica Visto Aperto 🔔';
      case 'zh': return '名额开放即时推送强提醒 🔔';
      case 'en':
      default: return 'Instant Visa Open Notification 🔔';
    }
  }

  static String instantVisaAlertBenefit(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es':
        return 'Suscríbete a OzAlert Pro para activar el canal de notificaciones 24/7 con alarma sonora en el segundo exacto en que Inmigración abra plazas para tu pasaporte.';
      case 'fr':
        return 'Abonnez-vous à OzAlert Pro pour activer le canal d\'alerte 24/7 avec alarme sonore dès l\'ouverture des quotas par l\'Immigration.';
      case 'it':
        return 'Abbonati a OzAlert Pro per attivare il canale notifiche 24/7 con allarme sonoro nel secondo esatto in cui aprono i posti per il tuo paese.';
      case 'zh':
        return '订阅 OzAlert Pro 即可激活 24/7 紧急推送通道，在澳洲移民局开放该国签证名额的第一秒响铃强提醒，确保抢先抢占席位。';
      case 'en':
      default:
        return 'Subscribe to OzAlert Pro to unlock the 24/7 emergency notification channel with sound alarm the exact second Immigration opens quota spots for your passport.';
    }
  }

  // ===========================================================================
  // 15. PAYWALL & MONETIZATION
  // ===========================================================================
  static String paywallFullProAccess(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Acceso Completo OzAlert Pro';
      case 'fr': return 'Accès Complet OzAlert Pro';
      case 'it': return 'Accesso Completo OzAlert Pro';
      case 'zh': return '全能解锁 OzAlert Pro';
      case 'en':
      default: return 'Full OzAlert Pro Access';
    }
  }

  static String paywallFullProDesc(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Alertas 24/7 de Visado Abierto, CVs en PDF, comprobar nóminas y Form 1263';
      case 'fr': return 'Alertes 24/7 d\'ouverture de visa, CV en PDF, vérification de fiches de paie & Form 1263';
      case 'it': return 'Avvisi 24/7 apertura visti, CV in PDF illimitati, buste paga e Form 1263';
      case 'zh': return '24/7 签证配额秒级报警、无限次生成澳洲 PDF 简历、薪资流水验算及 Form 1263 签名导出';
      case 'en':
      default: return '24/7 Visa Open Alerts, unlimited PDF CVs, payslip checks & Form 1263';
    }
  }

  static String paywallUnlockPriceMonthly(String? lang, String price) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Desbloquear por $price / mes';
      case 'fr': return 'Débloquer pour $price / mois';
      case 'it': return 'Sblocca a $price / mese';
      case 'zh': return '以 $price / 月立即解锁';
      case 'en':
      default: return 'Unlock for $price / month';
    }
  }

  static String paywallWelcomePro(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '¡Bienvenido a OzAlert Pro! Todas las funciones están desbloqueadas.';
      case 'fr': return 'Bienvenue sur OzAlert Pro ! Toutes les fonctionnalités sont débloquées.';
      case 'it': return 'Benvenuto su OzAlert Pro! Tutte le funzioni sono sbloccate.';
      case 'zh': return '欢迎加入 OzAlert Pro！所有尊贵功能已全面解锁。';
      case 'en':
      default: return 'Welcome to OzAlert Pro! All features unlocked.';
    }
  }

  static String paywallRestorePrevious(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Restaurar compras previas';
      case 'fr': return 'Restaurer mes achats';
      case 'it': return 'Ripristina acquisti precedenti';
      case 'zh': return '恢复已购买订阅';
      case 'en':
      default: return 'Restore previous purchases';
    }
  }

  static String paywallPerMonth(String? lang, String price) {
    switch (_cleanLang(lang)) {
      case 'es': return '$price/mes';
      case 'fr': return '$price/mois';
      case 'it': return '$price/mese';
      case 'zh': return '$price/月';
      case 'en':
      default: return '$price/mo';
    }
  }

  // ===========================================================================
  // 16. DASHBOARD CARDS & TRANSITIONS
  // ===========================================================================
  static String dashboardPhase2NextStep(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'SIGUIENTE PASO • FASE 2';
      case 'fr': return 'ÉTAPE SUIVANTE • PHASE 2';
      case 'it': return 'PROSSIMO PASSO • FASE 2';
      case 'zh': return '下一步规划 • 第二阶段';
      case 'en':
      default: return 'NEXT STEP • PHASE 2';
    }
  }

  static String dashboardAlreadyGotVisa(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '¿Ya tienes el visado? ¡Pasa a la Fase 2!';
      case 'fr': return 'Visa déjà accordé ? Passez en Phase 2 !';
      case 'it': return 'Hai già il visto? Passa alla Fase 2!';
      case 'zh': return '已经拿到签证？立即开启第二阶段！';
      case 'en':
      default: return 'Already got your visa? Switch to Phase 2!';
    }
  }

  static String dashboardTapToEnterPhase2(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Pulsar aquí para pasar a la Fase 2';
      case 'fr': return 'Appuyez ici pour entrer en Phase 2';
      case 'it': return 'Tocca qui per passare alla Fase 2';
      case 'zh': return '点击此处直接进入第二阶段';
      case 'en':
      default: return 'Tap here to enter Phase 2';
    }
  }

  // ===========================================================================
  // 17. PHASE 2 SETTINGS EXTENSIONS
  // ===========================================================================
  static String visaSubclassTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Subclase de Visado';
      case 'fr': return 'Sous-classe de Visa';
      case 'it': return 'Sottoclasse di Visto';
      case 'zh': return '打工度假签证类别 (Subclass)';
      case 'en':
      default: return 'Visa Subclass';
    }
  }

  static String visaSubclass462(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Work and Holiday (Subclase 462)';
      case 'fr': return 'Work and Holiday (Sous-classe 462)';
      case 'it': return 'Work and Holiday (Sottoclasse 462)';
      case 'zh': return '打工与度假签证 (Subclass 462)';
      case 'en':
      default: return 'Work and Holiday (Subclass 462)';
    }
  }

  static String visaSubclass417(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Working Holiday (Subclase 417)';
      case 'fr': return 'Working Holiday (Sous-classe 417)';
      case 'it': return 'Working Holiday (Sottoclasse 417)';
      case 'zh': return '工作假期签证 (Subclass 417)';
      case 'en':
      default: return 'Working Holiday (Subclass 417)';
    }
  }

  static String recordVisaDatesTile(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Registrar fechas de tu visado';
      case 'fr': return 'Enregistrer les dates de votre visa';
      case 'it': return 'Registra le date del tuo visto';
      case 'zh': return '录入签证下签时长数据';
      case 'en':
      default: return 'Record your Visa Dates';
    }
  }

  static String recordVisaDatesSubtitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Comparte anónimamente cuánto tardaron en concedértela';
      case 'fr': return 'Partagez anonymement le délai d\'obtention de votre visa';
      case 'it': return 'Condividi anonimamente quanto tempo hanno impiegato ad approvarlo';
      case 'zh': return '匿名分享下签处理等待周期，助力全球申请人掌握最新移民局审理动态';
      case 'en':
      default: return 'Share wait times anonymously to help other applicants';
    }
  }

  static String officialGovSources(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Fuentes Oficiales del Gobierno';
      case 'fr': return 'Sources Officielles du Gouvernement';
      case 'it': return 'Fonti Ufficiali Governative';
      case 'zh': return '澳大利亚联邦政府官方政策信源';
      case 'en':
      default: return 'Official Government Sources';
    }
  }

  // ===========================================================================
  // 18. VISA PROCESSING SURVEY DIALOG
  // ===========================================================================
  static String visaSurveyCongrats(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '¡Enhorabuena por tu Visado! 🎉';
      case 'fr': return 'Félicitations pour votre Visa ! 🎉';
      case 'it': return 'Congratulazioni per il tuo Visto! 🎉';
      case 'zh': return '热烈祝贺下签成功！🎉';
      case 'en':
      default: return 'Congrats on your Visa Grant! 🎉';
    }
  }

  static String visaSurveyBody(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Ayuda a la comunidad de OzAlert: dinos cuándo aplicaste y cuándo te lo concedieron para calcular los plazos reales de Inmigración.';
      case 'fr': return 'Aidez la communauté OzAlert : indiquez quand vous avez postulé et quand il vous a été accordé pour calculer les délais réels.';
      case 'it': return 'Aiuta la comunità di OzAlert: dicci quando hai fatto domanda e quando è stato approvato per stimare i tempi reali.';
      case 'zh': return '支持 OzAlert 全球互助社群：告诉我们你递交申请与正式下签的日期，用于测算移民局最新的真实下签周期。';
      case 'en':
      default: return 'Help the OzAlert community: tell us when you applied and when it was granted to compute real Immigration processing times.';
    }
  }

  static String visaSurveyApplyDate(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '¿Cuándo solicitaste la visa?';
      case 'fr': return 'Quand avez-vous demandé le visa ?';
      case 'it': return 'Quando hai richiesto il visto?';
      case 'zh': return '你何时正式在 ImmiAccount 递交？';
      case 'en':
      default: return 'When did you apply for the visa?';
    }
  }

  static String visaSurveyGrantDate(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '¿Cuándo te la concedieron?';
      case 'fr': return 'Quand vous a-t-il été accordé ?';
      case 'it': return 'Quando è stato concesso?';
      case 'zh': return '移民局在哪一天正式批准下签？';
      case 'en':
      default: return 'When was it granted?';
    }
  }

  static String visaSurveyTookDays(String? lang, int days) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Tu visado tardó $days ${days == 1 ? "día" : "días"} en ser aprobado';
      case 'fr': return 'Votre visa a pris $days ${days == 1 ? "jour" : "jours"} pour être approuvé';
      case 'it': return 'Il tuo visto ha impiegato $days ${days == 1 ? "giorno" : "giorni"} per essere approvato';
      case 'zh': return '你的签证共历时 $days 天成功获批';
      case 'en':
      default: return 'Your visa took $days ${days == 1 ? "day" : "days"} to be approved';
    }
  }

  static String visaSurveySave(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Guardar y compartir';
      case 'fr': return 'Enregistrer et partager';
      case 'it': return 'Salva e condividi';
      case 'zh': return '保存并贡献数据';
      case 'en':
      default: return 'Save & Share';
    }
  }

  static String visaSurveyLater(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Completar más tarde';
      case 'fr': return 'Compléter plus tard';
      case 'it': return 'Completa più tardi';
      case 'zh': return '稍后填写';
      case 'en':
      default: return 'Complete later';
    }
  }

  // ===========================================================================
  // 19. CHECKLIST TRAIL & TOOLTIPS
  // ===========================================================================
  static String checklistTrailBadge(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'LA RUTA HACIA TU VISADO';
      case 'fr': return 'LE CHEMIN VERS VOTRE VISA';
      case 'it': return 'LA STRADA VERSO IL TUO VISTO';
      case 'zh': return '签证通关升级路线';
      case 'en':
      default: return 'VISA EXPEDITION TRAIL';
    }
  }

  static String checklistApplicationKitTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Preparación Work & Holiday (462 / 417)';
      case 'fr': return 'Préparation Work & Holiday (462 / 417)';
      case 'it': return 'Preparazione Work & Holiday (462 / 417)';
      case 'zh': return '打工度假签证备签全套方案 (462 / 417)';
      case 'en':
      default: return 'Work & Holiday Application Kit (462 / 417)';
    }
  }

  static String checklistTrailStageTitle(String? lang, int stageIndex) {
    final clean = _cleanLang(lang);
    switch (stageIndex) {
      case 0:
        switch (clean) {
          case 'es': return '1. Identidad & ImmiAccount';
          case 'fr': return '1. Identité & ImmiAccount';
          case 'it': return '1. Identità & ImmiAccount';
          case 'zh': return '1. 身份认证与 ImmiAccount';
          default: return '1. Identity & ImmiAccount';
        }
      case 1:
        switch (clean) {
          case 'es': return '2. Inglés & Estudios';
          case 'fr': return '2. Anglais & Études';
          case 'it': return '2. Inglese & Studi';
          case 'zh': return '2. 语言水平与学历证明';
          default: return '2. English & Education';
        }
      case 2:
        switch (clean) {
          case 'es': return '3. Fondos & Antecedentes';
          case 'fr': return '3. Fonds & Casier';
          case 'it': return '3. Fondi & Fedina Penale';
          case 'zh': return '3. 资金存款与无犯罪体检';
          default: return '3. Funds & Background';
        }
      case 3:
      default:
        switch (clean) {
          case 'es': return '4. Traducción, Envío y Fase 2';
          case 'fr': return '4. Traduction, Envoi & Phase 2';
          case 'it': return '4. Traduzione, Invio & Fase 2';
          case 'zh': return '4. 材料翻译、正式递签与第二阶段';
          default: return '4. Translations, Submit & Phase 2';
        }
    }
  }

  static String checklistTrailStageSubtitle(String? lang, int stageIndex) {
    final clean = _cleanLang(lang);
    switch (stageIndex) {
      case 0:
        switch (clean) {
          case 'es': return 'Cuenta oficial, pasaporte y nacimiento';
          case 'fr': return 'Compte officiel, passeport & acte de naissance';
          case 'it': return 'Account ufficiale, passaporto e certificato di nascita';
          case 'zh': return '官方账号设立、护照合规与出生公证';
          default: return 'Account, passport & birth certificate';
        }
      case 1:
        switch (clean) {
          case 'es': return 'Exámenes oficiales y títulos';
          case 'fr': return 'Tests linguistiques officiels et diplômes';
          case 'it': return 'Esami di lingua ufficiali e diplomi';
          case 'zh': return '官方认可英语考试成绩与学历资格';
          default: return 'Accepted language tests & degrees';
        }
      case 2:
        switch (clean) {
          case 'es': return '\$5.000 AUD, penales y salud';
          case 'fr': return '5 000 \$ AUD, casier judiciaire et santé';
          case 'it': return '\$5.000 AUD, fedina penale e visita medica';
          case 'zh': return '5000澳元财力证明、无犯罪公证与出国体检';
          default: return '\$5,000 AUD bank proof, police & health';
        }
      case 3:
      default:
        switch (clean) {
          case 'es': return 'Traducciones, pago \$650 AUD y pasar a Fase 2';
          case 'fr': return 'Traductions, taxe de 650 \$ AUD et passage en Phase 2';
          case 'it': return 'Traduzioni, tassa di \$650 AUD e passaggio alla Fase 2';
          case 'zh': return '认证翻译、缴纳650澳元签证费并开启第二阶段';
          default: return 'Translations, \$650 AUD fee & enter Phase 2';
        }
    }
  }

  static String officialSourcesVerifiedData(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Información verificada del Gobierno de Australia';
      case 'fr': return 'Informations vérifiées du gouvernement australien';
      case 'it': return 'Informazioni verificate del Governo Australiano';
      case 'zh': return '澳大利亚联邦政府官方核实数据与法规';
      case 'en':
      default: return 'Verified Australian Government Data';
    }
  }

  static String regionalMapTitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Mapa Regional Interactivo';
      case 'fr': return 'Carte Régionale Interactive';
      case 'it': return 'Mappa Regionale Interattiva';
      case 'zh': return '澳洲偏远地区交互式地图';
      case 'en':
      default: return 'Interactive Regional Map';
    }
  }

  static String regionalMapSubtitle(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return 'Toca el mapa para ver el código y normativa';
      case 'fr': return 'Touchez une zone pour voir le code postal et l\'éligibilité';
      case 'it': return 'Tocca una zona per visualizzare codice postale e idoneità';
      case 'zh': return '点击各州版图查看合规邮编与工时政策';
      case 'en':
      default: return 'Tap any zone to view postcode & eligibility';
    }
  }

  static String regionalMapTapToExplore(String? lang) {
    switch (_cleanLang(lang)) {
      case 'es': return '👆 Toca para explorar';
      case 'fr': return '👆 Touchez pour explorer';
      case 'it': return '👆 Tocca per esplorare';
      case 'zh': return '👆 点击版图探索';
      case 'en':
      default: return '👆 Tap to explore';
    }
  }
}
