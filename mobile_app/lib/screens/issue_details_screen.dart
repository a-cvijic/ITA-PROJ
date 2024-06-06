import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/issue_details_model.dart';
import '../colors.dart';

class IssueScreen extends StatefulWidget {
  final String issueId;

  IssueScreen({required this.issueId});

  @override
  _IssueScreenState createState() => _IssueScreenState();
}

class _IssueScreenState extends State<IssueScreen> {
  late Future<IssueDetails> futureIssue;
  late LatLng issueLocation;
  Uint8List? imageBytes;
  String userRole = '';

  @override
  void initState() {
    super.initState();
    futureIssue = ApiService().fetchIssue(widget.issueId);
    futureIssue.then((issue) {
      if (issue.imageId != null) {
        imageBytes = base64Decode(issue.imageId!);
      }
    }).catchError((error) {
      print('Failed to load issue: $error');
    });
    _getUserRole();
  }


  void _getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('userRole'); // Use the correct key
    print('Retrieved userRole: $role'); // Debug print
    setState(() {
      userRole = role ?? '';
    });
  }

  Future<void> _updateIssueStatusToResolved() async {
    try {
      await ApiService().updateIssueStatusToResolved(widget.issueId);
      setState(() {
        futureIssue = ApiService().fetchIssue(widget.issueId);
      });
    } catch (e) {
      // Handle error
      print('Failed to update issue status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Issue Details'),
        backgroundColor: AppColors.slateBlue,
      ),
      body: FutureBuilder<IssueDetails>(
        future: futureIssue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            issueLocation = LatLng(
                snapshot.data!.coordinates[1], snapshot.data!.coordinates[0]);
            return SingleChildScrollView(
              child: Column(
                children: [
                  if (imageBytes != null)
                    Image.memory(imageBytes!,
                        fit: BoxFit.cover, width: double.infinity, height: 200)
                  else
                    Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!.description,
                          style: TextStyle(
                              fontSize: 16, color: AppColors.charcoal),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Address: ${snapshot.data!.title}',
                          style: TextStyle(
                              fontSize: 16, color: AppColors.charcoal),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Status: ${snapshot.data!.status}',
                          style: TextStyle(
                              fontSize: 16, color: AppColors.charcoal),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Reported By: ${snapshot.data!.reportedBy.username}',
                          style: TextStyle(
                              fontSize: 16, color: AppColors.charcoal),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Created At: ${snapshot.data!.createdAt}',
                          style: TextStyle(
                              fontSize: 16, color: AppColors.charcoal),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Coordinates: ${snapshot.data!.coordinates[1]}, ${snapshot.data!.coordinates[0]}',
                          style: TextStyle(
                              fontSize: 16, color: AppColors.charcoal),
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Votes',
                                style: TextStyle(
                                    fontSize: 16, color: AppColors.charcoal),
                              ),
                              Text(
                                '${snapshot.data!.upvotes - snapshot.data!.downvotes}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              if (userRole == 'citizen')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_upward,
                                        color: Colors.blue),
                                    onPressed: () {
                                      // Upvote logic
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_downward,
                                        color: Colors.blue),
                                    onPressed: () {
                                      // Downvote logic
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/map');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.slateBlue,
                                ),
                                child: Text('Show on map'),
                              ),
                              if (snapshot.data!.status != 'resolved' && userRole == 'worker')
                                ElevatedButton(
                                  onPressed: _updateIssueStatusToResolved,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.slateBlue,
                                  ),
                                  child: Text('Mark as Resolved'),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          height: 200,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: issueLocation,
                              zoom: 14,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId('issueLocation'),
                                position: issueLocation,
                              ),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data found'));
          }
        },
      ),
    );
  }
}
