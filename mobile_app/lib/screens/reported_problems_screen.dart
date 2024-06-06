import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/issue_model.dart';
import '../colors.dart';
import 'issue_details_screen.dart';

class ReportedProblemsScreen extends StatefulWidget {
  @override
  _ReportedProblemsScreenState createState() => _ReportedProblemsScreenState();
}

class _ReportedProblemsScreenState extends State<ReportedProblemsScreen> {
  late Future<List<Issue>> futureReportedIssues;

  @override
  void initState() {
    super.initState();
    futureReportedIssues = ApiService().fetchReportedIssues();
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'in progress':
        return Icon(Icons.hourglass_empty, color: Colors.orange);
      case 'resolved':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'reported':
      default:
        return Icon(Icons.report, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        title: Text('My Reported Problems'),
      ),
      body: FutureBuilder<List<Issue>>(
        future: futureReportedIssues,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final issues = snapshot.data!;
            if (issues.isEmpty) {
              return Center(child: Text('No reported issues found.'));
            }
            return ListView.builder(
              itemCount: issues.length,
              itemBuilder: (context, index) {
                final issue = issues[index];
                return ListTile(
                  title: Text(issue.title),
                  subtitle: Text(issue.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IssueScreen(issueId: issue.id),
                      ),
                    );
                  },
                  trailing: _getStatusIcon(issue.status),
                );
              },
            );
          } else {
            return Center(child: Text('No data found'));
          }
        },
      ),
    );
  }
}
