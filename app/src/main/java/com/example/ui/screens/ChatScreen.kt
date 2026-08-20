package com.example.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.MarketplaceRepository
import com.example.model.ChatMessage
import com.example.model.Listing
import com.example.model.Student
import com.example.ui.theme.*
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatScreen(
  listing: Listing,
  currentStudent: Student,
  onNavigateBack: () -> Unit,
  modifier: Modifier = Modifier
) {
  val isSeller = listing.sellerId == currentStudent.studentId
  val recipientId = if (isSeller) "std_buyer_campus" else listing.sellerId
  val recipientName = if (isSeller) "Verified Student (Buyer)" else listing.sellerName

  val allMessagesMap by MarketplaceRepository.messages.collectAsState()
  val convId = "conv_${listing.listingId}_${currentStudent.studentId}"
  val messages = allMessagesMap[convId] ?: (allMessagesMap["conv_java_001"] ?: emptyList())

  var messageText by remember { mutableStateOf("") }
  val listState = rememberLazyListState()
  val coroutineScope = rememberCoroutineScope()

  LaunchedEffect(messages.size) {
    if (messages.isNotEmpty()) {
      listState.animateScrollToItem(messages.size - 1)
    }
  }

  Scaffold(
    topBar = {
      TopAppBar(
        title = {
          Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
              modifier = Modifier
                .size(36.dp)
                .clip(CircleShape)
                .background(CampusBlueLight),
              contentAlignment = Alignment.Center
            ) {
              Text(
                text = recipientName.take(1).uppercase(),
                color = Color.White,
                fontWeight = FontWeight.Bold,
                fontSize = 15.sp
              )
            }
            Spacer(modifier = Modifier.width(10.dp))
            Column {
              Text(
                text = recipientName,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = CampusNavy
              )
              Text(
                text = "${listing.title} • ₹${listing.price.toInt()}",
                fontSize = 11.sp,
                color = CampusTeal
              )
            }
          }
        },
        navigationIcon = {
          IconButton(onClick = onNavigateBack) {
            Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = CampusNavy)
          }
        },
        colors = TopAppBarDefaults.topAppBarColors(containerColor = CampusSurface)
      )
    },
    bottomBar = {
      Surface(
        color = CampusSurface,
        tonalElevation = 8.dp,
        modifier = Modifier.fillMaxWidth()
      ) {
        Column(modifier = Modifier.padding(8.dp)) {
          // Quick prompt chips
          Row(
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            modifier = Modifier
              .fillMaxWidth()
              .padding(bottom = 6.dp)
          ) {
            listOf("Is this still available?", "Can we meet at Central Library?", "Are you on campus now?").forEach { quickText ->
              SuggestionChip(
                onClick = { messageText = quickText },
                label = { Text(quickText, fontSize = 11.sp) }
              )
            }
          }

          // Input field row
          Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.fillMaxWidth()
          ) {
            OutlinedTextField(
              value = messageText,
              onValueChange = { messageText = it },
              placeholder = { Text("Type message to agree on campus meetup...", fontSize = 13.sp) },
              shape = RoundedCornerShape(24.dp),
              colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = CampusBlue,
                unfocusedBorderColor = CampusBorder
              ),
              modifier = Modifier
                .weight(1f)
                .testTag("chat_input_field")
            )

            Spacer(modifier = Modifier.width(8.dp))

            IconButton(
              onClick = {
                if (messageText.isNotBlank()) {
                  MarketplaceRepository.sendMessage(
                    listingId = listing.listingId,
                    recipientId = recipientId,
                    recipientName = recipientName,
                    text = messageText.trim()
                  )
                  messageText = ""
                }
              },
              modifier = Modifier
                .size(48.dp)
                .clip(CircleShape)
                .background(CampusBlue)
                .testTag("send_chat_button")
            ) {
              Icon(
                imageVector = Icons.AutoMirrored.Filled.Send,
                contentDescription = "Send Message",
                tint = Color.White,
                modifier = Modifier.size(20.dp)
              )
            }
          }
        }
      }
    },
    modifier = modifier
  ) { innerPadding ->
    Column(
      modifier = Modifier
        .fillMaxSize()
        .padding(innerPadding)
        .background(CampusBackground)
    ) {
      // Trust & Safety Notice
      Surface(
        color = Color(0xFFFEF3C7),
        modifier = Modifier.fillMaxWidth()
      ) {
        Row(
          verticalAlignment = Alignment.CenterVertically,
          modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp)
        ) {
          Icon(
            imageVector = Icons.Default.Lock,
            contentDescription = "Safe Exchange",
            tint = CampusAmber,
            modifier = Modifier.size(14.dp)
          )
          Spacer(modifier = Modifier.width(6.dp))
          Text(
            text = "Campus Safety: Handover in person inside college premises.",
            fontSize = 11.sp,
            color = Color(0xFF92400E),
            fontWeight = FontWeight.Medium
          )
        }
      }

      // Messages list
      LazyColumn(
        state = listState,
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp),
        modifier = Modifier.fillMaxSize()
      ) {
        items(messages, key = { it.messageId }) { msg ->
          ChatBubble(message = msg, isFromMe = msg.isFromMe)
        }
      }
    }
  }
}

@Composable
fun ChatBubble(message: ChatMessage, isFromMe: Boolean, modifier: Modifier = Modifier) {
  val timeFormat = remember { SimpleDateFormat("hh:mm a", Locale.getDefault()) }
  val formattedTime = remember(message.timestamp) { timeFormat.format(Date(message.timestamp)) }

  Column(
    horizontalAlignment = if (isFromMe) Alignment.End else Alignment.Start,
    modifier = modifier.fillMaxWidth()
  ) {
    Surface(
      color = if (isFromMe) CampusBlue else CampusSurface,
      shape = RoundedCornerShape(
        topStart = 16.dp,
        topEnd = 16.dp,
        bottomStart = if (isFromMe) 16.dp else 4.dp,
        bottomEnd = if (isFromMe) 4.dp else 16.dp
      ),
      tonalElevation = if (isFromMe) 0.dp else 1.dp,
      modifier = Modifier.widthIn(max = 280.dp)
    ) {
      Column(modifier = Modifier.padding(12.dp)) {
        Text(
          text = message.content,
          color = if (isFromMe) Color.White else CampusTextPrimary,
          fontSize = 14.sp,
          lineHeight = 20.sp
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
          text = formattedTime,
          color = if (isFromMe) Color(0xFF93C5FD) else CampusTextMuted,
          fontSize = 10.sp,
          modifier = Modifier.align(Alignment.End)
        )
      }
    }
  }
}
