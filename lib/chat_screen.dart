// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, avoid_print, non_constant_identifier_names, must_be_immutable, invalid_return_type_for_catch_error, no_leading_underscores_for_local_identifiers, prefer_const_literals_to_create_immutables, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:progress_indicators/progress_indicators.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();

    @override
    void initState() {
      super.initState();
      // Add listener to scroll to the bottom of the list when a new item is added
      _scrollController.addListener(() {
        if (_scrollController.position.atEdge) {
          final isTop = _scrollController.position.pixels == 0;
          if (!isTop) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        }
      });
    }

    String message = '';
    String? response;
    final MessageTextController = TextEditingController();

    final List<Widget> _chatMessages = [];
    // final List<Widget> _progressloader = [
    //   LoadingIndicator(),
    // ];
    final StreamController<List<Widget>> _messageStreamController =
        StreamController();

    void addChatMessage(String? message, bool sender) {
      _chatMessages.add(ChatBubble(
        text: message,
        isMe: sender,
      ));
      _messageStreamController.add(_chatMessages);
    }

    // void showLoadingIndicator() {
    //   _messageStreamController.add(_progressloader);
    // }

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
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 100),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xff161622),
                      maxRadius: 15,
                      backgroundImage: AssetImage("images/ChatBot.png"),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      "Gemini ChatBot",
                      style: TextStyle(
                          fontSize: screenWidth * 0.02,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
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
                        controller: _scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
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
                              fontWeight: FontWeight.w700),
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
                        // showLoadingIndicator();
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  isMe
                      ? CircleAvatar(
                          maxRadius: 10,
                          backgroundColor: Colors.blueGrey,
                        )
                      : CircleAvatar(
                          maxRadius: 10,
                          backgroundColor: Color(0xff161622),
                          backgroundImage: AssetImage("images/ChatBot.png"),
                        ),
                  SizedBox(
                    width: 3,
                  ),
                  isMe
                      ? Text(
                          "Me",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w700),
                        )
                      : Text(
                          "Gemini",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w700),
                        )
                ],
              ),
              SizedBox(
                width: 320,
                child: Material(
                    elevation: 5,
                    color: Color(0xff161622),
                    borderRadius: isMe
                        ? BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10))
                        : BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: isMe
                          ? Text(
                              "$text",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            )
                          : DefaultTextStyle(
                              style: const TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                              child: AnimatedTextKit(
                                totalRepeatCount: 1,
                                animatedTexts: [
                                  TypewriterAnimatedText('$text'),
                                ],
                              ),
                            ),
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return JumpingDotsProgressIndicator(
      color: Colors.white,
      fontSize: 30.0,
    );
  }
}
