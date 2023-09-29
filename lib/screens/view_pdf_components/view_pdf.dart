import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metxtract/utils/color_utils.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewPdf extends StatefulWidget {
  final Uint8List pdfBytes;
  final VoidCallback uploadCallback;

  const ViewPdf(
      {Key? key, required this.pdfBytes, required this.uploadCallback})
      : super(key: key);

  @override
  State<ViewPdf> createState() => _ViewPdfState();
}

class _ViewPdfState extends State<ViewPdf> {
  //Initialize PdfViewerControl.
  uploadToFirebase() async {
    widget.uploadCallback;
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
