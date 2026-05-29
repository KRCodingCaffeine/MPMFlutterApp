class GetJobByMemberIdData {
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
  String? salaryMin;
  String? salaryMax;
  String? salaryVisible;
  String? experienceMinYears;
  String? experienceMaxYears;
  String? numberOfVacancies;
  String? lastDateToApply;
  String? jobType;
  String? workMode;
  String? jobPostStatus;
  String? internshipTimePeriod;
  String? status;
  String? publishedAt;
  String? closedAt;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? updatedBy;

  GetJobByMemberIdData({
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
    this.salaryMin,
    this.salaryMax,
    this.salaryVisible,
    this.experienceMinYears,
    this.experienceMaxYears,
    this.numberOfVacancies,
    this.lastDateToApply,
    this.jobType,
    this.workMode,
    this.jobPostStatus,
    this.internshipTimePeriod,
    this.status,
    this.publishedAt,
    this.closedAt,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  GetJobByMemberIdData.fromJson(Map<String, dynamic> json) {
    jobId = json['job_id']?.toString();
    memberId = json['member_id']?.toString();
    memberBusinessOccupationProfileId =
        json['member_business_occupation_profile_id']?.toString();
    companyName = json['company_name']?.toString();
    title = json['title'];
    description = json['description'];
    occupationId = json['occupation_id']?.toString();
    occupationProfessionId = json['occupation_profession_id']?.toString();
    occupationSpecializationId =
        json['occupation_specialization_id']?.toString();
    location = json['location'];
    cityId = json['city_id']?.toString();
    salaryMin = json['salary_min'];
    salaryMax = json['salary_max'];
    salaryVisible = json['salary_visible'];
    experienceMinYears = json['experience_min_years']?.toString();
    experienceMaxYears = json['experience_max_years']?.toString();
    numberOfVacancies =
        (json['number_of_vacancies'] ?? json['no_of_vacancy'])?.toString();
    lastDateToApply =
        (json['last_date_to_apply'] ?? json['last_apply_date'])?.toString();
    jobType = (json['job_type'] ?? json['work_type'])?.toString();
    workMode = json['work_mode']?.toString();
    jobPostStatus = json['job_post_status']?.toString() ?? json['status'];
    internshipTimePeriod =
        (json['internship_time_period'] ?? json['no_of_months_internship'])
            ?.toString();
    status = json['status'];
    publishedAt = json['published_at'];
    closedAt = json['closed_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by']?.toString();
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
    data['salary_min'] = salaryMin;
    data['salary_max'] = salaryMax;
    data['salary_visible'] = salaryVisible;
    data['experience_min_years'] = experienceMinYears;
    data['experience_max_years'] = experienceMaxYears;
    data['number_of_vacancies'] = numberOfVacancies;
    data['last_date_to_apply'] = lastDateToApply;
    data['job_type'] = jobType;
    data['work_mode'] = workMode;
    data['job_post_status'] = jobPostStatus;
    data['internship_time_period'] = internshipTimePeriod;
    data['status'] = status;
    data['published_at'] = publishedAt;
    data['closed_at'] = closedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;

    return data;
  }
}
