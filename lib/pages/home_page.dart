import 'package:flutter/material.dart';
import 'package:attune/widgets/chat_message.dart';
import 'package:attune/widgets/chat_input.dart';
import 'package:attune/services/gemini_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<ChatMessage> _messages = [];
  final GeminiService _geminiService = GeminiService();
  bool _isGeneratingPlaylist = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage("Hi there! I'm Attune, your musical friend. How are you feeling today?");
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
      ));
    });
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
      ));
    });

    // Show typing indicator
    setState(() {
      _messages.add(ChatMessage(
        text: '',
        isUser: false,
        isTyping: true,
      ));
    });

    // Get response from Gemini
    try {
      final response = await _geminiService.getResponse(text);
      
      // Remove typing indicator and add actual response
      setState(() {
        _messages.removeLast();
        _addBotMessage(response);
      });
    } catch (e) {
      // Remove typing indicator and add error message
      setState(() {
        _messages.removeLast();
        _addBotMessage("Sorry, I'm having trouble connecting right now. Let's try again?");
      });
    }
  }

  void _generatePlaylist() {
    setState(() {
      _isGeneratingPlaylist = true;
    });

    // Extract conversation context from messages
    final List<String> userMessages = _messages
        .where((msg) => msg.isUser)
        .map((msg) => msg.text)
        .toList();

    // Generate playlist based on conversation
    _geminiService.generatePlaylist(userMessages).then((playlist) {
      setState(() {
        _isGeneratingPlaylist = false;
      });
      
      // Navigate to playlist screen
      Navigator.of(context).pushNamed('/playlist', arguments: playlist);
    }).catchError((error) {
      setState(() {
        _isGeneratingPlaylist = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate playlist. Please try again.')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/mascot.png',
              height: 36,
              width: 36,
            ),
            const SizedBox(width: 10),
            const Text(
              'Attune',
              style: TextStyle(fontFamily: 'LilitaOne'),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Attune'),
                  content: const Text(
                    'Attune is your musical companion that helps create playlists based on how you feel. Just chat with me about your day, emotions, or anything on your mind!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _messages[index],
            ),
          ),
          const Divider(height: 1.0),
          ChatInput(
            onSubmitted: _handleSubmitted,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isGeneratingPlaylist ? null : _generatePlaylist,
        icon: _isGeneratingPlaylist
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              )
            : const Icon(Icons.music_note),
        label: Text(_isGeneratingPlaylist ? 'Creating...' : 'Create Playlist'),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}