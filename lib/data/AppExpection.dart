class AppExpections implements Exception {
  final String? message;
  final String? prefix;

  AppExpections({this.message, this.prefix});

  @override
  String toString() {
    return "$prefix: $message";
  }
}

class InternetExpection extends AppExpections {
  InternetExpection([String? message]) : super(message: message, prefix: "No Internet Connection");
}

class RequestTimeOutExpection extends AppExpections {
  RequestTimeOutExpection([String? message]) : super(message: message, prefix: "Request Time Out");
}

class ServerExpection extends AppExpections {
  ServerExpection([String? message]) : super(message: message, prefix: "Internal Server Error");
}

class InvalidExpection extends AppExpections {
  InvalidExpection([String? message]) : super(message: message, prefix: "Invalid Data");
}

class FetchDataExpection extends AppExpections {
  FetchDataExpection([String? message]) : super(message: message, prefix: "Fetch Data Error");
}
