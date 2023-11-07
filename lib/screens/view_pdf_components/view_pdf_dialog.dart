import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewPdfDialog extends StatefulWidget {
  final String pdfUrl;

  const ViewPdfDialog({
    Key? key,
    required this.pdfUrl,
  }) : super(key: key);

  @override
  State<ViewPdfDialog> createState() => _ViewPdfDialogState();
}

class _ViewPdfDialogState extends State<ViewPdfDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
      ),
      body: SfPdfViewer.network(
        widget.pdfUrl,
        key: GlobalKey<SfPdfViewerState>(),
      ),
    );
  }
}
