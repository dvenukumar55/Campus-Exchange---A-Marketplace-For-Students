import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/listing.dart';
import '../providers/chat_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/empty_state_view.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).fetchUserConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Messages'),
      ),
      body: chatProvider.isLoading && chatProvider.userConversations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : chatProvider.userConversations.isEmpty
              ? const EmptyStateView(
                  title: 'No Conversations',
                  message: 'When you message a seller or buyers message your listings, chats will appear here.',
                  icon: Icons.forum_outlined,
                )
              : ListView.separated(
                  itemCount: chatProvider.userConversations.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final conv = chatProvider.userConversations[index];
                    final dateStr = DateFormat.MMMd().format(conv.lastMessageAt);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: const Icon(Icons.school, color: AppTheme.primaryColor),
                      ),
                      title: Text(
                        conv.listingTitle ?? 'Item Listing',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        conv.lastMessage.isNotEmpty ? conv.lastMessage : 'No messages yet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(dateStr, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          if (conv.listingPrice != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '₹${conv.listingPrice!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                      onTap: () {
                        // Dummy listing context for route transition
                        final listing = Listing(
                          listingId: conv.listingId,
                          collegeId: conv.collegeId,
                          sellerId: conv.sellerId,
                          sellerName: 'Campus Peer',
                          title: conv.listingTitle ?? 'Item Chat',
                          description: 'Chat context',
                          category: 'Academic',
                          price: conv.listingPrice ?? 0,
                          condition: 'Good',
                          photoRefs: const ['chat_item.jpg'],
                          status: conv.listingStatus ?? 'active',
                          createdAt: conv.lastMessageAt,
                        );

                        Navigator.pushNamed(context, AppRoutes.chat, arguments: {'listing': listing});
                      },
                    );
                  },
                ),
    );
  }
}
