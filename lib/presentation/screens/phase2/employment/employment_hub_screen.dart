import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/fair_work_service.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../../domain/models/phase2/resume_data.dart';
import '../../../widgets/phase2/premium_feature_gate.dart';
import '../../../widgets/phase2/paywall_bottom_sheet.dart';
import 'package:ozvisa_alert/presentation/widgets/phase2/phase2_app_bar.dart';
import 'package:ozvisa_alert/presentation/widgets/phase2/official_sources_modal.dart';

class EmploymentHubScreen extends ConsumerStatefulWidget {
  const EmploymentHubScreen({super.key});

  @override
  ConsumerState<EmploymentHubScreen> createState() => _EmploymentHubScreenState();
}

class _EmploymentHubScreenState extends ConsumerState<EmploymentHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form Controllers para CV
  final _nameController = TextEditingController(text: 'Alejandro Morales');
  final _phoneController = TextEditingController(text: '+61 412 345 678');
  final _emailController = TextEditingController(text: 'alejandro.whv@gmail.com');
  final _suburbController = TextEditingController(text: 'Surry Hills, NSW');
  final _summaryController = TextEditingController(
    text: 'Enthusiastic and hardworking professional with full working rights in Australia. Experienced in customer service, bar preparation and team coordination with high attention to detail.',
  );
  String _selectedIndustry = 'hospitality';

  // Calculadora Fair Work
  double _hoursWorked = 38.0;
  bool _isCasualContract = true;
  String _dayType = 'weekday';
  final _grossPaidController = TextEditingController(text: '1255.90');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _suburbController.dispose();
    _summaryController.dispose();
    _grossPaidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isEn = locale?.languageCode == 'en';
    final profile = ref.watch(userProfileProvider).value;
    final isPremium = profile?.isPremium ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: Phase2AppBar(
        title: isEn ? 'Jobs & Documents' : 'Empleo & Formatos',
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
            Tab(text: isEn ? '📄 Resume Builder' : '📄 Generador CV'),
            Tab(text: isEn ? '💰 Fair Work Pay' : '💰 Calculadora Sueldo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // PESTAÑA 1: GENERADOR DE CV AUSTRALIANO
          _buildResumeBuilderTab(isEn, isPremium),

          // PESTAÑA 2: CALCULADORA FAIR WORK
          _buildFairWorkTab(isEn, isPremium),
        ],
      ),
    );
  }

  Widget _buildResumeBuilderTab(bool isEn, bool isPremium) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Regla de Oro Australiana (Anti-Discriminación)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(CupertinoIcons.info_circle_fill, color: AppColors.secondary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isEn
                      ? 'Australian Law strictly forbids photos, age, marital status, or nationality on resumes. Australian employers only evaluate visa rights and immediate availability.'
                      : 'La ley australiana prohíbe fotos, edad o estado civil en el CV. Los empleadores buscan exclusivamente visado legal (Full Work Rights) y disponibilidad inmediata.',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Sector objetivo
        Text(
          isEn ? 'Target Industry' : 'Sector de Empleo',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildIndustryChip('hospitality', isEn ? '☕ Hospitality' : '☕ Hostelería'),
            _buildIndustryChip('construction', isEn ? '🏗️ Construction' : '🏗️ Construcción'),
            _buildIndustryChip('farm', isEn ? '🚜 Farm / Harvest' : '🚜 Granja'),
            _buildIndustryChip('corporate', isEn ? '💻 Corporate' : '💻 Oficina'),
          ],
        ),
        const SizedBox(height: 18),

        // Datos Personales
        Text(
          isEn ? 'Personal Details' : 'Datos Personales',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        _buildTextField(_nameController, isEn ? 'Full Name' : 'Nombre Completo'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildTextField(_phoneController, isEn ? 'Phone (+61)' : 'Móvil (+61)')),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField(_suburbController, isEn ? 'Suburb, State' : 'Barrio, Estado')),
          ],
        ),
        const SizedBox(height: 10),
        _buildTextField(_emailController, isEn ? 'Email' : 'Correo Electrónico'),
        const SizedBox(height: 18),

        // Perfil Profesional
        Text(
          isEn ? 'Professional Summary' : 'Perfil Profesional Corto',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        _buildTextField(_summaryController, isEn ? 'Professional Summary' : 'Extracto Profesional', maxLines: 3),
        const SizedBox(height: 20),

        // Botón Generar PDF con Paywall
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(CupertinoIcons.doc_text_fill, size: 18),
            label: Text(
              isEn ? 'Download Australian Resume (PDF)' : 'Generar CV Oficial Australiano (PDF)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () async {
              if (!isPremium) {
                showPhase2PaywallBottomSheet(
                  context: context,
                  featureTitle: isEn ? 'Pro Australian Resume' : 'Generador de CV Australiano',
                  featureBenefit: isEn
                      ? 'Download official recruiter-ready PDF resumes tailored to Australian hiring laws with no watermarks.'
                      : 'Descarga currículums oficiales en PDF adaptados a la ley laboral australiana listos para entregar a empresas.',
                );
                return;
              }

              final resumeData = AustralianResumeData(
                fullName: _nameController.text,
                phone: _phoneController.text,
                email: _emailController.text,
                locationSuburb: _suburbController.text,
                visaStatus: 'Working Holiday Visa (Subclass 462) - Full Working Rights',
                availability: 'Immediate Start - Full Time & Weekends Available',
                targetIndustry: _selectedIndustry,
                summary: _summaryController.text,
                skills: const ['Customer Service', 'Cash Handling', 'Teamwork', 'Communication'],
                experiences: [
                  WorkExperience(
                    role: _selectedIndustry == 'hospitality' ? 'Barista & All-Rounder' : 'Labourer & Trade Assistant',
                    company: 'The Grounds & Co.',
                    location: 'Sydney, NSW',
                    period: '2024 - Present',
                    bulletPoints: const [
                      'Delivered high-volume customer service during peak morning rush with high accuracy.',
                      'Maintained strict Australian hygiene and workplace health and safety (WHS) standards.',
                    ],
                  ),
                ],
                certifications: const ['RSA NSW (Responsible Service of Alcohol)', 'First Aid Level 2'],
              );

              final pdfBytes = await PdfGeneratorService.generateAustralianResume(resumeData);
              await PdfGeneratorService.shareOrPrintPdf(pdfBytes, 'Resume_${_nameController.text.replaceAll(' ', '_')}.pdf');
            },
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFairWorkTab(bool isEn, bool isPremium) {
    final payCalc = FairWorkService.calculateShiftPay(
      hours: _hoursWorked,
      isCasual: _isCasualContract,
      dayType: _dayType,
    );

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Indicador de Salario Mínimo Nacional Oficial
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
                    child: Text(
                      isEn ? '2026 Fair Work Minimum Wage' : 'Tarifas Mínimas Fair Work 2026',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimary),
                    ),
                  ),
                  InkWell(
                    onTap: () => showOfficialSourcesModal(context, isEn: isEn, initialTopic: 'fair_work'),
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
                            isEn ? 'Full-Time Base' : 'Salario Base FT',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '\$26.44 / hr',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary),
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
                          Text(
                            isEn ? 'Casual (+25%)' : 'Mínimo Casual (+25%)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '\$33.05 / hr',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.primary),
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
        const SizedBox(height: 18),

        // Tipo de Contrato (Segmented Selector nativo para evitar recortes)
        Text(
          isEn ? 'Contract Type' : 'Tipo de Contrato',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isCasualContract = true),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: _isCasualContract ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isEn ? 'Casual (+25% Loading)' : 'Casual (+25% Loading)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: _isCasualContract ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isCasualContract = false),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: !_isCasualContract ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isEn ? 'Full-Time / Part-Time' : 'Tiempo Completo / Parcial',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: !_isCasualContract ? Colors.white : AppColors.textPrimary,
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
          isEn ? 'Shift & Penalty Rate' : 'Turno & Penalización Legal',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildShiftChip('weekday', isEn ? 'Weekday (Normal)' : 'Lunes a Viernes'),
            _buildShiftChip('saturday', isEn ? 'Saturday (150%)' : 'Sábado (150%)'),
            _buildShiftChip('sunday', isEn ? 'Sunday (175%)' : 'Domingo (175%)'),
            _buildShiftChip('public_holiday', isEn ? 'Public Holiday (250%)' : 'Festivo (250%)'),
          ],
        ),
        const SizedBox(height: 18),

        // Horas trabajadas con slider limpio
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
                borderRadius: BorderRadius.circular(8),
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

        // Auditor de Nómina (Paywall Gate)
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
                  isEn ? 'Auditor: Paste your gross payslip' : 'Auditor: Comprueba tu Nómina',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                _buildTextField(_grossPaidController, isEn ? 'Gross Paid in AUD' : 'Importe bruto pagado en AUD'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isEn ? 'Audit Payslip' : 'Auditar Nómina'),
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

  Widget _buildIndustryChip(String id, String label) {
    final isSelected = _selectedIndustry == id;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
      ),
      onSelected: (val) => setState(() => _selectedIndustry = id),
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
      style: const TextStyle(fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
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
