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

  /// Genera un Dossier de Verificación de Empleo Regional (88 Días / Formulario 1263 Summary)
  static Future<Uint8List> generateRegionalDossier({
    required String applicantName,
    required String passportNumber,
    required String visaSubclass,
    required List<RegionalJobEntry> jobs,
    required int totalDays,
  }) async {
    final pdf = pw.Document();

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
                      pw.Text('WORKING HOLIDAY VISA - SPECIFIED WORK SUMMARY',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#D96B43'))),
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
                    child: pw.Text('TOTAL: $totalDays / 88 DAYS',
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

  /// Muestra el diálogo nativo para previsualizar o compartir el PDF generado
  static Future<void> shareOrPrintPdf(Uint8List pdfBytes, String fileName) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  }
}
