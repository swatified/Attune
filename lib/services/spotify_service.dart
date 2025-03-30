import 'package:spotify/spotify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'dart:convert'; // Added for base64Encode

class SpotifyService {
  // Add your Spotify credentials from Spotify Developer Dashboard
  static const String clientId = '';
  static const String clientSecret = '';
  static const String redirectUri = 'attune://callback';
  static const String tokenKey = 'spotify_token';
  
  late SpotifyApi spotify;
  bool _isInitialized = false; // Track initialization state
  
  // Initialize the Spotify service
  Future<void> initialize() async {
    print('🎵 SpotifyService: Initializing');
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(tokenKey);
      
      if (accessToken != null) {
        print('🎵 SpotifyService: Found stored token');
        spotify = SpotifyApi(
          SpotifyApiCredentials(clientId, clientSecret, accessToken: accessToken)
        );
      } else {
        print('🎵 SpotifyService: No token found, initializing with client credentials only');
        spotify = SpotifyApi(
          SpotifyApiCredentials(clientId, clientSecret)
        );
      }
      _isInitialized = true;
      print('🎵 SpotifyService: Initialized successfully');
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
  
  // Create a playlist on Spotify - simplified for hackathon
  Future<String?> createPlaylist(String name, List<Map<String, dynamic>> songs) async {
    print('🎵 SpotifyService: Creating playlist "$name" with ${songs.length} songs');
    try {
      // For hackathon, simulate this process
      await Future.delayed(Duration(seconds: 2)); // Simulate API call
      
      // Generate a fake Spotify URL
      final playlistId = _generateRandomId();
      final spotifyUrl = 'https://open.spotify.com/playlist/$playlistId';
      
      print('🎵 SpotifyService: Created playlist with ID: $playlistId');
      // Log some of the songs
      for (int i = 0; i < min(5, songs.length); i++) {
        print('🎵 SpotifyService: Song ${i+1}: "${songs[i]['title']}" by "${songs[i]['artist']}"');
      }
      if (songs.length > 5) {
        print('🎵 SpotifyService: ... and ${songs.length - 5} more songs');
      }
      
      return spotifyUrl;
    } catch (e) {
      print('🎵 SpotifyService: Error creating playlist: $e');
      return null;
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