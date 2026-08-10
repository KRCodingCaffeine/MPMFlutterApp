class AddSeekerProfileData {
  String? memberId;
  String? resumePath;
  String? headline;
  String? summary;
  String? expectedSalaryMin;
  String? expectedSalaryMax;
  String? workMode;
  String? workType;
  String? noOfInternshipMonth;
  String? cityId;
  String? areaName;
  String? isVisible;
  String? createdBy;

  AddSeekerProfileData({
    this.memberId,
    this.resumePath,
    this.headline,
    this.summary,
    this.expectedSalaryMin,
    this.expectedSalaryMax,
    this.workMode,
    this.workType,
    this.noOfInternshipMonth,
    this.cityId,
    this.areaName,
    this.isVisible,
    this.createdBy,
  });

  AddSeekerProfileData.fromJson(Map<String, dynamic> json) {
    memberId = json['member_id']?.toString();
    resumePath = json['resume_path']?.toString();
    headline = json['headline']?.toString();
    summary = json['summary']?.toString();
    expectedSalaryMin = json['expected_salary_min']?.toString();
    expectedSalaryMax = json['expected_salary_max']?.toString();
    workMode = json['work_mode']?.toString();
    workType = json['work_type']?.toString();
    noOfInternshipMonth = json['no_of_internship_month']?.toString();
    cityId = json['city_id']?.toString();
    areaName = json['area_name']?.toString();
    isVisible = json['is_visible']?.toString();
    createdBy = json['created_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'resume_path': resumePath,
      'headline': headline,
      'summary': summary,
      'expected_salary_min': expectedSalaryMin,
      'expected_salary_max': expectedSalaryMax,
      'work_mode': workMode,
      'work_type': workType,
      'no_of_internship_month': noOfInternshipMonth,
      'city_id': cityId,
      'area_name': areaName,
      'is_visible': isVisible,
      'created_by': createdBy,
    };
  }
}
