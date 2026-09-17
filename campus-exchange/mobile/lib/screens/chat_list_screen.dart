import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';
import '../providers/listing_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/empty_state_view.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(
        context,
        listen: false,
      ).fetchUserConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    final listingProvider = Provider.of<ListingProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B1128),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1128),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Messages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 1),
            Text(
              'Your campus conversations',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.forum_rounded,
              size: 19,
              color: Color(0xFF818CF8),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      body: chatProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF60A5FA),
              ),
            )
          : chatProvider.userConversations.isEmpty
              ? EmptyStateView(
                  title: 'No Conversations Yet',
                  message:
                      'Your active chats regarding campus listings will appear here. Find an item in the marketplace and chat with the seller to coordinate pickup!',
                  icon: Icons.chat_bubble_outline_rounded,
                  actionLabel: 'Browse Marketplace',
                  onAction: () => Navigator.pop(context),
                )
              : RefreshIndicator(
                  color: const Color(0xFF60A5FA),
                  backgroundColor: const Color(0xFF111936),
                  onRefresh: () async {
                    await chatProvider.fetchUserConversations();
                  },
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 750),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                        itemCount: chatProvider.userConversations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final chat = chatProvider.userConversations[index];

                          final listing =
                              listingProvider.listings.cast<dynamic>().firstWhere(
                                    (l) => l.listingId == chat.listingId,
                                    orElse: () => null,
                                  );

                          return _buildConversationCard(
                            context,
                            chat,
                            listing,
                          );
                        },
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildConversationCard(
    BuildContext context,
    dynamic chat,
    dynamic listing,
  ) {
    final hasListing = listing != null;

    final listingTitle = hasListing
        ? listing.title
        : 'Item #${chat.listingId.length > 8 ? chat.listingId.substring(0, 8) : chat.listingId}';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (listing != null) {
            Navigator.pushNamed(
              context,
              AppRoutes.chat,
              arguments: {
                'listing': listing,
                'listingId': listing.listingId,
              },
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111936),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            listingTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatChatTime(chat.lastMessageAt),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFFCBD5E1),
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            size: 17,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: hasListing
                                ? const Color(0x2B6366F1)
                                : const Color(0x2BF97316),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: hasListing
                                  ? const Color(0x596366F1)
                                  : const Color(0x59F97316),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasListing
                                    ? Icons.inventory_2_outlined
                                    : Icons.link_off_rounded,
                                size: 11,
                                color: hasListing
                                    ? const Color(0xFF818CF8)
                                    : const Color(0xFFFB923C),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hasListing ? 'Listing' : 'Listing unavailable',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: hasListing
                                      ? const Color(0xFFA5B4FC)
                                      : const Color(0xFFFDBA74),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: AppTheme.buttonGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }

  String _formatChatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d';
    }

    return DateFormat('MMM d').format(date);
  }
}
