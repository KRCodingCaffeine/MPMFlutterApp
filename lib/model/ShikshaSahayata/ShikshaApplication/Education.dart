class Education {
  final String? standard;
  final String? yearOfPassing;
  final String? marksInPercentage;
  final String? schoolCollegeName;
  final String? boardOrUniversity;

  Education({
    this.standard,
    this.yearOfPassing,
    this.marksInPercentage,
    this.schoolCollegeName,
    this.boardOrUniversity,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      standard: json['standard']?.toString(),
      yearOfPassing: json['year_of_passing']?.toString(),
      marksInPercentage: json['marks_in_percentage']?.toString(),
      schoolCollegeName: json['school_college_name']?.toString(),
      boardOrUniversity: json['board_or_university']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'standard': standard,
      'year_of_passing': yearOfPassing,
      'marks_in_percentage': marksInPercentage,
      'school_college_name': schoolCollegeName,
      'board_or_university': boardOrUniversity,
    };
  }
}
