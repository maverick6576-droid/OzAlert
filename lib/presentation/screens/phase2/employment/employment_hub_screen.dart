import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/fair_work_service.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../../domain/models/phase2/resume_data.dart';
import '../../../../domain/models/phase2/resume_presets.dart';
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

  // Calculadora Fair Work
  double _hoursWorked = 38.0;
  bool _isCasualContract = true;
  String _dayType = 'weekday';
  final _grossPaidController = TextEditingController(text: '1255.90');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPreset('hospitality');

    // Inicializar nombre o email desde Firebase si existe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          _nameController.text = user.displayName!;
        }
        if (user.email != null && user.email!.isNotEmpty) {
          _emailController.text = user.email!;
        }
      }
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        setState(() {
          _visaSubclass = profile.visaSubclass;
        });
      }
    });
  }

  void _loadPreset(String industryId) {
    final preset = ResumePresets.getById(industryId);
    setState(() {
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
            Tab(text: isEn ? '📄 Smart Resume' : '📄 Generador CV Pro'),
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

  // ==========================================
  // PESTAÑA 1: GENERADOR DE CV INTELIGENTE
  // ==========================================
  Widget _buildResumeBuilderTab(bool isEn, bool isPremium) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

        // 3. Bloque Contacto Local (Formato Australiano Estricto)
        _buildSectionHeader(
          icon: CupertinoIcons.person_crop_circle_fill,
          title: isEn ? '1. Local Contact Info' : '1. Datos de Contacto Local',
          subtitle: isEn
              ? 'Australian law: No photo, no birthdate, no exact street address.'
              : 'Norma australiana: Sin foto, sin edad ni calle exacta.',
        ),
        const SizedBox(height: 8),
        _buildTextField(_nameController, isEn ? 'Full Name' : 'Nombre Completo'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildTextField(_phoneController, isEn ? 'Mobile (+61)' : 'Móvil australiano (+61)')),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField(_suburbController, isEn ? 'Suburb, State Postcode' : 'Barrio, Estado y CP')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildTextField(_emailController, isEn ? 'Professional Email' : 'Correo Electrónico')),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField(_linkedInController, isEn ? 'LinkedIn / Portfolio (Optional)' : 'LinkedIn (Opcional)')),
          ],
        ),
        const SizedBox(height: 18),

        // 4. Bloque Visado y Disponibilidad (Factor #1 para Jefes de Local)
        _buildSectionHeader(
          icon: CupertinoIcons.shield_lefthalf_fill,
          title: isEn ? '2. Visa Work Rights & Availability' : '2. Permiso de Trabajo y Disponibilidad',
          subtitle: isEn
              ? 'Top filter: Eliminates recruiter fear of 20-hour limits.'
              : 'Factor decisivo: Da tranquilidad inmediata al empleador.',
        ),
        const SizedBox(height: 8),
        _buildVisaSelector(isEn),
        const SizedBox(height: 18),

        // 5. Bloque Puesto y Extracto Profesional
        _buildSectionHeader(
          icon: CupertinoIcons.briefcase_fill,
          title: isEn ? '3. Position & Recruiter Summary' : '3. Puesto y Perfil Profesional',
          subtitle: isEn ? 'Crafted in Australian English' : 'Redactado en inglés australiano profesional',
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
        const SizedBox(height: 12),

        // 6. Bloque Licencias y Cursos Australianos (Tickets)
        _buildSectionHeader(
          icon: CupertinoIcons.checkmark_seal_fill,
          title: isEn ? '4. Australian Licences & Tickets' : '4. Licencias Oficiales (Tickets)',
          subtitle: isEn ? 'Mandatory for Hospitality & Construction' : 'Obligatorio para hostelería y construcción',
        ),
        const SizedBox(height: 8),
        _buildCertificationsChips(isEn),
        const SizedBox(height: 18),

        // 7. Bloque Habilidades Clave (Keywords ATS)
        _buildSectionHeader(
          icon: CupertinoIcons.sparkles,
          title: isEn ? '5. Key Skills (ATS Optimized)' : '5. Habilidades Clave (Filtro ATS)',
          subtitle: isEn ? 'Keywords recruiters search for' : 'Palabras clave que leen los algoritmos',
        ),
        const SizedBox(height: 8),
        _buildSkillsChips(isEn),
        const SizedBox(height: 18),

        // 8. Bloque Experiencias Laborales Adaptables
        _buildSectionHeader(
          icon: CupertinoIcons.building_2_fill,
          title: isEn ? '6. Experience (Recruiter-Tested)' : '6. Experiencia Laboral Adaptable',
          subtitle: isEn ? 'Customise with 1 tap or keep high-converting models' : 'Modifica empresas y fechas con 1 toque',
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

        // 9. Selector de Estilo y Color de Acento
        _buildSectionHeader(
          icon: CupertinoIcons.paintbrush_fill,
          title: isEn ? '7. PDF Style Accent' : '7. Estilo Visual del PDF',
          subtitle: isEn ? 'Executive recruiter palette' : 'Paleta corporativa ejecutiva',
        ),
        const SizedBox(height: 8),
        _buildColorPicker(isEn),
        const SizedBox(height: 24),

        // 10. Botón Principal: Generar y Descargar CV Oficial
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(CupertinoIcons.arrow_down_doc_fill, size: 20),
            label: Text(
              isEn ? 'Download Australian Pro Resume (PDF)' : 'Generar CV Oficial Australiano (PDF)',
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
                ? 'Guaranteed Australian Interview Format'
                : 'Formato Diseñado para Conseguir Entrevistas en Australia',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            isEn
                ? '• 100% Anti-Bias (No photo or age, legally compliant)\n• Visa Rights & Availability prominently featured on top\n• Australian Tickets & verifiable metrics included'
                : '• 100% Ley Anti-Discriminación (Sin foto ni edad, evita el 90% de descartes)\n• Permiso ilimitado y disponibilidad 7 días en cabecera\n• Licencias australianas (RSA, White Card) y métricas de impacto',
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
                        if (val != null) setState(() => _visaSubclass = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  isEn ? 'Availability Status:' : 'Disponibilidad Declarada:',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              DropdownButton<String>(
                value: _availability,
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
                  if (val != null) setState(() => _availability = val);
                },
              ),
            ],
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
            setState(() {
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
            setState(() => _currentSkills.remove(skill));
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
                    setState(() => _currentExperiences.removeAt(index));
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
            onTap: () => setState(() => _themeColorHex = hex),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                setState(() => _currentSkills.add(skillController.text.trim()));
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

                    setState(() {
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
        featureTitle: isEn ? 'Pro Australian Resume' : 'Generador de CV Australiano',
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

  // ==========================================
  // PESTAÑA 2: CALCULADORA FAIR WORK
  // ==========================================
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _isCasualContract ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isEn ? 'Casual (+25% Loading)' : 'Casual (+25% Carga)',
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_isCasualContract ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isEn ? 'Full-Time / Part-Time' : 'Jornada Completa / Media',
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
            _buildShiftChip('public_holiday', isEn ? 'Public Holiday (250%)' : 'Festivo (250%)'),
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
