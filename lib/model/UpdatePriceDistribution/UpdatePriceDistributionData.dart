class UpdatePriceDistributionData {
  final int? eventAttendeesPriceMemberId;
  final UpdatedRecord? updatedRecord;

  UpdatePriceDistributionData({this.eventAttendeesPriceMemberId, this.updatedRecord});

  factory UpdatePriceDistributionData.fromJson(Map<String, dynamic> json) {
    return UpdatePriceDistributionData(
      eventAttendeesPriceMemberId:
      json['event_attendees_price_member_id'] != null
          ? (json['event_attendees_price_member_id'] is int
          ? json['event_attendees_price_member_id']
          : int.tryParse(json['event_attendees_price_member_id'].toString()))
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
      eventAttendeesPriceMemberId: _parseInt(json['event_attendees_price_member_id']),
      eventAttendeesId: _parseInt(json['event_attendees_id']),
      eventId: _parseInt(json['event_id']),
      memberId: _parseInt(json['member_id']),
      priceMemberId: _parseInt(json['price_member_id']),
      studentName: _parseString(json['student_name']),
      schoolName: _parseString(json['school_name']),
      standardPassed: _parseString(json['standard_passed']),
      yearOfPassed: _parseString(json['year_of_passed']),
      grade: _parseString(json['grade']),
      markSheetAttachment: _parseString(json['mark_sheet_attachment']),
      createdBy: _parseInt(json['created_by']),
      createdAt: _parseString(json['created_at']),
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

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return int.tryParse(value.toString());
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }
}