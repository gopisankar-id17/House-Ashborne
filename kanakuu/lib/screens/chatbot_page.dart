import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

 
  static const String GRANITE_API_KEY = 'AIzaSyCQCqu0LbjPAdGyoffCuBuHo0yORIZLqV8'; // Replace with your actual API key
  static const String GRANITE_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  static const Duration API_TIMEOUT = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _addMessage(ChatMessage(
      text: "Hello! I'm your AI financial assistant powered by Granite model. How can I help you manage your finances today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Check if API key is configured
    if (GRANITE_API_KEY == 'YOUR_GRANITE_API_KEY_HERE') {
      _addMessage(ChatMessage(
        text: "Please configure your Granite API key first. Go to Settings to add your API key.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
      return;
    }

    // Add user message
    _addMessage(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _messageController.clear();

    // Show typing indicator
    setState(() {
      _isTyping = true;
    });

    try {
      print('🎯 Starting Granite API call for message: $text');
      
      // Make API call to Granite
      final response = await _callGraniteAPI(text);
      
      print('✅ Got Granite API response: $response');
      
      // Hide typing indicator
      setState(() {
        _isTyping = false;
      });

      // Add bot response
      _addMessage(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      print('❌ Granite API call failed with error: $e');
      
      // Hide typing indicator
      setState(() {
        _isTyping = false;
      });

      // Add error message with fallback
      _addMessage(ChatMessage(
        text: _generateFallbackResponse(text),
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<String> _callGraniteAPI(String userMessage) async {
    try {
      final url = Uri.parse('$GRANITE_API_URL?key=$GRANITE_API_KEY');
      
      print('🚀 Making Granite API call to: $url');
      
      // Create financial assistant context
      final systemPrompt = '''You are a helpful financial assistant. Your role is to:
- Provide practical financial advice
- Help with budgeting and expense tracking
- Suggest saving strategies
- Answer questions about personal finance
- Be encouraging and supportive
- Keep responses concise and actionable

User question: $userMessage''';

      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text": systemPrompt
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 1024,
        }
      };

      print('📤 Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(API_TIMEOUT);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          
          final responseText = data['candidates'][0]['content']['parts'][0]['text'];
          return responseText.toString();
        } else {
          throw Exception('Invalid response format from Granite API');
        }
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception('Bad request: ${errorData['error']['message'] ?? 'Invalid request'}');
      } else if (response.statusCode == 403) {
        throw Exception('API key invalid or quota exceeded. Please check your Granite API key.');
      } else {
        throw Exception('API request failed with status: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      throw Exception('Request timeout. Please check your internet connection.');
    } on http.ClientException catch (e) {
      throw Exception('Network error: Please check your internet connection.');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Fallback method for when API is unavailable
  String _generateFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('budget') || message.contains('budgets')) {
      return "I can help you with budgeting! Here are some key tips:\n\n• Track your income and expenses\n• Use the 50/30/20 rule (needs/wants/savings)\n• Set realistic spending limits\n• Review and adjust monthly\n\nWould you like specific budgeting strategies?";
    } else if (message.contains('expense') || message.contains('spending')) {
      return "For better expense management:\n\n• Categorize your spending\n• Track daily expenses\n• Identify unnecessary purchases\n• Use apps or spreadsheets for tracking\n• Review weekly patterns\n\nWhat specific area of spending would you like to focus on?";
    } else if (message.contains('save') || message.contains('saving')) {
      return "Here are effective saving strategies:\n\n• Start with small, achievable goals\n• Automate your savings\n• Cut unnecessary subscriptions\n• Cook at home more often\n• Use the 24-hour rule for purchases\n\nWhat's your current savings goal?";
    } else if (message.contains('debt') || message.contains('loan')) {
      return "For debt management:\n\n• List all debts with interest rates\n• Consider debt snowball or avalanche method\n• Pay more than minimums when possible\n• Avoid taking on new debt\n• Consider debt consolidation if beneficial\n\nWhat type of debt are you dealing with?";
    } else if (message.contains('invest') || message.contains('investment')) {
      return "Investment basics to consider:\n\n• Start with emergency fund first\n• Understand your risk tolerance\n• Diversify your portfolio\n• Consider low-cost index funds\n• Think long-term\n\nConsult with a financial advisor for personalized advice. What's your investment timeline?";
    } else {
      return "I'm here to help with your financial questions! I can assist with:\n\n• Budgeting and expense tracking\n• Saving strategies\n• Debt management\n• Basic investment guidance\n• Financial goal setting\n\nNote: I'm currently having connectivity issues, but I can still provide general financial guidance. What specific area would you like to explore?";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F2232),
      appBar: AppBar(
        backgroundColor: Color(0xFF2A2D3A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFFF6B35),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome, 
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Granite Financial Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isTyping ? 'Thinking...' : 'Powered by Granite',
                  style: TextStyle(
                    color: _isTyping ? Colors.orange : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            color: Color(0xFF2A2D3A),
            onSelected: (value) {
              if (value == 'clear') {
                _clearChat();
              } else if (value == 'settings') {
                _showAPISettings();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.white70, size: 16),
                    SizedBox(width: 8),
                    Text('Clear Chat', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.white70, size: 16),
                    SizedBox(width: 8),
                    Text('API Settings', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status indicator
          if (_isTyping)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 4),
              color: Colors.orange.withOpacity(0.2),
              child: Text(
                'AI is thinking...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),
          
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          
          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFFFF6B35),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome, 
                color: Colors.white,
                size: 18,
              ),
            ),
            SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Color(0xFFFF6B35) : Color(0xFF2A2D3A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: message.isUser ? Radius.circular(18) : Radius.circular(4),
                  bottomRight: message.isUser ? Radius.circular(4) : Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (message.isUser) ...[
            SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFF4A90E2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(0xFFFF6B35),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 18,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                SizedBox(width: 4),
                _buildTypingDot(1),
                SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -4 * value),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1F2232),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ask me anything about finance...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  maxLines: null,
                  enabled: !_isTyping,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: _isTyping ? Colors.grey : Color(0xFFFF6B35),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isTyping ? null : _sendMessage,
                icon: Icon(
                  _isTyping ? Icons.hourglass_empty : Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2D3A),
        title: Text(
          'Clear Chat',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to clear all chat messages?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _addMessage(ChatMessage(
                  text: "Hello! I'm your AI financial assistant powered by Granite model. How can I help you manage your finances today?",
                  isUser: false,
                  timestamp: DateTime.now(),
                ));
              });
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Color(0xFFFF6B35)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAPISettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2D3A),
        title: Text(
          'Granite API Configuration',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Status:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              GRANITE_API_KEY == 'YOUR_GRANITE_API_KEY_HERE' ? 'Not Configured' : 'Configured',
              style: TextStyle(
                color: GRANITE_API_KEY == 'YOUR_GRANITE_API_KEY_HERE' ? Colors.red : Colors.green,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Setup Instructions:',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              '1. Get Granite API key from AI Studio\n2. Replace "YOUR_GRANITE_API_KEY_HERE" in code\n3. Rebuild the app',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            SizedBox(height: 8),
            Text(
              'Website: granite.ai',
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: Color(0xFFFF6B35)),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}