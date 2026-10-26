class NotificationVisibility {
  static String normalizeType(String? type) {
    final value = (type ?? '').trim().toLowerCase();
    if (value.isEmpty) {
      return 'default';
    }
    if (value == 'trip') {
      return 'trips';
    }
    return value;
  }

  static bool isDefaultType(String? type) {
    return normalizeType(type) == 'default';
  }

  static bool isEventOrTripType(String? type) {
    final normalized = normalizeType(type);
    return normalized == 'event' || normalized == 'trips';
  }

  static DateTime? calendarDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return null;
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static bool isPastDate(String? value) {
    final endDay = calendarDate(value);
    if (endDay == null) {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return endDay.isBefore(today);
  }

  static bool isPastEventOrTrip({
    required String? type,
    String? relatedEndDate,
  }) {
    if (!isEventOrTripType(type)) {
      return false;
    }
    return isPastDate(relatedEndDate);
  }
}
