// ignore_for_file: prefer_typing_uninitialized_variables

class Pdf {
  String? title;
  String? authors;
  String? publicationDate;
  String? uid;
  String? pdfDownloadUrl;
  String? imgDownloadUrl;
  var dateAdded;

  Pdf({
    this.title,
    this.authors,
    this.publicationDate,
    this.uid,
    this.pdfDownloadUrl,
    this.imgDownloadUrl,
    this.dateAdded,
  });

  //receive
  factory Pdf.fromMap(map) {
    return Pdf(
      title: map["title"],
      authors: map["authors"],
      publicationDate: map["publicationDate"],
      uid: map["uid"],
      pdfDownloadUrl: map["pdfDownloadUrl"],
      imgDownloadUrl: map["imgDownloadUrl"],
      dateAdded: map["dateAdded"],
    );
  }
  //send
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "authors": authors,
      "publicationDate": publicationDate,
      "uid": uid,
      "pdfDownloadUrl": pdfDownloadUrl,
      "imgDownloadUrl": imgDownloadUrl,
      "dateAdded": dateAdded,
    };
  }
}
