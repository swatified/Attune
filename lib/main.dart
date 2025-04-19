import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:attune/pages/splash_screen.dart';
import 'package:attune/pages/home_page.dart';
import 'package:attune/pages/playlist_page.dart';
import 'services/spotify_callback_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top]
  );
  
  runApp(const AttuneApp());
}

class AttuneApp extends StatefulWidget {
  const AttuneApp({Key? key}) : super(key: key);
  @override
  State<AttuneApp> createState() => _AttuneAppState();
}

class _AttuneAppState extends State<AttuneApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  @override
  void initState() {
    super.initState();
    // Initialize link handler after the app is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentContext != null) {
        SpotifyCallbackHandler.initialize(navigatorKey.currentContext!);
      }
    });
  }
  
  @override
  void dispose() {
    SpotifyCallbackHandler.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Attune',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'LilitaOne',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Wrap your routes in SafeArea at the app level
      builder: (context, child) {
        return MediaQuery(
          // Preserve the original MediaQuery data but add bottom padding
          data: MediaQuery.of(context).copyWith(
            padding: MediaQuery.of(context).padding.copyWith(
              bottom: MediaQuery.of(context).padding.bottom,
            ),
          ),
          child: child!,
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/playlist': (context) => const PlaylistPage(),
      },
    );
  }
}