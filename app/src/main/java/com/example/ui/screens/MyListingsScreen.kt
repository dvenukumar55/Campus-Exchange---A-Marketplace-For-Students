package com.example.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.MarketplaceRepository
import com.example.model.Listing
import com.example.model.ListingStatus
import com.example.model.Student
import com.example.ui.components.ConditionBadge
import com.example.ui.components.StatusBadge
import com.example.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MyListingsScreen(
  currentStudent: Student,
  onNavigateBack: () -> Unit,
  onEditListing: (Listing) -> Unit,
  onOpenListing: (Listing) -> Unit,
  modifier: Modifier = Modifier
) {
  val allListings by MarketplaceRepository.listings.collectAsState()
  val myListings = remember(allListings, currentStudent) {
    allListings.filter { it.sellerId == currentStudent.studentId }
  }

  var selectedTab by remember { mutableStateOf(0) }
  val tabs = listOf("Active", "Sold", "Closed")

  val displayedListings = remember(myListings, selectedTab) {
    when (selectedTab) {
      0 -> myListings.filter { it.status == ListingStatus.ACTIVE }
      1 -> myListings.filter { it.status == ListingStatus.SOLD }
      else -> myListings.filter { it.status == ListingStatus.CLOSED }
    }
  }

  Scaffold(
    topBar = {
      TopAppBar(
        title = {
          Text(
            text = "My Posted Items",
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
    Column(
      modifier = Modifier
        .fillMaxSize()
        .padding(innerPadding)
    ) {
      TabRow(
        selectedTabIndex = selectedTab,
        containerColor = CampusSurface,
        contentColor = CampusBlue
      ) {
        tabs.forEachIndexed { index, title ->
          Tab(
            selected = selectedTab == index,
            onClick = { selectedTab = index },
            text = {
              Text(
                text = "$title (${myListings.count {
                  when (index) {
                    0 -> it.status == ListingStatus.ACTIVE
                    1 -> it.status == ListingStatus.SOLD
                    else -> it.status == ListingStatus.CLOSED
                  }
                }})",
                fontWeight = if (selectedTab == index) FontWeight.Bold else FontWeight.Normal,
                fontSize = 13.sp
              )
            }
          )
        }
      }

      if (displayedListings.isEmpty()) {
        Box(
          modifier = Modifier
            .fillMaxSize()
            .padding(32.dp),
          contentAlignment = Alignment.Center
        ) {
          Text(
            text = "No ${tabs[selectedTab].lowercase()} items in your history.",
            color = CampusTextSecondary,
            fontSize = 14.sp
          )
        }
      } else {
        LazyColumn(
          contentPadding = PaddingValues(16.dp),
          verticalArrangement = Arrangement.spacedBy(12.dp),
          modifier = Modifier.fillMaxSize()
        ) {
          items(displayedListings, key = { it.listingId }) { listing ->
            Card(
              shape = RoundedCornerShape(12.dp),
              colors = CardDefaults.cardColors(containerColor = CampusSurface),
              elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
              modifier = Modifier
                .fillMaxWidth()
                .clickable { onOpenListing(listing) }
                .testTag("my_listing_${listing.listingId}")
            ) {
              Column(modifier = Modifier.padding(14.dp)) {
                Row(
                  verticalAlignment = Alignment.CenterVertically,
                  horizontalArrangement = Arrangement.SpaceBetween,
                  modifier = Modifier.fillMaxWidth()
                ) {
                  Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                      text = "₹${listing.price.toInt()}",
                      fontSize = 18.sp,
                      fontWeight = FontWeight.ExtraBold,
                      color = CampusNavy
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    ConditionBadge(condition = listing.condition)
                  }
                  StatusBadge(status = listing.status)
                }

                Spacer(modifier = Modifier.height(6.dp))

                Text(
                  text = listing.title,
                  fontSize = 15.sp,
                  fontWeight = FontWeight.SemiBold,
                  color = CampusTextPrimary
                )

                Text(
                  text = "${listing.category} • ${listing.viewCount} views • ${listing.chatCount} chats",
                  fontSize = 12.sp,
                  color = CampusTextMuted,
                  modifier = Modifier.padding(vertical = 4.dp)
                )

                HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp), color = CampusBorder)

                Row(
                  horizontalArrangement = Arrangement.End,
                  modifier = Modifier.fillMaxWidth()
                ) {
                  if (listing.status == ListingStatus.ACTIVE) {
                    OutlinedButton(
                      onClick = { onEditListing(listing) },
                      shape = RoundedCornerShape(8.dp),
                      modifier = Modifier.padding(end = 8.dp)
                    ) {
                      Text("Edit", fontSize = 12.sp)
                    }

                    Button(
                      onClick = {
                        MarketplaceRepository.updateListingStatus(listing.listingId, ListingStatus.SOLD)
                      },
                      colors = ButtonDefaults.buttonColors(containerColor = CampusTeal),
                      shape = RoundedCornerShape(8.dp),
                      modifier = Modifier.testTag("mark_sold_${listing.listingId}")
                    ) {
                      Text("Mark Sold", fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }
                  } else if (listing.status == ListingStatus.SOLD) {
                    OutlinedButton(
                      onClick = {
                        MarketplaceRepository.updateListingStatus(listing.listingId, ListingStatus.ACTIVE)
                      },
                      shape = RoundedCornerShape(8.dp)
                    ) {
                      Text("Reactivate", fontSize = 12.sp)
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
