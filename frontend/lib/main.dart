import 'package:chat_ai_project/screens/chat_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Chat_ai());
}

class Chat_ai extends StatelessWidget {
  const Chat_ai({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat AI',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        cardColor: Colors.white,
        primaryColorLight: const Color(0xFFE3F2FD),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey[800]!,
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        primaryColorLight: Colors.blueGrey[700]!,
      ),
      themeMode: ThemeMode.system,
      home: const ChatScreen(),
    );
  }
}
