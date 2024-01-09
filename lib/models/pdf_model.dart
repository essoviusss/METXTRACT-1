// ignore_for_file: prefer_typing_uninitialized_variables

class Pdf {
  String? title;
  String? authors;
  String? publicationDate;
  String? adviser;
  String? methodology;
  String? keywords;
  String? researchDesign;
  String? researchType;
  String? uid;
  String? userId;
  String? pdfDownloadUrl;
  String? imgDownloadUrl;
  var dateAdded;

  Pdf({
    this.title,
    this.authors,
    this.publicationDate,
    this.adviser,
    this.methodology,
    this.keywords,
    this.researchDesign,
    this.researchType,
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
      adviser: map['adviser'],
      methodology: map['methodology'],
      keywords: map['keywords'],
      researchDesign: map['researchDesign'],
      researchType: map['researchType'],
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
      "adviser": adviser,
      "methodology": methodology,
      "keywords": keywords,
      "researchDesign": researchDesign,
      "researchType": researchType,
      "uid": uid,
      "userId": userId,
      "pdfDownloadUrl": pdfDownloadUrl,
      "imgDownloadUrl": imgDownloadUrl,
      "dateAdded": dateAdded,
    };
  }
}
