import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/models/phase2/resume_data.dart';
import '../../domain/models/phase2/regional_work_log.dart';

class PdfGeneratorService {
  /// Genera un Currículum Australiano estándar (1-2 páginas, sin foto ni edad)
  static Future<Uint8List> generateAustralianResume(AustralianResumeData data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        build: (pw.Context context) {
          return [
            // Cabecera: Nombre y Contacto (Estilo minimalista australiano)
            pw.Header(
              level: 0,
              decoration: const pw.BoxDecoration(border: null),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    data.fullName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#D96B43'), // Terracota corporativo
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      pw.Text('${data.phone}  |  ${data.email}  |  ${data.locationSuburb}',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  // DERECHOS DE VISADO Y DISPONIBILIDAD (Crucial para empleadores en Australia)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F4F1EA'),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('VISA STATUS: ${data.visaStatus}',
                            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E293B'))),
                        pw.Text('AVAILABILITY: ${data.availability}',
                            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#00A896'))),
                      ],
                    ),
                  ),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                ],
              ),
            ),

            // Perfil Profesional / Resumen
            pw.Paragraph(
              text: data.summary,
              style: const pw.TextStyle(fontSize: 10, lineSpacing: 2, color: PdfColors.grey800),
            ),
            pw.SizedBox(height: 10),

            // Habilidades Clave
            if (data.skills.isNotEmpty) ...[
              pw.Text('KEY COMPETENCIES',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E293B'))),
              pw.SizedBox(height: 4),
              pw.Wrap(
                spacing: 6,
                runSpacing: 4,
                children: data.skills.map((skill) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Text(skill, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                )).toList(),
              ),
              pw.SizedBox(height: 12),
            ],

            // Experiencia Laboral
            if (data.experiences.isNotEmpty) ...[
              pw.Text('WORK EXPERIENCE',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E293B'))),
              pw.SizedBox(height: 6),
              ...data.experiences.map((exp) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(exp.role, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                        pw.Text(exp.period, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                      ],
                    ),
                    pw.Text('${exp.company} - ${exp.location}',
                        style: pw.TextStyle(fontSize: 9.5, fontStyle: pw.FontStyle.italic, color: PdfColor.fromHex('#D96B43'))),
                    pw.SizedBox(height: 3),
                    ...exp.bulletPoints.map((bp) => pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('- ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                          pw.Expanded(child: pw.Text(bp, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800))),
                        ],
                      ),
                    )),
                  ],
                ),
              )),
              pw.SizedBox(height: 6),
            ],

            // Certificaciones Australianas
            if (data.certifications.isNotEmpty) ...[
              pw.Text('AUSTRALIAN LICENCES & CERTIFICATES',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E293B'))),
              pw.SizedBox(height: 4),
              ...data.certifications.map((cert) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
                child: pw.Row(
                  children: [
                    pw.Text('> ', style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#00A896'), fontWeight: pw.FontWeight.bold)),
                    pw.Text(cert, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                  ],
                ),
              )),
              pw.SizedBox(height: 10),
            ],

            // Referencias
            pw.Text('REFERENCES',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E293B'))),
            pw.SizedBox(height: 2),
            pw.Text(data.references, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ];
        },
      ),
    );

    return pdf.save();
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
