// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get loginTitle => 'OzAlert';

  @override
  String get loginSubtitle => '助你抢先获取澳洲打工度假签证的必备神器。';

  @override
  String get loginError => '登录失败：';

  @override
  String get loginGoogle => '使用 Google 登录';

  @override
  String get loginApple => '使用 Apple 登录';

  @override
  String get welcomeTitle => '你的澳洲打工度假之旅，\n从这里启程与成长';

  @override
  String get welcomeSubtitle =>
      '你的全能澳洲助手：从24/7全天候签证名额开放预警，到抵澳求职、官方简历、88天与179天工时记录，以及省心办理各项官方手续。';

  @override
  String get welcomeBullet1 => '24/7 实时雷达：打工度假签证（462/417）名额即时推送';

  @override
  String get welcomeBullet2 => '抵澳清单：行前及落地48小时官方指南（TFN、SIM卡、银行卡）';

  @override
  String get welcomeBullet3 => '求职与澳洲简历：符合招聘标准的PDF简历与Fair Work法定薪资计算';

  @override
  String get welcomeBullet4 => '偏远地区工时：邮编资格查询、88/179天工时记录与Form 1263电子签名';

  @override
  String get welcomeBullet5 => '税务与省钱中心：退税模拟器、Medicare 2%医保免征与DASP养老金申领';

  @override
  String get welcomeButton => '开启我的澳洲之旅';

  @override
  String get onboardingTitle => '定制你的签证雷达';

  @override
  String get onboardingSubtitle => '设置你的个人资料，仅接收与你的护照匹配的签证名额通知。';

  @override
  String get onboardingLanguage => '偏好语言';

  @override
  String get onboardingPassports => '选择你的护照所属国';

  @override
  String get onboardingErrorEmpty => '请至少选择一本护照';

  @override
  String get onboardingErrorSave => '保存失败：';

  @override
  String get onboardingNext => '下一步';

  @override
  String get paywallTitle => '开启名额预警雷达';

  @override
  String get paywallSubtitle => '一旦签证名额开放，立即接收秒级推送与邮件通知。订阅即可开启。';

  @override
  String paywallSubscribeMonthly(String price) {
    return '订阅 $price / 月';
  }

  @override
  String get paywallSubscribeOnly => '立即订阅';

  @override
  String get paywallRestore => '恢复已购项目';

  @override
  String get dashboardTitle => 'OzVisa 签证雷达';

  @override
  String get dashboardSettings => '设置';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguage => '应用语言';

  @override
  String get settingsLanguageEnglish => '英语 (English)';

  @override
  String get settingsLanguageSpanish => '西班牙语 (Español)';

  @override
  String get settingsLanguageFrench => '法语 (Français)';

  @override
  String get settingsLanguageItalian => '意大利语 (Italiano)';

  @override
  String get settingsLanguageChinese => '中文 (简体)';

  @override
  String get settingsLogout => '退出登录';

  @override
  String get settingsDeleteAccount => '注销账户';

  @override
  String get settingsDeleteAccountConfirmTitle => '确定注销吗？';

  @override
  String get settingsDeleteAccountConfirmMessage => '此操作不可逆，将永久删除你的所有数据。是否继续？';

  @override
  String get settingsDeleteAccountConfirmButton => '确认注销';

  @override
  String get settingsDeleteAccountCancelButton => '取消';

  @override
  String get visaStatusOpen => '开放申请';

  @override
  String get visaStatusClosed => '名额已满';

  @override
  String get visaStatusPaused => '暂时暂停';

  @override
  String get visaSourceButton => '查看官方数据源';

  @override
  String get settingsLegal => '法律条款';

  @override
  String get settingsPrivacyPolicy => '隐私政策';

  @override
  String get settingsTerms => '服务条款';

  @override
  String get checklistTitle => '行前准备清单';

  @override
  String get checklistProgress => '材料准备进度';

  @override
  String get checklistDescription => '提前备齐材料与存款证明，确保名额开放时能第一时间递交申请。';

  @override
  String get checklistKeyDocs => '核心材料清单：';

  @override
  String get checklistInstructions => '每准备好一项材料，勾选相应条目：';

  @override
  String get checklistTip => '经验贴士：签证名额往往几分钟内被抢空，提前整理好PDF材料至关重要。';

  @override
  String get dashboardSafeExpedition => '雷达监控中';

  @override
  String get dashboardSafeExpeditionDesc =>
      '目前暂无新名额。一旦澳大利亚移民局为你的护照开放申请，我们将第一时间向你发送信号。';

  @override
  String get newsTitle => '签证资讯雷达';

  @override
  String get newsTabOfficial => '官方来源';

  @override
  String get newsTabAlerts => '实时动态';

  @override
  String get newsEmptyState => '官方雷达静默中，暂无最新通告。';

  @override
  String get newsGlobalAlerts => '正在全球监控官方动态。';

  @override
  String newsError(String errorText) {
    return '雷达信号异常。\n无法加载最新资讯。\n$errorText';
  }

  @override
  String get radarScanning => '服务器正在24/7全天候追踪澳大利亚移民局官网';

  @override
  String get passportSelectorTitle => '选择你的护照 (WHV 417 & 462)';

  @override
  String passportSubclass(String subclass) {
    return '$subclass 类别 • 澳大利亚打工度假签证';
  }

  @override
  String get paywallModalTitle => '解锁 24/7 签证名额秒级雷达';

  @override
  String get paywallModalDesc => '在澳大利亚内政部开放你所在国家名额的同一秒，立即收到App弹窗与邮件双重警报。';

  @override
  String get paywallPlanAnnualTitle => '全季年卡 (Annual)';

  @override
  String get paywallPlanAnnualDesc => '最具性价比 • 立省 37%';

  @override
  String get paywallPlanMonthlyTitle => '灵活月卡';

  @override
  String get paywallPlanMonthlyDesc => '随时可一键取消订阅';

  @override
  String get paywallActivateAnnual => '开启全季通卡 (\$14.99)';

  @override
  String get paywallActivateMonthly => '按月订阅开启';

  @override
  String get paywallDisclaimer =>
      '确认购买后，款项将通过您的 Apple 或 Google 账户扣除。除非在当前周期结束前至少 24 小时取消，否则订阅将自动续订。购买后可随时在账户设置中管理或取消订阅。';

  @override
  String get paywallTermsOfUse => '使用条款';

  @override
  String get paywallPrivacyPolicy => '隐私政策';

  @override
  String get visaStatusOpenDesc => '名额正式开放，立即前往递交申请！';

  @override
  String get visaStatusPausedDesc => '处理暂时搁置，请密切保持关注。';

  @override
  String get visaStatusClosedDesc => '当前名额为 0，正在持续雷达轮询。';

  @override
  String get errorOpeningLink => '无法打开该链接。';

  @override
  String get tooltipScanRadar => '立即扫描官方雷达';

  @override
  String get newsSourceOfficial => '官方信源';

  @override
  String get newsSourceMarket => '汇率 / 签证行情';

  @override
  String get partnerAffiliate => '官方合作伙伴 • 专属 85 折';

  @override
  String get partnerDescription => '悉尼或墨尔本通关必备入境保险，涵盖全面医疗、运动与工伤保障。';

  @override
  String get partnerActivate => '领取保险 85 折优惠';

  @override
  String testAlertSending(String countryNames) {
    return '⚡ 正在向 $countryNames 发送测试警报... 2秒内送达。';
  }

  @override
  String get checklistCompletedDescription => '准备就绪！你的行前清单已100%完成。';

  @override
  String get partnerTitle => '需要澳洲境外旅行医疗险？通过 Chapka / IATI 享 85 折专属优惠';

  @override
  String get paywallSuccessMessage => '✅ VIP 权益已激活！24/7 即时通知已开启或已成功恢复购买。';

  @override
  String get navRadar => '雷达';

  @override
  String get navEquipment => '行前准备';

  @override
  String get navNews => '资讯日志';

  @override
  String get checklistIdentityDocumentsTitle => '身份证明材料';

  @override
  String get checklistIdentityDocumentsDesc =>
      '护照个人信息页（清晰彩照、个人信息及有效期）。出生证明公证件。如曾改名须提供证明。';

  @override
  String get checklistEducationTitle => '学历证明';

  @override
  String get checklistEducationDesc => '高等教育文凭、学位证或官方在读证明（根据所属国家具体要求而定）。';

  @override
  String get checklistEnglishLanguageTitle => '英语能力证明';

  @override
  String get checklistEnglishLanguageDesc =>
      '12个月内通过的官方语言考试成绩单（雅思4.5、PTE 30、剑桥147、托福iBT 32）或官方全英文教学证明。';

  @override
  String get checklistGovernmentSupportTitle => '政府支持信';

  @override
  String get checklistGovernmentSupportDesc =>
      '本国相关主管部门出具的签证支持信（部分国家如秘鲁、厄瓜多尔等适用）。';

  @override
  String get checklistEnoughMoneyTitle => '充足的资金与离澳返程机票证明';

  @override
  String get checklistEnoughMoneyDesc =>
      '证明拥有在澳基本生活费用（通常为 5,000 澳元）以及离澳机票或等额购买资金。';

  @override
  String get checklistCharacterDocumentsTitle => '无犯罪记录证明（品行证明）';

  @override
  String get checklistCharacterDocumentsDesc =>
      '自16周岁起，在过去10年内累计居住满12个月的所有国家/地区的官方无犯罪证明。';

  @override
  String get checklistGettingHelpTitle => '代理中介授权表格';

  @override
  String get checklistGettingHelpDesc =>
      '如聘请持牌移民代理或授权第三方代为递交材料，需填写 Form 956A 或 956。';

  @override
  String get checklistPrepareDocumentsTitle => '整理及翻译所有申请材料';

  @override
  String get checklistPrepareDocumentsDesc =>
      '非英文文件须经由资质翻译人员翻译成英文，并彩色高清扫描原件与翻译件。';

  @override
  String radarLastChecked(String seconds) {
    return '最近检查：$seconds 秒前（监控频率：每 60 秒轮询）';
  }

  @override
  String get newsExplore => '查看详情';

  @override
  String get newsUpdated => '已更新';

  @override
  String get countryAR => '阿根廷';

  @override
  String get countryAT => '奥地利';

  @override
  String get countryBR => '巴西';

  @override
  String get countryCL => '智利';

  @override
  String get countryCN => '中国';

  @override
  String get countryCZ => '捷克';

  @override
  String get countryEC => '厄瓜多尔';

  @override
  String get countryGR => '希腊';

  @override
  String get countryHU => '匈牙利';

  @override
  String get countryIN => '印度';

  @override
  String get countryID => '印度尼西亚';

  @override
  String get countryIL => '以色列';

  @override
  String get countryLU => '卢森堡';

  @override
  String get countryMY => '马来西亚';

  @override
  String get countryMN => '蒙古';

  @override
  String get countryPG => '巴布亚新几内亚';

  @override
  String get countryPE => '秘鲁';

  @override
  String get countryPL => '波兰';

  @override
  String get countryPT => '葡萄牙';

  @override
  String get countrySM => '圣马力诺';

  @override
  String get countrySG => '新加坡';

  @override
  String get countrySK => '斯洛伐克';

  @override
  String get countrySI => '斯洛文尼亚';

  @override
  String get countryES => '西班牙';

  @override
  String get countryCH => '瑞士';

  @override
  String get countryTH => '泰国';

  @override
  String get countryTR => '土耳其';

  @override
  String get countryUY => '乌拉圭';

  @override
  String get countryVN => '越南';

  @override
  String notificationTestTitle(String countryName) {
    return '🔔 测试警报：OzVisa 签证雷达已激活 ($countryName)';
  }

  @override
  String get notificationTestBody => '✅ 通道连接正常：服务器正在 24/7 实时监控移民局官方名额。';

  @override
  String notificationTestLongBody(String countryName) {
    return 'OzVisa Alert 针对 $countryName 的监控已生效！一旦澳大利亚内政部开放名额，将在第一时间通知你。';
  }

  @override
  String get notificationChannelName => 'OzVisa 签证名额警报';

  @override
  String get notificationChannelDesc => '澳大利亚打工度假签证名额开放即时推送';

  @override
  String get notificationTestTicker => 'OzVisa 测试警报';

  @override
  String get settingsNotifications => '消息通知';

  @override
  String get settingsNewsNotifs => '接收澳洲政策动态与求职攻略';

  @override
  String get referralTitle => '你是通过什么渠道了解到我们的？';

  @override
  String get referralSubtitle => '这能帮助我们更好地优化服务体验。';

  @override
  String get referralFriend => '朋友推荐';

  @override
  String get referralGroups => '微信 / WhatsApp 社群';

  @override
  String get referralOthers => '其他渠道';

  @override
  String get statsOfficialData => '官方数据（打工度假签证）';

  @override
  String get statsVolume => '申请量统计';

  @override
  String get statsSourceTooltip => '点击查看官方数据源';

  @override
  String get dndNoticeTitle => '如何确保第一时间听到签证报警？';

  @override
  String get dndDialogTitle => '提示音与免打扰设置指南';

  @override
  String get dndDialogIntro =>
      '为了确保 OzAlert 能及时唤醒你抢占名额，请正确配置手机。若开启静音或免打扰模式，可能错过名额开放。';

  @override
  String get dndDialogIosTitle => '🍏 苹果 iPhone (iOS) 用户';

  @override
  String get dndDialogIosSteps =>
      '1. 前往「设置」>「OzAlert」>「通知」。\n2. 确保开启「允许通知」并打开「声音」。\n3. 若使用「勿扰模式」或「睡眠专注模式」，请在专注模式设置中将 OzAlert 添加至「允许的应用」。';

  @override
  String get dndDialogAndroidTitle => '🤖 安卓 Android 用户';

  @override
  String get dndDialogAndroidSteps =>
      '1. 前往「设置」>「应用管理」>「OzAlert」>「通知管理」。\n2. 点击通知类别，将提示音设置为响亮的高优先级铃声。\n3. 若开启免打扰，请将 OzAlert 设为免打扰白名单应用。';

  @override
  String get dndDialogClose => '我知道了';
}
