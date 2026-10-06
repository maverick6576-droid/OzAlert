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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          isEn ? 'Jobs & Documents' : 'Empleo & Documentos',
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 22),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: isEn ? '📄 Resume Builder' : '📄 Generador de CV'),
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
      padding: const EdgeInsets.all(16),
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
              const Icon(CupertinoIcons.info_circle_fill, color: AppColors.secondary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isEn
                      ? 'Australian Law strictly forbids photos, date of birth, marital status, or nationality on resumes to avoid bias. Australian employers focus purely on visa rights and availability.'
                      : 'La ley australiana prohíbe fotos, fecha de nacimiento o estado civil en el currículum. Los empleadores buscan visado legal explícito y disponibilidad inmediata.',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Sector objetivo
        Text(isEn ? 'Target Industry:' : 'Sector de Empleo:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildIndustryChip('hospitality', isEn ? '☕ Hospitality' : '☕ Hostelería'),
            _buildIndustryChip('construction', isEn ? '🏗️ Construction' : '🏗️ Construcción'),
            _buildIndustryChip('farm', isEn ? '🚜 Farm / Harvest' : '🚜 Granja'),
            _buildIndustryChip('corporate', isEn ? '💻 Corporate' : '💻 Oficina'),
          ],
        ),
        const SizedBox(height: 16),

        _buildTextField(_nameController, isEn ? 'Full Name' : 'Nombre Completo'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField(_phoneController, isEn ? 'Phone (+61)' : 'Teléfono (+61)')),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(_suburbController, isEn ? 'Location (Suburb, State)' : 'Ubicación (Barrio, Estado)')),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(_emailController, isEn ? 'Email' : 'Correo electrónico'),
        const SizedBox(height: 12),
        _buildTextField(_summaryController, isEn ? 'Professional Summary' : 'Perfil Profesional', maxLines: 3),
        const SizedBox(height: 24),

        // Botón de Exportación PDF con bloqueo Freemium
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(isPremium ? CupertinoIcons.arrow_down_doc_fill : CupertinoIcons.lock_fill),
            label: Text(
              isEn ? 'Export Clean Australian Resume (PDF)' : 'Exportar CV Oficial en PDF',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPremium ? AppColors.secondary : AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              if (!isPremium) {
                showPhase2PaywallBottomSheet(
                  context: context,
                  featureTitle: isEn ? 'Australian Resume Pro' : 'Generador de CV Australiano',
                  featureBenefit: isEn
                      ? 'Download your watermark-free, ATS-friendly Australian resume in PDF ready to hand to employers.'
                      : 'Descarga tu CV sin marca de agua adaptado a los estándares australianos en PDF listo para imprimir o enviar.',
                );
                return;
              }

              // Usuario Premium: Generar PDF nativo
              final resumeData = AustralianResumeData(
                fullName: _nameController.text.trim(),
                phone: _phoneController.text.trim(),
                email: _emailController.text.trim(),
                locationSuburb: _suburbController.text.trim(),
                visaStatus: 'Work & Holiday Visa (Subclass 462) - Full Working Rights',
                availability: 'Immediate Start - Full 7 days flexibility',
                targetIndustry: _selectedIndustry,
                summary: _summaryController.text.trim(),
                skills: ['Customer Service', 'Cash Handling', 'Fast Learner', 'Punctual & Reliable'],
                experiences: [
                  const WorkExperience(
                    role: 'Customer Service & Team Member',
                    company: 'Beachside Cafe & Bar',
                    location: 'Sydney, NSW',
                    period: '2025 - Present',
                    bulletPoints: [
                      'Prepared coffee orders and assisted with high-volume customer service during peak morning rush.',
                      'Maintained strict food hygiene and safety standards across workstation.',
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
      padding: const EdgeInsets.all(16),
      children: [
        // Indicador de Salario Mínimo Nacional Oficial
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
              Text(
                isEn ? 'Official 2026 Fair Work Minimum Rates' : 'Tarifas Mínimas Fair Work Australia 2026',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEn ? 'Base Full-Time Rate' : 'Salario Base Full-Time', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const Text('\$26.44 / hr', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(isEn ? 'Casual Rate (+25%)' : 'Salario Mínimo Casual (+25%)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const Text('\$33.05 / hr', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Selectores de la calculadora
        Text(isEn ? 'Contract Type:' : 'Tipo de Contrato:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: Center(child: Text(isEn ? 'Casual (+25% Loading)' : 'Casual (+25% Loading)')),
                selected: _isCasualContract,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: _isCasualContract ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold),
                onSelected: (val) => setState(() => _isCasualContract = true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: Center(child: Text(isEn ? 'Full-Time / Part-Time' : 'Tiempo Completo / Parcial')),
                selected: !_isCasualContract,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: !_isCasualContract ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold),
                onSelected: (val) => setState(() => _isCasualContract = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Turno
        Text(isEn ? 'Shift / Penalty Type:' : 'Tipo de Turno / Penalización:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            _buildShiftChip('weekday', isEn ? 'Weekday (Normal)' : 'Lunes a Viernes'),
            _buildShiftChip('saturday', isEn ? 'Saturday (150%)' : 'Sábado (150%)'),
            _buildShiftChip('sunday', isEn ? 'Sunday (175%)' : 'Domingo (175%)'),
            _buildShiftChip('public_holiday', isEn ? 'Public Holiday (250%)' : 'Festivo (250%)'),
          ],
        ),
        const SizedBox(height: 16),

        // Horas
        Text(isEn ? 'Hours Worked: ${_hoursWorked.toStringAsFixed(1)} h' : 'Horas trabajadas: ${_hoursWorked.toStringAsFixed(1)} h', style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: _hoursWorked,
          min: 1.0,
          max: 60.0,
          divisions: 59,
          activeColor: AppColors.secondary,
          onChanged: (val) => setState(() => _hoursWorked = val),
        ),
        const SizedBox(height: 10),

        // Resultado con bloqueo Premium para auditoría completa
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              _buildPayRow(isEn ? 'Hourly Rate' : 'Tarifa por Hora', '\$${payCalc['effectiveHourlyRate']!.toStringAsFixed(2)} AUD/h'),
              const Divider(),
              _buildPayRow(isEn ? 'Gross Pay' : 'Salario Bruto Esperado', '\$${payCalc['grossPay']!.toStringAsFixed(2)} AUD', isBold: true),
              const Divider(),
              _buildPayRow(isEn ? 'Superannuation (12%)' : 'Aportación Super (12%)', '\$${payCalc['superannuationPay']!.toStringAsFixed(2)} AUD', color: AppColors.secondary),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Auditor de nómina anti-estafas (Bloqueado con candado)
        PremiumFeatureGate(
          featureTitle: isEn ? 'Payslip Underpayment Auditor' : 'Auditor de Nóminas Anti-Estafa',
          featureBenefit: isEn
              ? 'Check if your employer is paying you below the Fair Work legal award and generate formal claim text.'
              : 'Verifica si tu jefe te está pagando por debajo de ley y genera una reclamación formal automática con citas legales de Fair Work.',
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildTextField(_grossPaidController, isEn ? 'Gross Paid in AUD' : 'Importe bruto pagado en AUD'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(isEn ? 'Audit Payslip' : 'Auditar Nómina'),
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
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
      onSelected: (val) => setState(() => _selectedIndustry = id),
    );
  }

  Widget _buildShiftChip(String id, String label) {
    final isSelected = _dayType == id;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.secondary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
      onSelected: (val) => setState(() => _dayType = id),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPayRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isBold ? 16 : 14, fontWeight: FontWeight.bold, color: color ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}
