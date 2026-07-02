class UpdateJobData {
  String? jobId;
  String? title;
  String? description;
  String? workMode;
  String? workType;
  String? lastApplyDate;
  String? noOfVacancy;
  String? status;
  String? updatedBy;

  UpdateJobData({
    this.jobId,
    this.title,
    this.description,
    this.workMode,
    this.workType,
    this.lastApplyDate,
    this.noOfVacancy,
    this.status,
    this.updatedBy,
  });

  UpdateJobData.fromJson(Map<String, dynamic> json) {
    jobId = json['job_id']?.toString();
    title = json['title'];
    description = json['description'];
    workMode = json['work_mode'];
    workType = json['work_type'];
    lastApplyDate = json['last_apply_date'];
    noOfVacancy = json['no_of_vacancy']?.toString();
    status = json['status'];
    updatedBy = json['updated_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['job_id'] = jobId;
    data['title'] = title;
    data['description'] = description;
    data['work_mode'] = workMode;
    data['work_type'] = workType;
    data['last_apply_date'] = lastApplyDate;
    data['no_of_vacancy'] = noOfVacancy;
    data['status'] = status;
    data['updated_by'] = updatedBy;

    return data;
  }
}