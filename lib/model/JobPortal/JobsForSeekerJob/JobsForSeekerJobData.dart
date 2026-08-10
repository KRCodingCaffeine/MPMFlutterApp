class JobsForSeekerJobData {
  String? jobId;
  String? memberId;
  String? memberBusinessOccupationProfileId;

  String? title;
  String? description;

  String? occupationId;
  String? occupationProfessionId;
  String? occupationSpecializationId;

  String? location;
  String? cityId;
  String? areaName;

  String? salaryMin;
  String? salaryMax;
  String? salaryRange;
  String? salaryVisible;

  String? experienceMinYears;
  String? experienceMaxYears;

  String? workMode;
  String? workType;

  String? noOfMonthsInternship;
  String? lastApplyDate;
  String? profileSummaryDocument;

  String? noOfVacancy;
  String? status;

  String? expiredAt;
  String? publishedAt;
  String? closedAt;

  String? createdAt;
  String? updatedAt;

  String? createdBy;
  String? updatedBy;

  JobsForSeekerJobData({
    this.jobId,
    this.memberId,
    this.memberBusinessOccupationProfileId,
    this.title,
    this.description,
    this.occupationId,
    this.occupationProfessionId,
    this.occupationSpecializationId,
    this.location,
    this.cityId,
    this.areaName,
    this.salaryMin,
    this.salaryMax,
    this.salaryRange,
    this.salaryVisible,
    this.experienceMinYears,
    this.experienceMaxYears,
    this.workMode,
    this.workType,
    this.noOfMonthsInternship,
    this.lastApplyDate,
    this.profileSummaryDocument,
    this.noOfVacancy,
    this.status,
    this.expiredAt,
    this.publishedAt,
    this.closedAt,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  JobsForSeekerJobData.fromJson(Map<String, dynamic> json) {
    jobId = json['job_id']?.toString();
    memberId = json['member_id']?.toString();
    memberBusinessOccupationProfileId =
        json['member_business_occupation_profile_id']?.toString();

    title = json['title']?.toString();
    description = json['description']?.toString();

    occupationId = json['occupation_id']?.toString();
    occupationProfessionId =
        json['occupation_profession_id']?.toString();
    occupationSpecializationId =
        json['occupation_specialization_id']?.toString();

    location = json['location']?.toString();
    cityId = json['city_id']?.toString();
    areaName = json['area_name']?.toString();

    salaryMin = json['salary_min']?.toString();
    salaryMax = json['salary_max']?.toString();
    salaryRange = json['salary_range']?.toString();
    salaryVisible = json['salary_visible']?.toString();

    experienceMinYears =
        json['experience_min_years']?.toString();
    experienceMaxYears =
        json['experience_max_years']?.toString();

    workMode = json['work_mode']?.toString();
    workType = json['work_type']?.toString();

    noOfMonthsInternship =
        json['no_of_months_internship']?.toString();

    lastApplyDate = json['last_apply_date']?.toString();

    profileSummaryDocument =
        json['profile_summary_document']?.toString();

    noOfVacancy = json['no_of_vacancy']?.toString();

    status = json['status']?.toString();

    expiredAt = json['expired_at']?.toString();
    publishedAt = json['published_at']?.toString();
    closedAt = json['closed_at']?.toString();

    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();

    createdBy = json['created_by']?.toString();
    updatedBy = json['updated_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'member_id': memberId,
      'member_business_occupation_profile_id':
      memberBusinessOccupationProfileId,
      'title': title,
      'description': description,
      'occupation_id': occupationId,
      'occupation_profession_id': occupationProfessionId,
      'occupation_specialization_id':
      occupationSpecializationId,
      'location': location,
      'city_id': cityId,
      'area_name': areaName,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'salary_range': salaryRange,
      'salary_visible': salaryVisible,
      'experience_min_years': experienceMinYears,
      'experience_max_years': experienceMaxYears,
      'work_mode': workMode,
      'work_type': workType,
      'no_of_months_internship': noOfMonthsInternship,
      'last_apply_date': lastApplyDate,
      'profile_summary_document': profileSummaryDocument,
      'no_of_vacancy': noOfVacancy,
      'status': status,
      'expired_at': expiredAt,
      'published_at': publishedAt,
      'closed_at': closedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }
}