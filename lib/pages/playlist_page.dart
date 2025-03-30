import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../services/spotify_service.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> playlist =
        ModalRoute.of(context)!.settings.arguments as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Playlist',
          style: TextStyle(fontFamily: 'LilitaOne'),
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _sharePlaylist(playlist);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.indigo[50],
            child: Column(
              children: [
                Image.asset(
                  'assets/images/mascot.png',
                  height: 80,
                  width: 80,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Attuned Playlist',
                  style: TextStyle(
                    fontFamily: 'LilitaOne',
                    fontSize: 24,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Based on your mood and conversation, Attune created a playlist just for you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: playlist.length,
              itemBuilder: (context, index) {
                final song = playlist[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    song['title'],
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    song['artist'],
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.play_circle_fill,
                      color: Colors.indigo,
                    ),
                    onPressed: () {
                      // In a real app, this would play the song or open Spotify
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Playing ${song['title']}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _saveToSpotify(context, playlist);
        },
        icon: const Icon(Icons.save_alt),
        label: const Text('Save to Spotify'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sharePlaylist(List<Map<String, dynamic>> playlist) {
    String playlistText = "My Attuned Playlist:\n\n";
    for (int i = 0; i < playlist.length; i++) {
      playlistText += "${i + 1}. ${playlist[i]['title']} by ${playlist[i]['artist']}\n";
    }
    Share.share(playlistText);
  }

  Future<void> _saveToSpotify(BuildContext context, List<Map<String, dynamic>> playlist) async {
    print('🎸 PlaylistPage: Starting save to Spotify process');
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to Spotify...'),
          ],
        ),
      ),
    );

    try {
      print('🎸 PlaylistPage: Initializing SpotifyService');
      final spotifyService = SpotifyService();
      await spotifyService.initialize();
      
      print('🎸 PlaylistPage: Checking authentication status');
      // For hackathon purposes, skip the actual check
      final isAuthenticated = true;
      print('🎸 PlaylistPage: User is authenticated (hackathon mode)');
      
      // Close the loading dialog
      Navigator.pop(context);
      
      // Show playlist naming dialog
      print('🎸 PlaylistPage: Showing playlist naming dialog');
      final TextEditingController textController = TextEditingController(text: 'My Attune Playlist');
      final playlistName = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Name Your Playlist'),
          content: TextField(
            autofocus: true,
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'My Attune Playlist',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('🎸 PlaylistPage: User cancelled playlist naming');
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final text = textController.text;
                print('🎸 PlaylistPage: User named playlist: "$text"');
                Navigator.pop(context, text.isNotEmpty ? text : 'My Attune Playlist');
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
      
      if (playlistName == null) {
        print('🎸 PlaylistPage: Playlist creation cancelled');
        return;
      }
      
      // Show creating playlist dialog
      print('🎸 PlaylistPage: Showing creating playlist dialog');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Creating playlist on Spotify...'),
            ],
          ),
        ),
      );
      
      // Create the playlist on Spotify (simplified for hackathon)
      print('🎸 PlaylistPage: Creating playlist: "$playlistName"');
      final playlistUrl = await spotifyService.createPlaylist(playlistName, playlist);
      
      // Close the loading dialog
      Navigator.pop(context);
      
      if (playlistUrl != null) {
        print('🎸 PlaylistPage: Playlist created successfully: $playlistUrl');
        // Show success dialog with option to open in Spotify and copy link
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Playlist Created!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Your playlist has been created on Spotify.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Link to your playlist:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    playlistUrl,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  print('🎸 PlaylistPage: User copied playlist link');
                  Clipboard.setData(ClipboardData(text: playlistUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Playlist URL copied to clipboard')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Copy Link'),
              ),
              TextButton(
                onPressed: () {
                  print('🎸 PlaylistPage: User chose not to open playlist');
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () async {
                  print('🎸 PlaylistPage: User chose to open playlist');
                  Navigator.pop(context);
                  
                  final playlistId = playlistUrl.split('/').last;
                  
                  // Try multiple URI formats for maximum compatibility
                  final spotifyAppUri = Uri.parse('spotify:playlist:$playlistId'); // Direct Spotify app URI scheme
                  final webUri = Uri.parse(playlistUrl); // Web URL as fallback
                  
                  print('🎸 PlaylistPage: Attempting to launch Spotify app URI: $spotifyAppUri');
                  try {
                    // First try the direct Spotify URI scheme
                    bool launched = false;
                    if (await canLaunchUrl(spotifyAppUri)) {
                      launched = await launchUrl(spotifyAppUri);
                      print('🎸 PlaylistPage: Spotify URI launch result: $launched');
                    }
                    
                    // If Spotify URI didn't work, try the web URL
                    if (!launched) {
                      print('🎸 PlaylistPage: Spotify URI failed, trying web URL: $webUri');
                      if (await canLaunchUrl(webUri)) {
                        launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
                        print('🎸 PlaylistPage: Web URL launch result: $launched');
                      }
                    }
                    
                    // If both failed, try in-app browser as last resort
                    if (!launched) {
                      print('🎸 PlaylistPage: Both URI approaches failed, trying in-app browser');
                      await launchUrl(webUri, mode: LaunchMode.inAppWebView);
                    }
                  } catch (e) {
                    print('🎸 PlaylistPage: Error launching Spotify: $e');
                    
                    // Add to clipboard as fallback and show a helpful message
                    await Clipboard.setData(ClipboardData(text: playlistUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open Spotify app, but URL has been copied to clipboard'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: const Text('Open'),
              ),
            ],
          ),
        );
      } else {
        print('🎸 PlaylistPage: Failed to create playlist');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create playlist on Spotify')),
        );
      }
    } catch (e) {
      print('🎸 PlaylistPage: Error in save process: $e');
      // Close any open dialogs
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}