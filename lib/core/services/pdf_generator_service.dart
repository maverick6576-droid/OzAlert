import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/models/phase2/resume_data.dart';
import '../../domain/models/phase2/regional_work_log.dart';

class PdfGeneratorService {
  /// Genera un Currículum Australiano estándar de máximo impacto (ATS-friendly, sin foto ni edad, con derechos de visado destacados)
  static Future<Uint8List> generateAustralianResume(AustralianResumeData data) async {
    final pdf = pw.Document();

    final accentColor = PdfColor.fromHex(data.themeColorHex.isNotEmpty ? data.themeColorHex : '#D96B43');
    final navyColor = PdfColor.fromHex('#1E293B');
    final subtleBg = PdfColor.fromHex('#F8F6F0');
    final borderColor = PdfColor.fromHex('#E2DCD5');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 30),
        build: (pw.Context context) {
          return [
            // Cabecera: Nombre, Rol Objetivo y Contacto
            pw.Header(
              level: 0,
              decoration: const pw.BoxDecoration(border: null),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            data.fullName.toUpperCase(),
                            style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: navyColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                          if (data.jobTitle.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              data.jobTitle.toUpperCase(),
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
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                        child: pw.Text(
                          'AUSTRALIAN RESUME STANDARD',
                          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),

                  // Contact Strip (Phone, Email, Suburb, LinkedIn)
                  pw.Row(
                    children: [
                      pw.Text(
                        [
                          data.phone,
                          data.email,
                          data.locationSuburb,
                          if (data.linkedIn.isNotEmpty) data.linkedIn,
                        ].where((s) => s.isNotEmpty).join('   |   '),
                        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 6),

                  // DERECHOS DE VISADO Y DISPONIBILIDAD (EL ELEMENTO MÁS CRÍTICO PARA EMPLEADORES EN AUSTRALIA)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: subtleBg,
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: borderColor, width: 0.8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Row(
                              children: [
                                pw.Container(
                                  width: 6,
                                  height: 6,
                                  decoration: pw.BoxDecoration(
                                    shape: pw.BoxShape.circle,
                                    color: PdfColor.fromHex('#00A896'),
                                  ),
                                ),
                                pw.SizedBox(width: 5),
                                pw.Text(
                                  'VISA STATUS: ',
                                  style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: navyColor),
                                ),
                                pw.Text(
                                  data.visaStatus,
                                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                                ),
                              ],
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#00A896'),
                                borderRadius: pw.BorderRadius.circular(2),
                              ),
                              child: pw.Text(
                                'FULL WORK RIGHTS',
                                style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 3),
                        pw.Row(
                          children: [
                            pw.Container(
                              width: 6,
                              height: 6,
                              decoration: pw.BoxDecoration(
                                shape: pw.BoxShape.circle,
                                color: accentColor,
                              ),
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              'AVAILABILITY: ',
                              style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: navyColor),
                            ),
                            pw.Text(
                              data.availability,
                              style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Divider(thickness: 0.8, color: PdfColors.grey300),
                ],
              ),
            ),

            // Perfil Profesional / Summary
            _buildSectionHeader('PROFESSIONAL SUMMARY', accentColor, navyColor),
            pw.Paragraph(
              text: data.summary,
              style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.8, color: PdfColors.grey900),
            ),

            // Certificaciones Australianas (Crucial para Hospitality, Construction, etc.)
            if (data.certifications.isNotEmpty) ...[
              _buildSectionHeader('AUSTRALIAN LICENCES & CERTIFICATIONS', accentColor, navyColor),
              pw.Wrap(
                spacing: 6,
                runSpacing: 4,
                children: data.certifications.map((cert) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(3),
                    border: pw.Border.all(color: accentColor, width: 0.7),
                  ),
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Container(
                        width: 4,
                        height: 4,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: accentColor,
                        ),
                      ),
                      pw.SizedBox(width: 4),
                      pw.Text(
                        cert,
                        style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: navyColor),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ],

            // Habilidades Clave
            if (data.skills.isNotEmpty) ...[
              _buildSectionHeader('CORE COMPETENCIES & KEY ATTRIBUTES', accentColor, navyColor),
              pw.Wrap(
                spacing: 5,
                runSpacing: 3,
                children: data.skills.map((skill) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F1EFEA'),
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Text(
                    skill,
                    style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey900),
                  ),
                )).toList(),
              ),
            ],

            // Experiencia Laboral
            if (data.experiences.isNotEmpty) ...[
              _buildSectionHeader('WORK EXPERIENCE', accentColor, navyColor),
              ...data.experiences.map((exp) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          exp.role.toUpperCase(),
                          style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: navyColor),
                        ),
                        pw.Text(
                          exp.period,
                          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 1),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          exp.company,
                          style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, fontWeight: pw.FontWeight.bold, color: accentColor),
                        ),
                        pw.Text(
                          exp.location,
                          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                    ...exp.bulletPoints.map((bp) => pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 6, bottom: 2),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            margin: const pw.EdgeInsets.only(top: 3.5, right: 5),
                            width: 3,
                            height: 3,
                            decoration: const pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              bp,
                              style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800, lineSpacing: 1.4),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              )),
            ],

            // Formación / Educación
            if (data.education.isNotEmpty) ...[
              _buildSectionHeader('EDUCATION & QUALIFICATIONS', accentColor, navyColor),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 4),
                child: pw.Text(
                  data.education,
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                ),
              ),
            ],

            // Referencias
            _buildSectionHeader('REFERENCES', accentColor, navyColor),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 4),
              child: pw.Text(
                '${data.references} (Australian and international professional referees available upon interview)',
                style: pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700, fontStyle: pw.FontStyle.italic),
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
      padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: navyColor,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Container(
            width: 30,
            height: 1.8,
            color: accentColor,
          ),
          pw.SizedBox(height: 2),
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
  }) async {
    final pdf = pw.Document();
    final targetDays = targetYear == 3 ? 179 : 88;
    final yearTitle = targetYear == 3 ? 'THIRD' : 'SECOND';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('$yearTitle WORKING HOLIDAY VISA - SPECIFIED WORK SUMMARY',
                          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#D96B43'))),
                      pw.Text('Evidence Summary for Form 1263 / ImmiAccount Lodgement',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#00A896'),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text('TOTAL: $totalDays / $targetDays DAYS',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Applicant: $applicantName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('Passport: $passportNumber', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Subclass: $visaSubclass', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Tabla de Empleos
            pw.TableHelper.fromTextArray(
              headers: ['Employer / Business', 'ABN', 'Site Postcode', 'Industry', 'Period', 'Days'],
              headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#1E293B')),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              data: jobs.map((j) => [
                j.employerBusinessName,
                j.employerAbn,
                j.workSitePostcode,
                j.industry.replaceAll('_', ' ').toUpperCase(),
                '${j.startDate.day}/${j.startDate.month}/${j.startDate.year} - ${j.endDate.day}/${j.endDate.month}/${j.endDate.year}',
                j.totalDaysCounted.toString(),
              ]).toList(),
            ),

            pw.SizedBox(height: 24),
            pw.Text('DECLARATION', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(
              'I declare that the information provided above is true and correct and accurately reflects specified work completed in eligible regional postcodes in accordance with Australian immigration laws.',
              style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Genera una Carta de Presentación Australiana Oficial (Cover Letter)
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabecera del Candidato
              pw.Text(
                applicantName.toUpperCase(),
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: navyColor),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                '$phone   |   $email   |   $locationSuburb',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F4F1EA'),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'VISA STATUS: $visaStatus [FULL WORK RIGHTS]',
                  style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: accentColor),
                ),
              ),
              pw.Divider(thickness: 0.8, color: PdfColors.grey300),
              pw.SizedBox(height: 12),

              // Fecha y Destinatario
              pw.Text(
                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Hiring Manager / Recruitment Team\n$companyName',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: navyColor),
              ),
              pw.SizedBox(height: 12),

              // Asunto
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: accentColor, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'APPLICATION FOR: ${targetRole.toUpperCase()}',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: accentColor),
                ),
              ),
              pw.SizedBox(height: 16),

              // Cuerpo de la Carta
              pw.Paragraph(
                text: coverLetterBody,
                style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 2, color: PdfColors.grey900),
              ),
              pw.Spacer(),

              // Firma
              pw.Text('Sincerely,', style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800)),
              pw.SizedBox(height: 14),
              pw.Text(
                applicantName,
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: navyColor),
              ),
              pw.Text(
                'Available for immediate trial shift & interview.',
                style: pw.TextStyle(fontSize: 8.5, color: accentColor, fontStyle: pw.FontStyle.italic),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Genera un Perfil de Alquiler en Australia (Rental & Flatmate Bio)
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
    final accentColor = PdfColor.fromHex('#00A896'); // Verde azulado
    final navyColor = PdfColor.fromHex('#1E293B');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 34),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabecera
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        fullName.toUpperCase(),
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: navyColor),
                      ),
                      pw.Text(
                        'AUSTRALIAN RENTAL APPLICATION PROFILE & HOUSEMATE BIO',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: accentColor),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: accentColor,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      'BUDGET: \$$budgetAud AUD / WK',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Text('$phone  |  $email  |  Target Area: $currentCity  |  Move-in: $moveInDate',
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
              pw.Divider(thickness: 0.8, color: PdfColors.grey300),
              pw.SizedBox(height: 8),

              // Tarjeta de Solvencia y Visado
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8F6F0'),
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColor.fromHex('#E2DCD5')),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text('LEGAL VISA STATUS:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: navyColor)),
                      pw.Text(visaStatus, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
                    ]),
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text('EMPLOYMENT & INCOME:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: navyColor)),
                      pw.Text(employmentStatus, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
                    ]),
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text('BOND PAYMENT:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: navyColor)),
                      pw.Text('Ready 4 Weeks Upfront', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: accentColor)),
                    ]),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              // About Me
              pw.Text('ABOUT ME', style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
              pw.SizedBox(height: 3),
              pw.Paragraph(
                text: aboutMe,
                style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.8, color: PdfColors.grey900),
              ),
              pw.SizedBox(height: 12),

              // Hábitos de Convivencia
              pw.Text('LIVING HABITS & HOUSE ETIQUETTE', style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
              pw.SizedBox(height: 4),
              pw.Wrap(
                spacing: 6,
                runSpacing: 4,
                children: houseHabits.map((habit) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(color: accentColor, width: 0.8),
                  ),
                  child: pw.Text('[+] $habit', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
                )).toList(),
              ),
              pw.Spacer(),

              // Referencias
              pw.Text('LANDLORD & CHARACTER REFERENCES', style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
              pw.SizedBox(height: 2),
              pw.Text(references, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Genera una Carta Formal de Reclamación Salarial ante Fair Work
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
    final alertColor = PdfColor.fromHex('#D96B43');
    final navyColor = PdfColor.fromHex('#1E293B');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('FORMAL NOTICE OF WAGE UNDERPAYMENT',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: alertColor)),
                  pw.Text('Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                ],
              ),
              pw.Text('Under the Fair Work Act 2009 & Applicable Modern Award',
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              pw.Text('ATTENTION:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: navyColor)),
              pw.Text('The Directors / Payroll Department\n$employerName (ABN: $employerAbn)',
                  style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey900)),
              pw.SizedBox(height: 10),

              pw.Text('FROM EMPLOYEE:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: navyColor)),
              pw.Text('$employeeName | $employeePhone | $employeeEmail\nPeriod of Employment: $employmentPeriod',
                  style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey900)),
              pw.SizedBox(height: 14),

              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#FEE2E2'),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL OUTSTANDING REMUNERATION CLAIMED:',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#991B1B'))),
                    pw.Text('\$${totalOwedAud.toStringAsFixed(2)} AUD',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#991B1B'))),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              pw.Text('STATEMENT OF CLAIM & PARTICULARS:', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
              pw.SizedBox(height: 4),
              pw.Text(
                underpaymentDetails,
                style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.8, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 14),

              pw.Text('FORMAL REQUEST FOR RECTIFICATION:', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: navyColor)),
              pw.SizedBox(height: 4),
              pw.Text(
                'In accordance with Fair Work Ombudsman procedures, I formally request that the outstanding amount of \$${totalOwedAud.toStringAsFixed(2)} AUD (inclusive of unpaid base award rates, casual loading and 12% superannuation guarantee) be deposited into my nominated Australian bank account within 14 business days from the date of this letter.\n\nShould this matter not be resolved by this date, I reserve the full right to escalate this formal record to the Fair Work Ombudsman (FWO) and the Australian Taxation Office (ATO) for statutory dispute mediation.',
                style: const pw.TextStyle(fontSize: 8.5, lineSpacing: 1.8, color: PdfColors.grey800),
              ),
              pw.Spacer(),

              pw.Text('Signed:', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
              pw.SizedBox(height: 10),
              pw.Text(employeeName, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: navyColor)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Genera una Carta Formal de Renuncia con 2 Semanas de Preaviso (Two-Week Notice)
  static Future<Uint8List> generateResignationLetter({
    required String employeeName,
    required String employerName,
    required String role,
    required DateTime lastWorkingDay,
    required String gratitudeMessage,
  }) async {
    final pdf = pw.Document();
    final navyColor = PdfColor.fromHex('#1E293B');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('FORMAL LETTER OF RESIGNATION',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: navyColor)),
              pw.Text('Standard Two-Week Notice Period',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 12),

              pw.Text('Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
              pw.SizedBox(height: 8),
              pw.Text('To: Management Team\n$employerName',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: navyColor)),
              pw.SizedBox(height: 14),

              pw.Text('Dear Management,', style: const pw.TextStyle(fontSize: 9.5)),
              pw.SizedBox(height: 8),
              pw.Text(
                'Please accept this letter as formal notification that I am resigning from my position as $role at $employerName. My final working day will be ${lastWorkingDay.day}/${lastWorkingDay.month}/${lastWorkingDay.year}, providing the standard two weeks notice.',
                style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 2, color: PdfColors.grey900),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                gratitudeMessage,
                style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 2, color: PdfColors.grey900),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'During these next two weeks, I am fully committed to ensuring a smooth transition of my duties and assisting with training team members. I kindly request confirmation of my final payslip and an employment reference upon departure.',
                style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 2, color: PdfColors.grey900),
              ),
              pw.Spacer(),

              pw.Text('Sincerely,', style: const pw.TextStyle(fontSize: 9.5)),
              pw.SizedBox(height: 16),
              pw.Text(employeeName, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: navyColor)),
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
