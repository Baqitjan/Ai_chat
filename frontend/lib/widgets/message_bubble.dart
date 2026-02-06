import 'dart:math';
import 'dart:ui' as ui; // Import for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_ai_project/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Animation<double> animation;
  final Function(ChatMessage) onReply;
  final Function(ChatMessage) onShowReactionPicker;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.animation,
    required this.onReply,
    required this.onShowReactionPicker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    final alignment = isUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    final color = isUser ? theme.primaryColorLight.withOpacity(0.8) : theme.cardColor.withOpacity(0.8); // Make slightly transparent for glass effect
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black87;
    final borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(20), bottomLeft: Radius.circular(20), topRight: Radius.circular(20), bottomRight: Radius.circular(5))
        : const BorderRadius.only(
            topRight: Radius.circular(20), bottomRight: Radius.circular(20), topLeft: Radius.circular(5), bottomLeft: Radius.circular(20));

    final messageBubbleContent = GestureDetector(
      onLongPress: () => onShowReactionPicker(message),
      child: ClipRRect(
        borderRadius: borderRadius, // Apply borderRadius to ClipRRect
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Apply blur effect
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: color, // Use transparent color
              borderRadius: borderRadius,
              // Remove boxShadow here as Glassmorphism often uses subtle borders
              // boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 5, offset: const Offset(0, 3))],
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.8), // Add a subtle white border
            ),
            child: Column( 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        imageUrl: message.imageUrl!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                Text(message.text, style: TextStyle(color: textColor, fontSize: 16, height: 1.3)),
                if (message.reactions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      spacing: 4.0, 
                      runSpacing: 2.0, 
                      children: message.reactions.map((reaction) => Text(reaction, style: const TextStyle(fontSize: 12)))
                        .toList(),
                    ),
                  )
              ]
            ),
          ),
        ),
      ),
    );

    final animatedMessage = SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: alignment,
            children: [
              Flexible(
                child: messageBubbleContent,
              ),
            ],
          ),
        ),
      ),
    );

    return Slidable(
      key: ValueKey('${message.text}-${Random().nextInt(100000)}'), // Ensure unique key
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => onReply(message),
            backgroundColor: theme.primaryColor.withOpacity(0.7),
            foregroundColor: Colors.white,
            icon: Icons.reply,
            label: 'Reply',
          ),
        ],
      ),
      child: animatedMessage,
    );
  }
}
