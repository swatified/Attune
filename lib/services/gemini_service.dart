import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Add this import for TimeoutException

class GeminiService {
  // Use your own Gemini API key here
  final String apiKey = '';
  final String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent';
  
  // Conversation history to maintain context
  final List<Map<String, dynamic>> _conversationHistory = [];

  GeminiService() {
    // No initialization prompt - we'll include instructions with each request instead
  }

  Future<String> getResponse(String userMessage) async {
    try {
      // Create a fresh conversation for each request if history is empty
      final List<Map<String, dynamic>> conversationContext = [];
      
      if (_conversationHistory.isEmpty) {
        // Add the instruction as the first message
        conversationContext.add({
          "role": "user",
          "parts": [
            {"text": "You are Attune, an AI assistant specialized in empathy and music. Your personality is friendly, warm, and understanding. You're like a good friend who listens carefully and responds thoughtfully. Your purpose is to have meaningful conversations about how users are feeling, their day, emotions, or anything they want to talk about. You also have deep knowledge about music and can relate feelings to music styles. Always respond in a conversational, empathetic way. Never mention that you're an AI - act as if you're just 'Attune', a musical friend."}
          ]
        });
        
        // Add the model's acknowledgement (we'll ignore this in the response)
        conversationContext.add({
          "role": "model",
          "parts": [
            {"text": "I understand and will act as Attune, your musical friend."}
          ]
        });
        
        // Add the actual user message
        conversationContext.add({
          "role": "user",
          "parts": [
            {"text": userMessage}
          ]
        });
      } else {
        // Use existing conversation history and add the new message
        conversationContext.addAll(_conversationHistory);
        
        // Add user message to context
        conversationContext.add({
          "role": "user",
          "parts": [
            {"text": userMessage}
          ]
        });
      }

      final url = '$baseUrl?key=$apiKey';
      
      final requestBody = {
        "contents": conversationContext,
        "generationConfig": {
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 1024,
        }
      };

      // Add error handling and timeout
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // Handle potential missing response elements properly
        if (jsonResponse['candidates'] != null && 
            jsonResponse['candidates'].isNotEmpty && 
            jsonResponse['candidates'][0]['content'] != null) {
          final botResponse = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
          
          // Store the successful conversation for future context
          if (_conversationHistory.isEmpty) {
            // Add the entire context if this is the first successful exchange
            _conversationHistory.addAll(conversationContext);
          } else {
            // Just add the latest user message
            _conversationHistory.add({
              "role": "user",
              "parts": [
                {"text": userMessage}
              ]
            });
          }
          
          // Add the model's response to the history
          _conversationHistory.add({
            "role": "model",
            "parts": [
              {"text": botResponse}
            ]
          });
          
          return botResponse;
        } else {
          print('Unexpected response format: ${response.body}');
          return "I'm having trouble understanding. Could you try again?";
        }
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return "I'm having trouble connecting right now. Let's try again?";
      }
    } catch (e) {
      print('Exception in getResponse: $e');
      return "I'm having trouble connecting right now. Let's try again?";
    }
  }

  Future<List<Map<String, dynamic>>> generatePlaylist(List<String> userMessages) async {
    try {
      final url = '$baseUrl?key=$apiKey';
      
      // Create a special prompt for playlist generation that includes the instructions
      final String playlistPrompt = 
          "You are Attune, an AI assistant specialized in music. Based on these conversation excerpts, create a playlist of 15 songs that match the user's mood and feelings. " +
          "Each song should resonate with the emotions expressed. " +
          "Format each song as a numbered list item (e.g., '1. Song Title by Artist Name'). " +
          "Do not use any special formatting like asterisks, bold, or italic. " +
          "Here's what the user shared: ${userMessages.join(' ')}";

      final requestBody = {
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": playlistPrompt}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.8,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 1024,
        }
      };

      // Add timeout handling
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Playlist generation timed out');
      });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['candidates'] != null && 
            jsonResponse['candidates'].isNotEmpty && 
            jsonResponse['candidates'][0]['content'] != null) {
          final playlistText = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
          
          // Parse the text into a structured playlist
          final List<Map<String, dynamic>> playlist = parsePlaylistFromText(playlistText);
          return playlist;
        } else {
          print('Unexpected playlist response format: ${response.body}');
          // Return default playlist when API response is malformed
          return _getDefaultPlaylist();
        }
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        // Return default playlist when API fails
        return _getDefaultPlaylist();
      }
    } catch (e) {
      print('Exception in generatePlaylist: $e');
      // Return default playlist on any exception
      return _getDefaultPlaylist();
    }
  }

  List<Map<String, dynamic>> parsePlaylistFromText(String text) {
    print('📱 GeminiService: Parsing playlist from text');
    final List<Map<String, dynamic>> playlist = [];
    
    // Updated regex pattern that will capture song titles and artists while ignoring asterisks
    final RegExp songPattern = RegExp(r'(\d+)\.\s*(?:\*\*)?([^*"\n]+?)(?:\*\*)?(?:\s+by|\s*[-–]\s*)(?:\*\*)?([^*"\n\(]+?)(?:\*\*)?(?::|$|\n)');
    
    final matches = songPattern.allMatches(text);
    print('📱 GeminiService: Found ${matches.length} song matches in text');
    
    for (final match in matches) {
      if (match.groupCount >= 3) {
        // Clean up the title and artist by removing any remaining asterisks
        final title = match.group(2)?.trim().replaceAll('*', '') ?? 'Unknown Song';
        final artist = match.group(3)?.trim().replaceAll('*', '') ?? 'Unknown Artist';
        
        print('📱 GeminiService: Parsed song: "$title" by "$artist"');
        
        playlist.add({
          'title': title,
          'artist': artist,
          'albumArt': 'assets/images/default_album_art.png', // Default album art
        });
      }
    }
    
    // If parsing failed or found less than 5 songs, create some defaults
    if (playlist.length < 5) {
      print('📱 GeminiService: Not enough songs parsed (${playlist.length}), adding defaults');
      return _getDefaultPlaylist();
    }
    
    // Ensure we only return 15 songs maximum
    if (playlist.length > 15) {
      print('📱 GeminiService: Limiting playlist to 15 songs (from ${playlist.length})');
      return playlist.sublist(0, 15);
    }
    
    return playlist;
  }

  // Create a separate method for default playlist
  List<Map<String, dynamic>> _getDefaultPlaylist() {
    final List<Map<String, dynamic>> defaultSongs = [
      {'title': 'Happy', 'artist': 'Pharrell Williams'},
      {'title': 'Someone Like You', 'artist': 'Adele'},
      {'title': 'Stronger', 'artist': 'Kelly Clarkson'},
      {'title': 'Uptown Funk', 'artist': 'Mark Ronson ft. Bruno Mars'},
      {'title': 'Dancing On My Own', 'artist': 'Robyn'},
      {'title': 'Shake It Off', 'artist': 'Taylor Swift'},
      {'title': 'Fix You', 'artist': 'Coldplay'},
      {'title': 'Good as Hell', 'artist': 'Lizzo'},
      {'title': 'Bohemian Rhapsody', 'artist': 'Queen'},
      {'title': 'Feeling Good', 'artist': 'Nina Simone'},
      {'title': 'Don\'t Stop Believin\'', 'artist': 'Journey'},
      {'title': 'Lose Yourself', 'artist': 'Eminem'},
      {'title': 'Unwritten', 'artist': 'Natasha Bedingfield'},
      {'title': 'Titanium', 'artist': 'David Guetta ft. Sia'},
      {'title': 'Eye of the Tiger', 'artist': 'Survivor'},
    ];
    
    return defaultSongs.map((song) => {
      ...song,
      'albumArt': 'assets/images/default_album_art.png',
    }).toList();
  }
}

// Helper function to avoid the error with min
int min(int a, int b) {
  return a < b ? a : b;
}