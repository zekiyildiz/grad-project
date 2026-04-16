class Announcement {
  final String id;
  final String titleTr;
  final String titleEn;
  final String contentTr;
  final String contentEn;
  final DateTime date;

  Announcement({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.contentTr,
    required this.contentEn,
    required this.date,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? '',
      titleTr: json['title_tr'] ?? '',
      titleEn: json['title_en'] ?? '',
      contentTr: json['content_tr'] ?? '',
      contentEn: json['content_en'] ?? '',
      // Tarih formatını Firebase'den gelen saniye cinsinden DateTime'a çeviriyoruz
      date: json['date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['date']['_seconds'] * 1000)
          : DateTime.now(),
    );
  }
}