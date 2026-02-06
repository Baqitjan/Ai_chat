import 'dart:async';
import 'package:chat_ai_project/api/chat_api.dart';
import 'package:chat_ai_project/models/chat_message.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<ChatMessage> _messages = [];
  final List<List<ChatMessage>> _history = [];
  bool _isLoading = false;
  ChatMessage? _replyingTo;

  void _replyToMessage(ChatMessage message) {
    setState(() {
      _replyingTo = message;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();

    if (_replyingTo != null) {
      _cancelReply();
    }

    final userMessage = ChatMessage(text: text, isUser: true);
    _addMessage(userMessage);

    final aiMessage = ChatMessage(text: "", isUser: false);
    _addMessage(aiMessage);
    setState(() => _isLoading = true);

    StreamSubscription? subscription;
    try {
      final stream = ChatApi.sendMessage(text);
      subscription = stream.listen((chunk) {
        setState(() {
          aiMessage.text += chunk;
        });
      }, onDone: () {
        setState(() => _isLoading = false);
      }, onError: (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _addMessage(ChatMessage message) {
    _messages.insert(0, message);
    _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 400));
  }

  void _startNewChat() {
    if (_messages.isNotEmpty) {
      setState(() {
        _history.insert(0, List.from(_messages));
        for (var i = 0; i < _messages.length; i++) {
          _listKey.currentState?.removeItem(
            0,
            (context, animation) => _buildMessage(_messages[i], animation),
            duration: const Duration(milliseconds: 300),
          );
        }
        _messages.clear();
      });
    }
  }

  void _loadChat(int index) {
    _startNewChat();
    setState(() {
      final loadedMessages = _history[index];
      for (var msg in loadedMessages.reversed) {
        _addMessage(msg);
      }
      _history.removeAt(index);
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat AI'),
        elevation: 1,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildHistoryDrawer(),
      body: Column(
        children: [
          Expanded(
            child: AnimatedList(
              key: _listKey,
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              initialItemCount: _messages.length,
              itemBuilder: (context, index, animation) {
                return _buildMessage(_messages[index], animation);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(),
            ),
          _buildReplyPreview(),
          const Divider(height: 1.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    if (_replyingTo == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      color: theme.primaryColor.withAlpha(26),
      child: Row(
        children: [
          Icon(Icons.reply, size: 20, color: theme.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Replying to: "${_replyingTo!.text}"',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.textTheme.bodySmall?.color, fontStyle: FontStyle.italic),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _cancelReply,
          )
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message, Animation<double> animation) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    final alignment = isUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    final color = isUser ? theme.primaryColorLight : theme.cardColor;
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black87;
    final borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(20), bottomLeft: Radius.circular(20), topRight: Radius.circular(20), bottomRight: Radius.circular(5))
        : const BorderRadius.only(
            topRight: Radius.circular(20), bottomRight: Radius.circular(20), topLeft: Radius.circular(5), bottomLeft: Radius.circular(20));

    final messageBubble = SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: alignment,
            children: [
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: borderRadius,
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 5, offset: const Offset(0, 3))],
                  ),
                  child: Text(message.text, style: TextStyle(color: textColor, fontSize: 16, height: 1.3)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    return messageBubble;
  }

  Widget _buildTextComposer() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(color: theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _isLoading ? null : _handleSubmitted,
              decoration: const InputDecoration.collapsed(hintText: 'Send a message'),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: theme.primaryColor,
            onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }

  Drawer _buildHistoryDrawer() {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 120,
            width: double.infinity,
            child: DrawerHeader(
              decoration: BoxDecoration(color: theme.primaryColor),
              child: const Text('Chat History', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_comment_outlined),
            title: const Text('New Chat', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              _startNewChat();
              Navigator.of(context).pop();
            },
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final chat = _history[index];
                if (chat.isEmpty) return const SizedBox.shrink();
                return ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(
                    chat.firstWhere((m) => m.isUser, orElse: () => chat.first).text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  onTap: () => _loadChat(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
