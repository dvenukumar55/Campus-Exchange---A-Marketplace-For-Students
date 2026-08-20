package com.example.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Chat
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.MarketplaceRepository
import com.example.model.Conversation
import com.example.model.Listing
import com.example.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatListScreen(
  onNavigateBack: () -> Unit,
  onOpenConversation: (Listing) -> Unit,
  modifier: Modifier = Modifier
) {
  val conversations by MarketplaceRepository.conversations.collectAsState()
  val listings by MarketplaceRepository.listings.collectAsState()

  Scaffold(
    topBar = {
      TopAppBar(
        title = {
          Text(
            text = "Campus Inquiries",
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold,
            color = CampusNavy
          )
        },
        navigationIcon = {
          IconButton(onClick = onNavigateBack) {
            Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = CampusNavy)
          }
        },
        colors = TopAppBarDefaults.topAppBarColors(containerColor = CampusSurface)
      )
    },
    modifier = modifier
  ) { innerPadding ->
    if (conversations.isEmpty()) {
      Box(
        modifier = Modifier
          .fillMaxSize()
          .padding(innerPadding),
        contentAlignment = Alignment.Center
      ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
          Icon(
            imageVector = Icons.Default.Chat,
            contentDescription = null,
            tint = CampusTextMuted,
            modifier = Modifier.size(56.dp)
          )
          Spacer(modifier = Modifier.height(12.dp))
          Text(
            text = "No active conversations yet",
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = CampusNavy
          )
          Text(
            text = "When you inquire or receive questions on your listings, chats will appear here.",
            fontSize = 13.sp,
            color = CampusTextSecondary,
            modifier = Modifier.padding(horizontal = 32.dp, vertical = 6.dp)
          )
        }
      }
    } else {
      LazyColumn(
        modifier = Modifier
          .fillMaxSize()
          .padding(innerPadding)
      ) {
        items(conversations, key = { it.conversationId }) { conv ->
          val listing = listings.find { it.listingId == conv.listingId } ?: Listing(
            listingId = conv.listingId,
            collegeId = "avih-gunthapalli",
            sellerId = conv.otherUserId,
            sellerName = conv.otherUserName,
            sellerEmail = "student@avih.edu.in",
            title = conv.listingTitle,
            description = "",
            category = "Academic/Books",
            price = conv.listingPrice,
            condition = "Good"
          )

          Card(
            shape = RoundedCornerShape(0.dp),
            colors = CardDefaults.cardColors(containerColor = CampusSurface),
            modifier = Modifier
              .fillMaxWidth()
              .clickable { onOpenConversation(listing) }
          ) {
            Row(
              verticalAlignment = Alignment.CenterVertically,
              modifier = Modifier.padding(16.dp)
            ) {
              Box(
                modifier = Modifier
                  .size(46.dp)
                  .clip(CircleShape)
                  .background(CampusBlue),
                contentAlignment = Alignment.Center
              ) {
                Text(
                  text = conv.otherUserName.take(1).uppercase(),
                  color = Color.White,
                  fontWeight = FontWeight.Bold,
                  fontSize = 18.sp
                )
              }

              Spacer(modifier = Modifier.width(12.dp))

              Column(modifier = Modifier.weight(1f)) {
                Row(
                  verticalAlignment = Alignment.CenterVertically,
                  horizontalArrangement = Arrangement.SpaceBetween,
                  modifier = Modifier.fillMaxWidth()
                ) {
                  Text(
                    text = conv.otherUserName,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = CampusNavy
                  )
                  Text(
                    text = "₹${conv.listingPrice.toInt()}",
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = CampusTeal
                  )
                }

                Text(
                  text = conv.listingTitle,
                  fontSize = 12.sp,
                  fontWeight = FontWeight.SemiBold,
                  color = CampusBlueLight,
                  maxLines = 1,
                  overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.height(2.dp))

                Text(
                  text = conv.lastMessage,
                  fontSize = 12.sp,
                  color = CampusTextSecondary,
                  maxLines = 1,
                  overflow = TextOverflow.Ellipsis
                )
              }
            }
            HorizontalDivider(color = CampusBorder)
          }
        }
      }
    }
  }
}
