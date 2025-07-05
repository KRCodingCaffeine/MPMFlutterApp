class DashboardEventData {
  String? id;
  String? thumbnailImg;
  String? title;
  String? desc;
  String? organizedBy;
  String? date;

  DashboardEventData({
    this.id,
    this.thumbnailImg,
    this.title,
    this.desc,
    this.organizedBy,
    this.date,
  });

  DashboardEventData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    thumbnailImg = json['thumbnail_img'];
    title = json['title'];
    desc = json['desc'];
    organizedBy = json['organized_by'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'thumbnail_img': thumbnailImg,
    'title': title,
    'desc': desc,
    'organized_by': organizedBy,
    'date': date,
  };
}
