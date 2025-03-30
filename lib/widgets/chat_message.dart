import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isTyping;

  const ChatMessage({
    Key? key,
    required this.text,
    required this.isUser,
    this.isTyping = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isUser ? _buildUserMessage() : _buildBotMessage(context),
      ),
    );
  }

  List<Widget> _buildUserMessage() {
    return [
      const Spacer(),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.indigo[100],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16.0,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8.0),
      CircleAvatar(
        child: Text(
          'You',
          style: TextStyle(fontSize: 10),
        ),
      ),
    ];
  }

  List<Widget> _buildBotMessage(BuildContext context) {
    return [
      CircleAvatar(
        backgroundColor: Colors.indigo,
        child: Image.asset(
          'assets/images/mascot.png',
          height: 24,
          width: 24,
        ),
      ),
      const SizedBox(width: 8.0),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: isTyping
              ? _buildTypingIndicator()
              : Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 16.0,
                  ),
                ),
        ),
      ),
      const Spacer(),
    ];
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
          SizedBox(width: 8.0),
          Text(
            'Attune is typing...',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14.0,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}