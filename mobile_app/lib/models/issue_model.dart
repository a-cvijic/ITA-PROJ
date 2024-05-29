class Issue {
  final String id;
  final String address;
  final String description;
  final String imageUrl;
  final int upvotes;
  final int downvotes;
  final String status;
  final String reportedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<double> coordinates;

  Issue({
    required this.id,
    required this.address,
    required this.description,
    required this.imageUrl,
    required this.upvotes,
    required this.downvotes,
    required this.status,
    required this.reportedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.coordinates,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['_id'],
      address: json['address'],
      description: json['description'],
      imageUrl: json['image'],
      upvotes: json['upvotes'],
      downvotes: json['downvotes'],
      status: json['status'],
      reportedBy: json['reportedBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      coordinates: List<double>.from(json['location']['coordinates']),
    );
  }
}
