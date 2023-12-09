// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/services.dart';
import 'package:metxtract/screens/view_pdf_components/view_pdf.dart';
import 'package:metxtract/utils/color_utils.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metxtract/utils/responsize_utils.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<String> _scannedPictures = [];
  PdfDocument document = PdfDocument();
  Uint8List? uint8List;
  Uint8List? uint8List1;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {}

  Future<void> scanPDF() async {
    List<String> scannedPictures;
    try {
      scannedPictures = await CunningDocumentScanner.getPictures() ?? [];
      if (!mounted) return;
      setState(() {
        _scannedPictures.addAll(scannedPictures);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error uploading PDF $e");
    }
  }

  Future<void> uploadConvertedFile() async {
    if (_scannedPictures.isEmpty) {
      Fluttertoast.showToast(msg: "You haven't scanned an image yet!");
      return;
    }

    // Create a new PDF document for conversion.
    PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 0;
    // Iterate over the scanned pictures and add them to the PDF page.
    for (var picture in _scannedPictures) {
      // Read the image data.
      List<int> imageData = await File(picture).readAsBytes();

      // Create a PDF image from the image data.
      final PdfImage image = PdfBitmap(imageData);

      // Add a new page to the PDF document for each image (optional).
      PdfPage page = document.pages.add();

      // Draw the PDF image on the page.
      page.graphics.drawImage(
          image, Rect.fromLTWH(0, 0, page.size.width, page.size.height));
    }

    document.dispose();
  }

  Future<void> viewPDF() async {
    if (_scannedPictures.isEmpty) {
      Fluttertoast.showToast(msg: "You haven't scanned an image yet!");
      return;
    }
    // Create a new PDF document for viewing
    PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 0;

    // Iterate over the scanned pictures and add them to the PDF page.
    for (var picture in _scannedPictures) {
      // Read the image data.
      List<int> imageData = await File(picture).readAsBytes();

      // Create a PDF image from the image data.
      final PdfImage image = PdfBitmap(imageData);

      // Add a new page to the PDF document for each image (optional).
      PdfPage page = document.pages.add();

      // Draw the PDF image on the page.
      page.graphics.drawImage(
          image, Rect.fromLTWH(0, 0, page.size.width, page.size.height));
    }

    // Save the PDF document to a byte array.
    List<int> bytes = await document.save();

    // Convert the PDF bytes to a Uint8List.
    uint8List = Uint8List.fromList(bytes);

    // Dispose of the PDF document.
    document.dispose();

    // Open the PDF in the PDF viewer.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewPdf(
          pdfBytes: uint8List!,
        ),
      ),
    );
  }

  Future<void> uploadPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        // Use Dart's File class to read the content of the selected file.
        File selectedFile = File(file.path!);
        uint8List1 = await selectedFile.readAsBytes();

        if (uint8List1!.isNotEmpty) {
          // Provide user feedback that the upload was successful.
          Fluttertoast.showToast(
              msg: "PDF selected and converted successfully.");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewPdf(
                pdfBytes: uint8List1!,
              ),
            ),
          );
        } else {
          Fluttertoast.showToast(msg: "Selected file has no content.");
        }
      } else {
        // Handle the case where the user canceled the file picker.
        Fluttertoast.showToast(msg: "User canceled file selection.");
      }
    } catch (e) {
      // Handle other exceptions that might occur during the process.
      Fluttertoast.showToast(msg: "Error picking and uploading PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: EdgeInsets.only(
              left: ResponsiveUtil.widthVar / 25,
              right: ResponsiveUtil.widthVar / 25,
              top: ResponsiveUtil.heightVar / 50),
          child: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Hello Admin!",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveUtil.heightVar / 80,
              ),
              const Text(
                "Welcome back! Get familiar with the dashboard and view and upload thesis on-the-go!",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(
                height: ResponsiveUtil.heightVar / 60,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        scanPDF();
                      },
                      child: Container(
                          height: ResponsiveUtil.heightVar / 7,
                          color: ColorUtils.darkPurple,
                          child: Container(
                            margin: EdgeInsets.only(
                              left: ResponsiveUtil.widthVar / 25,
                              top: ResponsiveUtil.heightVar / 80,
                              right: ResponsiveUtil.widthVar / 25,
                              bottom: ResponsiveUtil.heightVar / 80,
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.topLeft,
                                    child: const Text(
                                      "Scan Image",
                                      style: TextStyle(
                                          color: ColorUtils.background,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.document_scanner,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.bottomLeft,
                                    child: const Icon(
                                      Icons.line_axis,
                                      color: ColorUtils.darkPurple,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveUtil.widthVar / 25,
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        uploadPDF();
                      },
                      child: Container(
                        height: ResponsiveUtil.heightVar / 7,
                        color: ColorUtils.darkPurple,
                        child: Container(
                          margin: EdgeInsets.only(
                            left: ResponsiveUtil.widthVar / 25,
                            top: ResponsiveUtil.heightVar / 80,
                            right: ResponsiveUtil.widthVar / 25,
                            bottom: ResponsiveUtil.heightVar / 80,
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  child: const Text(
                                    "Upload Document",
                                    style: TextStyle(
                                        color: ColorUtils.background,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.upload_file_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.bottomLeft,
                                  child: const Icon(
                                    Icons.line_axis,
                                    color: ColorUtils.darkPurple,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: ResponsiveUtil.heightVar / 20,
              ),
              const Text(
                "Backgrounds should be plain and unobtrusive providing no distraction from the area of interest.",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(
                height: ResponsiveUtil.heightVar / 30,
              ),
              const Text(
                "General library light may not be sufficient to Light an image. Consider using flash.",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: ResponsiveUtil.heightVar / 30,
              ),
              const Text(
                "Images must be in focus. If your camera is too close to the paper, this usually results in an out of focus photograph. Try taking the picture a bit further back.",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: Material(
          elevation: 4.0,
          shape: const CircleBorder(),
          color: _scannedPictures.isEmpty ? Colors.grey : ColorUtils.darkPurple,
          child: IconButton(
            icon: const Icon(Icons.preview),
            color: ColorUtils.background,
            onPressed: () {
              viewPDF();
            },
          ),
        ),
      ),
    );
  }
}
