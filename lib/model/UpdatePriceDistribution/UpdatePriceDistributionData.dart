class UpdatePriceDistributionData {
  final int? eventAttendeesPriceMemberId;
  final UpdatedRecord? updatedRecord;

  UpdatePriceDistributionData({this.eventAttendeesPriceMemberId, this.updatedRecord});

  factory UpdatePriceDistributionData.fromJson(Map<String, dynamic> json) {
    return UpdatePriceDistributionData(
      eventAttendeesPriceMemberId:
      json['event_attendees_price_member_id'] != null
          ? int.tryParse(json['event_attendees_price_member_id'].toString())
          : null,
      updatedRecord: json['updated_record'] != null
          ? UpdatedRecord.fromJson(json['updated_record'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'event_attendees_price_member_id': eventAttendeesPriceMemberId,
    'updated_record': updatedRecord?.toJson(),
  };
}

class UpdatedRecord {
  final int? eventAttendeesPriceMemberId;
  final int? eventAttendeesId;
  final int? eventId;
  final int? memberId;
  final int? priceMemberId;
  final String? studentName;
  final String? schoolName;
  final String? standardPassed;
  final String? yearOfPassed;
  final String? grade;
  final String? markSheetAttachment;
  final int? createdBy;
  final String? createdAt;

  UpdatedRecord({
    this.eventAttendeesPriceMemberId,
    this.eventAttendeesId,
    this.eventId,
    this.memberId,
    this.priceMemberId,
    this.studentName,
    this.schoolName,
    this.standardPassed,
    this.yearOfPassed,
    this.grade,
    this.markSheetAttachment,
    this.createdBy,
    this.createdAt,
  });

  factory UpdatedRecord.fromJson(Map<String, dynamic> json) {
    return UpdatedRecord(
      eventAttendeesPriceMemberId: int.tryParse(json['event_attendees_price_member_id'].toString()),
      eventAttendeesId: int.tryParse(json['event_attendees_id'].toString()),
      eventId: int.tryParse(json['event_id'].toString()),
      memberId: int.tryParse(json['member_id'].toString()),
      priceMemberId: int.tryParse(json['price_member_id'].toString()),
      studentName: json['student_name'] as String?,
      schoolName: json['school_name'] as String?,
      standardPassed: json['standard_passed'] as String?,
      yearOfPassed: json['year_of_passed'] as String?,
      grade: json['grade'] as String?,
      markSheetAttachment: json['mark_sheet_attachment'] as String?,
      createdBy: int.tryParse(json['created_by'].toString()),
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'event_attendees_price_member_id': eventAttendeesPriceMemberId,
    'event_attendees_id': eventAttendeesId,
    'event_id': eventId,
    'member_id': memberId,
    'price_member_id': priceMemberId,
    'student_name': studentName,
    'school_name': schoolName,
    'standard_passed': standardPassed,
    'year_of_passed': yearOfPassed,
    'grade': grade,
    'mark_sheet_attachment': markSheetAttachment,
    'created_by': createdBy,
    'created_at': createdAt,
  };
}