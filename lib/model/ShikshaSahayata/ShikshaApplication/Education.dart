class Education {
  final String? shikshaApplicantEducationId;
  final String? standard;
  final String? otherEducationDetails;
  final String? yearOfPassing;
  final String? marksInPercentage;
  final String? schoolCollegeName;
  final String? boardOrUniversity;
  final String? markSheetAttachment;

  Education({
    this.shikshaApplicantEducationId,
    this.standard,
    this.otherEducationDetails,
    this.yearOfPassing,
    this.marksInPercentage,
    this.schoolCollegeName,
    this.boardOrUniversity,
    this.markSheetAttachment,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      shikshaApplicantEducationId:
          json['shiksha_applicant_education_id']?.toString(),
      standard: json['standard']?.toString(),
        otherEducationDetails: json['other_education_details']?.toString(),
      yearOfPassing: json['year_of_passing']?.toString(),
      marksInPercentage: json['marks_in_percentage']?.toString(),
      schoolCollegeName: json['school_college_name']?.toString(),
      boardOrUniversity: json['board_or_university']?.toString(),
      markSheetAttachment: json['mark_sheet_attachment']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shiksha_applicant_education_id': shikshaApplicantEducationId,
      'standard': standard,
      'other_education_details': otherEducationDetails,
      'year_of_passing': yearOfPassing,
      'marks_in_percentage': marksInPercentage,
      'school_college_name': schoolCollegeName,
      'board_or_university': boardOrUniversity,
      'mark_sheet_attachment': markSheetAttachment,
    };
  }
}
