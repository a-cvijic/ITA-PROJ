import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/map');
              },
              child: Text('Map Screen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/issue',
                  arguments: '665f6eb2f872b76496457cc4',
                );
              },
              child: Text('Issue'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_problem');
              },
              child: Text('Add Issue'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/message');
              },
              child: Text('Chat with Representative'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/admin_messages');
              },
              child: Text('Manage Messages'),
            ),
          ],
        ),
      ),
    );
  }
}
