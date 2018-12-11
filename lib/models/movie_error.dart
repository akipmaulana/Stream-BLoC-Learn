
class MovieError extends Object {
  final int code;
  final String message;

  MovieError({this.code, this.message});

  MovieError.fromJSON(Map<String, dynamic> json)
      : code = json['status_code'],
        message = json['status_message'];

  @override
  int get hashCode => code;
}
