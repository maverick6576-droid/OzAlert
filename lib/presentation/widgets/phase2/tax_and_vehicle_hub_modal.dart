import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/tax_and_rego_service.dart';
import '../../../core/services/url_launcher_service.dart';

class TaxAndVehicleHubModal extends StatefulWidget {
  final bool isEn;
  final String userPassport;

  const TaxAndVehicleHubModal({
    super.key,
    required this.isEn,
    this.userPassport = 'Spain',
  });

  static Future<void> show(BuildContext context, {required bool isEn, String userPassport = 'Spain'}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaxAndVehicleHubModal(isEn: isEn, userPassport: userPassport),
    );
  }

  @override
  State<TaxAndVehicleHubModal> createState() => _TaxAndVehicleHubModalState();
}

class _TaxAndVehicleHubModalState extends State<TaxAndVehicleHubModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Calculadora Medicare & Tax
  double _annualIncome = 45000.0;
  String _selectedCountry = 'Spain';

  // Calculadora DASP
  double _accumulatedSuper = 5400.0;
  bool _isWhv = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedCountry = widget.userPassport.isNotEmpty ? widget.userPassport : 'Spain';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = widget.isEn;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(CupertinoIcons.money_dollar_circle_fill, color: AppColors.secondary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEn ? 'Tax, Medicare & Rego Hub' : 'Hub Fiscal, Medicare & Vehículos',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                            ),
                            Text(
                              isEn ? 'Australian Legal & Financial Suite' : 'Ahorro de impuestos y compras seguras',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: isEn ? '🏥 Medicare 2% (MES)' : '🏥 Exención Medicare 2%'),
              Tab(text: isEn ? '⚖️ Addy & Tax Return' : '⚖️ Doctrina Addy & ATO'),
              Tab(text: isEn ? '💰 DASP Super Refund' : '💰 Devolución Super (DASP)'),
              Tab(text: isEn ? '🚗 WA Rego & Tickets' : '🚗 WA Rego & Cursos'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMedicareTab(isEn),
                _buildAddyTab(isEn),
                _buildDaspTab(isEn),
                _buildRegoAndTicketsTab(isEn),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PESTAÑA 1: EXENCIÓN MEDICARE LEVY 2% (MES)
  // ===========================================================================
  Widget _buildMedicareTab(bool isEn) {
    final mesSaving = TaxAndRegoService.calculateMedicareLevySaving(_annualIncome);
    final isEligible = TaxAndRegoService.isEligibleForMedicareLevyExemption(_selectedCountry);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0D9488).withValues(alpha: 0.15),
                AppColors.surfaceElevated,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.checkmark_shield_fill, color: Color(0xFF0D9488), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEn ? '2% Medicare Levy Exemption (MES)' : 'Exención del 2.0% de Medicare (MES)',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isEn
                    ? 'In Australia, workers pay an automatic 2.0% tax for public healthcare. If you hold a Working Holiday Visa and have no access to Medicare, you can claim 100% of this tax back in your Tax Return.'
                    : 'En Australia se retiene por ley un 2.0% adicional para financiar la sanidad pública. Si tienes visado WHM y tu pasaporte no tiene convenio de acceso a Medicare, este dinero te corresponde íntegramente de vuelta.',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Selector de Salario Anual
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isEn ? 'Estimated Annual Income:' : 'Sueldo Anual Estimado:',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                softWrap: true,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${_annualIncome.toInt()} AUD',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primary),
            ),
          ],
        ),
        Slider(
          value: _annualIncome,
          min: 10000,
          max: 120000,
          divisions: 22,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.surfaceElevated,
          onChanged: (val) => setState(() => _annualIncome = val),
        ),
        const SizedBox(height: 8),

        // Tarjeta de Ahorro Neto
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isEn ? 'Direct Refund in Tax Return:' : 'Devolución Directa en el Tax Return:',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+\$${mesSaving.toStringAsFixed(2)} AUD',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0D9488)),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Icon(
                    isEligible ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.info_circle_fill,
                    size: 16,
                    color: isEligible ? const Color(0xFF0D9488) : AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEligible
                          ? (isEn
                              ? 'Your nationality is fully eligible for the MES 2% exemption!'
                              : '¡Tu nacionalidad califica al 100% para reclamar la exención!')
                          : (isEn
                              ? 'Your country has an RHCA agreement; consult if you enrolled in Medicare.'
                              : 'Tu país tiene convenio RHCA; comprueba si te registraste en Medicare.'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pasos para solicitarlo gratis
        Text(
          isEn ? 'How to claim without paying tax agents (\$0 cost):' : 'Cómo tramitarlo gratis sin pagar gestores (0.00€):',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        _buildStepTile(
          number: '1',
          title: isEn ? 'Submit Form MS015' : 'Presentar Formulario MS015',
          body: isEn
              ? 'Request your Medicare Entitlement Statement (MES) online via Services Australia MyGov portal.'
              : 'Solicita tu Medicare Entitlement Statement (MES) online en la web de Services Australia MyGov.',
        ),
        _buildStepTile(
          number: '2',
          title: isEn ? 'Attach Certified Passport' : 'Adjuntar Copia de Pasaporte',
          body: isEn
              ? 'Upload your photo page and Australian visa grant notice (VEVO).'
              : 'Sube la página de foto de tu pasaporte y la carta de concesión del visado (VEVO).',
        ),
        _buildStepTile(
          number: '3',
          title: isEn ? 'Receive Exemption Certificate' : 'Recibir Certificado de Exención',
          body: isEn
              ? 'In 4-8 weeks you will receive the certificate number to enter into Question M2 of your Tax Return.'
              : 'En 4-8 semanas recibirás la carta con el número de exención para introducirlo en la Casilla M2 del Tax Return.',
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ===========================================================================
  // PESTAÑA 2: DOCTRINA ADDY & ATO
  // ===========================================================================
  Widget _buildAddyTab(bool isEn) {
    final comparison = TaxAndRegoService.calculateAddyTaxComparison(_annualIncome);
    final isAddyCountry = TaxAndRegoService.isAddyProtectedCountry(_selectedCountry);

    return ListView(
      padding: const EdgeInsets.all(16),
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
              Text(
                isEn ? 'High Court Addy Precedent' : 'Doctrina Addy (Alta Corte Australiana)',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                isEn
                    ? 'Under international tax treaties, citizens of Chile, Germany, Japan, Norway, Finland, Turkey, Israel, and the UK who reside in Australia cannot be taxed at higher rates than Australian residents.'
                    : 'Bajo convenios de doble imposición, los ciudadanos de Chile, Alemania, Japón, Noruega, Finlandia, Turquía, Israel y Reino Unido que residan habitualmente en un lugar tienen derecho al tramo exento de \$18,200 AUD.',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isEn ? 'Standard WHM Tax (15%):' : 'Impuesto WHM Estándar (15%):',
                      style: const TextStyle(fontSize: 12.5),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('\$${comparison['whmTax']!.toStringAsFixed(2)} AUD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isEn ? 'Resident Tax (Addy Rule):' : 'Impuesto Residente (Addy):',
                      style: const TextStyle(fontSize: 12.5),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('\$${comparison['residentTax']!.toStringAsFixed(2)} AUD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isEn ? 'Potential Extra Refund:' : 'Posible Ahorro / Devolución:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.primary),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+\$${comparison['potentialSaving']!.toStringAsFixed(2)} AUD',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          isAddyCountry
              ? (isEn
                  ? '✅ Your country is protected by the Addy non-discrimination treaty.'
                  : '✅ Tu país de origen está protegido por el tratado de no discriminación Addy.')
              : (isEn
                  ? 'ℹ️ Standard WHM tax rules apply (15% up to \$45,000 AUD).'
                  : 'ℹ️ Se aplica el régimen fiscal estándar WHM (15% hasta \$45,000 AUD).'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isAddyCountry ? const Color(0xFF0D9488) : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // PESTAÑA 3: DEVOLUCIÓN DE SUPERANNUATION (DASP)
  // ===========================================================================
  Widget _buildDaspTab(bool isEn) {
    final dasp = TaxAndRegoService.calculateDaspRefund(
      grossSuperAccumulated: _accumulatedSuper,
      isWorkingHolidayVisa: _isWhv,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
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
              Text(
                isEn ? 'Departing Australia Superannuation (DASP)' : 'Devolución de Superannuation (DASP)',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                isEn
                    ? 'When you permanently depart Australia and your visa expires, you can claim your employer superannuation back in cash via the ATO portal.'
                    : 'Cuando dejas Australia definitivamente y tu visado expira o se cancela, puedes reclamar todas las aportaciones del 12% que pagaron tus jefes.',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Saldo Acumulado
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isEn ? 'Accumulated Super Balance:' : 'Saldo de Super Acumulado:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                softWrap: true,
              ),
            ),
            const SizedBox(width: 8),
            Text('\$${_accumulatedSuper.toInt()} AUD', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.secondary)),
          ],
        ),
        Slider(
          value: _accumulatedSuper,
          min: 1000,
          max: 25000,
          divisions: 24,
          activeColor: AppColors.secondary,
          inactiveColor: AppColors.surfaceElevated,
          onChanged: (val) => setState(() => _accumulatedSuper = val),
        ),
        const SizedBox(height: 12),

        // Selector Visado
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isEn ? 'WHM 417 / 462 (65% Tax)' : 'WHM 417 / 462 (65% IRPF)',
                    style: TextStyle(
                      color: _isWhv ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                selected: _isWhv,
                selectedColor: AppColors.primary,
                onSelected: (_) => setState(() => _isWhv = true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isEn ? 'Student 500 (35% Tax)' : 'Estudiante 500 (35% IRPF)',
                    style: TextStyle(
                      color: !_isWhv ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                selected: !_isWhv,
                selectedColor: AppColors.primary,
                onSelected: (_) => setState(() => _isWhv = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isEn ? 'ATO Departure Tax:' : 'Retención Fiscal ATO:',
                      style: const TextStyle(fontSize: 12.5),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('-\$${dasp['taxWithheld']!.toStringAsFixed(2)} AUD (${dasp['taxRatePercentage']!.toInt()}%)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.statusClosed)),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isEn ? 'Net Cash to Receive:' : 'Dinero Neto a Percibir:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+\$${dasp['netRefund']!.toStringAsFixed(2)} AUD',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0D9488)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // PESTAÑA 4: WA REGO & CURSOS DE ALTO RETORNO
  // ===========================================================================
  Widget _buildRegoAndTicketsTab(bool isEn) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Tarjeta WA Rego
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
                  const Icon(CupertinoIcons.car_detailed, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEn ? 'Western Australia (WA) Rego Advantage' : 'La Ventaja de la Matrícula de WA (Rego)',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isEn
                    ? 'WA vehicles are the backpacker holy grail: NO mandatory annual roadworthy inspection (RWC/Pink Slip) and 100% online renewals.'
                    : 'Los coches y furgonetas de Western Australia son los más cotizados: NO requieren inspección técnica anual (RWC/Pink Slip) y se renuevan 100% online.',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(CupertinoIcons.shield_lefthalf_fill, size: 16),
                  label: Flexible(
                    child: Text(
                      isEn ? 'Official PPSR Check (\$2 AUD)' : 'Comprobar VIN en PPSR Oficial (\$2 AUD)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => UrlLauncherService.openUrl(context, 'https://www.ppsr.gov.au/'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Catálogo de Cursos de Alto Retorno
        Text(
          isEn ? 'High-ROI Tickets & Licences' : 'Cursos y Licencias de Mayor Retorno (ROI)',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
          softWrap: true,
        ),
        const SizedBox(height: 4),
        Text(
          isEn ? 'Licences that pay for themselves in 1-2 shifts:' : 'Inversiones que se amortizan en 1 o 2 días de trabajo:',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          softWrap: true,
        ),
        const SizedBox(height: 10),
        ...TaxAndRegoService.highRoiTickets.map((ticket) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
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
                    Expanded(
                      child: Text(
                        ticket.title,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ROI: ~${ticket.payoffHours.toStringAsFixed(1)} h',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isEn ? ticket.descriptionEn : ticket.description,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
                  softWrap: true,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isEn ? 'Cost: ~\$${ticket.estimatedCostAud.toInt()} AUD' : 'Coste: ~\$${ticket.estimatedCostAud.toInt()} AUD',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEn ? 'Avg Wage: \$${ticket.averageHourlyWageAud.toStringAsFixed(2)}/h' : 'Sueldo: \$${ticket.averageHourlyWageAud.toStringAsFixed(2)}/h',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.secondary),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStepTile({required String number, required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(body, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
