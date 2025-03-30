import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSubmitted;

  const ChatInput({Key? key, required this.onSubmitted}) : super(key: key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmitted() {
    final text = _textController.text;
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    widget.onSubmitted(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4.0,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.isNotEmpty;
                  });
                },
                onSubmitted: (_) => _isComposing ? _handleSubmitted() : null,
                decoration: InputDecoration(
                  hintText: 'Tell Attune how you feel...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                ),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              decoration: BoxDecoration(
                color: _isComposing ? Colors.indigo : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send),
                color: Colors.white,
                onPressed: _isComposing ? _handleSubmitted : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}