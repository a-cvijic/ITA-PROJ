class TinyUser {
  final String id;
  final String username;

  TinyUser({
    required this.id,
    required this.username,
  });

  factory TinyUser.fromJson(Map<String, dynamic> json) {
    return TinyUser(
      id: json['_id'],
      username: json['username'],
    );
  }
}
