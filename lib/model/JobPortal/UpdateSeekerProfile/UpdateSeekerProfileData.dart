class UpdateSeekerProfileData {
  String? seekerProfileId;
  String? memberId;
  String? headline;
  String? summary;
  String? expectedSalaryMin;
  String? expectedSalaryMax;
  String? workMode;
  String? workType;
  String? isVisible;
  String? updatedBy;

  UpdateSeekerProfileData({
    this.seekerProfileId,
    this.memberId,
    this.headline,
    this.summary,
    this.expectedSalaryMin,
    this.expectedSalaryMax,
    this.workMode,
    this.workType,
    this.isVisible,
    this.updatedBy,
  });

  UpdateSeekerProfileData.fromJson(Map<String, dynamic> json) {
    seekerProfileId = json['seeker_profile_id']?.toString();
    memberId = json['member_id']?.toString();
    headline = json['headline']?.toString();
    summary = json['summary']?.toString();
    expectedSalaryMin = json['expected_salary_min']?.toString();
    expectedSalaryMax = json['expected_salary_max']?.toString();
    workMode = json['work_mode']?.toString();
    workType = json['work_type']?.toString();
    isVisible = json['is_visible']?.toString();
    updatedBy = json['updated_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'seeker_profile_id': seekerProfileId,
      'member_id': memberId,
      'headline': headline,
      'summary': summary,
      'expected_salary_min': expectedSalaryMin,
      'expected_salary_max': expectedSalaryMax,
      'work_mode': workMode,
      'work_type': workType,
      'is_visible': isVisible,
      'updated_by': updatedBy,
    };
  }
}