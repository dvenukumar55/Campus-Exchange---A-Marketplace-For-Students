import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/empty_state_view.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: const EmptyStateView(
        title: 'No Messages Yet',
        message: 'You have not started any conversations yet. When you contact a seller or a buyer contacts you, messages will appear here.',
        icon: Icons.chat_bubble_outline_rounded,
      ),
    );
  }
}
