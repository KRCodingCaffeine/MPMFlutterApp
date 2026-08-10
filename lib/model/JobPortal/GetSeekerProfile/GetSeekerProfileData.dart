class GetSeekerProfileData {
  String? seekerProfileId;
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
  String? createdAt;
  String? updatedBy;
  String? updatedAt;

  GetSeekerProfileData({
    this.seekerProfileId,
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
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  GetSeekerProfileData.fromJson(Map<String, dynamic> json) {
    seekerProfileId = json['seeker_profile_id']?.toString();
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
    createdAt = json['created_at']?.toString();
    updatedBy = json['updated_by']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'seeker_profile_id': seekerProfileId,
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
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
    };
  }
}
