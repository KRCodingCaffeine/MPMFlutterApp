import 'AppliedMemberData.dart';

class GetPostedJobsAppliedMembersData {
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

  String? workMode;
  String? workType;
  String? noOfMonthsInternship;

  String? lastApplyDate;

  String? profileSummaryDocument;

  String? noOfVacancy;

  String? status;

  String? hasRecruitedFromMpm;

  String? closingComments;

  String? expiredAt;
  String? publishedAt;
  String? closedAt;

  String? createdAt;
  String? updatedAt;

  String? createdBy;
  String? updatedBy;

  List<AppliedMemberData>? appliedMembers;

  int? appliedCount;

  GetPostedJobsAppliedMembersData({
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
    this.workMode,
    this.workType,
    this.noOfMonthsInternship,
    this.lastApplyDate,
    this.profileSummaryDocument,
    this.noOfVacancy,
    this.status,
    this.hasRecruitedFromMpm,
    this.closingComments,
    this.expiredAt,
    this.publishedAt,
    this.closedAt,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.appliedMembers,
    this.appliedCount,
  });

  GetPostedJobsAppliedMembersData.fromJson(Map<String, dynamic> json) {
    jobId = json['job_id']?.toString();

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

    workMode = json['work_mode']?.toString();

    workType = json['work_type']?.toString();

    noOfMonthsInternship = json['no_of_months_internship']?.toString();

    lastApplyDate = json['last_apply_date']?.toString();

    profileSummaryDocument = json['profile_summary_document']?.toString();

    noOfVacancy = json['no_of_vacancy']?.toString();

    status = json['status']?.toString();

    hasRecruitedFromMpm = json['has_recruited_from_mpm']?.toString();

    closingComments = json['closing_comments']?.toString();

    expiredAt = json['expired_at']?.toString();

    publishedAt = json['published_at']?.toString();

    closedAt = json['closed_at']?.toString();

    createdAt = json['created_at']?.toString();

    updatedAt = json['updated_at']?.toString();

    createdBy = json['created_by']?.toString();

    updatedBy = json['updated_by']?.toString();

    appliedMembers = json['applied_members'] != null
        ? List<AppliedMemberData>.from(
            json['applied_members'].map(
              (x) => AppliedMemberData.fromJson(x),
            ),
          )
        : [];

    appliedCount = json['applied_count'] is int
        ? json['applied_count']
        : int.tryParse(
            json['applied_count']?.toString() ?? '',
          );
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

    data['no_of_months_internship'] = noOfMonthsInternship;

    data['last_apply_date'] = lastApplyDate;

    data['profile_summary_document'] = profileSummaryDocument;

    data['no_of_vacancy'] = noOfVacancy;

    data['status'] = status;

    data['has_recruited_from_mpm'] = hasRecruitedFromMpm;

    data['closing_comments'] = closingComments;

    data['expired_at'] = expiredAt;

    data['published_at'] = publishedAt;

    data['closed_at'] = closedAt;

    data['created_at'] = createdAt;

    data['updated_at'] = updatedAt;

    data['created_by'] = createdBy;

    data['updated_by'] = updatedBy;

    if (appliedMembers != null) {
      data['applied_members'] = appliedMembers!.map((e) => e.toJson()).toList();
    }

    data['applied_count'] = appliedCount;

    return data;
  }
}
