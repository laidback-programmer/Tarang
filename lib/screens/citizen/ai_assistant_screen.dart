import 'package:flutter/material.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      "sender": "ai",
      "text":
          "Hello! I'm your Coastal Hazard Assistant. I can help you with safety information, emergency procedures, and hazard reporting. How can I assist you today?"
    }
  ];
  bool _isTyping = false;
  late AnimationController _typingController;
  late Animation<double> _typingAnimation;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _typingAnimation = CurvedAnimation(
      parent: _typingController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _typingController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    _controller.clear();
    _focusNode.unfocus();

    setState(() {
      _messages.add({"sender": "user", "text": userMessage});
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          "sender": "ai",
          "text": _getAIResponse(userMessage),
        });
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getAIResponse(String msg) {
    msg = msg.toLowerCase();
    if (msg.contains("tsunami") || msg.contains("wave")) {
      return "Tsunami safety:\n1. Move to higher ground\n2. Follow evacuation routes\n3. Do not wait if water recedes\n4. Stay away from beaches\nI can also help locate shelters.";
    } else if (msg.contains("flood") || msg.contains("water")) {
      return "Flood safety:\n• Avoid flood water\n• Evacuate if advised\n• Move to higher ground\n• Avoid downed power lines\n• Don't drink flood water";
    } else if (msg.contains("oil") || msg.contains("spill")) {
      return "Oil spill guidance:\n• Avoid the area\n• Report immediately\n• Do not clean yourself\n• Avoid fumes\n• Wash if contact occurs";
    } else if (msg.contains("help") || msg.contains("emergency")) {
      return "For emergencies, use the SOS button on the main screen. Authorities and responders will be alerted with your location.";
    } else if (msg.contains("hello") || msg.contains("hi")) {
      return "Hello! I can provide information on tsunamis, floods, oil spills, and other hazards. How can I assist you?";
    } else {
      return "I'm here for coastal hazard emergencies: tsunamis, floods, oil spills, safety procedures, and incident reporting.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: const Text("AI Assistant",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A2472),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAboutDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add({
                  "sender": "ai",
                  "text":
                      "Hello! I'm your Coastal Hazard Assistant. How can I assist you today?"
                });
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickSuggestions(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  final msg = _messages[index];
                  final isUser = msg["sender"] == "user";
                  return _buildMessageBubble(msg["text"]!, isUser);
                } else {
                  return _buildTypingIndicator();
                }
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    final suggestions = [
      "Tsunami safety?",
      "Flood procedures",
      "Report oil spill",
      "Emergency contacts"
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF0A2472).withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Questions:",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0A2472)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map(_buildSuggestionChip).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1))
          ],
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF0A2472))),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            _buildAvatar(isUser: false),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF0A2472) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Text(text,
                  style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14)),
            ),
          ),
          if (isUser) _buildAvatar(isUser: true),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Container(
      width: 32,
      height: 32,
      margin: EdgeInsets.only(left: isUser ? 8 : 0, right: isUser ? 0 : 8),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF16C79A) : const Color(0xFF0A2472),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.emergency,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildAvatar(isUser: false),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3 + i * 0.2),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: "Ask about coastal hazards...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onSubmitted: (value) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A2472),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("About AI Assistant"),
          content: const Text(
              "I'm your Coastal Hazard Assistant. I can provide information about emergency procedures, safety guidelines, and help with hazard reporting."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
