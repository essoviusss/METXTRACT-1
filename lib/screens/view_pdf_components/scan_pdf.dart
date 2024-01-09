import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:metxtract/screens/view_pdf_components/view_pdf.dart';
import 'package:metxtract/utils/color_utils.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class TestScan extends StatefulWidget {
  final Uint8List pdfBytes;
  const TestScan({Key? key, required this.pdfBytes}) : super(key: key);

  @override
  State<TestScan> createState() => _TestScanState();
}

class _TestScanState extends State<TestScan> {
  int? tableOfContentsPage;

  @override
  void initState() {
    super.initState();
    findTableOfContentsPage(widget.pdfBytes);
  }

  void findTableOfContentsPage(Uint8List pdfBytes) async {
    PdfDocument document = PdfDocument(inputBytes: pdfBytes);
    PdfTextExtractor extractor = PdfTextExtractor(document);

    Rect predefinedBounds = const Rect.fromLTRB(0, 0, 800, 300);

    for (int i = 0; i < document.pages.count; i++) {
      List<TextLine> result = extractor.extractTextLines(startPageIndex: i);

      for (int j = 0; j < result.length; j++) {
        List<TextWord> wordCollection = result[j].wordCollection;

        for (int k = 0; k < wordCollection.length; k++) {
          Rect wordBounds = wordCollection[k].bounds;

          if (predefinedBounds.overlaps(wordBounds) &&
              RegExp(r'ABSTRACT', caseSensitive: false)
                  .hasMatch(wordCollection[k].text)) {
            setState(() {
              tableOfContentsPage = i + 1;
            });
            return;
          }
        }
      }
    }
  }

  void testScan(Uint8List pdfBytes) async {
    PdfDocument document = PdfDocument(inputBytes: pdfBytes);
    PdfTextExtractor extractor = PdfTextExtractor(document);
    String text = extractor.extractText();

    if (RegExp(r'ABSTRACT', caseSensitive: false).hasMatch(text)) {
      _showResult("Found on Page ${tableOfContentsPage ?? 'Unknown'}");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewPdf(
            pdfBytes: widget.pdfBytes,
            abstractPage: tableOfContentsPage!,
          ),
        ),
      );
    } else {
      _showResult("Abstract not found");
    }
  }

  void _showResult(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Result'),
          content: Text(text),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF VIEWER"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(ColorUtils.darkPurple),
              ),
              child: const Text(
                'VIEW PDF',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                testScan(widget.pdfBytes);
              },
            )
          ],
        ),
      ),
    );
  }
}
