import 'package:mobile_app/models/tiny_user_model.dart';

class Message {
  String id;
  TinyUser from;
  TinyUser to;
  String message;
  bool read;

  Message({required this.id, required this.from, required this.to, required this.message, this.read = false});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      from: TinyUser.fromJson(json['from']),  // Convert 'from' to TinyUser
      to: TinyUser.fromJson(json['to']),      // Convert 'to' to TinyUser
      message: json['message'],
      read: json['read'],
    );
  }
}
