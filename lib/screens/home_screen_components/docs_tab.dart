// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metxtract/models/pdf_model.dart';
import 'package:metxtract/screens/view_pdf_components/view_pdf_dialog.dart';
import 'package:metxtract/utils/color_utils.dart';
import 'package:metxtract/utils/responsize_utils.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

enum SortOption {
  alphabetically,
  dateAdded,
}

class DocsTab extends StatefulWidget {
  const DocsTab({Key? key});

  @override
  State<DocsTab> createState() => _DocsTabState();
}

class _DocsTabState extends State<DocsTab> {
  String searchText = "";
  Map<String, TextEditingController> textEditingControllerMap = {};
  SortOption currentSortOption = SortOption.alphabetically;
  bool isList = true;

  @override
  Widget build(BuildContext context) {
    CollectionReference pdfList =
        FirebaseFirestore.instance.collection('pdfList');
    final storageRef = FirebaseStorage.instance.ref();
    int searchCount = 0;

    deleteData(String id) async {
      try {
        final pdfRef = await storageRef.child("pdfFiles").child(id).delete();
        final thumbnailRef =
            await storageRef.child("thumbnails").child(id).delete();
        final delData = await pdfList.doc(id).delete();
        Fluttertoast.showToast(msg: "Document Deleted Successfully!");
        Navigator.pop(context);
      } catch (e) {
        Fluttertoast.showToast(msg: "Error $e");
      }
    }

    editData(String id, title, author, pubDate) async {
      try {
        final edtData = await pdfList.doc(id).update({
          'title': title,
          'authors': author,
          'publicationDate': pubDate,
        });
        Fluttertoast.showToast(msg: "Document Updated Successfully!");
        Navigator.pop(context);
      } catch (e) {
        Fluttertoast.showToast(msg: "Error $e");
      }
    }

    void sortData(List<Pdf> data) {
      data.sort((a, b) {
        if (currentSortOption == SortOption.alphabetically) {
          return a.title!.compareTo(b.title!);
        } else if (currentSortOption == SortOption.dateAdded) {
          return b.dateAdded!.compareTo(a.dateAdded!);
        }
        return 0;
      });
    }

    IconButton buildSortButton(SortOption option, Widget icon) {
      return IconButton(
        onPressed: () {
          setState(() {
            currentSortOption = option;
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            currentSortOption == option ? ColorUtils.darkPurple : Colors.grey,
          ),
        ),
        icon: currentSortOption == SortOption.alphabetically ? icon : icon,
      );
    }

    viewPDfDialog(String pdfUrl) async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewPdfDialog(pdfUrl: pdfUrl),
        ),
      );
    }

    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(
            left: ResponsiveUtil.widthVar / 50,
            right: ResponsiveUtil.widthVar / 50),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: ResponsiveUtil.widthVar / 35,
                right: ResponsiveUtil.widthVar / 35,
                top: ResponsiveUtil.heightVar / 90,
                bottom: ResponsiveUtil.heightVar / 60,
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelText: 'Search Documents',
                  suffixIcon: const Icon(
                    Icons.search,
                    color: ColorUtils.darkPurple,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: ResponsiveUtil.widthVar / 50,
                right: ResponsiveUtil.widthVar / 50,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: pdfList.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        }
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        int docCount = snapshot.data!.docs.length;
                        return Text(
                          "Total Documents: $docCount",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      buildSortButton(
                          SortOption.alphabetically,
                          const Icon(
                            Icons.sort_by_alpha,
                            color: Colors.white,
                          )),
                      buildSortButton(
                        SortOption.dateAdded,
                        const Icon(
                          Icons.date_range,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (isList == true) {
                            setState(() {
                              isList = false;
                            });
                          } else if (isList == false) {
                            setState(() {
                              isList = true;
                            });
                          }
                        },
                        icon: isList == true
                            ? const Icon(
                                Icons.view_list_rounded,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.grid_on,
                                color: Colors.white,
                              ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            ColorUtils.darkPurple,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: ResponsiveUtil.heightVar / 70,
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collectionGroup("pdfList")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    Fluttertoast.showToast(msg: "Error");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingAnimationWidget.staggeredDotsWave(
                      color: ColorUtils.darkPurple,
                      size: 50,
                    );
                  }
                  if (!snapshot.hasData) {
                    return LoadingAnimationWidget.staggeredDotsWave(
                      color: ColorUtils.darkPurple,
                      size: 50,
                    );
                  }
                  List<Pdf> pdfList = snapshot.data!.docs.map((doc) {
                    return Pdf.fromMap(doc.data());
                  }).toList();

                  final filteredDocs = pdfList.where((pdf) {
                    final title1 = pdf.title ?? "";
                    final pubDate1 = pdf.publicationDate ?? "";
                    final authors1 = pdf.authors ?? "";
                    return title1
                            .toLowerCase()
                            .contains(searchText.toLowerCase()) ||
                        pubDate1
                            .toLowerCase()
                            .contains(searchText.toLowerCase()) ||
                        authors1
                            .toLowerCase()
                            .contains(searchText.toLowerCase());
                  }).toList();

                  sortData(filteredDocs);
                  return isList == true
                      ? ListView.builder(
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            Pdf pdf = filteredDocs[index];
                            String documentId = pdf.uid ?? "";
                            final title1 = pdf.title ?? "";
                            final pubDate1 = pdf.publicationDate ?? "";
                            final authors1 = pdf.authors ?? "";

                            // Initialize TextEditingController for this document if it doesn't exist
                            if (!textEditingControllerMap
                                .containsKey(documentId)) {
                              textEditingControllerMap[documentId] =
                                  TextEditingController();
                            }

                            // Get the TextEditingController for this document
                            TextEditingController? titleController =
                                textEditingControllerMap[documentId];
                            TextEditingController? authorController =
                                textEditingControllerMap[documentId];
                            TextEditingController? pubDateController =
                                textEditingControllerMap[documentId];
                            // Get the data from the document.
                            final String title2 = pdf.title ?? "";
                            final String pubDate2 = pdf.publicationDate ?? "";
                            final String authors2 = pdf.authors ?? "";
                            final String pdfUrl = pdf.pdfDownloadUrl ?? "";
                            var dateAdded = pdf.dateAdded ?? "";
                            return InkWell(
                              onTap: () {
                                viewPDfDialog(pdfUrl);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.transparent,
                                ),
                                margin: EdgeInsets.only(
                                    bottom: ResponsiveUtil.heightVar / 80,
                                    left: ResponsiveUtil.widthVar / 35,
                                    right: ResponsiveUtil.widthVar / 35),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                right: ResponsiveUtil.widthVar /
                                                    20),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title2,
                                                  style: const TextStyle(
                                                      color: Colors.blue),
                                                ),
                                                Text(
                                                  "Author/s: $authors2",
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  "Publication Date: $pubDate2",
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Row(
                                                    children: [
                                                      const Expanded(
                                                        child: Text(
                                                            "Document Details"),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        icon: const Icon(
                                                          Icons.close,
                                                          color: ColorUtils
                                                              .darkPurple,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        TextField(
                                                          decoration:
                                                              const InputDecoration(
                                                                  labelText:
                                                                      "Title"),
                                                          controller: titleController =
                                                              TextEditingController(
                                                                  text: titleController!
                                                                              .text ==
                                                                          ""
                                                                      ? title2
                                                                      : titleController!
                                                                          .text),
                                                          readOnly: false,
                                                          maxLines: null,
                                                        ),
                                                        TextField(
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText:
                                                                "Author/s",
                                                          ),
                                                          controller: authorController =
                                                              TextEditingController(
                                                                  text: authorController!
                                                                              .text ==
                                                                          ""
                                                                      ? authors2
                                                                      : authorController!
                                                                          .text),
                                                          readOnly: false,
                                                          maxLines: null,
                                                        ),
                                                        TextField(
                                                          decoration:
                                                              const InputDecoration(
                                                                  labelText:
                                                                      "Publication Date"),
                                                          controller: pubDateController =
                                                              TextEditingController(
                                                                  text: pubDateController!
                                                                              .text ==
                                                                          ""
                                                                      ? pubDate2
                                                                      : pubDateController!
                                                                          .text),
                                                          readOnly: false,
                                                          maxLines: null,
                                                        ),
                                                        SizedBox(
                                                          height: ResponsiveUtil
                                                                  .heightVar /
                                                              80,
                                                        ),
                                                        Text(
                                                            "Date Added: ${dateAdded.toDate().toString()}")
                                                        // Add more details as needed
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: Container(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            color: Colors
                                                                .transparent,
                                                            child: Center(
                                                              child: TextButton(
                                                                child:
                                                                    const Text(
                                                                  "Delete",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .deepPurple),
                                                                ),
                                                                onPressed: () {
                                                                  deleteData(
                                                                      pdf.uid!);
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Container(
                                                            color: ColorUtils
                                                                .darkPurple,
                                                            child: Center(
                                                              child: TextButton(
                                                                child:
                                                                    const Text(
                                                                  "Save",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                onPressed: () {
                                                                  editData(
                                                                      pdf.uid!,
                                                                      titleController!
                                                                          .text,
                                                                      authorController!
                                                                          .text,
                                                                      pubDateController!
                                                                          .text);
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            color: ColorUtils.darkPurple,
                                          ),
                                        )
                                      ],
                                    ),
                                    Divider(
                                      height: ResponsiveUtil.heightVar / 80,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          margin: EdgeInsets.only(
                              left: ResponsiveUtil.widthVar / 35,
                              right: ResponsiveUtil.widthVar / 35),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio:
                                  ((ResponsiveUtil.widthVar / 2.2) /
                                      (ResponsiveUtil.heightVar / 3.8)),
                              crossAxisCount: 2,
                              mainAxisSpacing: 1,
                              crossAxisSpacing: 1,
                            ),
                            shrinkWrap: true,
                            itemCount: filteredDocs.length,
                            itemBuilder: (context, index) {
                              Pdf pdf = filteredDocs[index];
                              String documentId = pdf.uid ?? "";
                              final title1 = pdf.title ?? "";
                              final pubDate1 = pdf.publicationDate ?? "";
                              final authors1 = pdf.authors ?? "";
                              final String pdfUrl = pdf.pdfDownloadUrl ?? "";
                              // Initialize TextEditingController for this document if it doesn't exist
                              if (!textEditingControllerMap
                                  .containsKey(documentId)) {
                                textEditingControllerMap[documentId] =
                                    TextEditingController();
                              }

                              // Get the TextEditingController for this document
                              TextEditingController? titleController =
                                  textEditingControllerMap[documentId];
                              TextEditingController? authorController =
                                  textEditingControllerMap[documentId];
                              TextEditingController? pubDateController =
                                  textEditingControllerMap[documentId];
                              // Get the data from the document.
                              final String title2 = pdf.title ?? "";
                              final String pubDate2 = pdf.publicationDate ?? "";
                              final String authors2 = pdf.authors ?? "";
                              final String imageUrl = pdf.imgDownloadUrl ?? "";

                              var dateAdded = pdf.dateAdded ?? "";

                              return InkWell(
                                onTap: () {
                                  viewPDfDialog(pdfUrl);
                                },
                                child: Card(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1.5,
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  title2,
                                                  style: const TextStyle(
                                                      fontSize: 8),
                                                  softWrap: false,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Row(
                                                        children: [
                                                          const Expanded(
                                                            child: Text(
                                                                "Document Details"),
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            icon: const Icon(
                                                              Icons.close,
                                                              color: ColorUtils
                                                                  .darkPurple,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            TextField(
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          "Title"),
                                                              controller: titleController = TextEditingController(
                                                                  text: titleController!
                                                                              .text ==
                                                                          ""
                                                                      ? title2
                                                                      : titleController!
                                                                          .text),
                                                              readOnly: false,
                                                              maxLines: null,
                                                            ),
                                                            TextField(
                                                              decoration:
                                                                  const InputDecoration(
                                                                labelText:
                                                                    "Author/s",
                                                              ),
                                                              controller: authorController = TextEditingController(
                                                                  text: authorController!
                                                                              .text ==
                                                                          ""
                                                                      ? authors2
                                                                      : authorController!
                                                                          .text),
                                                              readOnly: false,
                                                              maxLines: null,
                                                            ),
                                                            TextField(
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          "Publication Date"),
                                                              controller: pubDateController = TextEditingController(
                                                                  text: pubDateController!
                                                                              .text ==
                                                                          ""
                                                                      ? pubDate2
                                                                      : pubDateController!
                                                                          .text),
                                                              readOnly: false,
                                                              maxLines: null,
                                                            ),
                                                            SizedBox(
                                                              height: ResponsiveUtil
                                                                      .heightVar /
                                                                  80,
                                                            ),
                                                            Text(
                                                                "Date Added: ${dateAdded.toDate().toString()}")
                                                            // Add more details as needed
                                                          ],
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 1,
                                                              child: Container(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                color: Colors
                                                                    .transparent,
                                                                child: Center(
                                                                  child:
                                                                      TextButton(
                                                                    child:
                                                                        const Text(
                                                                      "Delete",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.deepPurple),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      deleteData(
                                                                          pdf.uid!);
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Container(
                                                                color: ColorUtils
                                                                    .darkPurple,
                                                                child: Center(
                                                                  child:
                                                                      TextButton(
                                                                    child:
                                                                        const Text(
                                                                      "Save",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      editData(
                                                                          pdf
                                                                              .uid!,
                                                                          titleController!
                                                                              .text,
                                                                          authorController!
                                                                              .text,
                                                                          pubDateController!
                                                                              .text);
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.edit,
                                                color: ColorUtils.darkPurple,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
