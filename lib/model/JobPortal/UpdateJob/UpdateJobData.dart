class UpdateJobData {
  String? jobId;
  String? memberId;
  String? memberBusinessOccupationProfileId;
  String? companyName;
  String? title;
  String? description;
  String? occupationId;
  String? occupationProfessionId;
  String? occupationSpecializationId;
  String? location;
  String? cityId;
  String? jobAreaName;
  String? salaryMin;
  String? salaryMax;
  String? salaryVisible;
  String? experienceMinYears;
  String? experienceMaxYears;
  String? noOfVacancy;
  String? lastApplyDate;
  String? workType;
  String? workMode;
  String? status;
  String? publishedAt;
  String? closedAt;
  String? updatedBy;

  UpdateJobData({
    this.jobId,
    this.memberId,
    this.memberBusinessOccupationProfileId,
    this.companyName,
    this.title,
    this.description,
    this.occupationId,
    this.occupationProfessionId,
    this.occupationSpecializationId,
    this.location,
    this.cityId,
    this.jobAreaName,
    this.salaryMin,
    this.salaryMax,
    this.salaryVisible,
    this.experienceMinYears,
    this.experienceMaxYears,
    this.noOfVacancy,
    this.lastApplyDate,
    this.workType,
    this.workMode,
    this.status,
    this.publishedAt,
    this.closedAt,
    this.updatedBy,
  });

  UpdateJobData.fromJson(Map<String, dynamic> json) {
    jobId = (json['job_id'] ?? json['id'])?.toString();
    memberId = json['member_id']?.toString();
    memberBusinessOccupationProfileId =
        json['member_business_occupation_profile_id']?.toString();
    companyName = json['company_name']?.toString();
    title = json['title']?.toString();
    description = json['description']?.toString();

    occupationId = json['occupation_id']?.toString();
    occupationProfessionId = json['occupation_profession_id']?.toString();
    occupationSpecializationId =
        json['occupation_specialization_id']?.toString();

    location = json['location']?.toString();
    cityId = json['city_id']?.toString();
    jobAreaName = json['job_area_name']?.toString();

    salaryMin = json['salary_min']?.toString();
    salaryMax = json['salary_max']?.toString();
    salaryVisible = json['salary_visible']?.toString();

    experienceMinYears = json['experience_min_years']?.toString();
    experienceMaxYears = json['experience_max_years']?.toString();

    noOfVacancy = json['no_of_vacancy']?.toString();
    lastApplyDate = json['last_apply_date']?.toString();

    workType = json['work_type']?.toString();
    workMode = json['work_mode']?.toString();

    status = json['status']?.toString();
    publishedAt = json['published_at']?.toString();
    closedAt = json['closed_at']?.toString();

    updatedBy = json['updated_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['job_id'] = jobId;
    data['member_id'] = memberId;
    data['member_business_occupation_profile_id'] =
        memberBusinessOccupationProfileId;
    data['company_name'] = companyName;
    data['title'] = title;
    data['description'] = description;
    data['occupation_id'] = occupationId;
    data['occupation_profession_id'] = occupationProfessionId;
    data['occupation_specialization_id'] = occupationSpecializationId;
    data['location'] = location;
    data['city_id'] = cityId;
    data['job_area_name'] = jobAreaName;
    data['salary_min'] = salaryMin;
    data['salary_max'] = salaryMax;
    data['salary_visible'] = salaryVisible;
    data['experience_min_years'] = experienceMinYears;
    data['experience_max_years'] = experienceMaxYears;
    data['work_mode'] = workMode;
    data['work_type'] = workType;
    data['last_apply_date'] = lastApplyDate;
    data['no_of_vacancy'] = noOfVacancy;
    data['status'] = status;
    data['published_at'] = publishedAt;
    data['closed_at'] = closedAt;
    data['updated_by'] = updatedBy;

    return data;
  }
}
