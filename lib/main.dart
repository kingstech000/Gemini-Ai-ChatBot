import 'package:aichatbot/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';



void main() {
  Gemini.init(apiKey: 'AIzaSyAOgFEJiKXjzYiG5KeV9mf8hdu_5kSOf-w');
  runApp(const AiChat());
}

class AiChat extends StatelessWidget {
  const AiChat({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}