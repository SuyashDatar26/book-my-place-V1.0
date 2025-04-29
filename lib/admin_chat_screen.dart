import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminChatScreen extends StatelessWidget {
  const AdminChatScreen({Key? key}) : super(key: key);

  final String adminId = 'admin123'; // Replace with actual admin ID

  @override
  Widget build(BuildContext context) {
    final TextEditingController _messageController = TextEditingController();

    void _sendMessage() {
      if (_messageController.text.trim().isNotEmpty) {
        FirebaseFirestore.instance.collection('chats').add({
          'sender': adminId,
          'message': _messageController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });
        _messageController.clear();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Customers'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index];
                    return ListTile(
                      title: Text(data['message']),
                      subtitle: Text(data['sender']),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
