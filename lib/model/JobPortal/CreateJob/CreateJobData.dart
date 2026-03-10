class CreateJobData {
  String? memberId;
  String? memberBusinessOccupationProfileId;
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
  String? status;
  String? publishedAt;
  String? closedAt;
  String? createdBy;

  CreateJobData({
    this.memberId,
    this.memberBusinessOccupationProfileId,
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
    this.status,
    this.publishedAt,
    this.closedAt,
    this.createdBy,
  });

  CreateJobData.fromJson(Map<String, dynamic> json) {
    memberId = json['member_id']?.toString();
    memberBusinessOccupationProfileId =
        json['member_business_occupation_profile_id']?.toString();
    title = json['title'];
    description = json['description'];
    occupationId = json['occupation_id']?.toString();
    occupationProfessionId =
        json['occupation_profession_id']?.toString();
    occupationSpecializationId =
        json['occupation_specialization_id']?.toString();
    location = json['location'];
    cityId = json['city_id']?.toString();
    salaryMin = json['salary_min']?.toString();
    salaryMax = json['salary_max']?.toString();
    salaryVisible = json['salary_visible']?.toString();
    experienceMinYears = json['experience_min_years']?.toString();
    experienceMaxYears = json['experience_max_years']?.toString();
    status = json['status'];
    publishedAt = json['published_at'];
    closedAt = json['closed_at'];

    createdBy = json['created_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['member_id'] = memberId;
    data['member_business_occupation_profile_id'] =
        memberBusinessOccupationProfileId;
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
    data['status'] = status;
    data['published_at'] = publishedAt;
    data['closed_at'] = closedAt;
    data['created_by'] = createdBy;
    return data;
  }
}