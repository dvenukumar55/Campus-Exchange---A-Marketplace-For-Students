package com.example.ui.screens

import androidx.compose.animation.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.R
import com.example.model.*
import com.example.ui.components.*
import com.example.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MarketplaceScreen(
  student: Student,
  listings: List<Listing>,
  onListingClick: (Listing) -> Unit,
  onCreateClick: () -> Unit,
  onOpenMetrics: () -> Unit,
  onOpenProfile: () -> Unit,
  onOpenChats: () -> Unit,
  onOpenAdmin: () -> Unit,
  modifier: Modifier = Modifier
) {
  var searchQuery by remember { mutableStateOf("") }
  var selectedCategory by remember { mutableStateOf("All") }
  var sortByPriceAsc by remember { mutableStateOf<Boolean?>(null) }

  val filteredListings = remember(listings, searchQuery, selectedCategory, sortByPriceAsc, student) {
    var result = listings.filter { it.collegeId == student.collegeId && it.status == ListingStatus.ACTIVE }

    if (selectedCategory != "All") {
      result = result.filter { it.category.equals(selectedCategory, ignoreCase = true) }
    }

    if (searchQuery.isNotBlank()) {
      val query = searchQuery.trim().lowercase()
      result = result.filter {
        it.title.lowercase().contains(query) ||
            it.description.lowercase().contains(query) ||
            it.category.lowercase().contains(query)
      }
    }

    when (sortByPriceAsc) {
      true -> result.sortedBy { it.price }
      false -> result.sortedByDescending { it.price }
      null -> result.sortedByDescending { it.createdAt }
    }
  }

  Scaffold(
    topBar = {
      TopAppBar(
        title = {
          Column {
            Text(
              text = "Campus Exchange",
              fontSize = 18.sp,
              fontWeight = FontWeight.Bold,
              color = CampusNavy
            )
            Text(
              text = "${student.collegeName.substringBefore("(").trim()} Exclusive",
              fontSize = 11.sp,
              color = CampusTeal
            )
          }
        },
        actions = {
          if (student.role == UserRole.ADMIN || student.role == UserRole.MODERATOR) {
            IconButton(
              onClick = onOpenAdmin,
              modifier = Modifier.testTag("admin_panel_topbar_button")
            ) {
              Icon(
                imageVector = Icons.Default.AdminPanelSettings,
                contentDescription = "Admin Console",
                tint = CampusAmber
              )
            }
          }
          IconButton(
            onClick = onOpenMetrics,
            modifier = Modifier.testTag("metrics_button")
          ) {
            Icon(
              imageVector = Icons.Default.Analytics,
              contentDescription = "Pilot Metrics Dashboard",
              tint = CampusBlue
            )
          }
          IconButton(
            onClick = onOpenChats,
            modifier = Modifier.testTag("chats_nav_button")
          ) {
            Icon(
              imageVector = Icons.Default.ChatBubbleOutline,
              contentDescription = "Chats",
              tint = CampusBlue
            )
          }
          IconButton(
            onClick = onOpenProfile,
            modifier = Modifier.testTag("profile_button")
          ) {
            Icon(
              imageVector = Icons.Default.AccountCircle,
              contentDescription = "Student Profile",
              tint = CampusBlue
            )
          }
        },
        colors = TopAppBarDefaults.topAppBarColors(containerColor = CampusSurface)
      )
    },
    floatingActionButton = {
      ExtendedFloatingActionButton(
        onClick = onCreateClick,
        icon = { Icon(Icons.Default.Add, contentDescription = "Add Listing") },
        text = { Text("Sell Item", fontWeight = FontWeight.Bold) },
        containerColor = CampusBlue,
        contentColor = Color.White,
        modifier = Modifier.testTag("create_listing_fab")
      )
    },
    modifier = modifier
  ) { paddingValues ->
    Column(
      modifier = Modifier
        .fillMaxSize()
        .padding(paddingValues)
    ) {
      // Search Bar
      OutlinedTextField(
        value = searchQuery,
        onValueChange = { searchQuery = it },
        placeholder = { Text("Search academic books, calculators, lab coats...", fontSize = 13.sp) },
        leadingIcon = {
          Icon(Icons.Default.Search, contentDescription = "Search", tint = CampusTextSecondary)
        },
        trailingIcon = {
          if (searchQuery.isNotEmpty()) {
            IconButton(onClick = { searchQuery = "" }) {
              Icon(Icons.Default.Clear, contentDescription = "Clear search")
            }
          }
        },
        singleLine = true,
        shape = RoundedCornerShape(12.dp),
        colors = OutlinedTextFieldDefaults.colors(
          focusedBorderColor = CampusBlue,
          unfocusedBorderColor = CampusBorder,
          focusedContainerColor = CampusSurface,
          unfocusedContainerColor = CampusSurface
        ),
        modifier = Modifier
          .fillMaxWidth()
          .padding(horizontal = 16.dp, vertical = 8.dp)
          .testTag("search_bar")
      )

      // Category filter chips
      CategoryChipsRow(
        categories = Categories.ALL,
        selectedCategory = selectedCategory,
        onSelect = { selectedCategory = it }
      )

      // Safety Notice banner
      SafetyBanner(modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp))

      // Header summary & Sort row
      Row(
        modifier = Modifier
          .fillMaxWidth()
          .padding(horizontal = 16.dp, vertical = 6.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
      ) {
        Text(
          text = "${filteredListings.size} Items Available",
          fontSize = 13.sp,
          fontWeight = FontWeight.SemiBold,
          color = CampusTextSecondary
        )

        Row(verticalAlignment = Alignment.CenterVertically) {
          Text(
            text = "Sort:",
            fontSize = 12.sp,
            color = CampusTextMuted
          )
          Spacer(modifier = Modifier.width(4.dp))
          AssistChip(
            onClick = {
              sortByPriceAsc = when (sortByPriceAsc) {
                null -> true
                true -> false
                false -> null
              }
            },
            label = {
              Text(
                text = when (sortByPriceAsc) {
                  true -> "Price: Low to High"
                  false -> "Price: High to Low"
                  null -> "Latest"
                },
                fontSize = 11.sp
              )
            },
            leadingIcon = {
              Icon(
                imageVector = Icons.Default.Sort,
                contentDescription = "Sort Icon",
                modifier = Modifier.size(14.dp)
              )
            }
          )
        }
      }

      // Listings Grid
      if (filteredListings.isEmpty()) {
        Box(
          modifier = Modifier
            .fillMaxSize()
            .padding(32.dp),
          contentAlignment = Alignment.Center
        ) {
          Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Icon(
              imageVector = Icons.Outlined.Storefront,
              contentDescription = "Empty Marketplace",
              tint = CampusTextMuted,
              modifier = Modifier.size(64.dp)
            )
            Spacer(modifier = Modifier.height(12.dp))
            Text(
              text = "No listings found",
              fontSize = 16.sp,
              fontWeight = FontWeight.Bold,
              color = CampusNavy
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
              text = "Be the first to list an academic book or essential in your college!",
              fontSize = 13.sp,
              color = CampusTextSecondary
            )
            Spacer(modifier = Modifier.height(16.dp))
            Button(
              onClick = onCreateClick,
              colors = ButtonDefaults.buttonColors(containerColor = CampusBlue)
            ) {
              Text("Post a Listing")
            }
          }
        }
      } else {
        LazyVerticalGrid(
          columns = GridCells.Fixed(2),
          contentPadding = PaddingValues(horizontal = 12.dp, vertical = 8.dp),
          horizontalArrangement = Arrangement.spacedBy(10.dp),
          verticalArrangement = Arrangement.spacedBy(12.dp),
          modifier = Modifier.fillMaxSize()
        ) {
          items(filteredListings, key = { it.listingId }) { listing ->
            MarketplaceItemCard(
              listing = listing,
              onClick = { onListingClick(listing) }
            )
          }
        }
      }
    }
  }
}

@Composable
fun MarketplaceItemCard(
  listing: Listing,
  onClick: () -> Unit,
  modifier: Modifier = Modifier
) {
  Card(
    shape = RoundedCornerShape(12.dp),
    colors = CardDefaults.cardColors(containerColor = CampusSurface),
    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    modifier = modifier
      .fillMaxWidth()
      .clickable { onClick() }
      .testTag("listing_card_${listing.listingId}")
  ) {
    Column {
      // Photo thumbnail Box
      Box(
        modifier = Modifier
          .fillMaxWidth()
          .height(130.dp)
          .background(CampusSurfaceVariant)
      ) {
        if (listing.drawableResId != null) {
          Image(
            painter = painterResource(id = listing.drawableResId),
            contentDescription = listing.title,
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
          )
        } else {
          // Placeholder with category icon
          Box(
            modifier = Modifier
              .fillMaxSize()
              .background(CampusSurfaceVariant),
            contentAlignment = Alignment.Center
          ) {
            Icon(
              imageVector = when (listing.category) {
                "Academic/Books" -> Icons.Default.MenuBook
                "Electronics" -> Icons.Default.Calculate
                "Uniforms/Lab Coats" -> Icons.Default.Checkroom
                "Stationery" -> Icons.Default.Draw
                else -> Icons.Default.Bed
              },
              contentDescription = listing.category,
              tint = CampusBlueLight,
              modifier = Modifier.size(44.dp)
            )
          }
        }

        // Condition badge overlay
        ConditionBadge(
          condition = listing.condition,
          modifier = Modifier
            .align(Alignment.TopStart)
            .padding(6.dp)
        )

        // Verified seller icon overlay
        Surface(
          color = Color(0xCC0F172A),
          shape = RoundedCornerShape(4.dp),
          modifier = Modifier
            .align(Alignment.BottomEnd)
            .padding(6.dp)
        ) {
          Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp)
          ) {
            Icon(
              imageVector = Icons.Default.VerifiedUser,
              contentDescription = "Verified student",
              tint = CampusTealLight,
              modifier = Modifier.size(10.dp)
            )
            Spacer(modifier = Modifier.width(2.dp))
            Text(
              text = "Student",
              color = Color.White,
              fontSize = 9.sp,
              fontWeight = FontWeight.Bold
            )
          }
        }
      }

      // Card Content
      Column(modifier = Modifier.padding(10.dp)) {
        Text(
          text = "₹${listing.price.toInt()}",
          fontSize = 17.sp,
          fontWeight = FontWeight.ExtraBold,
          color = CampusNavy
        )

        Spacer(modifier = Modifier.height(2.dp))

        Text(
          text = listing.title,
          fontSize = 13.sp,
          fontWeight = FontWeight.SemiBold,
          color = CampusTextPrimary,
          maxLines = 2,
          overflow = TextOverflow.Ellipsis
        )

        Spacer(modifier = Modifier.height(4.dp))

        Row(
          verticalAlignment = Alignment.CenterVertically,
          horizontalArrangement = Arrangement.SpaceBetween,
          modifier = Modifier.fillMaxWidth()
        ) {
          Text(
            text = listing.category,
            fontSize = 10.sp,
            color = CampusTextMuted,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f)
          )

          if (listing.chatCount > 0) {
            Row(verticalAlignment = Alignment.CenterVertically) {
              Icon(
                imageVector = Icons.Default.ChatBubble,
                contentDescription = "Chats",
                tint = CampusTeal,
                modifier = Modifier.size(10.dp)
              )
              Spacer(modifier = Modifier.width(2.dp))
              Text(
                text = "${listing.chatCount}",
                fontSize = 10.sp,
                color = CampusTeal,
                fontWeight = FontWeight.Bold
              )
            }
          }
        }
      }
    }
  }
}
