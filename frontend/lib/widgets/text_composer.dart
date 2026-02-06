import 'package:flutter/material.dart';

class TextComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend; // This callback now handles clearing the controller
  final VoidCallback? onPickImage;
  final bool isLoading;

  const TextComposer({
    Key? key,
    required this.controller,
    required this.onSend,
    this.onPickImage,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          if (onPickImage != null)
            IconButton(
              icon: const Icon(Icons.image),
              color: theme.primaryColor,
              onPressed: isLoading ? null : onPickImage,
            ),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: isLoading ? null : (_) => onSend(),
              decoration: const InputDecoration.collapsed(
                hintText: 'Send a message',
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: theme.primaryColor,
            onPressed: isLoading ? null : onSend,
          ),
        ],
      ),
    );
  }
}
