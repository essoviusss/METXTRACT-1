// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:metxtract/models/pdf_model.dart';
import 'package:metxtract/screens/home_screen.dart';
import 'package:metxtract/utils/color_utils.dart';
import 'package:metxtract/utils/loading_dialog.dart';
import 'package:metxtract/utils/responsize_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:uuid/uuid.dart';

class ViewPdf extends StatefulWidget {
  final Uint8List pdfBytes;

  const ViewPdf({
    Key? key,
    required this.pdfBytes,
  }) : super(key: key);

  @override
  State<ViewPdf> createState() => _ViewPdfState();
}

class _ViewPdfState extends State<ViewPdf> {
  InputImage? inputImage;
  PdfPageImage? image;
  CollectionReference pdf = FirebaseFirestore.instance.collection('pdfList');
  var uuid = const Uuid();
  String? uid;
  final List<String> textBlocks = [];
  String? authorsText;
  var now = DateTime.now();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  getImage() async {
    final document = await PdfDocument.openData(widget.pdfBytes);

    final page = await document.getPage(1);

    image = await page.render(
      width: page.width * 2,
      height: page.height * 2,
      format: PdfPageImageFormat.jpeg,
    );

    inputImage = await convertPdfPageImageToInputImage(image!);

    return inputImage;
  }

  scanText() async {
    try {
      if (image != null) {
        final Uint8List imageData = image!.bytes;
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/temp_image.jpg');
        await tempFile.writeAsBytes(imageData);
        final inputImage = InputImage.fromFile(tempFile);
        final textRecognizer =
            TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText =
            await textRecognizer.processImage(inputImage);

        textRecognizer.close();

        String currentBlock = '';
        int blockNumber = 1;
        double previousBlockBottom = 0.0;

        for (TextBlock block in recognizedText.blocks) {
          String blockText = block.text;
          double blockTop = block.boundingBox.top;

          if (blockTop - previousBlockBottom > 20.0) {
            if (currentBlock.isNotEmpty) {
              textBlocks.add(currentBlock);
              currentBlock = '';
              blockNumber++;
            }
          }

          currentBlock += '$blockText ';
          previousBlockBottom = block.boundingBox.bottom;
        }

        // Add the last block
        if (currentBlock.isNotEmpty) {
          textBlocks.add(currentBlock);
        }

        // Split the author names by line breaks and join them with commas
        final List<String> authorLines = textBlocks[1].split('\n');
        authorsText = authorLines.join(', ');
        final sContext = scaffoldKey.currentState?.context;
        showDialog<void>(
          context: sContext!,
          builder: (BuildContext context) {
            return AlertDialog(
              titlePadding: EdgeInsets.zero,
              title: Container(
                decoration: const BoxDecoration(
                  color: ColorUtils.darkPurple,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      top: ResponsiveUtil.heightVar / 70,
                      bottom: ResponsiveUtil.heightVar / 70),
                  child: const Center(
                    child: Text(
                      "Recognized Text",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Title",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      controller: TextEditingController(text: textBlocks[0]),
                      readOnly: false,
                      maxLines: null,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Author/s",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      controller: TextEditingController(text: authorsText),
                      readOnly: false,
                      maxLines: null,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Publication Date",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      controller: TextEditingController(text: textBlocks[4]),
                      readOnly: false,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorUtils.darkPurple),
                    ),
                    onPressed: () {
                      uploadFiles();
                    },
                    child: const Text(
                      "Upload PDF",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        Fluttertoast.showToast(msg: "Input image is null");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error during text recognition: $e");
    }
  }

  Future<InputImage> convertPdfPageImageToInputImage(
      PdfPageImage pdfPageImage) async {
    if (pdfPageImage.width == null || pdfPageImage.height == null) {
      throw Exception("Invalid PDF page image data");
    }

    final Uint8List imageData = pdfPageImage.bytes;

    // Determine the format based on the actual image format
    InputImageFormat inputImageFormat;
    switch (pdfPageImage.format) {
      case PdfPageImageFormat.jpeg:
        inputImageFormat = InputImageFormat.yuv420;
        break;
      case PdfPageImageFormat.png:
        inputImageFormat = InputImageFormat.bgra8888;
        break;
      default:
        throw Exception("Invalid image format. Expected JPEG or PNG.");
    }

    // Verify that the ByteBuffer size matches the expected values
    if (imageData.lengthInBytes > 0) {
      final InputImage inputImage = InputImage.fromBytes(
        bytes: imageData,
        metadata: InputImageMetadata(
          size: Size(
            pdfPageImage.width!.toDouble(),
            pdfPageImage.height!.toDouble(),
          ),
          rotation: InputImageRotation.rotation0deg,
          format: inputImageFormat,
          bytesPerRow: pdfPageImage.width! * 4,
        ),
      );

      return inputImage;
    } else {
      throw Exception("Invalid image data format or size");
    }
  }

  showImageDialog(final image) async {
    if (image == null) {
      Fluttertoast.showToast(msg: "No Image Found!");
      return;
    }
    final sContext = scaffoldKey.currentState?.context;
    await showDialog<void>(
      context: sContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorUtils.background,
          content: Image.memory(image.bytes),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: ColorUtils.darkPurple),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorUtils.darkPurple),
                    ),
                    onPressed: () async {
                      scanText();
                    },
                    child: const Text(
                      'Scan Text',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> uploadFiles() async {
    uid = uuid.v1();

    if (widget.pdfBytes.isEmpty || inputImage == null) {
      Fluttertoast.showToast(msg: "No PDF data or image to upload!");
      return;
    }

    final Reference pdfStorageReference =
        FirebaseStorage.instance.ref().child("pdfFiles").child(uid!);
    final Reference imageStorageReference =
        FirebaseStorage.instance.ref().child("thumbnails").child(uid!);
    final sContext = scaffoldKey.currentState?.context;

    LoadingDialog.showLoadingDialog(context, 'Uploading');

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      final UploadTask pdfUploadTask =
          pdfStorageReference.putData(Uint8List.fromList(widget.pdfBytes));

      final UploadTask imageUploadTask =
          imageStorageReference.putData(Uint8List.fromList(inputImage!.bytes!));

      await pdfUploadTask;
      await imageUploadTask;

      final String pdfDownloadUrl = await pdfStorageReference.getDownloadURL();

      final String imageDownloadUrl =
          await imageStorageReference.getDownloadURL();

      Pdf pdfModel = Pdf();
      pdfModel.title = textBlocks[0];
      pdfModel.authors = authorsText;
      pdfModel.publicationDate = textBlocks[4];
      pdfModel.uid = uid;
      pdfModel.userId = userId;
      pdfModel.pdfDownloadUrl = pdfDownloadUrl;
      pdfModel.imgDownloadUrl = imageDownloadUrl;
      pdfModel.dateAdded = now;

      final upload = await pdf.doc(pdfModel.uid).set(pdfModel.toMap());
      Fluttertoast.showToast(msg: "PDF uploaded successfully!");
      scaffoldKey.currentState?.closeDrawer();
      Navigator.pop(context);
      Navigator.pop(context);

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()));
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error uploading PDF and image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('PDF Preview'),
      ),
      body: SfPdfViewer.memory(
        widget.pdfBytes,
        key: GlobalKey<SfPdfViewerState>(),
      ),
      persistentFooterButtons: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(ColorUtils.darkPurple),
          ),
          onPressed: () async {
            final image = await getImage();
            showImageDialog(image);
          },
          child: const Text(
            'Scan PDF',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
