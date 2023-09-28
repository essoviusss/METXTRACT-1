import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metxtract/utils/color_utils.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewPdf extends StatefulWidget {
  final Uint8List pdfBytes;
  final VoidCallback uploadCallback; // Callback for uploading PDF.

  const ViewPdf(
      {Key? key, required this.pdfBytes, required this.uploadCallback})
      : super(key: key);

  @override
  State<ViewPdf> createState() => _ViewPdfState();
}

class _ViewPdfState extends State<ViewPdf> {
  Future<List<int>> _readDocumentData(String name) async {
    final ByteData data = await rootBundle.load('assets/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  void _showResult(String text) {
    // Replace line breaks with spaces to make the text continuous with single spacing.

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Extracted text'),
          content: Scrollbar(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Text(text),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  extractText() async {
    //Load an existing PDF document.
    // Load the PDF document from the Uint8List.
    PdfDocument document = PdfDocument(inputBytes: widget.pdfBytes);

    // Create a new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    // Extract all the text from the document.
    String text = extractor.extractText(startPageIndex: 0);

    // Display the text.
    _showResult(text);
  }

  uploadToFirebase() async {
    await extractText();
    // widget.uploadCallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: ColorUtils.darkPurple,
        title: const Text(
          'PDF Preview',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SfPdfViewer.memory(
        widget.pdfBytes,
        key: GlobalKey<SfPdfViewerState>(),
      ),
      floatingActionButton: TextButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(ColorUtils.darkPurple)),
        onPressed: uploadToFirebase,
        child: const Text(
          'Upload PDF',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
