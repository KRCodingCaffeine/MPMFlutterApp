class GetAppliedJobsByMemberIdData {
  String? memberJobAppliedId;
  String? memberId;
  String? jobId;
  String? applicationStatus;
  String? appliedDate;
  String? remarks;
  String? createdAt;

  String? title;
  String? description;
  String? location;
  String? cityId;

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

  GetAppliedJobsByMemberIdData({
    this.memberJobAppliedId,
    this.memberId,
    this.jobId,
    this.applicationStatus,
    this.appliedDate,
    this.remarks,
    this.createdAt,
    this.title,
    this.description,
    this.location,
    this.cityId,
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

  GetAppliedJobsByMemberIdData.fromJson(Map<String, dynamic> json) {
    memberJobAppliedId = json['member_job_applied_id']?.toString();
    memberId = json['member_id']?.toString();
    jobId = json['job_id']?.toString();
    applicationStatus = json['application_status']?.toString();
    appliedDate = json['applied_date']?.toString();
    remarks = json['remarks']?.toString();
    createdAt = json['created_at']?.toString();

    title = json['title']?.toString();
    description = json['description']?.toString();
    location = json['location']?.toString();
    cityId = json['city_id']?.toString();

    salaryMin = json['salary_min']?.toString();
    salaryMax = json['salary_max']?.toString();
    salaryVisible = json['salary_visible']?.toString();

    experienceMinYears = json['experience_min_years']?.toString();
    experienceMaxYears = json['experience_max_years']?.toString();

    workMode = json['work_mode']?.toString();
    workType = json['work_type']?.toString();
    noOfMonthsInternship = json['no_of_months_internship']?.toString();

    lastApplyDate = json['last_apply_date']?.toString();
    noOfVacancy = json['no_of_vacancy']?.toString();
    status = json['status']?.toString();

    expiredAt = json['expired_at']?.toString();
    publishedAt = json['published_at']?.toString();
    closedAt = json['closed_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'member_job_applied_id': memberJobAppliedId,
      'member_id': memberId,
      'job_id': jobId,
      'application_status': applicationStatus,
      'applied_date': appliedDate,
      'remarks': remarks,
      'created_at': createdAt,
      'title': title,
      'description': description,
      'location': location,
      'city_id': cityId,
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
