// ignore_for_file: prefer_typing_uninitialized_variables

class Pdf {
  String? title;
  String? authors;
  String? publicationDate;
  String? uid;
  String? userId;
  String? pdfDownloadUrl;
  String? imgDownloadUrl;
  var dateAdded;

  Pdf({
    this.title,
    this.authors,
    this.publicationDate,
    this.uid,
    this.userId,
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
      userId: map["userId"],
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
      "userId": userId,
      "pdfDownloadUrl": pdfDownloadUrl,
      "imgDownloadUrl": imgDownloadUrl,
      "dateAdded": dateAdded,
    };
  }
}
