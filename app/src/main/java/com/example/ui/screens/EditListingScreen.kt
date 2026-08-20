package com.example.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.MarketplaceRepository
import com.example.model.Categories
import com.example.model.Listing
import com.example.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditListingScreen(
  listing: Listing,
  onNavigateBack: () -> Unit,
  onUpdated: () -> Unit,
  modifier: Modifier = Modifier
) {
  var title by remember { mutableStateOf(listing.title) }
  var price by remember { mutableStateOf(listing.price.toInt().toString()) }
  var selectedCategory by remember { mutableStateOf(listing.category) }
  var selectedCondition by remember { mutableStateOf(listing.condition) }
  var description by remember { mutableStateOf(listing.description) }
  var errorMessage by remember { mutableStateOf<String?>(null) }

  Scaffold(
    topBar = {
      TopAppBar(
        title = {
          Text(
            text = "Edit Listing",
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
    bottomBar = {
      Surface(
        color = CampusSurface,
        tonalElevation = 8.dp,
        modifier = Modifier.fillMaxWidth()
      ) {
        Column(
          modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
        ) {
          if (errorMessage != null) {
            Text(
              text = errorMessage ?: "",
              color = CampusRose,
              fontSize = 12.sp,
              modifier = Modifier.padding(bottom = 8.dp)
            )
          }

          Button(
            onClick = {
              val parsedPrice = price.toDoubleOrNull()
              if (parsedPrice == null || parsedPrice <= 0) {
                errorMessage = "Valid price required"
                return@Button
              }
              if (title.trim().length < 3) {
                errorMessage = "Title must be >= 3 characters"
                return@Button
              }

              val res = MarketplaceRepository.updateListing(
                listingId = listing.listingId,
                title = title,
                price = parsedPrice,
                condition = selectedCondition,
                category = selectedCategory,
                description = description
              )
              if (res.isSuccess) {
                onUpdated()
              } else {
                errorMessage = res.exceptionOrNull()?.message
              }
            },
            colors = ButtonDefaults.buttonColors(containerColor = CampusBlue),
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier
              .fillMaxWidth()
              .height(50.dp)
              .testTag("save_edits_button")
          ) {
            Text("Save Changes", fontWeight = FontWeight.Bold)
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
        .padding(16.dp),
      verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
      OutlinedTextField(
        value = title,
        onValueChange = { title = it },
        label = { Text("Title") },
        modifier = Modifier.fillMaxWidth()
      )

      OutlinedTextField(
        value = price,
        onValueChange = { price = it.filter { c -> c.isDigit() || c == '.' } },
        label = { Text("Price (₹)") },
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
        modifier = Modifier.fillMaxWidth()
      )

      Text("Condition", fontWeight = FontWeight.Bold, fontSize = 14.sp)
      Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        listOf("New", "Like New", "Good", "Fair").forEach { condition ->
          FilterChip(
            selected = selectedCondition.equals(condition, ignoreCase = true),
            onClick = { selectedCondition = condition },
            label = { Text(condition) }
          )
        }
      }

      OutlinedTextField(
        value = description,
        onValueChange = { description = it },
        label = { Text("Description") },
        minLines = 4,
        modifier = Modifier.fillMaxWidth()
      )
    }
  }
}
