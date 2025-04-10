import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String sender;
  final String text;

  ChatMessage({required this.sender, required this.text});

  @override
  Widget build(BuildContext context) {
    bool isUser = sender == "You";
    return Container(
      padding: EdgeInsets.all(10),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(sender, style: TextStyle(fontWeight: FontWeight.bold)),
          Material(
            borderRadius: BorderRadius.circular(10),
            color: isUser ? Colors.blueAccent : Colors.grey[300],
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(text, style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
