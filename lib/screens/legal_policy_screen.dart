import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../constants/legal_constants.dart';
import '../constants/colors.dart';
import '../widgets/translated_widget.dart';

class LegalPolicyScreen extends StatelessWidget {
  const LegalPolicyScreen({Key? key}) : super(key: key);

  Future<void> _downloadPdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Privacy Policy & Terms', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Paragraph(text: LegalConstants.privacyPolicy),
          ];
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'privacy_policy.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const AutoTranslateText('Privacy Policy & Terms'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadPdf(context),
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: Markdown(
        data: LegalConstants.privacyPolicy,
        padding: const EdgeInsets.all(16.0),
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          h1: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            color: AppColors.primary,
          ),
          h2: const TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Colors.black87,
          ),
          p: const TextStyle(
            fontSize: 14, 
            height: 1.5, 
            color: Colors.black87,
          ),
          blockSpacing: 16.0,
        ),
      ),
    );
  }
}
