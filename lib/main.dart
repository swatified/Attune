import 'package:flutter/material.dart';
import 'package:attune/pages/splash_screen.dart';
import 'package:attune/pages/home_page.dart';
import 'package:attune/pages/playlist_page.dart';

void main() {
  runApp(const AttuneApp());
}

class AttuneApp extends StatelessWidget {
  const AttuneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attune',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'LilitaOne',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/playlist': (context) => const PlaylistPage(),
      },
    );
  }
}