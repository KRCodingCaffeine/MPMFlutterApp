class Qualification {
  var memberQualificationId;
  var memberId;
  var qualificationId;
  var qualificationCategoryId;
  var qualificationMainId;
  var qualificationOtherName;
  var createdAt;
  var createdBy;

  var updatedBy;
  var qualification;
  var  qualificationMainName;
  var qualificationCategoryName;

  Qualification(
      {this.memberQualificationId,
        this.memberId,
        this.qualificationId,
        this.qualificationCategoryId,
        this.qualificationMainId,
        this.qualificationOtherName,
        this.createdAt,
        this.createdBy,

        this.updatedBy,
        this.qualification,
        this.qualificationMainName,
        this.qualificationCategoryName});

  Qualification.fromJson(Map<String, dynamic> json) {
    memberQualificationId = json['member_qualification_id'];
    memberId = json['member_id'];
    qualificationId = json['qualification_id'];
    qualificationCategoryId = json['qualification_category_id'];
    qualificationMainId = json['qualification_main_id'];
    qualificationOtherName = json['qualification_other_name'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];

    updatedBy = json['updated_by'];
    qualification = json['qualification'];
    qualificationMainName = json['qualification_main_name'];
    qualificationCategoryName = json['qualification_category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['member_qualification_id'] = this.memberQualificationId;
    data['member_id'] = this.memberId;
    data['qualification_id'] = this.qualificationId;
    data['qualification_category_id'] = this.qualificationCategoryId;
    data['qualification_main_id'] = this.qualificationMainId;
    data['qualification_other_name'] = this.qualificationOtherName;
    data['created_at'] = this.createdAt;
    data['created_by'] = this.createdBy;

    data['updated_by'] = this.updatedBy;
    data['qualification'] = this.qualification;
    data['qualification_main_name'] = this.qualificationMainName;
    data['qualification_category_name'] = this.qualificationCategoryName;
    return data;
  }
}
