import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'history_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  bool _isListening = false;
  bool _isWaitingResponse = false;
  bool _isUserIdentified = false;
  String? _mobileNumber;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _messages.add({
      'sender': 'bot',
      'text': '👋 Hey there! Please enter your mobile number to start chatting.'
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || _isWaitingResponse) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
    });

    _controller.clear();

    if (!_isUserIdentified) {
      _verifyUser(text);
    } else {
      _getBotReply(text);
    }
  }

  void _verifyUser(String mobile) async {
    setState(() => _isWaitingResponse = true);
    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobileNumber': mobile}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isUserIdentified = true;
          _mobileNumber = mobile;
          _messages.add({
            'sender': 'bot',
            'text': '✅ You\'re done my dear user , $mobile! Now, I am waiting to chat with you.'
          });
        });
      }
      else if (response.statusCode == 400) {
        setState(() {
          _isUserIdentified = false;
          _mobileNumber = null;
          _messages.add({
            'sender': 'bot',
            'text': '❗Incorrect Mobile Number format. Please enter a valid mobile number.'
          });
        });
        }
      
       else {
        setState(() {
          _messages.add({'sender': 'bot', 'text': '❌ Failed to register. Try again!'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'bot', 'text': '🚫 Server error. Please try again later.'});
      });
    } finally {
      setState(() => _isWaitingResponse = false);
    }
  }

  void _getBotReply(String userInput) async {
    setState(() {
      _messages.add({'sender': 'bot', 'text': '...typing'});
      _isWaitingResponse = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      String reply;
      String input = userInput.toLowerCase();

      if (input.contains("hello") || input.contains("hi") || input.contains("hey") || input.contains("greetings") || input.contains("welcome")) {
        reply = "Hi there! How can I assist you today?";
      } else if (input.contains("help")) {
        reply = "Sure! I'm here to help. Please tell me your concern.";
      } else if (input.contains("thank")) {
        reply = "You're welcome! 😊";
      } else if (input.contains("bye")) {
        reply = "Goodbye! Have a great day!";
      } else {
        reply = "Hmm... I’m not sure how to respond to that yet.";
      }

      setState(() {
        _messages.removeWhere((msg) => msg['text'] == '...typing');
        _messages.add({'sender': 'bot', 'text': reply});
      });

      await _flutterTts.speak(reply);

      if (_mobileNumber != null) {
        final url = Uri.parse('http://10.0.2.2:8080/api/history/save');
        await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'mobileNumber': _mobileNumber,
            'userMessage': userInput,
            'chatResponse': reply,
          }),
        );
      }
    } catch (e) {
      setState(() {
        _messages.removeWhere((msg) => msg['text'] == '...typing');
        _messages.add({'sender': 'bot', 'text': '⚠️ Oops! Something went wrong.'});
      });
    } finally {
      setState(() => _isWaitingResponse = false);
    }
  }

  Widget _buildMessage(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[300] : Colors.deepPurple[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildChatBody() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[_messages.length - 1 - index];
              return _buildMessage(msg['text']!, msg['sender'] == 'user');
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                onPressed: _listen,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: _isUserIdentified
                        ? 'Type a message...'
                        : 'Enter your mobile number...',
                  ),
                  enabled: !_isWaitingResponse,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
                color: _isWaitingResponse ? Colors.grey : Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ChatSmart",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                  )
                ],
              ),
            ),
            Expanded(
              child: _currentIndex == 0
                  ? _buildChatBody()
                  : (_mobileNumber != null
                      ? HistoryScreen(mobileNumber: _mobileNumber!)
                      : const Center(child: Text('📱 Please enter your mobile number first'))),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
