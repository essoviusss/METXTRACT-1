// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:metxtract/main.dart';
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

  getImage() async {
    final document = await PdfDocument.openData(widget.pdfBytes);

    final page = await document.getPage(1);

    // Increase resolution
    image = await page.render(
      width: page.width * 2,
      height: page.height * 2,
      format: PdfPageImageFormat.jpeg,
    );

    // Apply image enhancement and binarization here if needed

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

        // Close the text recognizer as soon as you're done processing
        textRecognizer.close();

        // Process recognized text to group into blocks based on spacing

        String currentBlock = '';
        int blockNumber = 1; // Initialize block number
        double previousBlockBottom =
            0.0; // Initialize the bottom of the previous block

        for (TextBlock block in recognizedText.blocks) {
          String blockText = block.text;
          double blockTop = block.boundingBox.top;

          // Adjust the threshold and check for spacing relative to the previous block's bottom
          if (blockTop - previousBlockBottom > 20.0) {
            if (currentBlock.isNotEmpty) {
              textBlocks.add(currentBlock);
              currentBlock = '';
              blockNumber++;
            }
          }

          currentBlock += '$blockText '; // Add space between words
          previousBlockBottom =
              block.boundingBox.bottom; // Update previous block's bottom
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
                      maxLines: null, // Allow multiple lines
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
                    uploadFile();
                  },
                  child: Text('Upload PDF'),
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
          format: inputImageFormat, // Set the expected format here
          bytesPerRow:
              pdfPageImage.width! * 4, // You may need to adjust this value
        ),
      );

      return inputImage;
    } else {
      throw Exception("Invalid image data format or size");
    }
  }

  showImageDialog(final image) async {
    if (image == null) {
      // Handle the case where the image is not available.
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content:
              Image.memory(image.bytes), // Display the image using Image.memory
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

  Future<void> uploadFile() async {
    uid = uuid.v1();

    if (widget.pdfBytes.isEmpty) {
      Fluttertoast.showToast(msg: "No PDF data to upload!");
      return;
    }

    final Reference storageReference =
        FirebaseStorage.instance.ref().child("pdfFiles").child(uid!);

    try {
      // Upload the PDF file to Firebase Storage.
      final UploadTask uploadTask =
          storageReference.putData(Uint8List.fromList(widget.pdfBytes));

      // Monitor the upload progress.
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print(
            'Upload Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
      });

      // Await the completion of the upload.
      await uploadTask;

      // Get the download URL for the uploaded file.
      final String downloadUrl = await storageReference.getDownloadURL();

      pdf.doc(uid).set({
        "title": textBlocks[0],
        "author/s": authorsText,
        "publication_date": textBlocks[4],
        "pdfUID": uid,
        "downloadUrl": downloadUrl,
      }).then((value) {
        Fluttertoast.showToast(msg: "PDF uploaded successfully!");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MyApp()));
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error uploading PDF");
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
