import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/issue_model.dart';

class IssueScreen extends StatefulWidget {
  final String issueId;

  IssueScreen({required this.issueId});

  @override
  _IssueScreenState createState() => _IssueScreenState();
}

class _IssueScreenState extends State<IssueScreen> {
  late Future<Issue> futureIssue;

  @override
  void initState() {
    super.initState();
    futureIssue = ApiService().fetchIssue(widget.issueId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Issue Details'),
      ),
      body: FutureBuilder<Issue>(
        future: futureIssue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Uint8List bytes = base64Decode(snapshot.data!.imageUrl);
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.memory(bytes),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!.description,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Address: ${snapshot.data!.title}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Status: ${snapshot.data!.status}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Reported By: ${snapshot.data!.reportedBy.username}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Created At: ${snapshot.data!.createdAt}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Coordinates: ${snapshot.data!.coordinates[1]}, ${snapshot.data!.coordinates[0]}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Votes',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '${snapshot.data!.upvotes - snapshot.data!.downvotes}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_upward, color: Colors.blue),
                                  onPressed: () {
                                    // Upvote logic
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_downward, color: Colors.blue),
                                  onPressed: () {
                                    // Downvote logic
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/map');
                      },
                      child: Text('Show on map'),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
