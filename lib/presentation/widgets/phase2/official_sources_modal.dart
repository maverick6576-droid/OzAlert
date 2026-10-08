import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/services/url_launcher_service.dart';
import '../../../core/theme/app_colors.dart';

void showOfficialSourcesModal(BuildContext context, {bool isEn = false, String? initialTopic}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _OfficialSourcesBottomSheet(isEn: isEn, initialTopic: initialTopic),
  );
}

class _OfficialSourcesBottomSheet extends StatelessWidget {
  final bool isEn;
  final String? initialTopic;

  const _OfficialSourcesBottomSheet({
    required this.isEn,
    this.initialTopic,
  });

  Future<void> _launchUrl(BuildContext context, String url) async {
    await UrlLauncherService.openUrl(context, url);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.info_circle_fill, color: AppColors.secondary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'Official Government Sources' : 'Fuentes Oficiales & Marco Legal',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEn ? 'Verified Australian Government Data' : 'Información verificada del Gobierno de Australia',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
          const Divider(height: 1),

          // Content List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Disclaimer Banner
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
                      const Icon(CupertinoIcons.shield_lefthalf_fill, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isEn
                              ? 'OzAlert references strictly public regulations from Australian Government agencies. We ensure absolute transparency with direct links to primary sources.'
                              : 'OzAlert referencia rigurosamente las normativas vigentes de los organismos del Gobierno de Australia. Garantizamos total transparencia con acceso directo a las fuentes primarias.',
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 1. Fair Work Ombudsman
                _buildSourceCard(
                  context,
                  title: 'Fair Work Ombudsman',
                  subtitle: isEn ? 'National Minimum Wage & Employment Awards' : 'Salarios Mínimos y Convenios Laborales',
                  description: isEn
                      ? 'Regulates legal pay rates (\$26.44 base, \$33.05 casual with 25% loading), penalty rates for weekends, and 12% mandatory Superannuation.'
                      : 'Regula las tarifas salariales legales (\$26.44 base, \$33.05 casual con 25% loading), penalizaciones por turnos de fin de semana y 12% de Superannuation obligatoria.',
                  url: 'https://www.fairwork.gov.au',
                  urlLabel: 'fairwork.gov.au',
                  icon: Icons.account_balance_wallet_rounded,
                  isHighlighted: initialTopic == 'fair_work',
                ),
                const SizedBox(height: 14),

                // 2. Department of Home Affairs
                _buildSourceCard(
                  context,
                  title: 'Department of Home Affairs',
                  subtitle: isEn ? 'Regional Work 88 Days & Visa Conditions' : 'Trabajo Regional 88 Días y Requisitos de Visado',
                  description: isEn
                      ? 'Defines official eligible postcodes for Subclass 462 and 417 second/third year extensions. Note: Hospitality qualifies for 462 ONLY in Northern/Remote areas.'
                      : 'Define la lista oficial de códigos postales para la extensión de visa de 88 días. En la Subclase 462, hostelería cuenta ÚNICAMENTE en el Norte o zonas remotas.',
                  url: 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/specified-462-work',
                  urlLabel: 'immi.homeaffairs.gov.au',
                  icon: CupertinoIcons.map_pin_ellipse,
                  isHighlighted: initialTopic == 'home_affairs' || initialTopic == 'regional',
                ),
                const SizedBox(height: 14),

                // 3. Australian Taxation Office (ATO)
                _buildSourceCard(
                  context,
                  title: 'Australian Taxation Office (ATO)',
                  subtitle: isEn ? 'TFN Application & Superannuation Rules' : 'Solicitud Gratuita de TFN y Fondos de Pensiones',
                  description: isEn
                      ? 'The official government tax authority. Applying for a TFN is 100% FREE. Never pay third-party scam services. Also manages DASP super refund upon departing Australia.'
                      : 'La agencia tributaria australiana. Solicitar el TFN es 100% GRATUITO. Nunca pagues a webs intermediarias. Gestiona además la devolución del DASP al marcharte del país.',
                  url: 'https://www.ato.gov.au/individuals-and-families/tax-file-number/apply-for-a-tfn',
                  urlLabel: 'ato.gov.au',
                  icon: Icons.receipt_long_rounded,
                  isHighlighted: initialTopic == 'ato' || initialTopic == 'tax',
                ),
                const SizedBox(height: 14),

                // 4. SafeWork Australia
                _buildSourceCard(
                  context,
                  title: 'SafeWork Australia & Liquor Regulators',
                  subtitle: isEn ? 'White Card & RSA Mandatory Certifications' : 'White Card de Construcción y Certificados RSA',
                  description: isEn
                      ? 'Governs safety standards on worksites (White Card CPCCWHS101) and liquor licensing (RSA SITHFAB021 / Liquor & Gaming NSW).'
                      : 'Establece los requisitos obligatorios de seguridad en obra (White Card CPCCWHS101) y servicio responsable de alcohol (RSA / Liquor & Gaming NSW).',
                  url: 'https://www.safeworkaustralia.gov.au',
                  urlLabel: 'safeworkaustralia.gov.au',
                  icon: Icons.verified_user_rounded,
                  isHighlighted: initialTopic == 'certifications',
                ),
                const SizedBox(height: 14),

                // 5. Federal Register of Legislation (LIN 22/050)
                _buildSourceCard(
                  context,
                  title: 'Federal Register of Legislation',
                  subtitle: isEn ? 'Instrument LIN 22/050 (Eligible Postcodes)' : 'Instrumento Legal LIN 22/050 (Códigos Postales)',
                  description: isEn
                      ? 'The definitive legal act governing all specified work postcodes and industries for Working Holiday Subclasses 417 & 462.'
                      : 'La ley oficial vinculante que define cada código postal e industria habilitada para los 88 días y 179 días de las subclases 417 y 462.',
                  url: 'https://www.legislation.gov.au/Details/F2022L00445',
                  urlLabel: 'legislation.gov.au',
                  icon: Icons.gavel_rounded,
                  isHighlighted: initialTopic == 'legislation' || initialTopic == 'regional',
                ),
                const SizedBox(height: 14),

                // 6. Services Australia
                _buildSourceCard(
                  context,
                  title: 'Services Australia (Medicare RHCA)',
                  subtitle: isEn ? 'Reciprocal Health Care Agreements' : 'Convenios Recíprocos de Cobertura Sanitaria',
                  description: isEn
                      ? 'Administers free Medicare enrollment for citizens of reciprocal countries (Spain, UK, Italy, Ireland, etc.) during their stay.'
                      : 'Gestiona la inscripción gratuita en la sanidad pública de Australia (Medicare) para ciudadanos de países con convenio (España, Italia, Reino Unido, etc.).',
                  url: 'https://www.servicesaustralia.gov.au/reciprocal-health-care-agreements',
                  urlLabel: 'servicesaustralia.gov.au',
                  icon: Icons.medical_services_rounded,
                  isHighlighted: initialTopic == 'medicare' || initialTopic == 'insurance',
                ),
                const SizedBox(height: 14),

                // 7. State Rental Bond Boards
                _buildSourceCard(
                  context,
                  title: 'State Tenancy & Rental Bond Authorities',
                  subtitle: isEn ? 'NSW Fair Trading, RTA QLD, RTBA VIC' : 'Organismos Estatales Oficiales de Fianzas',
                  description: isEn
                      ? 'Statutory state bodies where rental bonds must be legally lodged. Protects tenants from unfair deductions upon moving out.'
                      : 'Entidades públicas estatales donde es obligatorio por ley depositar las fianzas de alquiler. Protege tu depósito de abusos al dejar el piso.',
                  url: 'https://www.fairtrading.nsw.gov.au/housing-and-property/renting/rental-bonds-online',
                  urlLabel: 'fairtrading.nsw.gov.au',
                  icon: CupertinoIcons.building_2_fill,
                  isHighlighted: initialTopic == 'housing' || initialTopic == 'departure',
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required String url,
    required String urlLabel,
    required IconData icon,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHighlighted ? AppColors.secondary : AppColors.cardBorder,
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
                child: Icon(icon, color: AppColors.secondary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _launchUrl(context, url),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.arrow_up_right_square_fill, size: 16, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  isEn ? 'Verify at $urlLabel' : 'Verificar en $urlLabel',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
