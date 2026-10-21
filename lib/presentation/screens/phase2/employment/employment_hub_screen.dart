import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/fair_work_service.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../../../core/services/payslip_parser_service.dart';
import '../../../../core/services/community_telemetry_service.dart';
import '../../../../data/repositories/phase2/community_intel_repository.dart';
import '../../../providers/locale_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../../domain/models/phase2/resume_data.dart';
import '../../../../domain/models/phase2/resume_presets.dart';
import '../../../widgets/phase2/premium_feature_gate.dart';
import '../../../widgets/phase2/paywall_bottom_sheet.dart';
import '../../../widgets/phase2/signature_pad_dialog.dart';
import '../../../widgets/phase2/tax_and_vehicle_hub_modal.dart';
import 'package:ozvisa_alert/presentation/widgets/phase2/phase2_app_bar.dart';
import 'package:ozvisa_alert/presentation/widgets/phase2/official_sources_modal.dart';

class EmploymentHubScreen extends ConsumerStatefulWidget {
  const EmploymentHubScreen({super.key});

  @override
  ConsumerState<EmploymentHubScreen> createState() => _EmploymentHubScreenState();
}

class _EmploymentHubScreenState extends ConsumerState<EmploymentHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String get _currentLang => ref.watch(localeProvider)?.languageCode ?? 'es';

  // Datos del Generador de CV
  String _selectedIndustry = 'hospitality';
  final _nameController = TextEditingController(text: 'Alejandro Morales');
  final _phoneController = TextEditingController(text: '+61 412 345 678');
  final _emailController = TextEditingController(text: 'alejandro.whv@gmail.com');
  final _suburbController = TextEditingController(text: 'Surry Hills, NSW 2010');
  final _jobTitleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _linkedInController = TextEditingController();

  String _visaSubclass = '462';
  String _availability = 'Immediate Start | Flexible 7 Days & Weekends | 6-Month Commitment';
  String _themeColorHex = '#D96B43';
  final String _education = 'Completed Secondary Education Graduate';

  List<String> _currentSkills = [];
  List<String> _currentCertifications = [];
  List<WorkExperience> _currentExperiences = [];

  // Opciones avanzadas de personalización colapsadas por defecto
  bool _showAdvancedCvOptions = false;

  // Formato de Documento Seleccionado
  String _selectedDocType = 'resume'; // 'resume', 'cover_letter', 'rental_bio', 'fair_work_claim', 'resignation'

  // Cover Letter
  final _clCompanyController = TextEditingController(text: 'Merivale Hospitality Group');
  final _clRoleController = TextEditingController(text: 'Food & Beverage Attendant / Barista');
  final _clBodyController = TextEditingController(
    text: 'I am writing to express my strong interest in the role. With over 3 years of hands-on experience in high-volume customer service and specialty coffee, I thrive in fast-paced environments while maintaining exceptional standards.\n\nI hold an active Working Holiday Visa with full working rights and a 6-month commitment. I am available for immediate start across all shift rotations, including weekends and public holidays.',
  );

  // Rental Bio
  final _rentCityController = TextEditingController(text: 'Sydney Inner West / Eastern Suburbs');
  final _rentBudgetController = TextEditingController(text: '350');
  final _rentMoveInController = TextEditingController(text: 'Immediate / Next 7 Days');
  final _rentEmploymentController = TextEditingController(text: 'Employed Full-Time Casual (Payslips Available)');
  final _rentAboutController = TextEditingController(
    text: 'Hi everyone! I am a 26-year-old professional on a Working Holiday Visa. I am clean, respectful, non-smoker, and very considerate of shared spaces. I love coastal walks, cooking, and keeping a quiet, peaceful home environment.',
  );
  final List<String> _rentHabits = [
    'Non-smoker',
    'Quiet after 10 PM',
    'Clean & tidy common areas',
    'Always pay rent on time',
    'No parties inside',
  ];

  // Fair Work Claim
  final _fwEmployerNameController = TextEditingController(text: 'Sunny Coast Hospitality Pty Ltd');
  final _fwEmployerAbnController = TextEditingController(text: '45 123 456 789');
  final _fwPeriodController = TextEditingController(text: '12/01/2026 - 28/02/2026');
  final _fwOwedAmountController = TextEditingController(text: '1420.50');
  final _fwDetailsController = TextEditingController(
    text: 'Audit of timesheets and payslips indicates non-compliance with the Hospitality Industry (General) Award 2020. The statutory minimum casual base rate of \$30.91/hr was paid at \$24.00/hr cash-in-hand, omitting 25% casual loading, weekend penalty rates, and statutory 12% superannuation contributions.',
  );

  // Resignation
  final _resEmployerController = TextEditingController(text: 'The Grounds of Alexandria');
  final _resRoleController = TextEditingController(text: 'Barista / All-Rounder');
  DateTime _resLastDay = DateTime.now().add(const Duration(days: 14));
  final _resGratitudeController = TextEditingController(
    text: 'I would like to sincerely thank you for the wonderful opportunity to work with the team. I have thoroughly enjoyed my time here and greatly appreciate the support and experience gained during my tenure.',
  );

  // Calculadora Fair Work & Modern Awards
  String _selectedAwardId = 'horticulture_lvl1';
  double _hoursWorked = 38.0;
  bool _isCasualContract = true;
  String _dayType = 'weekday';
  final _grossPaidController = TextEditingController(text: '1255.90');

  // Rental Bond Receipt
  final _bondLandlordController = TextEditingController(text: 'John Henderson');
  final _bondPropertyController = TextEditingController(text: '42 Albion St, Surry Hills NSW 2010');
  final _bondAmountController = TextEditingController(text: '1400.00');
  final _bondWeeklyRentController = TextEditingController(text: '350.00');
  String _bondPaymentMethod = 'Bank Transfer / OSKO';
  String _bondStateAuthority = 'RBO (Rental Bonds Online - NSW)';
  final DateTime _bondMoveInDate = DateTime.now();

  // Vehicle Bill of Sale
  final _vehMakeModelController = TextEditingController(text: 'Toyota HiAce Commuter Campervan');
  final _vehYearController = TextEditingController(text: '2011');
  final _vehRegoNumberController = TextEditingController(text: '1GBA452');
  String _vehRegoState = 'WA (Western Australia)';
  final _vehVinController = TextEditingController(text: 'JT732GHA109847261');
  final _vehOdometerController = TextEditingController(text: '248000');
  final _vehPriceController = TextEditingController(text: '8500.00');
  final _vehSellerNameController = TextEditingController(text: 'Lucas Dupont');
  final _vehSellerPhoneController = TextEditingController(text: '+61 411 222 333');
  final _vehSellerIdController = TextEditingController(text: 'Passport 21FA98124');
  final _vehBuyerNameController = TextEditingController();
  final _vehBuyerPhoneController = TextEditingController();
  final _vehBuyerIdController = TextEditingController(text: 'Passport / Australian ID');
  Uint8List? _vehBuyerSignature;
  Uint8List? _vehSellerSignature;

  // Condition 8547 Exemption Memo
  final _c8547PassportController = TextEditingController(text: 'PA1234567');
  final _c8547EmployerController = TextEditingController(text: 'Sunburst Orchards Pty Ltd');
  String _c8547Category = 'different_locations';
  final _c8547DetailsController = TextEditingController(
    text: 'Transferred to Griffith regional packing shed (Location B) after 6 months at Cobram farm (Location A), operating under LIN 22/050 regional site criteria.',
  );

  // Test Falso Autónomo ABN (Sección 15AA Fair Work Act)
  final List<bool> _shamAnswers = [false, false, false, false, false];

  // Escáner de Nómina Offline
  final _payslipRawTextController = TextEditingController();
  ParsedPayslip? _lastParsedPayslip;

  // Repositorio de Foso de Datos Comunitario (Atomic FieldValue.increment)
  final _communityIntelRepo = CommunityIntelRepository();

  bool _hasSyncedAuthIdentity = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPreset('hospitality');

    // Inicializar nombre y email dinámicamente desde la sesión de Firebase de cada usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncAuthenticatedUserIdentity();
    });
  }

  void _syncAuthenticatedUserIdentity() {
    final user = ref.read(authStateProvider).value;
    if (user != null && !_hasSyncedAuthIdentity) {
      _hasSyncedAuthIdentity = true;
      String resolvedName = '';
      if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        resolvedName = user.displayName!.trim();
      } else if (user.email != null && user.email!.contains('@')) {
        // Si el usuario se registró por email sin displayName, derivar su nombre limpio del correo
        final prefix = user.email!.split('@').first;
        resolvedName = prefix
            .split(RegExp(r'[._\-]+'))
            .where((part) => part.isNotEmpty)
            .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
            .join(' ');
      }
      if (mounted) {
        setState(() {
          if (resolvedName.isNotEmpty) {
            _nameController.text = resolvedName;
          }
          if (user.email != null && user.email!.trim().isNotEmpty) {
            _emailController.text = user.email!.trim();
          }
        });
      }
    }
    final profile = ref.read(userProfileProvider).value;
    if (profile != null && mounted && _visaSubclass != profile.visaSubclass) {
      setState(() {
        _visaSubclass = profile.visaSubclass;
      });
    }
  }

  StateSetter? _activeModalSetState;

  void _syncState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
      _activeModalSetState?.call(() {});
    }
  }

  void _loadPreset(String industryId) {
    final preset = ResumePresets.getById(industryId);
    _syncState(() {
      _selectedIndustry = industryId;
      _jobTitleController.text = preset.defaultJobTitle;
      _summaryController.text = preset.summary;
      _currentSkills = List.from(preset.skills);
      _currentCertifications = List.from(preset.certifications);
      _currentExperiences = List.from(preset.experiences);
      _themeColorHex = preset.colorHex;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _suburbController.dispose();
    _jobTitleController.dispose();
    _summaryController.dispose();
    _linkedInController.dispose();
    _grossPaidController.dispose();
    _clCompanyController.dispose();
    _clRoleController.dispose();
    _clBodyController.dispose();
    _rentCityController.dispose();
    _rentBudgetController.dispose();
    _rentMoveInController.dispose();
    _rentEmploymentController.dispose();
    _rentAboutController.dispose();
    _fwEmployerNameController.dispose();
    _fwEmployerAbnController.dispose();
    _fwPeriodController.dispose();
    _fwOwedAmountController.dispose();
    _fwDetailsController.dispose();
    _resEmployerController.dispose();
    _resRoleController.dispose();
    _resGratitudeController.dispose();
    _bondLandlordController.dispose();
    _bondPropertyController.dispose();
    _bondAmountController.dispose();
    _bondWeeklyRentController.dispose();
    _vehMakeModelController.dispose();
    _vehYearController.dispose();
    _vehRegoNumberController.dispose();
    _vehVinController.dispose();
    _vehOdometerController.dispose();
    _vehPriceController.dispose();
    _vehSellerNameController.dispose();
    _vehSellerPhoneController.dispose();
    _vehSellerIdController.dispose();
    _vehBuyerNameController.dispose();
    _vehBuyerPhoneController.dispose();
    _vehBuyerIdController.dispose();
    _c8547PassportController.dispose();
    _c8547EmployerController.dispose();
    _c8547DetailsController.dispose();
    _payslipRawTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final lang = locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    final isEn = lang != 'es';
    final profile = ref.watch(userProfileProvider).value;
    final isPremium = profile?.isPremium ?? false;
    final authUser = ref.watch(authStateProvider).value;

    if (authUser != null && !_hasSyncedAuthIdentity) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncAuthenticatedUserIdentity();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: Phase2AppBar(
        title: AppStrings.employmentAppBarTitle(lang),
        isEn: isEn,
        infoTopic: 'fair_work',
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          tabs: [
            Tab(text: AppStrings.tabResumeBuilder(lang)),
            Tab(text: AppStrings.tabFairWork(lang)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // PESTAÑA 1: GENERADOR DE CV AUSTRALIANO
          _buildResumeBuilderTab(lang, isEn, isPremium),

          // PESTAÑA 2: CALCULADORA FAIR WORK
          _buildFairWorkTab(lang, isEn, isPremium),
        ],
      ),
    );
  }

  // ==========================================
  // PESTAÑA 1: SUITE DE DOCUMENTOS LABORALES Y VITALES
  // ==========================================
  Widget _buildResumeBuilderTab(String lang, bool isEn, bool isPremium) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // Cabecera Ejecutiva de la Suite
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(CupertinoIcons.briefcase_fill, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.docSuiteTitle(lang),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.docSuiteSubtitle(lang),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 1. Australian Resume ATS-Friendly
        _buildDocumentHubCard(
          docId: 'resume',
          icon: CupertinoIcons.doc_text_fill,
          iconColor: AppColors.primary,
          title: isEn ? 'Australian Resume (ATS)' : 'Currículum Australiano (ATS)',
          subtitle: isEn
              ? 'A4 format with native bullet points, 1-tap presets (Mining, Hospitality, Construction) and recruiter audit.'
              : 'Formato A4 sin foto con viñetas nativas de alto impacto, preajustes en 1 toque (Minas, Hostelería, Obra) y auditoría.',
          tags: [isEn ? 'ATS-Optimized' : 'Filtro ATS', isEn ? '1-Tap Roles' : 'Auto-rellenado', isEn ? 'Official' : 'Oficial'],
          isPro: false,
          isEn: isEn,
          isPremium: isPremium,
        ),
        const SizedBox(height: 12),

        // 2. Cover Letter
        _buildDocumentHubCard(
          docId: 'cover_letter',
          icon: CupertinoIcons.mail_solid,
          iconColor: AppColors.secondary,
          title: isEn ? 'Australian Cover Letter' : 'Cover Letter (Carta Presentación)',
          subtitle: isEn
              ? 'Formal introductory letter tailored to job ads on Seek/Indeed, highlighting your visa rights and immediate start.'
              : 'Carta formal adaptada a ofertas de Seek e Indeed. Destaca permiso de trabajo legal, disponibilidad y flexibilidad.',
          tags: [isEn ? 'Recruiter Ready' : 'Seek & Indeed', isEn ? 'Visa Highlights' : 'Visado Legal', isEn ? 'Official' : 'Oficial'],
          isPro: false,
          isEn: isEn,
          isPremium: isPremium,
        ),
        const SizedBox(height: 12),

        // 3. Rental Bio
        _buildDocumentHubCard(
          docId: 'rental_bio',
          icon: CupertinoIcons.house_fill,
          iconColor: const Color(0xFF0D9488),
          title: isEn ? 'Rental & Flatmate Bio' : 'Perfil de Alquiler & Flatmates',
          subtitle: isEn
              ? 'Stand out in tight rental markets with verified proof of income, bond readiness, and clean living etiquette.'
              : 'Destaca ante caseros y compañeros con solvencia acreditada, fianza lista y normas de convivencia impecables.',
          tags: [isEn ? 'Fast Approval' : 'Aprobación Rápida', isEn ? 'Bond Ready' : 'Fianza Lista', isEn ? 'Verified' : 'Solvencia'],
          isPro: false,
          isEn: isEn,
          isPremium: isPremium,
        ),
        const SizedBox(height: 12),

        // 4. Fair Work Claim
        _buildDocumentHubCard(
          docId: 'fair_work_claim',
          icon: CupertinoIcons.shield_fill,
          iconColor: const Color(0xFFDC2626),
          title: isEn ? 'Fair Work Underpayment Claim' : 'Reclamación Formal Fair Work',
          subtitle: isEn
              ? 'Legally drafted formal notice under Fair Work Act 2009 demanding backpay, 25% casual loading or unpaid super.'
              : 'Requerimiento formal bajo la Fair Work Act 2009 exigiendo salarios impagados, 25% casual loading o Superannuation.',
          tags: [isEn ? 'Fair Work Act 2009' : 'Ley Fair Work 2009', isEn ? 'Backpay Demand' : 'Reclamar Dinero'],
          isPro: false,
          isEn: isEn,
          isPremium: isPremium,
        ),
        const SizedBox(height: 12),

        // 5. Resignation Letter
        _buildDocumentHubCard(
          docId: 'resignation',
          icon: CupertinoIcons.hand_raised_fill,
          iconColor: AppColors.textPrimary,
          title: isEn ? '2-Week Resignation Letter' : 'Carta de Renuncia Legal (2 Semanas)',
          subtitle: isEn
              ? 'Standard Australian 14-day notice guaranteeing your final payslip calculation and positive employer reference.'
              : 'Preaviso estándar de 14 días para asegurar el finiquito íntegro y una referencia laboral impecable.',
          tags: [isEn ? '14-Day Notice' : 'Preaviso 14 Días', isEn ? 'Guaranteed Reference' : 'Referencia Segura'],
          isPro: false,
          isEn: isEn,
          isPremium: isPremium,
        ),
        const SizedBox(height: 12),

        // 6. Rental Bond Receipt
        _buildDocumentHubCard(
          docId: 'rental_bond',
          icon: CupertinoIcons.doc_checkmark_fill,
          iconColor: const Color(0xFF0284C7),
          title: isEn ? 'Rental Bond Receipt & Shield' : 'Recibo Legal de Fianza (Share-House)',
          subtitle: isEn
              ? 'Official deposit receipt requiring landlord to lodge funds with state bond authority (RBO/RTBA/RTA).'
              : 'Recibo vinculante para pagar fianzas en habitaciones y pisos, exigiendo el registro en el organismo estatal.',
          tags: [isEn ? 'Anti-Scam' : 'Anti-Fraude', isEn ? 'State Lodgement' : 'Fianza Legal', isEn ? 'Official' : 'Oficial'],
          isPro: false,
          isEn: isEn,
          isPremium: isPremium,
        ),
        const SizedBox(height: 12),

        // 7. Vehicle Bill of Sale
        _buildDocumentHubCard(
          docId: 'vehicle_sale',
          icon: CupertinoIcons.car_detailed,
          iconColor: const Color(0xFFF59E0B),
          title: isEn ? 'Vehicle & Camper Bill of Sale' : 'Contrato Compraventa Coche/Camper',
          subtitle: isEn
              ? 'Bilingual contract with PPSR clear title warranty, RWC/roadworthy status and on-screen signatures.'
              : 'Contrato legal de compraventa con cláusula PPSR sin cargas financieras, estado RWC y firmas en pantalla.',
          tags: [isEn ? 'PPSR Warranty' : 'Cargas PPSR', isEn ? 'WA/Interstate' : 'Traspaso Seguro', isEn ? 'Signatures' : 'Firmas'],
          isPro: false,
          isEn: isEn,
          isPremium: isPremium,
        ),
        const SizedBox(height: 12),

        // 8. Condition 8547 Exemption Memo
        _buildDocumentHubCard(
          docId: 'condition_8547',
          icon: CupertinoIcons.building_2_fill,
          iconColor: const Color(0xFF8B5CF6),
          title: isEn ? 'Condition 8547 Exemption Memo' : 'Memorando Exención 6 Meses (LIN 22/050)',
          subtitle: isEn
              ? 'Official HR advisory citing Home Affairs policy for working beyond 6 months at different sites or sectors.'
              : 'Escrito formal para RRHH citando la normativa de Inmigración para trabajar más de 6 meses con la misma empresa.',
          tags: [isEn ? 'LIN 22/050' : 'Ley LIN 22/050', isEn ? 'Home Affairs' : 'Inmigración', isEn ? 'HR Ready' : 'Para RRHH'],
          isPro: false,
          isEn: isEn,
          isPremium: isPremium,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDocumentHubCard({
    required String docId,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<String> tags,
    required bool isPro,
    required bool isEn,
    required bool isPremium,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDocumentAssistantModal(context, docId, isEn, isPremium),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            subtitle,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: tags.map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.docConfigure(_currentLang),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: iconColor,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(CupertinoIcons.chevron_right, size: 12, color: iconColor),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDocumentAssistantModal(BuildContext context, String docType, bool isEn, bool isPremium) {
    setState(() {
      _selectedDocType = docType;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            _activeModalSetState = setModalState;
            final title = AppStrings.docModalTitle(_currentLang, _selectedDocType);
            final keyboardInset = MediaQuery.of(ctx).viewInsets.bottom;
            return AnimatedPadding(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: keyboardInset),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.92,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 6),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textMuted),
                            onPressed: () => Navigator.pop(modalContext),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.cardBorder),
                    // Selector rápido de documento dentro del modal
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _buildDocumentTypeSelector(isEn),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        child: _buildSelectedDocForm(isEn, isPremium),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _activeModalSetState = null;
    });
  }


  Widget _buildSelectedDocForm(bool isEn, bool isPremium) {
    if (_selectedDocType == 'resume') {
      return _buildResumeForm(isEn, isPremium);
    } else if (_selectedDocType == 'cover_letter') {
      return _buildCoverLetterForm(isEn, isPremium);
    } else if (_selectedDocType == 'rental_bio') {
      return _buildRentalBioForm(isEn, isPremium);
    } else if (_selectedDocType == 'fair_work_claim') {
      return _buildFairWorkClaimForm(isEn, isPremium);
    } else if (_selectedDocType == 'resignation') {
      return _buildResignationForm(isEn, isPremium);
    } else if (_selectedDocType == 'rental_bond') {
      return _buildRentalBondForm(isEn, isPremium);
    } else if (_selectedDocType == 'vehicle_sale') {
      return _buildVehicleSaleForm(isEn, isPremium);
    } else {
      return _buildCondition8547Form(isEn, isPremium);
    }
  }

  Widget _buildDocumentTypeSelector(bool isEn) {
    final docs = [
      {
        'id': 'resume',
        'icon': CupertinoIcons.doc_text_fill,
        'label': '📄 CV Australiano',
        'labelEn': '📄 Resume ATS',
      },
      {
        'id': 'cover_letter',
        'icon': CupertinoIcons.mail_solid,
        'label': '✉️ Cover Letter',
        'labelEn': '✉️ Cover Letter',
      },
      {
        'id': 'rental_bio',
        'icon': CupertinoIcons.house_fill,
        'label': '🏠 Perfil Alquiler',
        'labelEn': '🏠 Rental Bio',
      },
      {
        'id': 'fair_work_claim',
        'icon': CupertinoIcons.shield_fill,
        'label': '⚖️ Reclamo Fair Work',
        'labelEn': '⚖️ Wage Claim',
      },
      {
        'id': 'resignation',
        'icon': CupertinoIcons.hand_raised_fill,
        'label': '🤝 Renuncia 2 Sem.',
        'labelEn': '🤝 2-Wk Resign',
      },
      {
        'id': 'rental_bond',
        'icon': CupertinoIcons.doc_checkmark_fill,
        'label': '🔑 Recibo Fianza',
        'labelEn': '🔑 Bond Receipt',
      },
      {
        'id': 'vehicle_sale',
        'icon': CupertinoIcons.car_detailed,
        'label': '🚗 Venta Coche',
        'labelEn': '🚗 Car Sale',
      },
      {
        'id': 'condition_8547',
        'icon': CupertinoIcons.building_2_fill,
        'label': '🏢 Exención 6m',
        'labelEn': '🏢 6-Mo Exemption',
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: docs.map((doc) {
          final id = doc['id'] as String;
          final isSelected = _selectedDocType == id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(isEn ? (doc['labelEn'] as String) : (doc['label'] as String)),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 12.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.cardBorder,
                  width: 1.2,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  _syncState(() => _selectedDocType = id);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResumeForm(bool isEn, bool isPremium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tarjeta de Puntuación de Empleabilidad Australiana (Recruiter Audit)
        _buildRecruiterScoreCard(isEn),
        const SizedBox(height: 16),

        // 2. Selector de Rol / Industria en 1 Toque (Auto-Fill sin esfuerzo)
        Text(
          isEn ? '🎯 Target Industry (1-Tap Auto Fill)' : '🎯 Puesto Objetivo en Australia (Auto-rellenado)',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          isEn
              ? 'Select your target job: all high-impact Australian bullet points and summary will load automatically.'
              : 'Selecciona el sector y la app rellenará el CV con redacción nativa y métricas reales probadas por reclutadores.',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        _buildRoleSelectorChips(isEn),
        const SizedBox(height: 18),

        // 3. Bloque Contacto Esencial (Rápido y sin agobios)
        _buildSectionHeader(
          icon: CupertinoIcons.person_crop_circle_fill,
          title: isEn ? '1. Essential Contact Info' : '1. Datos de Contacto Esenciales',
          subtitle: isEn
              ? 'Australian law: No photo, no birthdate, no street address.'
              : 'Norma australiana: Sin foto, sin fecha de nacimiento ni dirección.',
        ),
        const SizedBox(height: 8),
        _buildTextField(_nameController, isEn ? 'Full Name' : 'Nombre Completo'),
        const SizedBox(height: 10),
        _buildTextField(_phoneController, isEn ? 'Australian Mobile (+61)' : 'Móvil Australiano (+61)'),
        const SizedBox(height: 18),

        // 4. Bloque Visado y Disponibilidad (Factor #1 para Jefes de Local)
        _buildSectionHeader(
          icon: CupertinoIcons.shield_lefthalf_fill,
          title: isEn ? '2. Visa Work Rights & Availability' : '2. Permiso de Trabajo y Visado',
          subtitle: isEn
              ? 'Top filter: Eliminates recruiter fear of 20-hour student limits.'
              : 'Factor decisivo: Demuestra permiso ilimitado de trabajo.',
        ),
        const SizedBox(height: 8),
        _buildVisaSelector(isEn),
        const SizedBox(height: 18),

        // Desplegable de Opciones Avanzadas (Divulgación Progresiva)
        InkWell(
          onTap: () => _syncState(() => _showAdvancedCvOptions = !_showAdvancedCvOptions),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _showAdvancedCvOptions ? AppColors.secondary : AppColors.cardBorder,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _showAdvancedCvOptions ? CupertinoIcons.slider_horizontal_below_rectangle : CupertinoIcons.slider_horizontal_3,
                  size: 18,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEn
                        ? (_showAdvancedCvOptions ? 'Hide Advanced Settings ▲' : '⚙️ Customise Details & Advanced Settings ▾')
                        : (_showAdvancedCvOptions ? 'Ocultar Opciones Avanzadas ▲' : '⚙️ Personalizar Detalles & Opciones Avanzadas ▾'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                  ),
                ),
                Icon(
                  _showAdvancedCvOptions ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                  size: 15,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),

        if (_showAdvancedCvOptions) ...[
          const SizedBox(height: 16),

          // Contacto Secundario (Barrio, Correo, LinkedIn)
          _buildSectionHeader(
            icon: CupertinoIcons.location_fill,
            title: isEn ? 'Additional Contact Info' : 'Contacto Secundario',
            subtitle: isEn ? 'Suburb and online links' : 'Barrio de residencia y enlaces',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField(_suburbController, isEn ? 'Suburb, State Postcode' : 'Barrio, Estado y CP')),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField(_emailController, isEn ? 'Email' : 'Correo Electrónico')),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(_linkedInController, isEn ? 'LinkedIn / Portfolio (Optional)' : 'LinkedIn (Opcional)'),
          const SizedBox(height: 18),

          // Puesto y Extracto
          _buildSectionHeader(
            icon: CupertinoIcons.briefcase_fill,
            title: isEn ? 'Position & Executive Summary' : 'Puesto y Extracto Profesional',
            subtitle: isEn ? 'Tailored Australian wording' : 'Redactado en inglés australiano profesional',
          ),
          const SizedBox(height: 8),
          _buildTextField(_jobTitleController, isEn ? 'Job Title on Resume' : 'Título del puesto en el CV'),
          const SizedBox(height: 10),
          _buildTextField(_summaryController, isEn ? 'Executive Summary' : 'Extracto profesional', maxLines: 4),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _loadPreset(_selectedIndustry),
              icon: const Icon(CupertinoIcons.arrow_counterclockwise, size: 14, color: AppColors.secondary),
              label: Text(
                isEn ? 'Reset to Role Preset' : 'Restaurar texto modelo',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Licencias Oficiales (Tickets)
          _buildSectionHeader(
            icon: CupertinoIcons.checkmark_seal_fill,
            title: isEn ? 'Australian Licences & Tickets' : 'Licencias Oficiales (Tickets)',
            subtitle: isEn ? 'Mandatory for Hospitality & Construction' : 'Obligatorio para hostelería y construcción',
          ),
          const SizedBox(height: 8),
          _buildCertificationsChips(isEn),
          const SizedBox(height: 18),

          // Habilidades Clave (Keywords ATS)
          _buildSectionHeader(
            icon: CupertinoIcons.sparkles,
            title: isEn ? 'Key Skills (ATS Keywords)' : 'Habilidades Clave (Filtro ATS)',
            subtitle: isEn ? 'Keywords recruiters search for' : 'Palabras clave que leen los algoritmos',
          ),
          const SizedBox(height: 8),
          _buildSkillsChips(isEn),
          const SizedBox(height: 18),

          // Experiencias Laborales
          _buildSectionHeader(
            icon: CupertinoIcons.building_2_fill,
            title: isEn ? 'Experience (Recruiter-Tested)' : 'Experiencia Laboral Adaptable',
            subtitle: isEn ? 'Customise with 1 tap' : 'Modifica empresas y fechas con 1 toque',
          ),
          const SizedBox(height: 8),
          ..._currentExperiences.asMap().entries.map((entry) {
            final index = entry.key;
            final exp = entry.value;
            return _buildExperienceCard(exp, index, isEn);
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _showEditExperienceDialog(isEn, null),
            icon: const Icon(CupertinoIcons.plus_circle, size: 16),
            label: Text(isEn ? 'Add Another Job' : '+ Añadir Otra Experiencia'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 11),
            ),
          ),
          const SizedBox(height: 18),

          // Selector de Color
          _buildSectionHeader(
            icon: CupertinoIcons.paintbrush_fill,
            title: isEn ? 'PDF Style Accent' : 'Estilo Visual del PDF',
            subtitle: isEn ? 'Executive recruiter palette' : 'Paleta corporativa ejecutiva',
          ),
          const SizedBox(height: 8),
          _buildColorPicker(isEn),
        ],
        const SizedBox(height: 24),

        // 10. Botón Principal: Generar y Descargar CV Oficial
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(CupertinoIcons.arrow_down_doc_fill, size: 20),
            label: Text(
              isEn ? 'Download Australian Resume (PDF)' : 'Generar CV Oficial Australiano (PDF)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 2,
            ),
            onPressed: () => _generateAndShareResume(context, isEn, isPremium),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCoverLetterForm(bool isEn, bool isPremium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isEn ? '✉️ SEEK & INDEED STANDARD' : '✉️ ESTÁNDAR SEEK & INDEED',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.secondary),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isEn ? '1-Page A4 PDF' : 'PDF 1 Página A4',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isEn ? 'Official Australian Cover Letter' : 'Carta de Presentación Oficial Australiana',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                isEn
                    ? 'Required by 80% of hiring managers in Australia. Formatted to highlight your visa validity, immediate availability, and local contact info.'
                    : 'Exigida por el 80% de contratadores en Australia. Destaca tus derechos legales de visado, disponibilidad para trial shifts y contacto local.',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionHeader(
          icon: CupertinoIcons.building_2_fill,
          title: isEn ? 'Recipient & Target Role' : 'Destinatario y Puesto Objetivo',
          subtitle: isEn ? 'Customised for the company you are targeting' : 'Personalizado para la empresa a la que aplicas',
        ),
        const SizedBox(height: 8),
        _buildTextField(_clCompanyController, isEn ? 'Company / Employer Name' : 'Nombre de la Empresa (ej. Merivale Group)'),
        const SizedBox(height: 10),
        _buildTextField(_clRoleController, isEn ? 'Position Applying For' : 'Puesto al que aplicas (ej. Head Barista)'),
        const SizedBox(height: 16),

        _buildSectionHeader(
          icon: CupertinoIcons.doc_text_fill,
          title: isEn ? 'Cover Letter Body (Australian Tone)' : 'Cuerpo de la Carta (Tono Australiano)',
          subtitle: isEn ? 'Proven pro structure ready to send' : 'Estructura redactada en inglés nativo con métricas',
        ),
        const SizedBox(height: 8),
        _buildTextField(_clBodyController, isEn ? 'Letter Content' : 'Contenido de la Carta', maxLines: 7),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(CupertinoIcons.arrow_down_doc_fill, size: 20),
            label: Text(
              isEn ? 'Download Pro Cover Letter (PDF)' : 'Generar Cover Letter Oficial (PDF)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 2,
            ),
            onPressed: () => _generateAndShareCoverLetter(context, isEn, isPremium),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildRentalBioForm(bool isEn, bool isPremium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isEn ? '🏠 FLATMATE & TENANT PROFILE' : '🏠 PERFIL DE ALQUILER & FLATMATE',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.secondary),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isEn ? 'Bond-Ready' : 'Fianza Lista',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isEn ? 'Stand Out in Australian Rentals' : 'Gana Habitaciones y Pisos en Australia',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                isEn
                    ? 'Rental markets in Sydney and Melbourne are crowded. Send this executive bio to landlords on Flatmates.com.au and Domain to prove verified income and quiet living etiquette.'
                    : 'El alquiler en Sídney y Melbourne es feroz. Envía este perfil en Flatmates.com.au y Domain para demostrar visado legal, 4 semanas de fianza y convivencia impecable.',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionHeader(
          icon: CupertinoIcons.location_solid,
          title: isEn ? 'Target Area & Budget' : 'Zona Buscada y Presupuesto Semanal',
          subtitle: isEn ? 'Crucial info for landlords and housemates' : 'Datos clave para filtrar propietarios compatibles',
        ),
        const SizedBox(height: 8),
        _buildTextField(_rentCityController, isEn ? 'Target Suburbs / City' : 'Barrios / Zona de Búsqueda (ej. Surry Hills, Bondi)'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTextField(_rentBudgetController, isEn ? 'Budget (\$ AUD / Wk)' : 'Presupuesto (\$ AUD / Sem)'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(_rentMoveInController, isEn ? 'Move-in Date' : 'Fecha de Mudanza'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildSectionHeader(
          icon: CupertinoIcons.person_badge_plus_fill,
          title: isEn ? 'Employment, Income & Lifestyle' : 'Acreditación Laboral y Estilo de Vida',
          subtitle: isEn ? 'Eliminates landlord fear of missed rent' : 'Garantiza al casero que no habrá problemas de pago',
        ),
        const SizedBox(height: 8),
        _buildTextField(_rentEmploymentController, isEn ? 'Current Job & Income Status' : 'Situación Laboral y Solvencia (ej. Empleado Casual)'),
        const SizedBox(height: 10),
        _buildTextField(_rentAboutController, isEn ? 'About Me (English)' : 'Sobre Mí & Convivencia (en inglés)', maxLines: 4),
        const SizedBox(height: 14),

        Text(
          isEn ? 'Living Habits & House Etiquette:' : 'Hábitos de Convivencia Destacados:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Non-smoker',
            'Quiet after 10 PM',
            'Clean & tidy common areas',
            'Always pay rent on time',
            'No parties inside',
            'Respectful of privacy',
          ].map((habit) {
            final isChecked = _rentHabits.contains(habit);
            return FilterChip(
              label: Text(habit),
              selected: isChecked,
              selectedColor: AppColors.secondary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.secondary,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                color: isChecked ? AppColors.secondary : AppColors.textPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isChecked ? AppColors.secondary : AppColors.cardBorder),
              ),
              onSelected: (val) {
                _syncState(() {
                  if (val) {
                    _rentHabits.add(habit);
                  } else {
                    _rentHabits.remove(habit);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(CupertinoIcons.arrow_down_doc_fill, size: 20),
            label: Text(
              isEn ? 'Download Rental Profile (PDF)' : 'Generar Perfil de Alquiler Oficial (PDF)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 2,
            ),
            onPressed: () => _generateAndShareRentalBio(context, isEn, isPremium),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFairWorkClaimForm(bool isEn, bool isPremium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isEn ? '⚖️ FAIR WORK ACT 2009' : '⚖️ LEY FAIR WORK ACT 2009',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.warning),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isEn ? '14-Day Notice' : 'Plazo 14 Días',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isEn ? 'Formal Wage Underpayment Notice' : 'Notificación Formal de Reclamación Salarial',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                isEn
                    ? 'Official letter based on Fair Work Ombudsman procedures. Legally demands unpaid minimum award rates, casual loading (25%), and superannuation (12%) within 14 days before escalation.'
                    : 'Carta formal según el procedimiento del Ombudsman. Exige a tu empleador pagar salarios mínimos, casual loading (25%) y superannuation (12%) en 14 días antes de elevar la denuncia al gobierno.',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionHeader(
          icon: CupertinoIcons.building_2_fill,
          title: isEn ? 'Employer Details' : 'Datos de la Empresa Infractora',
          subtitle: isEn ? 'Company name and registered ABN' : 'Nombre comercial y ABN obligatorio',
        ),
        const SizedBox(height: 8),
        _buildTextField(_fwEmployerNameController, isEn ? 'Employer / Business Name' : 'Nombre de la Empresa o Local'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildTextField(_fwEmployerAbnController, isEn ? 'Employer ABN (11 digits)' : 'ABN de la Empresa (11 dígitos)')),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField(_fwPeriodController, isEn ? 'Dates Worked' : 'Periodo de Trabajo')),
          ],
        ),
        const SizedBox(height: 16),

        _buildSectionHeader(
          icon: CupertinoIcons.money_dollar_circle_fill,
          title: isEn ? 'Underpayment Claim & Amount' : 'Importe Reclamado y Argumentación Legal',
          subtitle: isEn ? 'Total estimated owed amount in AUD' : 'Total adeudado según tablas de Fair Work',
        ),
        const SizedBox(height: 8),
        _buildTextField(_fwOwedAmountController, isEn ? 'Total Owed Amount (\$ AUD)' : 'Importe Total Adeudado (\$ AUD)'),
        const SizedBox(height: 10),
        _buildTextField(_fwDetailsController, isEn ? 'Statement of Claim Particulars' : 'Detalle del Incumplimiento Salarial', maxLines: 4),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(CupertinoIcons.arrow_down_doc_fill, size: 20),
            label: Text(
              isEn ? 'Download Fair Work Letter (PDF)' : 'Generar Carta Formal Fair Work (PDF)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 2,
            ),
            onPressed: () => _generateAndShareFairWorkClaim(context, isEn, isPremium),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildResignationForm(bool isEn, bool isPremium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isEn ? '🤝 TWO WEEKS NOTICE' : '🤝 PREAVISO 2 SEMANAS',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.secondary),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isEn ? 'Standard Protocol' : 'Protocolo Oficial',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isEn ? 'Formal Letter of Resignation' : 'Carta Formal de Renuncia Laboral',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                isEn
                    ? 'In Australia, standard protocol requires a 2-week written notice. Ensures you leave gracefully, receive your final payslip with super, and secure a written reference.'
                    : 'En Australia, entregar 2 semanas de preaviso formal es la clave para salir de la empresa por la puerta grande y asegurar tu carta de recomendación.',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionHeader(
          icon: CupertinoIcons.building_2_fill,
          title: isEn ? 'Company & Position' : 'Empresa y Puesto a Renunciar',
          subtitle: isEn ? 'Formal notice details' : 'Datos para la dirección de la empresa',
        ),
        const SizedBox(height: 8),
        _buildTextField(_resEmployerController, isEn ? 'Employer / Company Name' : 'Nombre de la Empresa o Local'),
        const SizedBox(height: 10),
        _buildTextField(_resRoleController, isEn ? 'Your Position' : 'Tu Puesto Actual'),
        const SizedBox(height: 16),

        _buildSectionHeader(
          icon: CupertinoIcons.calendar,
          title: isEn ? 'Last Working Day & Note' : 'Último Día de Trabajo y Mensaje',
          subtitle: isEn ? 'Standard 2 weeks notice period' : 'Fecha final de contrato y nota de transición',
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _resLastDay,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
            );
            if (picked != null) {
              _syncState(() => _resLastDay = picked);
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEn ? 'Final Working Day:' : 'Último día de trabajo:',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                Row(
                  children: [
                    const Icon(CupertinoIcons.calendar, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${_resLastDay.day}/${_resLastDay.month}/${_resLastDay.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildTextField(_resGratitudeController, isEn ? 'Gratitude & Transition Message' : 'Mensaje de Agradecimiento', maxLines: 3),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(CupertinoIcons.arrow_down_doc_fill, size: 20),
            label: Text(
              isEn ? 'Download Resignation Letter (PDF)' : 'Generar Carta de Renuncia Oficial (PDF)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 2,
            ),
            onPressed: () => _generateAndShareResignation(context, isEn, isPremium),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // ==========================================
  // WIDGETS AUXILIARES PARA EL CV
  // ==========================================

  Widget _buildRecruiterScoreCard(bool isEn) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.star_fill, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 5),
                    Text(
                      isEn ? 'Recruiter Score: 98/100' : 'Score Recruiter: 98/100',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isEn ? 'ATS-Friendly' : 'Anti-Filtro ATS',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isEn
                ? '⚡ 90% of Foreign Resumes Get Discarded in 6 Seconds'
                : '⚡ El 90% de los CVs extranjeros van directos a la papelera',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            isEn
                ? 'Australian recruiters and ATS filters instantly discard CVs with photos, birthdates, or vague visa permissions. OzAlert formats your profile into an executive standard designed to land trial shifts.'
                : 'Los reclutadores y algoritmos ATS descartan al instante CVs con foto, edad o permisos de visado confusos. OzAlert estructura tu perfil con el estándar oficial para asegurar llamadas a entrevistas y trial shifts.',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelectorChips(bool isEn) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ResumePresets.presets.map((preset) {
          final isSelected = _selectedIndustry == preset.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              avatar: Text(preset.icon, style: const TextStyle(fontSize: 15)),
              label: Text(isEn ? preset.titleEn : preset.title),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
              ),
              onSelected: (_) => _loadPreset(preset.id),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildVisaSelector(bool isEn) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Visa Subclass' : 'Subclase de Visado',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    DropdownButton<String>(
                      value: _visaSubclass,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: '462', child: Text('Subclass 462 (Work & Holiday)')),
                        DropdownMenuItem(value: '417', child: Text('Subclass 417 (Working Holiday)')),
                        DropdownMenuItem(value: '500', child: Text('Subclass 500 (Student Visa)')),
                      ],
                      onChanged: (val) {
                        if (val != null) _syncState(() => _visaSubclass = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Text(
            isEn ? 'Availability Status:' : 'Disponibilidad Declarada:',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          DropdownButton<String>(
            value: _availability,
            isExpanded: true,
            underline: const SizedBox(),
            isDense: true,
            items: [
              DropdownMenuItem(
                value: 'Immediate Start | Flexible 7 Days & Weekends | 6-Month Commitment',
                child: Text(isEn ? 'Immediate (7 Days & Weekends)' : 'Inmediata (7 Días & Fines de Semana)', style: const TextStyle(fontSize: 12)),
              ),
              DropdownMenuItem(
                value: 'Immediate Start | Morning Shifts & Weekends Available',
                child: Text(isEn ? 'Mornings & Weekends' : 'Mañanas & Fines de Semana', style: const TextStyle(fontSize: 12)),
              ),
              DropdownMenuItem(
                value: 'Immediate Start | Evening & Night Shifts Ready',
                child: Text(isEn ? 'Evenings & Nights' : 'Tardes y Noches', style: const TextStyle(fontSize: 12)),
              ),
            ],
            onChanged: (val) {
              if (val != null) _syncState(() => _availability = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsChips(bool isEn) {
    final standardTickets = [
      'RSA (Responsible Service of Alcohol) - Valid & Active',
      'General Construction Induction (White Card CPCCWHS1001)',
      'Barista Mastery Level 1 & 2 (Espresso Extraction)',
      'Australian / International Driver\'s Licence (Class C)',
      'First Aid & CPR (HLTAID011)',
      'Food Safety & Handling Certificate',
      'Forklift Licence (LF)',
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: standardTickets.map((ticket) {
        final isChecked = _currentCertifications.contains(ticket);
        final shortLabel = ticket.split('(').first.trim();
        return FilterChip(
          label: Text(shortLabel),
          selected: isChecked,
          selectedColor: AppColors.secondary.withValues(alpha: 0.2),
          checkmarkColor: AppColors.secondary,
          backgroundColor: AppColors.surface,
          labelStyle: TextStyle(
            fontSize: 11.5,
            fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
            color: isChecked ? AppColors.secondary : AppColors.textPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isChecked ? AppColors.secondary : AppColors.cardBorder),
          ),
          onSelected: (val) {
            _syncState(() {
              if (val) {
                _currentCertifications.add(ticket);
              } else {
                _currentCertifications.remove(ticket);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSkillsChips(bool isEn) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ..._currentSkills.map((skill) => Chip(
          label: Text(skill, style: const TextStyle(fontSize: 11.5)),
          backgroundColor: AppColors.surfaceElevated,
          deleteIcon: const Icon(CupertinoIcons.xmark_circle_fill, size: 14, color: AppColors.textMuted),
          onDeleted: () {
            _syncState(() => _currentSkills.remove(skill));
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
        )),
        ActionChip(
          avatar: const Icon(CupertinoIcons.plus, size: 14, color: AppColors.primary),
          label: Text(isEn ? 'Add Skill' : 'Añadir Habilidad', style: const TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.primary),
          ),
          onPressed: () => _showAddSkillDialog(isEn),
        ),
      ],
    );
  }

  Widget _buildExperienceCard(WorkExperience exp, int index, bool isEn) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exp.role,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.pencil_circle_fill, color: AppColors.secondary, size: 22),
                  onPressed: () => _showEditExperienceDialog(isEn, index),
                  tooltip: isEn ? 'Edit Experience' : 'Editar Experiencia',
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.trash, color: AppColors.statusClosed, size: 18),
                  onPressed: () {
                    _syncState(() => _currentExperiences.removeAt(index));
                  },
                ),
              ],
            ),
            Text(
              '${exp.company} • ${exp.location} | ${exp.period}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            ...exp.bulletPoints.map((bp) => Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.textMuted)),
                  Expanded(child: Text(bp, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(bool isEn) {
    final colors = [
      {'hex': '#D96B43', 'name': isEn ? 'Terracotta' : 'Ayers Rock Terracota'},
      {'hex': '#1E293B', 'name': isEn ? 'Executive Navy' : 'Azul Ejecutivo Costa'},
      {'hex': '#00A896', 'name': isEn ? 'Outback Green' : 'Verde Esmeralda Outback'},
    ];

    return Row(
      children: colors.map((c) {
        final hex = c['hex'] as String;
        final name = c['name'] as String;
        final isSelected = _themeColorHex == hex;
        final colorObj = Color(int.parse(hex.replaceFirst('#', '0xFF')));

        return Expanded(
          child: GestureDetector(
            onTap: () => _syncState(() => _themeColorHex = hex),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? colorObj.withValues(alpha: 0.12) : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? colorObj : AppColors.cardBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(radius: 10, backgroundColor: colorObj),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? colorObj : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAddSkillDialog(bool isEn) {
    final skillController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEn ? 'Add Key Skill' : 'Añadir Habilidad Clave'),
        content: TextField(
          controller: skillController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: isEn ? 'e.g. Latte Art, Square POS...' : 'Ej. Latte Art, Manejo de Caja...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isEn ? 'Cancel' : 'Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (skillController.text.trim().isNotEmpty) {
                _syncState(() => _currentSkills.add(skillController.text.trim()));
              }
              Navigator.pop(ctx);
            },
            child: Text(isEn ? 'Add' : 'Añadir'),
          ),
        ],
      ),
    );
  }

  void _showEditExperienceDialog(bool isEn, int? index) {
    final isNew = index == null;
    final exp = !isNew ? _currentExperiences[index] : null;

    final roleCtrl = TextEditingController(text: exp?.role ?? '');
    final compCtrl = TextEditingController(text: exp?.company ?? '');
    final locCtrl = TextEditingController(text: exp?.location ?? 'Sydney, NSW');
    final perCtrl = TextEditingController(text: exp?.period ?? '2024 - Present');
    final bulletsCtrl = TextEditingController(text: exp != null ? exp.bulletPoints.join('\n') : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isNew
                    ? (isEn ? 'Add Work Experience' : 'Añadir Experiencia Laboral')
                    : (isEn ? 'Edit Experience' : 'Editar Experiencia'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildTextField(roleCtrl, isEn ? 'Job Title' : 'Puesto de Trabajo'),
              const SizedBox(height: 8),
              _buildTextField(compCtrl, isEn ? 'Company / Business' : 'Empresa / Negocio'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildTextField(locCtrl, isEn ? 'Location' : 'Ciudad, Estado')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField(perCtrl, isEn ? 'Period (e.g. 2024 - Present)' : 'Fechas (ej. 2024 - Present)')),
                ],
              ),
              const SizedBox(height: 8),
              _buildTextField(
                bulletsCtrl,
                isEn ? 'Achievements / Bullets (1 per line)' : 'Logros y Tareas (1 por línea)',
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    final bullets = bulletsCtrl.text
                        .split('\n')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();

                    final newExp = WorkExperience(
                      role: roleCtrl.text.trim().isNotEmpty ? roleCtrl.text.trim() : 'Staff Member',
                      company: compCtrl.text.trim().isNotEmpty ? compCtrl.text.trim() : 'Australian Business',
                      location: locCtrl.text.trim(),
                      period: perCtrl.text.trim(),
                      bulletPoints: bullets.isNotEmpty ? bullets : ['Executed daily responsibilities with high punctuality and accuracy.'],
                    );

                    _syncState(() {
                      if (isNew) {
                        _currentExperiences.add(newExp);
                      } else {
                        _currentExperiences[index] = newExp;
                      }
                    });

                    Navigator.pop(ctx);
                  },
                  child: Text(isEn ? 'Save Experience' : 'Guardar Experiencia'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateAndShareResume(BuildContext context, bool isEn, bool isPremium) async {
    if (!isPremium) {
      showPhase2PaywallBottomSheet(
        context: context,
        featureTitle: isEn ? 'Australian Resume Generator' : 'Generador de CV Australiano',
        featureBenefit: isEn
            ? 'Download official recruiter-ready PDF resumes tailored to Australian hiring laws with no watermarks.'
            : 'Descarga currículums oficiales en PDF adaptados a la ley laboral australiana listos para entregar a empresas.',
      );
      return;
    }

    final visaLabel = _visaSubclass == '462'
        ? 'Working Holiday Visa (Subclass 462) - Full Working Rights'
        : (_visaSubclass == '417'
            ? 'Working Holiday Visa (Subclass 417) - Full Working Rights'
            : 'Student Visa (Subclass 500) - Legal Work Rights');

    final resumeData = AustralianResumeData(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      locationSuburb: _suburbController.text.trim(),
      visaStatus: visaLabel,
      availability: _availability,
      targetIndustry: _selectedIndustry,
      jobTitle: _jobTitleController.text.trim(),
      summary: _summaryController.text.trim(),
      skills: _currentSkills,
      experiences: _currentExperiences,
      certifications: _currentCertifications,
      education: _education,
      linkedIn: _linkedInController.text.trim(),
      themeColorHex: _themeColorHex,
    );

    final pdfBytes = await PdfGeneratorService.generateAustralianResume(resumeData);
    final cleanName = _nameController.text.trim().replaceAll(' ', '_');
    await PdfGeneratorService.shareOrPrintPdf(pdfBytes, 'Resume_${cleanName.isNotEmpty ? cleanName : "Australian"}.pdf');
  }

  String _getVisaLabel() {
    return _visaSubclass == '462'
        ? 'Working Holiday Visa (Subclass 462) - Full Working Rights'
        : (_visaSubclass == '417'
            ? 'Working Holiday Visa (Subclass 417) - Full Working Rights'
            : 'Student Visa (Subclass 500) - Legal Work Rights');
  }

  Future<void> _generateAndShareCoverLetter(BuildContext context, bool isEn, bool isPremium) async {
    if (!isPremium) {
      showPhase2PaywallBottomSheet(
        context: context,
        featureTitle: isEn ? 'Official Australian Cover Letter' : 'Cover Letter Australiana Oficial',
        featureBenefit: isEn
            ? 'Generate customized, recruiter-compliant Australian cover letters that highlight your visa work rights and immediate availability.'
            : 'Genera cartas de presentación adaptadas a ofertas de Seek e Indeed destacando tu permiso de trabajo y disponibilidad.',
      );
      return;
    }

    final visaLabel = _getVisaLabel();
    final pdfBytes = await PdfGeneratorService.generateCoverLetter(
      applicantName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      locationSuburb: _suburbController.text.trim(),
      targetRole: _clRoleController.text.trim(),
      companyName: _clCompanyController.text.trim(),
      visaStatus: visaLabel,
      coverLetterBody: _clBodyController.text.trim(),
      themeColorHex: _themeColorHex,
    );

    final cleanName = _nameController.text.trim().replaceAll(' ', '_');
    await PdfGeneratorService.shareOrPrintPdf(pdfBytes, 'Cover_Letter_${cleanName.isNotEmpty ? cleanName : "Australian"}.pdf');
  }

  Future<void> _generateAndShareRentalBio(BuildContext context, bool isEn, bool isPremium) async {
    if (!isPremium) {
      showPhase2PaywallBottomSheet(
        context: context,
        featureTitle: isEn ? 'Rental & Flatmate Profile' : 'Perfil de Alquiler en Australia',
        featureBenefit: isEn
            ? 'Stand out to landlords and housemates in competitive rental markets with proof of income, bond readiness, and living etiquette.'
            : 'Destaca ante caseros y compañeros en Flatmates con acreditación de solvencia, fianza lista y convivencia impecable.',
      );
      return;
    }

    final visaLabel = _getVisaLabel();
    final pdfBytes = await PdfGeneratorService.generateRentalBio(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      currentCity: _rentCityController.text.trim(),
      budgetAud: _rentBudgetController.text.trim(),
      moveInDate: _rentMoveInController.text.trim(),
      visaStatus: visaLabel,
      employmentStatus: _rentEmploymentController.text.trim(),
      aboutMe: _rentAboutController.text.trim(),
      houseHabits: _rentHabits,
    );

    final cleanName = _nameController.text.trim().replaceAll(' ', '_');
    await PdfGeneratorService.shareOrPrintPdf(pdfBytes, 'Rental_Bio_${cleanName.isNotEmpty ? cleanName : "Australian"}.pdf');
  }

  Future<void> _generateAndShareFairWorkClaim(BuildContext context, bool isEn, bool isPremium) async {
    if (!isPremium) {
      showPhase2PaywallBottomSheet(
        context: context,
        featureTitle: isEn ? 'Fair Work Formal Notice' : 'Reclamación Salarial Fair Work',
        featureBenefit: isEn
            ? 'Demand backpay and unpaid superannuation with a legally drafted formal notice under the Fair Work Act 2009.'
            : 'Exige el pago de salarios impagados y superannuation con una carta formal respaldada por la ley Fair Work Act 2009.',
      );
      return;
    }

    final pdfBytes = await PdfGeneratorService.generateFairWorkClaimLetter(
      employeeName: _nameController.text.trim(),
      employeePhone: _phoneController.text.trim(),
      employeeEmail: _emailController.text.trim(),
      employerName: _fwEmployerNameController.text.trim(),
      employerAbn: _fwEmployerAbnController.text.trim(),
      employmentPeriod: _fwPeriodController.text.trim(),
      totalOwedAud: double.tryParse(_fwOwedAmountController.text.trim()) ?? 0.0,
      underpaymentDetails: _fwDetailsController.text.trim(),
    );

    final cleanName = _nameController.text.trim().replaceAll(' ', '_');
    await PdfGeneratorService.shareOrPrintPdf(pdfBytes, 'FairWork_Claim_${cleanName.isNotEmpty ? cleanName : "Notice"}.pdf');
  }

  Future<void> _generateAndShareResignation(BuildContext context, bool isEn, bool isPremium) async {
    if (!isPremium) {
      showPhase2PaywallBottomSheet(
        context: context,
        featureTitle: isEn ? 'Two-Week Notice Resignation Letter' : 'Carta de Renuncia (2 Semanas)',
        featureBenefit: isEn
            ? 'Resign with standard Australian protocol, guaranteeing your final payslip and essential employer reference.'
            : 'Renuncia con el protocolo australiano estándar de 2 semanas garantizando tu finiquito y carta de recomendación.',
      );
      return;
    }

    final pdfBytes = await PdfGeneratorService.generateResignationLetter(
      employeeName: _nameController.text.trim(),
      employerName: _resEmployerController.text.trim(),
      role: _resRoleController.text.trim(),
      lastWorkingDay: _resLastDay,
      gratitudeMessage: _resGratitudeController.text.trim(),
    );

    final cleanName = _nameController.text.trim().replaceAll(' ', '_');
    await PdfGeneratorService.shareOrPrintPdf(pdfBytes, 'Resignation_${cleanName.isNotEmpty ? cleanName : "Notice"}.pdf');
  }

  Future<void> _generateAndShareRentalBond(BuildContext context, bool isEn, bool isPremium) async {
    if (!isPremium) {
      showPhase2PaywallBottomSheet(
        context: context,
        featureTitle: isEn ? 'Rental Bond Receipt & Shield' : 'Recibo Legal de Fianza y Alquiler',
        featureBenefit: isEn
            ? 'Legally binding receipt protecting your deposit under official Australian tenancy laws.'
            : 'Protege tu dinero con un recibo vinculante que obliga al casero a registrar la fianza en el organismo oficial del estado.',
      );
      return;
    }
    final bondAmount = double.tryParse(_bondAmountController.text.trim()) ?? 0.0;
    final weeklyRent = double.tryParse(_bondWeeklyRentController.text.trim()) ?? 0.0;
    final pdfBytes = await PdfGeneratorService.generateRentalBondReceiptPdf(
      tenantName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Tenant',
      landlordName: _bondLandlordController.text.trim(),
      propertyAddress: _bondPropertyController.text.trim(),
      bondAmountAud: bondAmount,
      weeklyRentAud: weeklyRent,
      moveInDate: _bondMoveInDate,
      paymentMethod: _bondPaymentMethod,
      stateRentalAuthority: _bondStateAuthority,
    );
    // Telemetría comunitaria anónima silenciosa de alquileres
    CommunityTelemetryService().logRentalBond(
      stateAuthority: _bondStateAuthority,
      weeklyRentAud: weeklyRent,
      bondAmountAud: bondAmount,
      propertyAddress: _bondPropertyController.text.trim(),
    );
    await PdfGeneratorService.shareOrPrintPdf(pdfBytes, 'Rental_Bond_Receipt.pdf');
  }

  Future<void> _generateAndShareVehicleSale(BuildContext context, bool isEn, bool isPremium) async {
    if (!isPremium) {
      showPhase2PaywallBottomSheet(
        context: context,
        featureTitle: isEn ? 'Vehicle & Camper Bill of Sale' : 'Contrato Compraventa Coche/Camper',
        featureBenefit: isEn
            ? 'Bilingual contract with PPSR clear title warranty and touch signatures to legally transfer vehicles.'
            : 'Contrato bilingüe con garantía de título limpio PPSR y firmas táctiles para comprar o vender vehículos con total seguridad.',
      );
      return;
    }
    final buyerName = _vehBuyerNameController.text.trim().isNotEmpty
        ? _vehBuyerNameController.text.trim()
        : _nameController.text.trim();
    final buyerPhone = _vehBuyerPhoneController.text.trim().isNotEmpty
        ? _vehBuyerPhoneController.text.trim()
        : _phoneController.text.trim();

    final salePrice = double.tryParse(_vehPriceController.text.trim()) ?? 0.0;
    final pdfBytes = await PdfGeneratorService.generateVehicleBillOfSalePdf(
      buyerName: buyerName,
      buyerPhone: buyerPhone,
      buyerLicenseOrPassport: _vehBuyerIdController.text.trim(),
      sellerName: _vehSellerNameController.text.trim(),
      sellerPhone: _vehSellerPhoneController.text.trim(),
      sellerLicenseOrPassport: _vehSellerIdController.text.trim(),
      makeModel: _vehMakeModelController.text.trim(),
      year: _vehYearController.text.trim(),
      regoNumber: _vehRegoNumberController.text.trim(),
      regoState: _vehRegoState,
      vin: _vehVinController.text.trim(),
      odometerKm: _vehOdometerController.text.trim(),
      salePriceAud: salePrice,
      saleDate: DateTime.now(),
      buyerSignatureBytes: _vehBuyerSignature,
      sellerSignatureBytes: _vehSellerSignature,
    );
    // Telemetría comunitaria anónima silenciosa de vehículos
    CommunityTelemetryService().logVehicleTransaction(
      makeModel: _vehMakeModelController.text.trim(),
      year: _vehYearController.text.trim(),
      regoState: _vehRegoState,
      salePriceAud: salePrice,
      odometerKm: _vehOdometerController.text.trim(),
    );
    await PdfGeneratorService.shareOrPrintPdf(pdfBytes, 'Vehicle_Bill_of_Sale.pdf');
  }

  Future<void> _generateAndShareCondition8547(BuildContext context, bool isEn, bool isPremium) async {
    if (!isPremium) {
      showPhase2PaywallBottomSheet(
        context: context,
        featureTitle: isEn ? 'Condition 8547 Exemption Memo' : 'Memorando Exención Condición 8547',
        featureBenefit: isEn
            ? 'Official legal letter invoking Home Affairs policy to work beyond 6 months for the same employer.'
            : 'Carta formal con directrices de Inmigración para trabajar más de 6 meses con el mismo empleador legalmente.',
      );
      return;
    }
    final pdfBytes = await PdfGeneratorService.generateCondition8547ExemptionMemoPdf(
      employeeName: _nameController.text.trim(),
      passportNumber: _c8547PassportController.text.trim(),
      employerBusinessName: _c8547EmployerController.text.trim(),
      exemptionCategory: _c8547Category,
      workDetails: _c8547DetailsController.text.trim(),
    );
    await PdfGeneratorService.shareOrPrintPdf(pdfBytes, 'Condition_8547_Exemption_Memo.pdf');
  }

  Future<void> _generateAndShareShamContractingClaim(BuildContext context, bool isEn, bool isPremium) async {
    if (!isPremium) {
      showPhase2PaywallBottomSheet(
        context: context,
        featureTitle: isEn ? 'ABN Sham Contracting Demand' : 'Reclamación Falso Autónomo (ABN)',
        featureBenefit: isEn
            ? 'Legally enforce Section 15AA Fair Work Act to claim 25% casual loading and 12% super backpay.'
            : 'Exige el cobro retroactivo del 25% de casual loading y el 12% de superannuation bajo las secciones 15AA y 357 de Fair Work.',
      );
      return;
    }
    final indicators = <String>[];
    if (_shamAnswers[0]) indicators.add('Set working hours controlled entirely by employer with no right of delegation/substitution');
    if (_shamAnswers[1]) indicators.add('All tools, machinery, and equipment provided directly by employer at zero capital cost to worker');
    if (_shamAnswers[2]) indicators.add('Remunerated strictly on hourly basis rather than quoting an agreed lump-sum project price');
    if (_shamAnswers[3]) indicators.add('Direct operational supervision, control, and management by employer representatives');
    if (_shamAnswers[4]) indicators.add('Worker has no independent commercial enterprise, business profile, or multiple independent clients');

    final grossEstimated = double.tryParse(_fwOwedAmountController.text.trim()) ?? 2500.0;
    final pdfBytes = await PdfGeneratorService.generateShamContractingClaimPdf(
      workerName: _nameController.text.trim(),
      workerPhone: _phoneController.text.trim(),
      workerEmail: _emailController.text.trim(),
      employerBusinessName: _fwEmployerNameController.text.trim(),
      employerAbn: _fwEmployerAbnController.text.trim(),
      roleTitle: _jobTitleController.text.trim().isNotEmpty ? _jobTitleController.text.trim() : 'Farm / Regional Hand',
      periodWorked: _fwPeriodController.text.trim(),
      shamIndicators: indicators.isNotEmpty ? indicators : ['Direct employer control and no genuine independent business under Section 15AA'],
      estimatedBackpayAud: grossEstimated * 0.25,
      estimatedSuperAud: grossEstimated * 0.12,
    );
    await PdfGeneratorService.shareOrPrintPdf(pdfBytes, 'Sham_Contracting_Section15AA_Claim.pdf');
  }

  // Formularios de configuración de los nuevos documentos
  Widget _buildRentalBondForm(bool isEn, bool isPremium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isEn ? '🔑 RENTAL BOND SHIELD' : '🔑 ESCUDO DE FIANZA',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF0284C7)),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isEn ? 'Anti-Scam Proof' : 'Anti-Fraude',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isEn ? 'Official Rental & Sublet Bond Receipt' : 'Recibo Oficial de Fianza de Habitación / Piso',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                isEn
                    ? 'Prevents cash bond theft when moving into share-houses. Legally requires landlord or head tenant to lodge funds with the official State Tenancy Board.'
                    : 'Evita perder tu fianza al alquilar habitaciones en Flatmates o casas compartidas. Obliga legalmente al casero o subarrendador a registrar el dinero en el organismo estatal.',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionHeader(
          icon: CupertinoIcons.person_crop_circle_fill,
          title: isEn ? 'Landlord & Property' : 'Datos del Casero y Vivienda',
          subtitle: isEn ? 'Address and receiving party' : 'Nombre de quien cobra y dirección exacta',
        ),
        const SizedBox(height: 8),
        _buildTextField(_bondLandlordController, isEn ? 'Landlord / Head-Tenant Full Name' : 'Nombre Completo del Casero o Head-Tenant'),
        const SizedBox(height: 10),
        _buildTextField(_bondPropertyController, isEn ? 'Rental Premises Address' : 'Dirección del Inmueble Alquilado'),
        const SizedBox(height: 16),

        _buildSectionHeader(
          icon: CupertinoIcons.money_dollar_circle_fill,
          title: isEn ? 'Financial Terms' : 'Importes y Modalidad de Pago',
          subtitle: isEn ? 'Bond and weekly rent in AUD' : 'Fianza y renta pactada en dólares australianos',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTextField(_bondAmountController, isEn ? 'Bond Amount (\$ AUD)' : 'Importe Fianza (\$ AUD)')),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField(_bondWeeklyRentController, isEn ? 'Weekly Rent (\$ AUD)' : 'Renta Semanal (\$ AUD)')),
          ],
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _bondPaymentMethod,
          decoration: InputDecoration(
            labelText: isEn ? 'Payment Method' : 'Método de Pago',
            filled: true,
            fillColor: AppColors.surfaceElevated,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          items: const [
            DropdownMenuItem(value: 'Bank Transfer / OSKO', child: Text('Bank Transfer / OSKO')),
            DropdownMenuItem(value: 'Cash in Hand (with this receipt)', child: Text('Cash with Signed Receipt')),
            DropdownMenuItem(value: 'Bank Cheque / Money Order', child: Text('Bank Cheque')),
          ],
          onChanged: (val) {
            if (val != null) _syncState(() => _bondPaymentMethod = val);
          },
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _bondStateAuthority,
          decoration: InputDecoration(
            labelText: isEn ? 'State Bond Authority' : 'Organismo Estatal de Fianza',
            filled: true,
            fillColor: AppColors.surfaceElevated,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          items: const [
            DropdownMenuItem(value: 'RBO (Rental Bonds Online - NSW)', child: Text('NSW: Rental Bonds Online (RBO)')),
            DropdownMenuItem(value: 'RTBA (Residential Tenancies Bond Authority - VIC)', child: Text('VIC: RTBA Victoria')),
            DropdownMenuItem(value: 'RTA (Residential Tenancies Authority - QLD)', child: Text('QLD: RTA Queensland')),
            DropdownMenuItem(value: 'BondAdministrator (Department of Commerce - WA)', child: Text('WA: BondAdministrator')),
            DropdownMenuItem(value: 'CBS (Consumer and Business Services - SA)', child: Text('SA: CBS South Australia')),
          ],
          onChanged: (val) {
            if (val != null) _syncState(() => _bondStateAuthority = val);
          },
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(CupertinoIcons.arrow_down_doc_fill, size: 20),
            label: Text(
              isEn ? 'Generate Bond Receipt (PDF)' : 'Generar Recibo de Fianza Oficial (PDF)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 2,
            ),
            onPressed: () => _generateAndShareRentalBond(context, isEn, isPremium),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildVehicleSaleForm(bool isEn, bool isPremium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isEn ? '🚗 VEHICLE & CAMPER CONTRACT' : '🚗 CONTRATO COCHE/CAMPER',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFFD97706)),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isEn ? 'PPSR Clear Title' : 'Sin Cargas PPSR',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isEn ? 'Official Vehicle Bill of Sale & Receipt' : 'Contrato Legal de Compraventa de Vehículo',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                isEn
                    ? 'Protects buyer and seller across WA, NSW, QLD, VIC with statutory title warranty, VIN particulars, and touch signatures.'
                    : 'Protege a comprador y vendedor al comprar o vender coches o furgonetas en Australia, garantizando la titularidad sin deudas financieras.',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionHeader(
          icon: CupertinoIcons.car_detailed,
          title: isEn ? 'Vehicle Particulars' : 'Datos del Vehículo o Campervan',
          subtitle: isEn ? 'Make, model, VIN and Rego plate' : 'Marca, modelo, VIN y matrícula',
        ),
        const SizedBox(height: 8),
        _buildTextField(_vehMakeModelController, isEn ? 'Make & Model (e.g. Toyota HiAce)' : 'Marca y Modelo'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildTextField(_vehYearController, isEn ? 'Year' : 'Año')),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField(_vehOdometerController, isEn ? 'Odometer (Kms)' : 'Kilómetros')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildTextField(_vehRegoNumberController, isEn ? 'Rego Plate' : 'Matrícula (Placa)')),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField(_vehPriceController, isEn ? 'Price (\$ AUD)' : 'Precio (\$ AUD)')),
          ],
        ),
        const SizedBox(height: 10),
        _buildTextField(_vehVinController, isEn ? 'VIN / Chassis Number (17 chars)' : 'Número de Bastidor / VIN (17 caracteres)'),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _vehRegoState,
          decoration: InputDecoration(
            labelText: isEn ? 'Registration State' : 'Estado de Matriculación (Rego)',
            filled: true,
            fillColor: AppColors.surfaceElevated,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          items: const [
            DropdownMenuItem(value: 'WA (Western Australia)', child: Text('WA (Western Australia - Sin RWC)')),
            DropdownMenuItem(value: 'NSW (New South Wales)', child: Text('NSW (New South Wales)')),
            DropdownMenuItem(value: 'QLD (Queensland)', child: Text('QLD (Queensland)')),
            DropdownMenuItem(value: 'VIC (Victoria)', child: Text('VIC (Victoria)')),
            DropdownMenuItem(value: 'SA (South Australia)', child: Text('SA (South Australia)')),
          ],
          onChanged: (val) {
            if (val != null) _syncState(() => _vehRegoState = val);
          },
        ),
        const SizedBox(height: 16),

        _buildSectionHeader(
          icon: CupertinoIcons.person_2_fill,
          title: isEn ? 'Seller & Buyer Particulars' : 'Datos del Vendedor y Comprador',
          subtitle: isEn ? 'Contacts and touch signatures' : 'Identificación y firmas digitales',
        ),
        const SizedBox(height: 8),
        _buildTextField(_vehSellerNameController, isEn ? 'Seller Name' : 'Nombre del Vendedor'),
        const SizedBox(height: 8),
        _buildTextField(_vehSellerPhoneController, isEn ? 'Seller Phone' : 'Teléfono del Vendedor'),
        const SizedBox(height: 8),
        _buildTextField(_vehSellerIdController, isEn ? 'Seller License/Passport' : 'Pasaporte / Carnet del Vendedor'),
        const SizedBox(height: 12),

        // Firmas táctiles
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(_vehSellerSignature != null ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.pencil, size: 16),
                label: Text(
                  _vehSellerSignature != null ? (isEn ? 'Seller Signed ✓' : 'Firma Vendedor ✓') : (isEn ? 'Sign (Seller)' : 'Firmar Vendedor'),
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _vehSellerSignature != null ? const Color(0xFF0D9488) : AppColors.primary,
                  side: BorderSide(color: _vehSellerSignature != null ? const Color(0xFF0D9488) : AppColors.cardBorder),
                ),
                onPressed: () async {
                  final bytes = await showDialog<Uint8List>(
                    context: context,
                    builder: (ctx) => SignaturePadDialog(
                      title: isEn ? 'Seller Signature' : 'Firma del Vendedor',
                      subtitle: isEn ? 'Sign with finger on screen' : 'Firma con el dedo para el contrato',
                    ),
                  );
                  if (bytes != null) {
                    _syncState(() => _vehSellerSignature = bytes);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(_vehBuyerSignature != null ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.pencil, size: 16),
                label: Text(
                  _vehBuyerSignature != null ? (isEn ? 'Buyer Signed ✓' : 'Firma Comprador ✓') : (isEn ? 'Sign (Buyer)' : 'Firmar Comprador'),
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _vehBuyerSignature != null ? const Color(0xFF0D9488) : AppColors.secondary,
                  side: BorderSide(color: _vehBuyerSignature != null ? const Color(0xFF0D9488) : AppColors.cardBorder),
                ),
                onPressed: () async {
                  final bytes = await showDialog<Uint8List>(
                    context: context,
                    builder: (ctx) => SignaturePadDialog(
                      title: isEn ? 'Buyer Signature' : 'Firma del Comprador',
                      subtitle: isEn ? 'Sign with finger on screen' : 'Firma con el dedo para el contrato',
                    ),
                  );
                  if (bytes != null) {
                    _syncState(() => _vehBuyerSignature = bytes);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(CupertinoIcons.arrow_down_doc_fill, size: 20),
            label: Text(
              isEn ? 'Generate Bill of Sale (PDF)' : 'Generar Contrato Compraventa (PDF)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 2,
            ),
            onPressed: () => _generateAndShareVehicleSale(context, isEn, isPremium),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCondition8547Form(bool isEn, bool isPremium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isEn ? '🏢 CONDITION 8547 EXEMPTION' : '🏢 EXENCIÓN CONDICIÓN 8547',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF8B5CF6)),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isEn ? 'Home Affairs LIN 22/050' : 'Ley LIN 22/050',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isEn ? 'Condition 8547 Exemption Memorandum' : 'Memorando Legal de Exención de 6 Meses',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                isEn
                    ? 'Official HR advisory letter invoking Home Affairs policy to permit employment beyond 6 months with the same business at different sites or sectors without departmental permission.'
                    : 'Escrito formal para Recursos Humanos que acredita que puedes seguir trabajando más de 6 meses con la misma empresa (en distintas sedes, hostelería o agricultura) sin cometer infracción.',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionHeader(
          icon: CupertinoIcons.building_2_fill,
          title: isEn ? 'Employer & Category' : 'Empresa y Categoría de Exención',
          subtitle: isEn ? 'Business name and statutory exemption' : 'Nombre de la empresa y causa legal',
        ),
        const SizedBox(height: 8),
        _buildTextField(_c8547EmployerController, isEn ? 'Employer Business Name' : 'Nombre de la Empresa'),
        const SizedBox(height: 10),
        _buildTextField(_c8547PassportController, isEn ? 'Your Passport Number' : 'Número de Pasaporte del Trabajador'),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _c8547Category,
          decoration: InputDecoration(
            labelText: isEn ? 'Exemption Category' : 'Categoría de Exención Aplicable',
            filled: true,
            fillColor: AppColors.surfaceElevated,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          items: [
            DropdownMenuItem(
              value: 'different_locations',
              child: Text(isEn ? 'Different Business Locations (LIN 22/050)' : 'Diferentes Sedes / Ubicaciones (LIN 22/050)'),
            ),
            DropdownMenuItem(
              value: 'agriculture',
              child: Text(isEn ? 'Plant & Animal Cultivation (Agriculture)' : 'Agricultura, Fruta y Ganadería'),
            ),
            DropdownMenuItem(
              value: 'hospitality',
              child: Text(isEn ? 'Tourism & Hospitality Nationwide' : 'Hostelería y Turismo'),
            ),
            DropdownMenuItem(
              value: 'disaster_recovery',
              child: Text(isEn ? 'Natural Disaster Recovery Works' : 'Recuperación de Desastres Naturales'),
            ),
          ],
          onChanged: (val) {
            if (val != null) _syncState(() => _c8547Category = val);
          },
        ),
        const SizedBox(height: 10),
        _buildTextField(_c8547DetailsController, isEn ? 'Operational Evidence & Work Particulars' : 'Justificación y Detalles del Trabajo', maxLines: 3),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(CupertinoIcons.arrow_down_doc_fill, size: 20),
            label: Text(
              isEn ? 'Generate Exemption Memo (PDF)' : 'Generar Memorando Exención (PDF)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 2,
            ),
            onPressed: () => _generateAndShareCondition8547(context, isEn, isPremium),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  void _showPayslipScannerSheet(BuildContext context, bool isEn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final keyboardInset = MediaQuery.of(ctx).viewInsets.bottom;
            final parsed = _lastParsedPayslip;
            return AnimatedPadding(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: keyboardInset),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.90,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 6),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(CupertinoIcons.doc_text_search, color: AppColors.primary, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  isEn ? 'Digital Payslip Scanner (Free)' : 'Escáner de Nómina (Gratuito)',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textMuted),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.cardBorder),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEn
                                  ? 'Paste the text from your payslip PDF, email, Xero, MYOB or KeyPay:'
                                  : 'Pega el texto de tu nómina en PDF, email, Xero, MYOB o KeyPay:',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _payslipRawTextController,
                              maxLines: 5,
                              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                              decoration: InputDecoration(
                                hintText: isEn ? 'Paste payslip text here...' : 'Pega el texto de la nómina aquí...',
                                filled: true,
                                fillColor: AppColors.surfaceElevated,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 16),
                                    label: Text(isEn ? 'Paste' : 'Pegar'),
                                    onPressed: () async {
                                      final cdata = await Clipboard.getData(Clipboard.kTextPlain);
                                      if (cdata?.text != null) {
                                        setModalState(() {
                                          _payslipRawTextController.text = cdata!.text!;
                                        });
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(CupertinoIcons.sparkles, size: 16),
                                    label: Text(isEn ? 'Audit Now' : 'Auditar Nómina'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () {
                                      final res = PayslipParserService.parse(
                                        _payslipRawTextController.text,
                                        selectedAwardId: _selectedAwardId,
                                        isCasual: _isCasualContract,
                                      );
                                      setModalState(() {
                                        _lastParsedPayslip = res;
                                      });
                                      if (res.hoursWorked != null && res.grossPay != null) {
                                        _communityIntelRepo.logAnonymousShiftMetrics(
                                          postcode: '',
                                          abn: res.abn,
                                          hours: res.hoursWorked!,
                                          grossPay: res.grossPay!,
                                          isFairWorkCompliant: !(res.fairWorkAudit?['isUnderpaid'] ?? false),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (parsed != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          isEn ? 'Extracted ABN:' : 'ABN Detectado:',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: parsed.isAbnChecksumValid
                                                ? const Color(0xFF0D9488).withValues(alpha: 0.15)
                                                : AppColors.statusClosed.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            parsed.abn != null
                                                ? '${parsed.abn} (${parsed.isAbnChecksumValid ? "Válido" : "Inválido"})'
                                                : (isEn ? 'Not found' : 'No detectado'),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: parsed.isAbnChecksumValid ? const Color(0xFF0D9488) : AppColors.statusClosed,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 14),
                                    _buildPayRow(isEn ? 'Gross Pay' : 'Salario Bruto', '\$${parsed.grossPay?.toStringAsFixed(2) ?? "---"} AUD'),
                                    _buildPayRow(isEn ? 'Hours' : 'Horas', '${parsed.hoursWorked?.toStringAsFixed(1) ?? "---"} h'),
                                    _buildPayRow(isEn ? 'Effective Rate' : 'Tarifa por Hora', '\$${parsed.hourlyRate?.toStringAsFixed(2) ?? "---"}/h'),
                                    _buildPayRow(isEn ? 'Tax Withheld' : 'Impuesto Retenido (PAYG)', '\$${parsed.taxWithheld?.toStringAsFixed(2) ?? "---"} AUD'),
                                    _buildPayRow(isEn ? 'Superannuation' : 'Superannuation (12%)', '\$${parsed.superannuation?.toStringAsFixed(2) ?? "---"} AUD'),
                                    if (parsed.fairWorkAudit != null) ...[
                                      const Divider(height: 14),
                                      if (parsed.fairWorkAudit!['isUnderpaid'] == true) ...[
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.statusClosed.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: AppColors.statusClosed, size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  isEn
                                                      ? '⚠️ Underpayment of \$${parsed.fairWorkAudit!["underpaidAmount"].toStringAsFixed(2)} AUD detected!'
                                                      : '⚠️ ¡Infrasueldo de \$${parsed.fairWorkAudit!["underpaidAmount"].toStringAsFixed(2)} AUD detectado!',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.statusClosed),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            onPressed: () {
                                              if (parsed.abn != null) {
                                                _fwEmployerAbnController.text = parsed.abn!;
                                              }
                                              _fwOwedAmountController.text = parsed.fairWorkAudit!["underpaidAmount"].toStringAsFixed(2);
                                              Navigator.pop(modalCtx);
                                              _openDocumentAssistantModal(context, 'fair_work_claim', isEn, true);
                                            },
                                            child: Text(isEn ? 'Transfer to Formal Wage Claim' : 'Llevar a Reclamación Formal'),
                                          ),
                                        ),
                                      ] else ...[
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(CupertinoIcons.checkmark_seal_fill, color: Color(0xFF0D9488), size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  isEn
                                                      ? '✅ Payslip matches or exceeds legal Fair Work minimum award rates!'
                                                      : '✅ ¡Tu nómina cumple o supera los mínimos legales de Fair Work!',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0D9488)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                    if (parsed.taxAudit != null && parsed.taxAudit!['issueType'] != 'correct_15') ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          parsed.taxAudit!['warning'] ?? '',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // PESTAÑA 2: CALCULADORA FAIR WORK & SUITE LEGAL
  // ==========================================
  Widget _buildFairWorkTab(String lang, bool isEn, bool isPremium) {
    final award = FairWorkService.getAwardById(_selectedAwardId);
    final payCalc = FairWorkService.calculateShiftPay(
      hours: _hoursWorked,
      isCasual: _isCasualContract,
      dayType: _dayType,
      awardId: _selectedAwardId,
    );

    final shamYesCount = _shamAnswers.where((a) => a).length;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // 1. Banner Destacado Hub Fiscal & Rego
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF0D9488).withValues(alpha: 0.16), AppColors.surfaceElevated],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.money_dollar_circle_fill, color: Color(0xFF0D9488), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Tax Hub: 2% Medicare MES & WA Rego' : 'Hub Fiscal: Exención Medicare 2% & Coche WA',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEn ? 'Calculate your \$900+ refund & PPSR car checks' : 'Calcula tu devolución de +\$900 AUD y revisión de cargas PPSR',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => TaxAndVehicleHubModal.show(context, lang: lang, isEn: isEn),
                child: Text(isEn ? 'Open' : 'Abrir', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Selector de Convenio Colectivo (Modern Awards 2026)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'Modern Award 2026 (Fair Work)' : 'Convenio Colectivo Oficial 2026',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Award Code: ${award.code}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => showOfficialSourcesModal(context, lang: lang, isEn: isEn, initialTopic: 'fair_work'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.info_circle_fill, size: 16, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            isEn ? 'Law' : 'Ley',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedAwardId,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                items: FairWorkService.officialAwards.map((aw) {
                  return DropdownMenuItem(
                    value: aw.id,
                    child: Text(aw.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedAwardId = val);
                },
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.lightbulb_fill, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        award.specialRuleNote,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? 'Base Rate (FT/PT)' : 'Salario Base FT',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$${award.baseHourlyRate.toStringAsFixed(2)} / hr',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Casual (+25%)',
                            style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$${award.casualHourlyRate.toStringAsFixed(2)} / hr',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Botón Destacado: Escáner de Nóminas Digital (100% Gratis y Offline)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.doc_text_search, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Free Payslip Scanner' : 'Escáner Digital de Nómina',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
                    ),
                    Text(
                      isEn ? 'Audit ABN, 15% tax & 12% super offline' : 'Audita tu ABN, 15% IRPF y 12% super gratis',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showPayslipScannerSheet(context, isEn),
                child: Text(isEn ? 'Scan' : 'Escanear', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Tipo de Contrato
        Text(
          isEn ? 'Contract Type' : 'Tipo de Contrato',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isCasualContract = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    decoration: BoxDecoration(
                      color: _isCasualContract ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Casual (+25%)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isCasualContract ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isCasualContract = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    decoration: BoxDecoration(
                      color: !_isCasualContract ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isEn ? 'Full / Part-Time' : 'Completa / Media',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !_isCasualContract ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Tipo de Turno / Penalizaciones
        Text(
          isEn ? 'Shift Type & Penalty Rates' : 'Turno y Penalizaciones de Fin de Semana',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildShiftChip('weekday', isEn ? 'Weekday (Normal)' : 'Entre Semana (100%)'),
            _buildShiftChip('saturday', isEn ? 'Saturday (150%)' : 'Sábado (150%)'),
            _buildShiftChip('sunday', isEn ? 'Sunday (175%)' : 'Domingo (175%)'),
            _buildShiftChip('public_holiday', isEn ? 'Public Holiday (225%)' : 'Festivo (225%)'),
          ],
        ),
        const SizedBox(height: 18),

        // Horas Trabajadas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEn ? 'Hours Worked' : 'Horas Trabajadas',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_hoursWorked.toStringAsFixed(1)} h',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondary),
              ),
            ),
          ],
        ),
        Slider(
          value: _hoursWorked,
          min: 1.0,
          max: 60.0,
          divisions: 59,
          activeColor: AppColors.secondary,
          inactiveColor: AppColors.surfaceElevated,
          onChanged: (val) => setState(() => _hoursWorked = val),
        ),
        const SizedBox(height: 12),

        // Tarjeta de Desglose Salarial
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            children: [
              _buildPayRow(isEn ? 'Effective Hourly Rate' : 'Tarifa por Hora', '\$${payCalc['effectiveHourlyRate']!.toStringAsFixed(2)} AUD/h'),
              const Divider(height: 16),
              _buildPayRow(isEn ? 'Expected Gross Pay' : 'Salario Bruto Legal', '\$${payCalc['grossPay']!.toStringAsFixed(2)} AUD', isBold: true),
              const Divider(height: 16),
              _buildPayRow(isEn ? 'Superannuation (12% Extra)' : 'Superannuation (12% Extra)', '\$${payCalc['superannuationPay']!.toStringAsFixed(2)} AUD', color: AppColors.secondary),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 5. ABN Sham Contracting Shield (Test de Falso Autónomo - Sección 15AA)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: shamYesCount >= 3 ? AppColors.statusClosed : AppColors.cardBorder,
              width: shamYesCount >= 3 ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (shamYesCount >= 3 ? AppColors.statusClosed : AppColors.secondary).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      CupertinoIcons.shield_lefthalf_fill,
                      color: shamYesCount >= 3 ? AppColors.statusClosed : AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'ABN Sham Contracting Shield' : 'Test Falso Autónomo (Ley 15AA)',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                        ),
                        Text(
                          isEn ? 'Fair Work Act 2026 - Whole of Relationship Test' : 'Detecta si te obligaron a abrir ABN ilegalmente',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isEn
                    ? 'Answer these 5 questions based on your day-to-day work:'
                    : 'Responde a estas 5 preguntas sobre tu día a día en el puesto:',
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              ...[
                isEn ? '1. Boss decides your exact hours with no right of substitution?' : '1. ¿Tu jefe fija tu horario exacto y no puedes enviar a otro en tu lugar?',
                isEn ? '2. Company provides all tools, equipment, or machinery?' : '2. ¿La empresa te proporciona todas las herramientas y maquinaria?',
                isEn ? '3. Paid on an hourly rate instead of fixed quoted job price?' : '3. ¿Cobras una tarifa por hora en vez de un presupuesto por obra acabada?',
                isEn ? '4. Directly supervised and managed by employer staff?' : '4. ¿Tu trabajo es supervisado y dirigido directamente por la empresa?',
                isEn ? '5. You have no independent business or other direct clients?' : '5. ¿No tienes un negocio propio real con otros clientes en Australia?',
              ].asMap().entries.map((entry) {
                final idx = entry.key;
                final qText = entry.value;
                final isChecked = _shamAnswers[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: () => setState(() => _shamAnswers[idx] = !_shamAnswers[idx]),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isChecked ? AppColors.statusClosed.withValues(alpha: 0.08) : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isChecked ? AppColors.statusClosed.withValues(alpha: 0.3) : AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isChecked ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                            size: 18,
                            color: isChecked ? AppColors.statusClosed : AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              qText,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                                color: isChecked ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              if (shamYesCount >= 3) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.statusClosed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn
                            ? '⚠️ HIGH RISK: ILLEGAL SHAM CONTRACTING DETECTED'
                            : '⚠️ RIESGO ALTO: FALSO AUTÓNOMO DETECTADO',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.statusClosed),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEn
                            ? 'Under Section 15AA, you are legally an employee! You are entitled to 25% casual loading and 12% superannuation backpay.'
                            : 'Bajo la Sección 15AA de Fair Work, ¡eres legalmente un empleado! Tienes derecho a reclamar el +25% de casual loading y el 12% de superannuation impagados.',
                        style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, height: 1.35),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(CupertinoIcons.arrow_down_doc_fill, size: 16),
                          label: Text(
                            isEn ? 'Generate Section 15AA Claim (PDF)' : 'Generar Reclamación Falso Autónomo (PDF)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.statusClosed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _generateAndShareShamContractingClaim(context, isEn, isPremium),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  isEn ? '✅ Low risk of sham contracting based on current answers.' : '✅ Riesgo bajo de falso autónomo según las respuestas seleccionadas.',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 6. Auditor Manual Rápido (Gross Pay)
        PremiumFeatureGate(
          featureTitle: isEn ? 'Payslip Underpayment Auditor' : 'Auditor de Nóminas Anti-Fraude',
          featureBenefit: isEn
              ? 'Check if your employer is paying below the legal Fair Work award and auto-generate formal claim emails.'
              : 'Detecta si tu empleador te está pagando por debajo de ley y genera un texto formal de reclamación legal ante Fair Work.',
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Payslip Checker: Enter your gross pay' : 'Comprobar Salario Bruto Percibido',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                _buildTextField(_grossPaidController, isEn ? 'Gross Paid in AUD' : 'Importe bruto pagado en AUD'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final paid = double.tryParse(_grossPaidController.text) ?? 0.0;
                      final expected = payCalc['grossPay']!;
                      final diff = expected - paid;

                      if (diff > 5.0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.statusClosed,
                            content: Text(
                              isEn
                                  ? '⚠️ Underpayment detected! You are owed at least \$${diff.toStringAsFixed(2)} AUD under Fair Work award.'
                                  : '⚠️ ¡Posible infrasueldo! Tu empleador te debe al menos \$${diff.toStringAsFixed(2)} AUD según las tablas oficiales.',
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.statusOpen,
                            content: Text(
                              isEn
                                  ? '✅ Approved! The payslip matches or exceeds legal minimum rates.'
                                  : '✅ ¡Correcto! Tu nómina cumple o supera los mínimos legales de Fair Work.',
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isEn ? 'Check Payslip' : 'Comprobar Nómina'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildShiftChip(String id, String label) {
    final isSelected = _dayType == id;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.secondary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isSelected ? AppColors.secondary : AppColors.cardBorder),
      ),
      onSelected: (val) => setState(() => _dayType = id),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      scrollPadding: EdgeInsets.only(bottom: maxLines > 1 ? 240 : 140),
      style: const TextStyle(fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPayRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13.5,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
