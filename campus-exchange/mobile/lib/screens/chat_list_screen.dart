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
      backgroundColor: AppTheme.backgroundColor,

      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            color: AppTheme.dividerColor,
          ),
        ),
      ),

      body: chatProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
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
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount:
                      chatProvider.userConversations.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),

                  itemBuilder: (context, index) {
                    final chat =
                        chatProvider.userConversations[index];

                    final listing = listingProvider.listings
                        .cast<dynamic>()
                        .firstWhere(
                          (l) =>
                              l.listingId == chat.listingId,
                          orElse: () => null,
                        );

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.dividerColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A)
                                .withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),

                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),

                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration:
                              const BoxDecoration(
                            gradient:
                                AppTheme.heroCardGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),

                        title: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                listing?.title ??
                                    'Item #${chat.listingId.length > 8 ? chat.listingId.substring(0, 8) : chat.listingId}',
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w700,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Text(
                              DateFormat(
                                'MMM d, h:mm a',
                              ).format(
                                chat.lastMessageAt,
                              ),
                              style: const TextStyle(
                                fontSize: 11,
                                color:
                                    AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        subtitle: Padding(
                          padding:
                              const EdgeInsets.only(top: 4),
                          child: Text(
                            chat.lastMessage,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color:
                                  AppTheme.textSecondary,
                            ),
                          ),
                        ),

                        onTap: () {
                          if (listing != null) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.chat,
                              arguments: {
                                'listing': listing,
                                'listingId':
                                    listing.listingId,
                              },
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}