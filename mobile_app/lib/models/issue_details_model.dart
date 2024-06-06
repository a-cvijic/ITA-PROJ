import 'package:mobile_app/models/tiny_user_model.dart';

class IssueDetails {
  final String id;
  final String title;
  final String description;
  final String imageId; // Updated to match backend
  final int upvotes;
  final int downvotes;
  final String status;
  final TinyUser reportedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedDate;
  final List<String> upvotedBy;
  final List<String> downvotedBy;
  final List<double> coordinates;

  IssueDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.imageId, // Updated to match backend
    required this.upvotes,
    required this.downvotes,
    required this.status,
    required this.reportedBy,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedDate,
    required this.upvotedBy,
    required this.downvotedBy,
    required this.coordinates,
  });

  factory IssueDetails.fromJson(Map<String, dynamic> json) {
    return IssueDetails(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      imageId: json['imageId']['base64String'], // Updated to match backend
      upvotes: json['upvotes'],
      downvotes: json['downvotes'],
      status: json['status'],
      reportedBy: TinyUser.fromJson(json['reportedBy']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      resolvedDate: json['resolvedDate'] != null
          ? DateTime.parse(json['resolvedDate'])
          : null,
      upvotedBy: List<String>.from(json['upvotedBy']),
      downvotedBy: List<String>.from(json['downvotedBy']),
      coordinates: List<double>.from(json['location']['coordinates']),
    );
  }
}
