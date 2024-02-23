// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, avoid_print, non_constant_identifier_names, must_be_immutable, invalid_return_type_for_catch_error, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    String message = '';
    String? response;
    final MessageTextController = TextEditingController();

    final List<Widget> _chatMessages = [];
    final StreamController<List<Widget>> _messageStreamController =
        StreamController();

    void addChatMessage(String? message, bool sender) {
      _chatMessages.add(ChatBubble(
        text: message,
        isMe: sender,
      ));
      _messageStreamController.add(_chatMessages);
    }

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xff161622),
      body: SafeArea(
        child: Container(
          height: screenHeight,
          width: screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Gemini ChatBot✨",
                  style: TextStyle(
                      fontSize: screenWidth * 0.02,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: StreamBuilder<List<Widget>>(
                  stream: _messageStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return snapshot.data![index];
                        },
                      );
                    } else {
                      return SizedBox(
                        width: 250.0,
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Agne',
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w700
                          ),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                  'How may I help you today?'),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 280,
                    padding: EdgeInsets.only(
                      left: 20,
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                        color: Color(0xff161622),
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    child: TextField(
                      controller: MessageTextController,
                      onChanged: (value) {
                        message = value;
                      },
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          hintText: "Write your message",
                          hintStyle: TextStyle(color: Colors.blueGrey),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  IconButton(
                    onPressed: () async {
                      addChatMessage(message, true);
                      MessageTextController.clear();
                      try {
                        final gemini = Gemini.instance;

                        await gemini.text(message).then((value) {
                          response = value?.output;
                          // print(value?.output);
                        }).catchError((e) => print(e));
                        addChatMessage(response, false);
                        print(response);
                      } catch (e) {
                        print("The error is $e");
                      }
                    },
                    icon: Icon(Icons.send),
                    color: Colors.blueGrey,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  ChatBubble({super.key, required this.text, required this.isMe});

  String? text;
  bool isMe;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Material(
              elevation: 5,
              color: Colors.blueGrey,
              borderRadius: isMe
                  ? BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))
                  : BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  "$text",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              )),
        ),
      ],
    );
  }
}
