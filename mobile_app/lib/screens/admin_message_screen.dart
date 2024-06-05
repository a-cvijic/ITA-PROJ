import 'package:flutter/material.dart';
import '../colors.dart';
import '../services/messages_api_service.dart';
import '../models/tiny_user_model.dart';
import '../models/message_model.dart';

class AdminMessageScreen extends StatefulWidget {
  @override
  _AdminMessageScreenState createState() => _AdminMessageScreenState();
}

class _AdminMessageScreenState extends State<AdminMessageScreen> {
  final MessageService _messageService = MessageService();
  late Future<List<TinyUser>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = _messageService.fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Messages'),
        backgroundColor: AppColors.charcoal,
      ),
      backgroundColor: AppColors.pastelSky,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<TinyUser>>(
          future: _contactsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to load contacts'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No contacts found'));
            }

            final contacts = snapshot.data!;
            return ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  title: Text(contact.username!),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminChatScreen(
                          userId: contact.id,
                          username: contact.username!,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}


class AdminChatScreen extends StatefulWidget {
  final String userId;
  final String username;

  AdminChatScreen({required this.userId, required this.username});

  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final MessageService _messageService = MessageService();
  final TextEditingController _messageController = TextEditingController();
  late Future<List<Message>> _conversationFuture;

  @override
  void initState() {
    super.initState();
    _conversationFuture = _messageService.fetchConversation(widget.userId);
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await _messageService.replyMessage(widget.userId, _messageController.text.trim());
      setState(() {
        _conversationFuture = _messageService.fetchConversation(widget.userId);
      });
      _messageController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.username}'),
        backgroundColor: AppColors.charcoal,
      ),
      backgroundColor: AppColors.pastelSky,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Message>>(
                future: _conversationFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Failed to load conversation' + snapshot.error.toString()));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No messages found'));
                  }

                  final messages = snapshot.data!;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return message.from == widget.userId
                          ? _buildReceivedMessage(message.message)
                          : _buildSentMessage(message.message);
                    },
                  );
                },
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
                  onPressed: _sendMessage,
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