import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:metxtract/screens/view_pdf_components/view_pdf.dart';

class TestScan1 extends StatefulWidget {
  final Uint8List pdfBytes;
  final int pageNum;
  const TestScan1({Key? key, required this.pdfBytes, required this.pageNum})
      : super(key: key);

  @override
  State<TestScan1> createState() => _TestScan1State();
}

class _TestScan1State extends State<TestScan1> {
  int? tableOfContentsPage;

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
              child: const Text(
                'VIEW PDF',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ViewPdf(
                        pdfBytes: widget.pdfBytes,
                        abstractPage: widget.pageNum)));
              },
            )
          ],
        ),
      ),
    );
  }
}
