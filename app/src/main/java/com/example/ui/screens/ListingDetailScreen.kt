package com.example.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.model.*
import com.example.ui.components.*
import com.example.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ListingDetailScreen(
  listing: Listing,
  currentStudent: Student,
  onNavigateBack: () -> Unit,
  onOpenChat: (Listing) -> Unit,
  onEditListing: (Listing) -> Unit,
  onMarkSold: (Listing) -> Unit,
  onCloseListing: (Listing) -> Unit,
  onReportClick: (Listing) -> Unit,
  modifier: Modifier = Modifier
) {
  val isMyListing = listing.sellerId == currentStudent.studentId

  Scaffold(
    topBar = {
      TopAppBar(
        title = { Text(text = "Listing Details", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = CampusNavy) },
        navigationIcon = {
          IconButton(onClick = onNavigateBack) {
            Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = CampusNavy)
          }
        },
        actions = {
          if (!isMyListing) {
            IconButton(
              onClick = { onReportClick(listing) },
              modifier = Modifier.testTag("report_button")
            ) {
              Icon(Icons.Outlined.Flag, contentDescription = "Report Listing", tint = CampusRose)
            }
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
        Row(
          modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
          horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
          if (isMyListing) {
            if (listing.status == ListingStatus.ACTIVE) {
              OutlinedButton(
                onClick = { onEditListing(listing) },
                modifier = Modifier
                  .weight(1f)
                  .height(48.dp)
                  .testTag("edit_listing_button"),
                shape = RoundedCornerShape(10.dp)
              ) {
                Icon(Icons.Default.Edit, contentDescription = null, modifier = Modifier.size(16.dp))
                Spacer(modifier = Modifier.width(6.dp))
                Text("Edit Details")
              }

              Button(
                onClick = { onMarkSold(listing) },
                colors = ButtonDefaults.buttonColors(containerColor = CampusTeal),
                modifier = Modifier
                  .weight(1.2f)
                  .height(48.dp)
                  .testTag("mark_sold_button"),
                shape = RoundedCornerShape(10.dp)
              ) {
                Icon(Icons.Default.CheckCircle, contentDescription = null, modifier = Modifier.size(16.dp))
                Spacer(modifier = Modifier.width(6.dp))
                Text("Mark as Sold", fontWeight = FontWeight.Bold)
              }
            } else {
              OutlinedButton(
                onClick = { onCloseListing(listing) },
                modifier = Modifier
                  .fillMaxWidth()
                  .height(48.dp),
                shape = RoundedCornerShape(10.dp)
              ) {
                Text("Listing is ${listing.status.name}")
              }
            }
          } else {
            // Buyer CTAs
            Button(
              onClick = { onOpenChat(listing) },
              colors = ButtonDefaults.buttonColors(containerColor = CampusBlue),
              modifier = Modifier
                .fillMaxWidth()
                .height(50.dp)
                .testTag("chat_seller_button"),
              shape = RoundedCornerShape(12.dp)
            ) {
              Icon(Icons.Default.ChatBubbleOutline, contentDescription = null, modifier = Modifier.size(18.dp))
              Spacer(modifier = Modifier.width(8.dp))
              Text("Chat with Seller on Campus", fontSize = 15.sp, fontWeight = FontWeight.Bold)
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
        .verticalScroll(rememberScrollState())
    ) {
      // Photo Header
      Box(
        modifier = Modifier
          .fillMaxWidth()
          .height(260.dp)
          .background(CampusSurfaceVariant)
      ) {
        if (listing.drawableResId != null) {
          Image(
            painter = painterResource(id = listing.drawableResId),
            contentDescription = listing.title,
            contentScale = ContentScale.Fit,
            modifier = Modifier.fillMaxSize()
          )
        } else {
          Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
          ) {
            Icon(
              imageVector = Icons.Default.MenuBook,
              contentDescription = "Default item icon",
              tint = CampusBlueLight,
              modifier = Modifier.size(80.dp)
            )
          }
        }

        // Status & Condition Overlay
        Row(
          modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
            .align(Alignment.TopStart),
          horizontalArrangement = Arrangement.SpaceBetween
        ) {
          ConditionBadge(condition = listing.condition)
          StatusBadge(status = listing.status)
        }
      }

      // Details Body
      Column(
        modifier = Modifier
          .fillMaxWidth()
          .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
      ) {
        // Price & Category
        Row(
          verticalAlignment = Alignment.CenterVertically,
          horizontalArrangement = Arrangement.SpaceBetween,
          modifier = Modifier.fillMaxWidth()
        ) {
          Text(
            text = "₹${listing.price.toInt()}",
            fontSize = 28.sp,
            fontWeight = FontWeight.ExtraBold,
            color = CampusNavy
          )

          AssistChip(
            onClick = {},
            label = { Text(listing.category, fontSize = 12.sp, fontWeight = FontWeight.SemiBold) },
            leadingIcon = {
              Icon(Icons.Default.Category, contentDescription = null, modifier = Modifier.size(14.dp))
            }
          )
        }

        // Title
        Text(
          text = listing.title,
          fontSize = 20.sp,
          fontWeight = FontWeight.Bold,
          color = CampusTextPrimary
        )

        HorizontalDivider(color = CampusBorder)

        // Verified Seller Card
        Card(
          shape = RoundedCornerShape(12.dp),
          colors = CardDefaults.cardColors(containerColor = CampusSurfaceVariant),
          modifier = Modifier.fillMaxWidth()
        ) {
          Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(14.dp)
          ) {
            Box(
              modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .background(CampusBlue),
              contentAlignment = Alignment.Center
            ) {
              Text(
                text = listing.sellerName.take(1).uppercase(),
                color = Color.White,
                fontWeight = FontWeight.Bold,
                fontSize = 18.sp
              )
            }

            Spacer(modifier = Modifier.width(12.dp))

            Column(modifier = Modifier.weight(1f)) {
              Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                  text = listing.sellerName,
                  fontWeight = FontWeight.Bold,
                  fontSize = 15.sp,
                  color = CampusNavy
                )
                Spacer(modifier = Modifier.width(4.dp))
                Icon(
                  imageVector = Icons.Default.Verified,
                  contentDescription = "Verified College Student",
                  tint = CampusTeal,
                  modifier = Modifier.size(16.dp)
                )
              }
              Text(
                text = "${listing.sellerEmail} • ${currentStudent.collegeName.substringBefore("(").trim()}",
                fontSize = 11.sp,
                color = CampusTextSecondary
              )
            }
          }
        }

        // Description Section
        Text(
          text = "Item Description",
          fontSize = 16.sp,
          fontWeight = FontWeight.Bold,
          color = CampusNavy
        )

        Text(
          text = listing.description,
          fontSize = 14.sp,
          color = CampusTextPrimary,
          lineHeight = 22.sp
        )

        // Safety rules callout
        SafetyBanner()
      }
    }
  }
}
