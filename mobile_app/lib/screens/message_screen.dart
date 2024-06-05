import 'package:flutter/material.dart';
import '../colors.dart';

class MessageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Representative'),
        backgroundColor: AppColors.charcoal,
      ),
      backgroundColor: AppColors.pastelSky,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildReceivedMessage('Hello! How can I assist you today?'),
                  _buildSentMessage('I have a problem with street lights.'),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message',
                      filled: true,
                      fillColor: AppColors.whiteSmoke,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Add send message logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.charcoal,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedMessage(String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.whiteSmoke,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(message),
      ),
    );
  }

  Widget _buildSentMessage(String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.slateBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(message, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
