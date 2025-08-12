class EventRegistrationData {
  int? memberId;
  int? eventId;
  String? eventRegisteredDate;
  int? addedBy;
  String? dateAdded;
  int? noOfFoodContainer;

  EventRegistrationData({
    this.memberId,
    this.eventId,
    this.eventRegisteredDate,
    this.addedBy,
    this.dateAdded,
    this.noOfFoodContainer,
  });

  factory EventRegistrationData.fromJson(Map<String, dynamic> json) {
    return EventRegistrationData(
      memberId: int.tryParse(json['member_id'].toString()),
      eventId: int.tryParse(json['event_id'].toString()),
      eventRegisteredDate: json['event_registered_data'],
      addedBy: int.tryParse(json['added_by'].toString()),
      dateAdded: json['date_added'],
      noOfFoodContainer: int.tryParse(json['no_of_food_container'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'event_id': eventId,
      'event_registered_data': eventRegisteredDate,
      'added_by': addedBy,
      'date_added': dateAdded,
      'no_of_food_container': noOfFoodContainer,
    };
  }
}