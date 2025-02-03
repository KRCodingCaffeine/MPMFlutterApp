class AppExpections implements Exception{
  final message;
  final prefix;

  AppExpections({this.message,this.prefix});
  String toString(){
    return '$message$prefix';
  }
}
class InternetExpection extends AppExpections{
  InternetExpection([String? message]): super(message: "No Internet Connection");

}
class RequestTimeOutExpection extends AppExpections{
  RequestTimeOutExpection([String? message]): super(message: "Request Time Out");

}
class ServerExpection extends AppExpections{
  ServerExpection([String? message]): super(message: "Internal server error");

}
class InvalidExpection extends AppExpections{
  InvalidExpection([String? message]): super(message: "Invalid Url");

}
class FetchDataExpection extends AppExpections{
  FetchDataExpection([String? message]): super(message: "");

}
