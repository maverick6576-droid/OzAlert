import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/models/phase2/resume_data.dart';
import '../../domain/models/phase2/regional_work_log.dart';

class PdfGeneratorService {
  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  /// Limpia caracteres fuera de Latin-1 para evitar glifos vacíos en la fuente nativa Helvetica del motor PDF
  static String _sanitizeLatin1(String input) {
    return input
        .replaceAll('•', '-')
        .replaceAll('—', ' - ')
        .replaceAll('–', '-')
        .replaceAll('✓', 'v')
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"');
  }

  /// Genera un Currículum Australiano Ejecutivo (ATS-Friendly, sin foto ni edad, con derechos de visado VEVO y disponibilidad destacados)
  static Future<Uint8List> generateAustralianResume(AustralianResumeData data) async {
    final pdf = pw.Document();

    final accentColor = PdfColor.fromHex(data.themeColorHex.isNotEmpty ? data.themeColorHex : '#D96B43');
    final navyColor = PdfColor.fromHex('#1E293B');
    final tealColor = PdfColor.fromHex('#00A896');
    final subtleBg = PdfColor.fromHex('#F8FAFC');
    final warmBg = PdfColor.fromHex('#F8F6F0');
    final borderColor = PdfColor.fromHex('#CBD5E1');

    final displayName = _sanitizeLatin1(
      data.fullName.trim().isNotEmpty ? data.fullName.trim() : 'CANDIDATE PROFILE',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 26),
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 8),
            padding: const pw.EdgeInsets.only(top: 5),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.6)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '${displayName.toUpperCase()}  |  Australian Standard Resume (ATS Compliant - No Photo / No DOB)',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: navyColor),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Barra Superior Ejecutiva
            pw.Container(
              height: 4,
              width: double.infinity,
              decoration: pw.BoxDecoration(
                color: accentColor,
                borderRadius: pw.BorderRadius.circular(2),
              ),
            ),
            pw.SizedBox(height: 8),

            // Cabecera Principal: Nombre, Rol Objetivo y Sello de Cumplimiento Australiano
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        displayName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 21,
                          fontWeight: pw.FontWeight.bold,
                          color: navyColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (data.jobTitle.trim().isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          _sanitizeLatin1(data.jobTitle.trim()).toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 10.5,
                            fontWeight: pw.FontWeight.bold,
                            color: accentColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: navyColor,
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                      child: pw.Text(
                        'ATS-OPTIMISED | AU STANDARD',
                        style: pw.TextStyle(fontSize: 6.8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#E6F6F4'),
                        borderRadius: pw.BorderRadius.circular(3),
                        border: pw.Border.all(color: tealColor, width: 0.6),
                      ),
                      child: pw.Text(
                        'VEVO WORK RIGHTS VERIFIED',
                        style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: tealColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 6),

            // Barra de Contacto Directo
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: pw.BoxDecoration(
                color: subtleBg,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: borderColor, width: 0.6),
              ),
              child: pw.Wrap(
                spacing: 14,
                runSpacing: 3,
                children: [
                  if (data.phone.trim().isNotEmpty)
                    pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text('MOBILE: ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: accentColor)),
                        pw.Text(_sanitizeLatin1(data.phone.trim()), style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: navyColor)),
                      ],
                    ),
                  if (data.email.trim().isNotEmpty)
                    pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text('EMAIL: ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: accentColor)),
                        pw.Text(_sanitizeLatin1(data.email.trim()), style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
                      ],
                    ),
                  if (data.locationSuburb.trim().isNotEmpty)
                    pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text('LOCATION: ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: accentColor)),
                        pw.Text(_sanitizeLatin1(data.locationSuburb.trim()), style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
                      ],
                    ),
                  if (data.linkedIn.trim().isNotEmpty)
                    pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text('PORTFOLIO: ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: accentColor)),
                        pw.Text(_sanitizeLatin1(data.linkedIn.trim()), style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
                      ],
                    ),
                ],
              ),
            ),
            pw.SizedBox(height: 6),

            // Panel Crítico para Empleadores Australianos: Derechos de Trabajo y Disponibilidad
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: pw.BoxDecoration(
                color: warmBg,
                borderRadius: pw.BorderRadius.circular(5),
                border: pw.Border.all(color: accentColor, width: 0.8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Row(
                          children: [
                            pw.Container(
                              width: 6,
                              height: 6,
                              decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: tealColor),
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              'LEGAL WORK RIGHTS: ',
                              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: navyColor),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                _sanitizeLatin1(data.visaStatus),
                                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: pw.BoxDecoration(
                          color: tealColor,
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                        child: pw.Text(
                          'UNRESTRICTED FULL-TIME / CASUAL HOURS',
                          style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Row(
                          children: [
                            pw.Container(
                              width: 6,
                              height: 6,
                              decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: accentColor),
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              'SHIFT AVAILABILITY: ',
                              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: navyColor),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                _sanitizeLatin1(data.availability),
                                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey900),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        'READY FOR IMMEDIATE TRIAL SHIFT',
                        style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: accentColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Resumen Ejecutivo (Executive Summary)
            _buildSectionHeader('EXECUTIVE PROFILE & VALUE PROPOSITION', accentColor, navyColor),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.only(left: 8, top: 2, bottom: 2),
              decoration: pw.BoxDecoration(
                border: pw.Border(left: pw.BorderSide(color: accentColor, width: 2.2)),
              ),
              child: pw.Text(
                _sanitizeLatin1(data.summary),
                style: const pw.TextStyle(fontSize: 8.8, lineSpacing: 1.6, color: PdfColors.grey900),
              ),
            ),

            // Licencias y Certificaciones Oficiales Australianas
            if (data.certifications.isNotEmpty) ...[
              _buildSectionHeader('AUSTRALIAN LICENCES, TICKETS & WHS CLEARANCES', accentColor, navyColor),
              pw.Wrap(
                spacing: 6,
                runSpacing: 4,
                children: data.certifications.map((cert) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(3),
                    border: pw.Border.all(color: tealColor, width: 0.8),
                  ),
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Container(
                        width: 4.5,
                        height: 4.5,
                        decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: tealColor),
                      ),
                      pw.SizedBox(width: 4),
                      pw.Text(
                        _sanitizeLatin1(cert),
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: navyColor),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ],

            // Competencias Clave y Palabras Clave ATS
            if (data.skills.isNotEmpty) ...[
              _buildSectionHeader('CORE COMPETENCIES & ATS KEYWORDS', accentColor, navyColor),
              pw.Wrap(
                spacing: 5,
                runSpacing: 4,
                children: data.skills.map((skill) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: subtleBg,
                    borderRadius: pw.BorderRadius.circular(3),
                    border: pw.Border.all(color: borderColor, width: 0.6),
                  ),
                  child: pw.Text(
                    '- ${_sanitizeLatin1(skill)}',
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: navyColor),
                  ),
                )).toList(),
              ),
            ],

            // Experiencia Profesional
            if (data.experiences.isNotEmpty) ...[
              _buildSectionHeader('PROFESSIONAL WORK EXPERIENCE', accentColor, navyColor),
              ...data.experiences.map((exp) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 7),
                padding: const pw.EdgeInsets.only(left: 8),
                decoration: pw.BoxDecoration(
                  border: pw.Border(left: pw.BorderSide(color: borderColor, width: 1.5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            _sanitizeLatin1(exp.role).toUpperCase(),
                            style: pw.TextStyle(fontSize: 9.2, fontWeight: pw.FontWeight.bold, color: navyColor),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: pw.BoxDecoration(
                            color: subtleBg,
                            borderRadius: pw.BorderRadius.circular(3),
                          ),
                          child: pw.Text(
                            _sanitizeLatin1(exp.period),
                            style: pw.TextStyle(fontSize: 7.8, fontWeight: pw.FontWeight.bold, color: navyColor),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 1.5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          _sanitizeLatin1(exp.company),
                          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: accentColor),
                        ),
                        pw.Text(
                          _sanitizeLatin1(exp.location),
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                    ...exp.bulletPoints.map((bp) => pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 4, bottom: 2),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            margin: const pw.EdgeInsets.only(top: 3.5, right: 5),
                            width: 3.2,
                            height: 3.2,
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              color: accentColor,
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              _sanitizeLatin1(bp),
                              style: const pw.TextStyle(fontSize: 8.3, color: PdfColors.grey900, lineSpacing: 1.35),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              )),
            ],

            // Educación y Cumplimiento WHS
            if (data.education.isNotEmpty) ...[
              _buildSectionHeader('EDUCATION & AUSTRALIAN WHS COMPLIANCE', accentColor, navyColor),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      '- ${_sanitizeLatin1(data.education)}',
                      style: pw.TextStyle(fontSize: 8.3, fontWeight: pw.FontWeight.bold, color: navyColor),
                    ),
                  ),
                  pw.Text(
                    '- Full PPE Ready & WHS Safety Inducted',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                  ),
                ],
              ),
            ],

            // Referencias Profesionales
            _buildSectionHeader('PROFESSIONAL REFEREES', accentColor, navyColor),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: pw.BoxDecoration(
                color: subtleBg,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                '${_sanitizeLatin1(data.references)} - Verified supervisors and managers available immediately upon request or following a trial shift.',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey800, fontStyle: pw.FontStyle.italic),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSectionHeader(String title, PdfColor accentColor, PdfColor navyColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 7, bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 3,
                height: 10,
                color: accentColor,
              ),
              pw.SizedBox(width: 5),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 9.2,
                  fontWeight: pw.FontWeight.bold,
                  color: navyColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Divider(thickness: 0.6, height: 2, color: PdfColors.grey300),
        ],
      ),
    );
  }

  /// Genera un Dossier de Verificación de Empleo Regional (88 Días / 179 Días / Formulario 1263 Summary)
  static Future<Uint8List> generateRegionalDossier({
    required String applicantName,
    required String passportNumber,
    required String visaSubclass,
    required List<RegionalJobEntry> jobs,
    required int totalDays,
    int targetYear = 2,
    String? visaGrantNumber,
    String? contactEmail,
    String? contactPhone,
  }) async {
    final pdf = pw.Document();
    final targetDays = targetYear == 3 ? 179 : 88;
    final yearTitle = targetYear == 3 ? 'THIRD' : 'SECOND';
    final navyColor = PdfColor.fromHex('#1E293B');
    final accentColor = PdfColor.fromHex('#D96B43');
    final tealColor = PdfColor.fromHex('#00A896');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Container(height: 4, width: double.infinity, color: accentColor),
            pw.SizedBox(height: 8),
            pw.Header(
              level: 0,
              decoration: const pw.BoxDecoration(border: null),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '$yearTitle WORKING HOLIDAY VISA - SPECIFIED WORK DOSSIER',
                        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: navyColor),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Official Evidence Summary for Form 1263 & ImmiAccount Audit Verification (LIN 22/050)',
                        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: tealColor,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      'VERIFIED: $totalDays / $targetDays DAYS',
                      style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F8FAFC'),
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Applicant: ${_sanitizeLatin1(applicantName)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5, color: navyColor)),
                      pw.Text('Passport: ${_sanitizeLatin1(passportNumber)}', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
                      pw.Text('Visa Subclass: ${_sanitizeLatin1(visaSubclass)}', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: accentColor)),
                    ],
                  ),
                  if ((visaGrantNumber != null && visaGrantNumber.isNotEmpty) || (contactEmail != null && contactEmail.isNotEmpty)) ...[
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        if (visaGrantNumber != null && visaGrantNumber.isNotEmpty)
                          pw.Text('Visa Grant No: ${_sanitizeLatin1(visaGrantNumber)}', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                        if (contactEmail != null && contactEmail.isNotEmpty)
                          pw.Text('Contact: ${_sanitizeLatin1(contactEmail)} ${contactPhone != null && contactPhone.isNotEmpty ? " | ${_sanitizeLatin1(contactPhone)}" : ""}',
                              style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // Tabla de Empleos Regionales
            pw.TableHelper.fromTextArray(
              headers: ['Employer / Business', 'ABN', 'Location & Postcode', 'Role & Industry', 'Period Worked', 'Days', 'Hours', 'Gross AUD'],
              headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: navyColor),
              cellStyle: const pw.TextStyle(fontSize: 7.5),
              data: jobs.map((j) => [
                _sanitizeLatin1(j.employerBusinessName),
                _sanitizeLatin1(j.employerAbn),
                '${_sanitizeLatin1(j.workSiteLocation)}\n(CP: ${_sanitizeLatin1(j.workSitePostcode)})',
                '${_sanitizeLatin1(j.jobRole)}\n[${j.industry.replaceAll('_', ' ').toUpperCase()}]',
                '${_formatDate(j.startDate)} -\n${_formatDate(j.endDate)}',
                j.totalDaysCounted.toString(),
                '${j.totalHours.toStringAsFixed(0)}h',
                '\$${j.grossEarningsAud.toStringAsFixed(0)}',
              ]).toList(),
            ),

            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F8F6F0'),
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColor.fromHex('#E2DCD5')),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'APPLICANT STATUTORY DECLARATION (FORM 1263 COMPLIANCE)',
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: navyColor),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'I declare that the specified work recorded above was completed in eligible regional Australian postcodes in accordance with Migration Instrument LIN 22/050 and remunerated in accordance with applicable Fair Work Modern Awards. Original payslips, bank statements, and payment summaries are attached.',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800, lineSpacing: 1.4),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Genera una Carta de Presentación Australiana Ejecutiva (Seek & Indeed Executive Standard)
  static Future<Uint8List> generateCoverLetter({
    required String applicantName,
    required String phone,
    required String email,
    required String locationSuburb,
    required String targetRole,
    required String companyName,
    required String visaStatus,
    required String coverLetterBody,
    String themeColorHex = '#D96B43',
  }) async {
    final pdf = pw.Document();
    final accentColor = PdfColor.fromHex(themeColorHex.isNotEmpty ? themeColorHex : '#D96B43');
    final navyColor = PdfColor.fromHex('#1E293B');
    final tealColor = PdfColor.fromHex('#00A896');
    final displayName = _sanitizeLatin1(applicantName.trim().isNotEmpty ? applicantName.trim() : 'Candidate');
    final displayCompany = _sanitizeLatin1(companyName.trim().isNotEmpty ? companyName.trim() : 'Hiring Organization');
    final displayRole = _sanitizeLatin1(targetRole.trim().isNotEmpty ? targetRole.trim() : 'Advertised Position');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Barra Superior Ejecutiva
              pw.Container(height: 4, width: double.infinity, color: accentColor),
              pw.SizedBox(height: 10),

              // Membrete Ejecutivo del Candidato
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          displayName.toUpperCase(),
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: navyColor, letterSpacing: 0.6),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          displayRole.toUpperCase(),
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: accentColor),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          [_sanitizeLatin1(phone), _sanitizeLatin1(email), _sanitizeLatin1(locationSuburb)]
                              .where((s) => s.trim().isNotEmpty)
                              .join('   |   '),
                          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                        ),
                      ],
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: tealColor,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      'TRIAL SHIFT & IMMEDIATE START READY',
                      style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),

              // Cuadro Resumen de Empleabilidad para Reclutadores (Seek / Indeed Quick-Scan)
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8F6F0'),
                  borderRadius: pw.BorderRadius.circular(5),
                  border: pw.Border.all(color: PdfColor.fromHex('#E2DCD5'), width: 0.8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('VISA & WORK RIGHTS (VEVO VERIFIED):', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: navyColor)),
                          pw.SizedBox(height: 1),
                          pw.Text(_sanitizeLatin1(visaStatus), style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: tealColor)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('AVAILABILITY & ROSTER:', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: navyColor)),
                          pw.SizedBox(height: 1),
                          pw.Text('Immediate Start | 7 Days / Weekends', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey900)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('CURRENT BASE:', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: navyColor)),
                          pw.SizedBox(height: 1),
                          pw.Text(_sanitizeLatin1(locationSuburb), style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey900)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Divider(thickness: 0.6, color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              // Fecha y Destinatario Formal
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('TO:', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Hiring Manager & Recruitment Team',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: navyColor),
                      ),
                      pw.Text(
                        displayCompany,
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: accentColor),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Date: ${_formatDate(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.SizedBox(height: 14),

              // Asunto Destacado
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8FAFC'),
                  border: pw.Border(left: pw.BorderSide(color: accentColor, width: 3)),
                ),
                child: pw.Text(
                  'RE: APPLICATION FOR ${displayRole.toUpperCase()} - ${displayCompany.toUpperCase()}',
                  style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: navyColor),
                ),
              ),
              pw.SizedBox(height: 14),

              pw.Text(
                'Dear Hiring Manager,',
                style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: navyColor),
              ),
              pw.SizedBox(height: 8),

              // Cuerpo de la Carta
              pw.Paragraph(
                text: _sanitizeLatin1(coverLetterBody),
                style: const pw.TextStyle(fontSize: 9.3, lineSpacing: 1.85, color: PdfColors.grey900),
              ),
              pw.SizedBox(height: 10),

              // Bloque de Garantías Clave para el Empleador Australiano
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8FAFC'),
                  borderRadius: pw.BorderRadius.circular(5),
                  border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.7),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'KEY HIRING ADVANTAGES FOR ${displayCompany.toUpperCase()}:',
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: navyColor),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '- Unrestricted Legal Work Rights: Active Australian visa with full working permissions (no 24h student cap).\n'
                      '- Zero Onboarding Friction: Active Australian TFN, Superannuation fund, bank account, and local mobile number.\n'
                      '- Immediate Trial Shift Readiness: Available at short notice across early mornings, evenings, weekends, and public holidays.',
                      style: const pw.TextStyle(fontSize: 8.2, lineSpacing: 1.45, color: PdfColors.grey800),
                    ),
                  ],
                ),
              ),
              pw.Spacer(),

              // Cierre y Firma Ejecutiva
              pw.Text(
                'Thank you for your time and consideration. I welcome the opportunity to demonstrate my work ethic during a trial shift or interview at your earliest convenience.',
                style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.5, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 12),
              pw.Text('Yours sincerely,', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
              pw.SizedBox(height: 10),
              pw.Container(width: 140, height: 1, color: accentColor),
              pw.SizedBox(height: 4),
              pw.Text(
                displayName,
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: navyColor),
              ),
              pw.Text(
                '${_sanitizeLatin1(phone)}  |  ${_sanitizeLatin1(email)}',
                style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: accentColor),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Genera un Dossier de Solvencia y Perfil de Inquilino en Australia (Rental & Flatmate Bio)
  static Future<Uint8List> generateRentalBio({
    required String fullName,
    required String phone,
    required String email,
    required String currentCity,
    required String budgetAud,
    required String moveInDate,
    required String visaStatus,
    required String employmentStatus,
    required String aboutMe,
    required List<String> houseHabits,
    String references = 'Available upon request',
  }) async {
    final pdf = pw.Document();
    final accentColor = PdfColor.fromHex('#00A896');
    final terracotta = PdfColor.fromHex('#D96B43');
    final navyColor = PdfColor.fromHex('#1E293B');
    final displayName = _sanitizeLatin1(fullName.trim().isNotEmpty ? fullName.trim() : 'Tenant Applicant');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 34, vertical: 30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Barra Superior
              pw.Container(height: 4, width: double.infinity, color: accentColor),
              pw.SizedBox(height: 10),

              // Cabecera Ejecutiva del Inquilino
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          displayName.toUpperCase(),
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: navyColor, letterSpacing: 0.6),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'VERIFIED TENANT APPLICATION DOSSIER & HOUSEMATE BIO',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: accentColor),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${_sanitizeLatin1(phone)}   |   ${_sanitizeLatin1(email)}   |   Preferred Area: ${_sanitizeLatin1(currentCity)}',
                          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                        ),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                        decoration: pw.BoxDecoration(
                          color: accentColor,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          'BUDGET: \$${_sanitizeLatin1(budgetAud)} AUD / WEEK',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#FEF3C7'),
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                        child: pw.Text(
                          '4-WEEK BOND + RENT READY UPFRONT',
                          style: pw.TextStyle(fontSize: 6.8, fontWeight: pw.FontWeight.bold, color: terracotta),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 0.7, color: PdfColors.grey300),
              pw.SizedBox(height: 6),

              // Matriz de Solvencia Financiera y Estabilidad (Lo que buscan Agencias y Caseros)
              _buildSectionHeader('1. FINANCIAL SOLVENCY, EMPLOYMENT & VISA VERIFICATION', accentColor, navyColor),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8F6F0'),
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.8),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('EMPLOYMENT & INCOME STATUS:', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
                              pw.SizedBox(height: 2),
                              pw.Text(_sanitizeLatin1(employmentStatus), style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: accentColor)),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('MOVE-IN AVAILABILITY:', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
                              pw.SizedBox(height: 2),
                              pw.Text(_sanitizeLatin1(moveInDate), style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('LEGAL VISA STATUS:', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
                              pw.SizedBox(height: 2),
                              pw.Text(_sanitizeLatin1(visaStatus), style: const pw.TextStyle(fontSize: 8.2, color: PdfColors.grey800)),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('BOND & UPFRONT DEPOSIT:', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
                              pw.SizedBox(height: 2),
                              pw.Text('Instant Osko / PayID Transfer Ready', style: pw.TextStyle(fontSize: 8.2, fontWeight: pw.FontWeight.bold, color: terracotta)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),

              // Presentación Personal
              _buildSectionHeader('2. PERSONAL INTRODUCTION & LIFESTYLE OVERVIEW', accentColor, navyColor),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8FAFC'),
                  border: pw.Border(left: pw.BorderSide(color: accentColor, width: 2.5)),
                ),
                child: pw.Text(
                  _sanitizeLatin1(aboutMe),
                  style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.65, color: PdfColors.grey900),
                ),
              ),
              pw.SizedBox(height: 8),

              // Hábitos de Convivencia
              _buildSectionHeader('3. SHARED LIVING ETIQUETTE & TENANT COMMITMENTS', accentColor, navyColor),
              pw.Wrap(
                spacing: 6,
                runSpacing: 5,
                children: houseHabits.map((habit) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(color: accentColor, width: 0.8),
                  ),
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Container(
                        width: 4.5,
                        height: 4.5,
                        decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: accentColor),
                      ),
                      pw.SizedBox(width: 4),
                      pw.Text(
                        _sanitizeLatin1(habit),
                        style: pw.TextStyle(fontSize: 8.3, fontWeight: pw.FontWeight.bold, color: navyColor),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              pw.SizedBox(height: 10),

              // Documentación Adjunta / Verificación Lista para Inspección
              _buildSectionHeader('4. SUPPORTING DOCUMENTS READY FOR LANDLORD / AGENT INSPECTION', accentColor, navyColor),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(9),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8FAFC'),
                  borderRadius: pw.BorderRadius.circular(5),
                  border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '- 100 Points of ID Ready: Valid Passport, Australian Visa Grant Notice (VEVO), and Driver Licence.\n'
                      '- Proof of Financial Capacity: Australian bank statement showing savings + recent payslips.\n'
                      '- Landlord & Character References: ${_sanitizeLatin1(references)} (Direct contact details available upon inspection).',
                      style: const pw.TextStyle(fontSize: 8.2, lineSpacing: 1.5, color: PdfColors.grey800),
                    ),
                  ],
                ),
              ),
              pw.Spacer(),

              // Pie de Firma y Contacto para Inspección
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: pw.BoxDecoration(
                  color: navyColor,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'AVAILABLE FOR IN-PERSON INSPECTION TODAY',
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                    ),
                    pw.Text(
                      '$displayName  |  ${_sanitizeLatin1(phone)}',
                      style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#FCD34D')),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Genera una Notificación Formal de Reclamación Salarial bajo la Fair Work Act 2009 (Letter of Demand)
  static Future<Uint8List> generateFairWorkClaimLetter({
    required String employeeName,
    required String employeePhone,
    required String employeeEmail,
    required String employerName,
    required String employerAbn,
    required String employmentPeriod,
    required double totalOwedAud,
    required String underpaymentDetails,
  }) async {
    final pdf = pw.Document();
    final alertColor = PdfColor.fromHex('#B91C1C');
    final terracotta = PdfColor.fromHex('#D96B43');
    final navyColor = PdfColor.fromHex('#1E293B');
    final displayEmployee = _sanitizeLatin1(employeeName.trim().isNotEmpty ? employeeName.trim() : 'Employee Claimant');
    final displayEmployer = _sanitizeLatin1(employerName.trim().isNotEmpty ? employerName.trim() : 'Respondent Employer');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Barra Superior de Requerimiento Legal
              pw.Container(height: 4, width: double.infinity, color: alertColor),
              pw.SizedBox(height: 8),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'FORMAL LETTER OF DEMAND - WAGE UNDERPAYMENT',
                          style: pw.TextStyle(fontSize: 13.5, fontWeight: pw.FontWeight.bold, color: alertColor),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Issued Pursuant to the Fair Work Act 2009 (Cth) & Applicable Modern Award',
                          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: navyColor),
                        ),
                      ],
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#FEF2F2'),
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: alertColor, width: 0.8),
                    ),
                    child: pw.Text(
                      'DATE: ${_formatDate(DateTime.now())}',
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: alertColor),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.8, color: PdfColors.grey300),
              pw.SizedBox(height: 6),

              // Bloque de Partes (Respondent Employer vs Claimant Employee)
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8FAFC'),
                  borderRadius: pw.BorderRadius.circular(5),
                  border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.8),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('TO RESPONDENT (EMPLOYER):', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: alertColor)),
                          pw.SizedBox(height: 2),
                          pw.Text(displayEmployer, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
                          pw.Text('ABN: ${employerAbn.trim().isNotEmpty ? _sanitizeLatin1(employerAbn.trim()) : "Registered Entity"}',
                              style: const pw.TextStyle(fontSize: 8.3, color: PdfColors.grey800)),
                          pw.Text('Attn: Company Directors & Payroll Officer',
                              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('FROM CLAIMANT (EMPLOYEE):', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
                          pw.SizedBox(height: 2),
                          pw.Text(displayEmployee, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
                          pw.Text('${_sanitizeLatin1(employeePhone)}  |  ${_sanitizeLatin1(employeeEmail)}', style: const pw.TextStyle(fontSize: 8.3, color: PdfColors.grey800)),
                          pw.Text('Employment Period: ${_sanitizeLatin1(employmentPeriod)}',
                              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: terracotta)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // Importe Total Reclamado y Plazo Legal
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#FEE2E2'),
                  borderRadius: pw.BorderRadius.circular(5),
                  border: pw.Border.all(color: alertColor, width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'TOTAL OUTSTANDING REMUNERATION CLAIMED:',
                          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: alertColor),
                        ),
                        pw.Text(
                          'Statutory Resolution Deadline: Within 14 Calendar Days of Notice',
                          style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                        ),
                      ],
                    ),
                    pw.Text(
                      '\$${totalOwedAud.toStringAsFixed(2)} AUD',
                      style: pw.TextStyle(fontSize: 13.5, fontWeight: pw.FontWeight.bold, color: alertColor),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // 1. Particularidades del Incumplimiento
              _buildSectionHeader('1. STATEMENT OF CLAIM & PARTICULARS OF UNDERPAYMENT', alertColor, navyColor),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(9),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#FFFBEB'),
                  borderRadius: pw.BorderRadius.circular(4),
                  border: pw.Border.all(color: PdfColor.fromHex('#FDE68A')),
                ),
                child: pw.Text(
                  _sanitizeLatin1(underpaymentDetails),
                  style: const pw.TextStyle(fontSize: 8.6, lineSpacing: 1.55, color: PdfColors.grey900),
                ),
              ),
              pw.SizedBox(height: 6),

              // 2. Disposiciones Legales Aplicables
              _buildSectionHeader('2. APPLICABLE AUSTRALIAN STATUTORY OBLIGATIONS', alertColor, navyColor),
              pw.Text(
                '- Section 45 of the Fair Work Act 2009 (Cth): Contravening a term of a Modern Award (including base hourly rates, 25% casual loading, and weekend/public holiday penalty rates) is a civil remedy violation.\n'
                '- Section 323 of the Fair Work Act 2009 (Cth): Amounts payable to an employee in relation to the performance of work must be paid in full, in money, and at least monthly.\n'
                '- Superannuation Guarantee (Administration) Act 1992: Employers are legally required to pay 12% statutory superannuation on Ordinary Time Earnings (OTE) to the employee\'s nominated fund.',
                style: const pw.TextStyle(fontSize: 8, lineSpacing: 1.45, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 6),

              // 3. Requerimiento Formal y Escalado a FWO / ATO
              _buildSectionHeader('3. FORMAL DEMAND FOR RECTIFICATION & NOTICE OF ESCALATION', alertColor, navyColor),
              pw.Text(
                'In accordance with the Fair Work Ombudsman (FWO) dispute resolution protocol, I formally request that:\n'
                '1. The outstanding balance of \$${totalOwedAud.toStringAsFixed(2)} AUD be transferred into my nominated Australian bank account within 14 calendar days of the date of this notice.\n'
                '2. Compliant itemised payslips (pursuant to s.536 of the Fair Work Act 2009) and confirmation of 12% superannuation remittance be provided via email to ${_sanitizeLatin1(employeeEmail)}.\n\n'
                'Please be advised that if payment and written confirmation are not received within 14 days, I will immediately lodge a formal investigation request with the Fair Work Ombudsman (FWO), report unpaid superannuation to the Australian Taxation Office (ATO), and pursue recovery through the Federal Circuit and Family Court of Australia (Small Claims Division) without further notice.',
                style: const pw.TextStyle(fontSize: 8.2, lineSpacing: 1.45, color: PdfColors.grey900),
              ),
              pw.Spacer(),

              // Firma del Reclamante
              pw.Divider(thickness: 0.6, color: PdfColors.grey300),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Signed & Issued By Claimant:', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text(displayEmployee, style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Direct Contact for Remittance Advice:', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text('${_sanitizeLatin1(employeePhone)}  |  ${_sanitizeLatin1(employeeEmail)}',
                          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Genera una Carta Formal de Renuncia con 2 Semanas de Preaviso y Solicitud de Finiquito + Referencia
  static Future<Uint8List> generateResignationLetter({
    required String employeeName,
    required String employerName,
    required String role,
    required DateTime lastWorkingDay,
    required String gratitudeMessage,
  }) async {
    final pdf = pw.Document();
    final navyColor = PdfColor.fromHex('#1E293B');
    final accentColor = PdfColor.fromHex('#D96B43');
    final tealColor = PdfColor.fromHex('#00A896');
    final displayEmployee = _sanitizeLatin1(employeeName.trim().isNotEmpty ? employeeName.trim() : 'Employee');
    final displayEmployer = _sanitizeLatin1(employerName.trim().isNotEmpty ? employerName.trim() : 'Employer Management');
    final displayRole = _sanitizeLatin1(role.trim().isNotEmpty ? role.trim() : 'Team Member');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 38, vertical: 34),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Barra Superior Ejecutiva
              pw.Container(height: 4, width: double.infinity, color: navyColor),
              pw.SizedBox(height: 10),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'FORMAL NOTICE OF RESIGNATION',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: navyColor),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Standard Australian Two-Week Notice & Handover Protocol',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: accentColor),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#E6F6F4'),
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: tealColor, width: 0.8),
                    ),
                    child: pw.Text(
                      'DATE ISSUED: ${_formatDate(DateTime.now())}',
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: tealColor),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 0.7, color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              // Tarjeta Resumen de Fechas y Puesto
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8FAFC'),
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('EMPLOYEE NAME:', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                          pw.SizedBox(height: 2),
                          pw.Text(displayEmployee, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('POSITION HELD:', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                          pw.SizedBox(height: 2),
                          pw.Text(displayRole, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: accentColor)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('FINAL WORKING DAY:', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                          pw.SizedBox(height: 2),
                          pw.Text(_formatDate(lastWorkingDay), style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: tealColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              pw.Text(
                'TO: Management & Human Resources Department\n$displayEmployer',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: navyColor, lineSpacing: 1.4),
              ),
              pw.SizedBox(height: 14),

              pw.Text('Dear Management,', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
              pw.SizedBox(height: 8),

              pw.Text(
                'Please accept this letter as formal notification that I am resigning from my position as $displayRole with $displayEmployer. In accordance with standard Australian workplace protocol, my final day of employment will be ${_formatDate(lastWorkingDay)}.',
                style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.8, color: PdfColors.grey900),
              ),
              pw.SizedBox(height: 12),

              // Mensaje de Agradecimiento Personalizado
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8F6F0'),
                  border: pw.Border(left: pw.BorderSide(color: accentColor, width: 2.5)),
                ),
                child: pw.Text(
                  _sanitizeLatin1(gratitudeMessage),
                  style: const pw.TextStyle(fontSize: 9.3, lineSpacing: 1.75, color: PdfColors.grey900),
                ),
              ),
              pw.SizedBox(height: 12),

              // Compromiso de Transición y Solicitud de Finiquito / Referencia
              _buildSectionHeader('HANDOVER COMMITMENT & FINAL EMPLOYMENT ENTITLEMENTS', accentColor, navyColor),
              pw.Text(
                '- Smooth Transition & Handover: Throughout my remaining notice period, I am fully committed to completing all assigned shifts, maintaining operational standards, and assisting with training replacement staff.\n'
                '- Final Pay & Superannuation Summary: I kindly request that my final payslip (including any accrued entitlements) and confirmation of Superannuation Guarantee contributions be forwarded upon completion of my final shift.\n'
                '- Statement of Service / Reference: I would greatly appreciate a brief written employment reference or confirmation of service (including Form 1263 verification if applicable) for my professional records.',
                style: const pw.TextStyle(fontSize: 8.6, lineSpacing: 1.55, color: PdfColors.grey800),
              ),
              pw.Spacer(),

              pw.Text(
                'Thank you once again for the opportunity and support during my time with $displayEmployer. I wish the business and the team every continued success.',
                style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.5, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 14),
              pw.Text('Yours sincerely,', style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800)),
              pw.SizedBox(height: 12),
              pw.Container(width: 140, height: 1, color: navyColor),
              pw.SizedBox(height: 4),
              pw.Text(displayEmployee, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: navyColor)),
              pw.Text(displayRole, style: pw.TextStyle(fontSize: 8.5, color: accentColor, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Muestra el diálogo nativo para previsualizar o compartir el PDF generado
  static Future<void> shareOrPrintPdf(Uint8List pdfBytes, String fileName) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  }
}
