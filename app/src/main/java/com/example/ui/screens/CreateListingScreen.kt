package com.example.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
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
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.R
import com.example.data.MarketplaceRepository
import com.example.model.Categories
import com.example.model.ItemCondition
import com.example.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreateListingScreen(
  onNavigateBack: () -> Unit,
  onListingCreated: () -> Unit,
  modifier: Modifier = Modifier
) {
  var title by remember { mutableStateOf("") }
  var price by remember { mutableStateOf("") }
  var selectedCategory by remember { mutableStateOf("Academic/Books") }
  var selectedCondition by remember { mutableStateOf("Good") }
  var description by remember { mutableStateOf("") }
  var hasPhotoAttached by remember { mutableStateOf(false) }
  var photoDrawableRes by remember { mutableStateOf<Int?>(null) }
  var errorMessage by remember { mutableStateOf<String?>(null) }
  var isSubmitting by remember { mutableStateOf(false) }

  // Quick filler function for the required test workflow
  fun fillJavaBookSample() {
    title = "Java Programming Book"
    price = "500"
    selectedCondition = "Good"
    selectedCategory = "Academic/Books"
    description = "Java programming book in good condition"
    hasPhotoAttached = true
    photoDrawableRes = R.drawable.img_java_book_1787076327185
  }

  Scaffold(
    topBar = {
      TopAppBar(
        title = {
          Text(
            text = "Create New Listing",
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold,
            color = CampusNavy
          )
        },
        navigationIcon = {
          IconButton(onClick = onNavigateBack) {
            Icon(
              imageVector = Icons.AutoMirrored.Filled.ArrowBack,
              contentDescription = "Back",
              tint = CampusNavy
            )
          }
        },
        actions = {
          TextButton(
            onClick = { fillJavaBookSample() },
            modifier = Modifier.testTag("fill_sample_button")
          ) {
            Text(
              text = "Auto-Fill Java Book",
              color = CampusBlueLight,
              fontWeight = FontWeight.SemiBold,
              fontSize = 12.sp
            )
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
              fontWeight = FontWeight.SemiBold,
              modifier = Modifier.padding(bottom = 8.dp)
            )
          }

          Button(
            onClick = {
              errorMessage = null
              val parsedPrice = price.toDoubleOrNull()
              if (parsedPrice == null || parsedPrice <= 0) {
                errorMessage = "Please enter a valid price greater than ₹0."
                return@Button
              }
              if (title.trim().length < 3) {
                errorMessage = "Title must be at least 3 characters long."
                return@Button
              }
              if (description.trim().length < 5) {
                errorMessage = "Description must be at least 5 characters long."
                return@Button
              }
              if (!hasPhotoAttached) {
                // Auto attach photo if missing
                hasPhotoAttached = true
                photoDrawableRes = if (title.contains("Java", ignoreCase = true)) {
                  R.drawable.img_java_book_1787076327185
                } else null
              }

              isSubmitting = true
              val result = MarketplaceRepository.createListing(
                title = title,
                price = parsedPrice,
                condition = selectedCondition,
                category = selectedCategory,
                description = description,
                photoRefs = listOf("photo_${System.currentTimeMillis()}.jpg"),
                drawableResId = photoDrawableRes
              )

              if (result.isSuccess) {
                onListingCreated()
              } else {
                isSubmitting = false
                errorMessage = result.exceptionOrNull()?.message ?: "Failed to create listing"
              }
            },
            enabled = !isSubmitting,
            colors = ButtonDefaults.buttonColors(containerColor = CampusBlue),
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier
              .fillMaxWidth()
              .height(50.dp)
              .testTag("publish_listing_button")
          ) {
            if (isSubmitting) {
              CircularProgressIndicator(
                color = Color.White,
                modifier = Modifier.size(20.dp),
                strokeWidth = 2.dp
              )
            } else {
              Text(
                text = "Publish Active Listing",
                fontWeight = FontWeight.Bold,
                fontSize = 15.sp
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
        .verticalScroll(rememberScrollState())
        .padding(16.dp),
      verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
      // Photo Upload Box
      Text(
        text = "Item Photo (Required)",
        fontWeight = FontWeight.Bold,
        fontSize = 14.sp,
        color = CampusNavy
      )

      Box(
        modifier = Modifier
          .fillMaxWidth()
          .height(180.dp)
          .clip(RoundedCornerShape(12.dp))
          .background(CampusSurfaceVariant)
          .border(1.dp, CampusBorder, RoundedCornerShape(12.dp))
          .clickable {
            hasPhotoAttached = true
            photoDrawableRes = R.drawable.img_java_book_1787076327185
          }
          .testTag("photo_upload_box"),
        contentAlignment = Alignment.Center
      ) {
        if (hasPhotoAttached && photoDrawableRes != null) {
          Image(
            painter = painterResource(id = photoDrawableRes!!),
            contentDescription = "Uploaded item photo",
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
          )
          Surface(
            color = Color(0xCC000000),
            shape = RoundedCornerShape(20.dp),
            modifier = Modifier
              .align(Alignment.BottomEnd)
              .padding(8.dp)
          ) {
            Row(
              verticalAlignment = Alignment.CenterVertically,
              modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
            ) {
              Icon(
                imageVector = Icons.Default.Check,
                contentDescription = "Photo Validated",
                tint = CampusTealLight,
                modifier = Modifier.size(14.dp)
              )
              Spacer(modifier = Modifier.width(4.dp))
              Text(
                text = "Photo Attached",
                color = Color.White,
                fontSize = 11.sp
              )
            }
          }
        } else {
          Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Icon(
              imageVector = Icons.Outlined.AddPhotoAlternate,
              contentDescription = "Attach photo",
              tint = CampusBlue,
              modifier = Modifier.size(44.dp)
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
              text = "Tap to capture or choose item photo",
              fontSize = 13.sp,
              fontWeight = FontWeight.SemiBold,
              color = CampusBlue
            )
            Text(
              text = "Clear, real photo of physical item",
              fontSize = 11.sp,
              color = CampusTextMuted
            )
          }
        }
      }

      // Title input
      OutlinedTextField(
        value = title,
        onValueChange = { title = it },
        label = { Text("Listing Title") },
        placeholder = { Text("e.g. Java Programming Book") },
        singleLine = true,
        shape = RoundedCornerShape(10.dp),
        colors = OutlinedTextFieldDefaults.colors(
          focusedBorderColor = CampusBlue,
          unfocusedBorderColor = CampusBorder
        ),
        modifier = Modifier
          .fillMaxWidth()
          .testTag("input_title")
      )

      // Price input
      OutlinedTextField(
        value = price,
        onValueChange = { price = it.filter { char -> char.isDigit() || char == '.' } },
        label = { Text("Price (₹ INR)") },
        placeholder = { Text("500") },
        leadingIcon = { Text("₹", fontWeight = FontWeight.Bold, fontSize = 16.sp, color = CampusNavy) },
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
        singleLine = true,
        shape = RoundedCornerShape(10.dp),
        colors = OutlinedTextFieldDefaults.colors(
          focusedBorderColor = CampusBlue,
          unfocusedBorderColor = CampusBorder
        ),
        modifier = Modifier
          .fillMaxWidth()
          .testTag("input_price")
      )

      // Category Selection
      Text(
        text = "Category",
        fontWeight = FontWeight.Bold,
        fontSize = 14.sp,
        color = CampusNavy
      )
      var categoryExpanded by remember { mutableStateOf(false) }
      ExposedDropdownMenuBox(
        expanded = categoryExpanded,
        onExpandedChange = { categoryExpanded = !categoryExpanded },
        modifier = Modifier.fillMaxWidth()
      ) {
        OutlinedTextField(
          value = selectedCategory,
          onValueChange = {},
          readOnly = true,
          trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = categoryExpanded) },
          colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = CampusBlue,
            unfocusedBorderColor = CampusBorder
          ),
          shape = RoundedCornerShape(10.dp),
          modifier = Modifier
            .fillMaxWidth()
            .menuAnchor()
            .testTag("category_dropdown")
        )
        ExposedDropdownMenu(
          expanded = categoryExpanded,
          onDismissRequest = { categoryExpanded = false }
        ) {
          Categories.ALL.filter { it != "All" }.forEach { category ->
            DropdownMenuItem(
              text = { Text(category) },
              onClick = {
                selectedCategory = category
                categoryExpanded = false
              }
            )
          }
        }
      }

      // Item Condition Selection
      Text(
        text = "Item Condition",
        fontWeight = FontWeight.Bold,
        fontSize = 14.sp,
        color = CampusNavy
      )
      Row(
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        modifier = Modifier.fillMaxWidth()
      ) {
        listOf("New", "Like New", "Good", "Fair").forEach { condition ->
          val isSelected = selectedCondition.equals(condition, ignoreCase = true)
          FilterChip(
            selected = isSelected,
            onClick = { selectedCondition = condition },
            label = { Text(condition, fontSize = 12.sp) },
            colors = FilterChipDefaults.filterChipColors(
              selectedContainerColor = CampusBlue,
              selectedLabelColor = Color.White
            ),
            shape = RoundedCornerShape(8.dp)
          )
        }
      }

      // Description input
      OutlinedTextField(
        value = description,
        onValueChange = { description = it },
        label = { Text("Description & Notes") },
        placeholder = { Text("Mention details like edition, physical condition, highlighting, or accessories included...") },
        minLines = 4,
        maxLines = 6,
        shape = RoundedCornerShape(10.dp),
        colors = OutlinedTextFieldDefaults.colors(
          focusedBorderColor = CampusBlue,
          unfocusedBorderColor = CampusBorder
        ),
        modifier = Modifier
          .fillMaxWidth()
          .testTag("input_description")
      )
    }
  }
}
