class CreateJobData {
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

  String? createdBy;

  CreateJobData({
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
    this.createdBy,
  });

  CreateJobData.fromJson(Map<String, dynamic> json) {
    jobId = (json['job_id'] ?? json['id'])?.toString();
    memberId = json['member_id']?.toString();
    memberBusinessOccupationProfileId =
        json['member_business_occupation_profile_id']?.toString();
    companyName = json['company_name']?.toString();
    title = json['title']?.toString();
    description = json['description']?.toString();

    occupationId = json['occupation_id']?.toString();
    occupationProfessionId =
        json['occupation_profession_id']?.toString();
    occupationSpecializationId =
        json['occupation_specialization_id']?.toString();

    location = json['location']?.toString();
    cityId = json['city_id']?.toString();
    jobAreaName = json['job_area_name']?.toString();

    salaryMin = json['salary_min']?.toString();
    salaryMax = json['salary_max']?.toString();
    salaryVisible = json['salary_visible']?.toString();

    experienceMinYears =
        json['experience_min_years']?.toString();
    experienceMaxYears =
        json['experience_max_years']?.toString();

    noOfVacancy = json['no_of_vacancy']?.toString();
    lastApplyDate = json['last_apply_date']?.toString();

    workType = json['work_type']?.toString();
    workMode = json['work_mode']?.toString();

    status = json['status']?.toString();
    publishedAt = json['published_at']?.toString();
    closedAt = json['closed_at']?.toString();

    createdBy = json['created_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'member_id': memberId,
      'member_business_occupation_profile_id':
      memberBusinessOccupationProfileId,
      'company_name': companyName,
      'title': title,
      'description': description,

      'occupation_id': occupationId,
      'occupation_profession_id': occupationProfessionId,
      'occupation_specialization_id':
      occupationSpecializationId,

      'location': location,
      'city_id': cityId,
      'job_area_name': jobAreaName,

      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'salary_visible': salaryVisible,

      'experience_min_years': experienceMinYears,
      'experience_max_years': experienceMaxYears,

      'no_of_vacancy': noOfVacancy,
      'last_apply_date': lastApplyDate,

      'work_type': workType,
      'work_mode': workMode,

      'status': status,
      'published_at': publishedAt,
      'closed_at': closedAt,

      'created_by': createdBy,
    };
  }
}
