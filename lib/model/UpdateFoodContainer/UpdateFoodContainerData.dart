class UpdateFoodContainerData {
  final int? eventAttendeesId;
  final String? noOfFoodContainer;
  final int? updatedBy;

  UpdateFoodContainerData({
    this.eventAttendeesId,
    this.noOfFoodContainer,
    this.updatedBy,
  });

  factory UpdateFoodContainerData.fromJson(Map<String, dynamic> json) {
    return UpdateFoodContainerData(
      eventAttendeesId: _parseInt(json['event_attendees_id']),
      noOfFoodContainer: json['no_of_food_container']?.toString(),
      updatedBy: _parseInt(json['updated_by']),
    );
  }

  Map<String, dynamic> toJson() => {
    'event_attendees_id': eventAttendeesId,
    'no_of_food_container': noOfFoodContainer?.toString(),
    'updated_by': updatedBy,
  };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return int.tryParse(value.toString());
  }
}
