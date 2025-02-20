class StateData{

  String? id;
  String? countryId;
  String? stateName;
  String? status;


  StateData(
      {this.id,
        this.countryId,
        this.stateName,
        this.status,
        });

  StateData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    countryId = json['country_id'];
    stateName = json['state_name'];
    status = json['status'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['country_id'] = this.countryId;
    data['state_name'] = this.stateName;
    data['status'] = this.status;

    return data;
  }
}