// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:metxtract/main.dart';
import 'package:metxtract/models/pdf_model.dart';
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

        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Recognized Text Blocks'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: "Title"),
                      controller: TextEditingController(text: textBlocks[0]),
                      readOnly: false,
                      maxLines: null,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: "Author/s"),
                      controller: TextEditingController(text: authorsText),
                      readOnly: false,
                      maxLines: null,
                    ),
                    TextField(
                      decoration:
                          const InputDecoration(labelText: "Publication Date"),
                      controller: TextEditingController(text: textBlocks[4]),
                      readOnly: false,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    uploadFiles();
                  },
                  child: const Text('Upload PDF'),
                ),
              ],
            );
          },
        );
      } else {
        print("Input image is null");
      }
    } catch (e) {
      print("Error during text recognition: $e");
    }
  }

  Future<InputImage> convertPdfPageImageToInputImage(
      PdfPageImage pdfPageImage) async {
    if (pdfPageImage.width == null || pdfPageImage.height == null) {
      throw Exception("Invalid PDF page image data");
    }

    final Uint8List imageData = pdfPageImage.bytes;

    // Verify the format of the image
    print("Image format: ${pdfPageImage.format}");

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

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.memory(image.bytes),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                scanText();
              },
              child: Text('Scan'),
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

    try {
      // Upload the PDF file to Firebase Storage.
      final UploadTask pdfUploadTask =
          pdfStorageReference.putData(Uint8List.fromList(widget.pdfBytes));

      // Upload the input image to Firebase Storage.
      final UploadTask imageUploadTask =
          imageStorageReference.putData(Uint8List.fromList(inputImage!.bytes!));

      // Monitor the upload progress for both tasks.
      pdfUploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print(
            'PDF Upload Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
      });

      imageUploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print(
            'Image Upload Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
      });

      // Await the completion of both upload tasks.
      await pdfUploadTask;
      await imageUploadTask;

      // Get the download URL for the uploaded PDF file.
      final String pdfDownloadUrl = await pdfStorageReference.getDownloadURL();
      // Get the download URL for the uploaded input image.
      final String imageDownloadUrl =
          await imageStorageReference.getDownloadURL();

      Pdf pdfModel = Pdf();
      pdfModel.title = textBlocks[0];
      pdfModel.authors = authorsText;
      pdfModel.publicationDate = textBlocks[4];
      pdfModel.uid = uid;
      pdfModel.pdfDownloadUrl = pdfDownloadUrl;
      pdfModel.imgDownloadUrl = imageDownloadUrl;
      pdfModel.dateAdded = now;

      pdf.doc(pdfModel.uid).set(pdfModel.toMap()).then(
        (value) {
          Fluttertoast.showToast(msg: "PDF uploaded successfully!");
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MyApp()));
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Error uploading PDF and image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
      ),
      body: SfPdfViewer.memory(
        widget.pdfBytes,
        key: GlobalKey<SfPdfViewerState>(),
      ),
      floatingActionButton: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
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
    );
  }
}
