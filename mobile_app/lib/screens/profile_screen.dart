import 'package:flutter/material.dart';
import '../colors.dart';
import 'reported_problems_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.softSky,
              child: Icon(
                Icons.person,
                size: 50,
                color: AppColors.whiteSmoke,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'User Name',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'user@example.com',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.spanishGray,
              ),
            ),
            SizedBox(height: 32),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Navigate to settings
              },
            ),
            ListTile(
              leading: Icon(Icons.report_problem),
              title: Text('My Reported Problems'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportedProblemsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
