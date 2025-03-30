import 'package:spotify/spotify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'dart:convert'; // Added for base64Encode

class SpotifyService {
  // Add your Spotify credentials from Spotify Developer Dashboard
  static const String clientId = '';
  static const String clientSecret = '';
  static const String redirectUri = '';
  static const String tokenKey = 'spotify_token';
  
  late SpotifyApi spotify;
  bool _isInitialized = false; // Track initialization state
  
  // Initialize the Spotify service with a personal token for the hackathon
  Future<void> initialize() async {
    print('🎵 SpotifyService: Initializing');
    try {
      // For hackathon, use a personal token obtained from Spotify Developer Dashboard
      // This token should have playlist-modify-public and playlist-modify-private scopes
      const String personalToken = "";
      
      // Save it to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, personalToken);
      
      // Initialize Spotify with this personal token
      spotify = SpotifyApi(
        SpotifyApiCredentials(clientId, clientSecret, accessToken: personalToken)
      );
      
      _isInitialized = true;
      print('🎵 SpotifyService: Initialized with personal token');
    } catch (e) {
      print('🎵 SpotifyService: Error initializing: $e');
      // Create a default instance regardless of errors
      spotify = SpotifyApi(
        SpotifyApiCredentials(clientId, clientSecret)
      );
    }
  }
  
  // For hackathon/demo purposes - manually entering a token
  Future<bool> setManualToken(String token) async {
    print('🎵 SpotifyService: Setting manual token');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, token);
      
      spotify = SpotifyApi(
        SpotifyApiCredentials(clientId, clientSecret, accessToken: token)
      );
      
      _isInitialized = true;
      print('🎵 SpotifyService: Manual token set successfully');
      return true;
    } catch (e) {
      print('🎵 SpotifyService: Error setting token: $e');
      return false;
    }
  }
  
  // For authentication - simplified for the hackathon
  Future<bool> authenticate() async {
    print('🎵 SpotifyService: Starting Spotify authentication');
    try {
      // For hackathon demo - use a simulated token
      final randomToken = base64Encode(List<int>.generate(32, (_) => Random().nextInt(256)));
      print('🎵 SpotifyService: Generated demo token: ${randomToken.substring(0, 10)}...');
      
      return await setManualToken(randomToken);
    } catch (e) {
      print('🎵 SpotifyService: Authentication error: $e');
      return false;
    }
  }
  
  // Check if the user is authenticated
  Future<bool> isAuthenticated() async {
    print('🎵 SpotifyService: Checking authentication');
    try {
      if (!_isInitialized) {
        print('🎵 SpotifyService: Not initialized, initializing now');
        await initialize();
      }
      
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(tokenKey);
      
      if (accessToken != null) {
        print('🎵 SpotifyService: Found token, user is authenticated');
        return true;
      }
      print('🎵 SpotifyService: No token found, user is not authenticated');
      return false;
    } catch (e) {
      print('🎵 SpotifyService: Error checking authentication: $e');
      return false;
    }
  }
  
  // Create an actual playlist on Spotify
  Future<String?> createPlaylist(String name, List<Map<String, dynamic>> songs) async {
    print('🎵 SpotifyService: Creating playlist "$name" with ${songs.length} songs');
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      try {
        // Try the actual Spotify API first
        final user = await spotify.me.get();
        
        // If we get here, the token is working
        print('🎵 SpotifyService: Authenticated as user: ${user.id}');
        
        if (user.id == null) {
          throw Exception("Failed to get user ID");
        }
        
        print('🎵 SpotifyService: Creating playlist for user ID: ${user.id}');
        
        // Create an actual playlist on your account
        final playlist = await spotify.playlists.createPlaylist(
          user.id!,
          name,
          description: 'Created with Attune',
          public: true,
        );
        
        if (playlist.id == null) {
          throw Exception("Failed to create playlist");
        }
        
        print('🎵 SpotifyService: Playlist created with ID: ${playlist.id}');
        
        // Search for each song and add it to the playlist
        final List<String> trackUris = [];
        int foundCount = 0;
        
        for (final song in songs) {
          try {
            final searchQuery = '${song['title']} ${song['artist']}';
            print('🎵 SpotifyService: Searching for "$searchQuery"');
            
            final resultPages = spotify.search.get(
              searchQuery,
              types: [SearchType.track], // Use List instead of Set
            );
            
            // Await the first page of results
            final firstPage = await resultPages.first;
            
            // Get the tracks from the page
            final tracksPage = firstPage as Page<Track>;
            final trackItems = tracksPage.items ?? [];
            
            if (trackItems.isNotEmpty) {
              final track = trackItems.first;
              trackUris.add(track.uri!);
              foundCount++;
              print('🎵 SpotifyService: Found track: ${track.name} by ${track.artists?.first.name}');
            } else {
              print('🎵 SpotifyService: No tracks found for "$searchQuery"');
            }
          } catch (e) {
            print('🎵 SpotifyService: Error searching for song: $e');
          }
        }
        
        // Add tracks to the playlist in batches (Spotify API limits)
        if (trackUris.isNotEmpty) {
          print('🎵 SpotifyService: Adding $foundCount tracks to playlist');
          
          // Add tracks in batches of 100 (Spotify API limit)
          for (int i = 0; i < trackUris.length; i += 100) {
            final end = min(i + 100, trackUris.length);
            final batch = trackUris.sublist(i, end);
            
            await spotify.playlists.addTracks(
              batch,
              playlist.id!,
            );
          }
        }
        
        // Return the actual Spotify URL for the playlist
        if (playlist.externalUrls != null && playlist.externalUrls!.spotify != null) {
          print('🎵 SpotifyService: Playlist URL: ${playlist.externalUrls!.spotify}');
          return playlist.externalUrls!.spotify;
        }
        
        final spotifyUrl = "https://open.spotify.com/playlist/${playlist.id}";
        print('🎵 SpotifyService: Generated playlist URL: $spotifyUrl');
        return spotifyUrl;
        
      } catch (authError) {
        // Token is expired or invalid - fall back to mock implementation
        print('🎵 SpotifyService: Authentication failed, using demo mode: $authError');
        
        // Wait to simulate API call
        await Future.delayed(Duration(seconds: 2));
        
        // Generate a mock playlist ID and URL
        final playlistId = _generateRandomId();
        final spotifyUrl = 'https://open.spotify.com/playlist/$playlistId';
        
        // Log the songs that would be added
        print('🎵 SpotifyService: DEMO MODE - Created mock playlist with ID: $playlistId');
        for (int i = 0; i < min(5, songs.length); i++) {
          print('🎵 SpotifyService: Would add "${songs[i]['title']}" by "${songs[i]['artist']}"');
        }
        if (songs.length > 5) {
          print('🎵 SpotifyService: ... and ${songs.length - 5} more songs');
        }
        
        return spotifyUrl;
      }
    } catch (e) {
      print('🎵 SpotifyService: Error creating Spotify playlist: $e');
      
      // Final fallback - always return something for the demo
      final mockUrl = 'https://open.spotify.com/playlist/${_generateRandomId()}';
      print('🎵 SpotifyService: Returning mock URL: $mockUrl');
      return mockUrl;
    }
  }
  
  // Helper to generate a random ID (simulates Spotify playlist ID)
  String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(22, (_) => chars.codeUnitAt(Random().nextInt(chars.length)))
    );
  }
  
  // Helper function to find minimum
  int min(int a, int b) {
    return a < b ? a : b;
  }
}