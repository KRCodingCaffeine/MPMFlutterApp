class MemberSalutationData{

  String? memberSalutaitonId;
  String? salutationName;
  String? status;

  MemberSalutationData({this.memberSalutaitonId, this.salutationName, this.status});

  MemberSalutationData.fromJson(Map<String, dynamic> json) {
    memberSalutaitonId = json['member_salutaiton_id'];
    salutationName = json['salutation_name'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['member_salutaiton_id'] = this.memberSalutaitonId;
    data['salutation_name'] = this.salutationName;
    data['status'] = this.status;
    return data;
  }
}