class GetSavedJobsData {
  String? memberSavedJobId;
  String? memberId;
  String? jobId;
  String? isSaved;
  String? isSavedDate;
  String? memberBusinessOccupationProfileId;
  String? companyName;
  String? createdAt;

  String? title;
  String? description;
  String? location;
  String? cityId;
  String? jobAreaName;

  String? salaryMin;
  String? salaryMax;
  String? salaryVisible;

  String? experienceMinYears;
  String? experienceMaxYears;

  String? workMode;
  String? workType;
  String? noOfMonthsInternship;

  String? lastApplyDate;
  String? noOfVacancy;
  String? status;

  String? expiredAt;
  String? publishedAt;
  String? closedAt;

  GetSavedJobsData({
    this.memberSavedJobId,
    this.memberId,
    this.jobId,
    this.isSaved,
    this.isSavedDate,
    this.memberBusinessOccupationProfileId,
    this.companyName,
    this.createdAt,
    this.title,
    this.description,
    this.location,
    this.cityId,
    this.jobAreaName,
    this.salaryMin,
    this.salaryMax,
    this.salaryVisible,
    this.experienceMinYears,
    this.experienceMaxYears,
    this.workMode,
    this.workType,
    this.noOfMonthsInternship,
    this.lastApplyDate,
    this.noOfVacancy,
    this.status,
    this.expiredAt,
    this.publishedAt,
    this.closedAt,
  });

  GetSavedJobsData.fromJson(Map<String, dynamic> json) {
    memberSavedJobId = (json['member_saved_job_id'] ??
            json['member_job_saved_id'] ??
            json['saved_job_id'] ??
            json['id'])
        ?.toString();
    memberId = json['member_id']?.toString();
    jobId = json['job_id']?.toString();
    isSaved = json['is_saved']?.toString();
    isSavedDate = json['is_saved_date']?.toString();
    memberBusinessOccupationProfileId =
        json['member_business_occupation_profile_id']?.toString();
    companyName =
        (json['company_name'] ?? json['business_name'] ?? json['company'])
            ?.toString();
    createdAt = json['created_at']?.toString();

    title = json['title']?.toString();
    description = json['description']?.toString();
    location = json['location']?.toString();
    cityId = json['city_id']?.toString();
    jobAreaName = (json['area_name'] ?? json['job_area_name'])?.toString();

    salaryMin = json['salary_min']?.toString();
    salaryMax = json['salary_max']?.toString();
    salaryVisible = json['salary_visible']?.toString();

    experienceMinYears = json['experience_min_years']?.toString();
    experienceMaxYears = json['experience_max_years']?.toString();

    workMode = json['work_mode']?.toString();
    workType = (json['work_type'] ?? json['job_type'])?.toString();
    noOfMonthsInternship = (json['no_of_months_internship'] ??
            json['internship_time_period'])
        ?.toString();

    lastApplyDate =
        (json['last_apply_date'] ?? json['last_date_to_apply'])?.toString();
    noOfVacancy =
        (json['no_of_vacancy'] ?? json['number_of_vacancies'])?.toString();
    status = json['status']?.toString();

    expiredAt = json['expired_at']?.toString();
    publishedAt = json['published_at']?.toString();
    closedAt = json['closed_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'member_saved_job_id': memberSavedJobId,
      'member_id': memberId,
      'job_id': jobId,
      'is_saved': isSaved,
      'is_saved_date': isSavedDate,
      'member_business_occupation_profile_id':
          memberBusinessOccupationProfileId,
      'company_name': companyName,
      'created_at': createdAt,
      'title': title,
      'description': description,
      'location': location,
      'city_id': cityId,
      'area_name': jobAreaName,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'salary_visible': salaryVisible,
      'experience_min_years': experienceMinYears,
      'experience_max_years': experienceMaxYears,
      'work_mode': workMode,
      'work_type': workType,
      'no_of_months_internship': noOfMonthsInternship,
      'last_apply_date': lastApplyDate,
      'no_of_vacancy': noOfVacancy,
      'status': status,
      'expired_at': expiredAt,
      'published_at': publishedAt,
      'closed_at': closedAt,
    };
  }
}
