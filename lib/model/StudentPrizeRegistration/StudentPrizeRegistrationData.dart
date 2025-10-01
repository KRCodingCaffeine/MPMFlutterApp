class StudentPrizeRegistrationData {
  int? eventId;
  int? memberId;
  int? addedBy;
  int? eventAttendeesId;
  int? priceMemberId;
  String? studentName;
  String? schoolName;
  String? standardPassed;
  String? yearOfPassed;
  String? grade;
  int? addBy;
  String? markSheetAttachment;

  StudentPrizeRegistrationData({
    this.eventId,
    this.memberId,
    this.addedBy,
    this.eventAttendeesId,
    this.priceMemberId,
    this.studentName,
    this.schoolName,
    this.standardPassed,
    this.yearOfPassed,
    this.grade,
    this.addBy,
    this.markSheetAttachment,
  });

  factory StudentPrizeRegistrationData.fromJson(Map<String, dynamic> json) {
    return StudentPrizeRegistrationData(
      eventId: int.tryParse(json['event_id'].toString()),
      memberId: int.tryParse(json['member_id'].toString()),
      addedBy: int.tryParse(json['added_by'].toString()),
      eventAttendeesId: int.tryParse(json['event_attendees_id'].toString()),
      priceMemberId: int.tryParse(json['price_member_id'].toString()),
      studentName: json['student_name'],
      schoolName: json['school_name'],
      standardPassed: json['standard_passed'],
      yearOfPassed: json['year_of_passed'],
      grade: json['grade'],
      addBy: json['added_by'],
      markSheetAttachment: json['mark_sheet_attachment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'member_id': memberId,
      'added_by': addedBy,
      'event_attendees_id': eventAttendeesId,
      'price_member_id': priceMemberId,
      'student_name': studentName,
      'school_name': schoolName,
      'standard_passed': standardPassed,
      'year_of_passed': yearOfPassed,
      'grade': grade,
      'added_by': addBy,
      'mark_sheet_attachment': markSheetAttachment,
    };
  }
}
