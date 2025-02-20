class CountryData {
  String? id;
  String? countryName;
  String? status;


  CountryData(
      {this.id, this.countryName, this.status});

  CountryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    countryName = json['country_name'];
    status = json['status'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['country_name'] = this.countryName;
    data['status'] = this.status;

    return data;
  }
}