package com.example.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.MarketplaceRepository
import com.example.model.Listing
import com.example.model.ReportReasons
import com.example.ui.theme.*

@Composable
fun ReportDialog(
  listing: Listing,
  onDismiss: () -> Unit,
  onReportSubmitted: () -> Unit
) {
  var selectedReason by remember { mutableStateOf(ReportReasons.ALL.first()) }
  var description by remember { mutableStateOf("") }
  var isSubmitted by remember { mutableStateOf(false) }

  AlertDialog(
    onDismissRequest = onDismiss,
    icon = {
      Icon(
        imageVector = Icons.Default.Warning,
        contentDescription = "Report",
        tint = CampusRose,
        modifier = Modifier.size(32.dp)
      )
    },
    title = {
      Text(
        text = "Report Listing to College Admin",
        fontSize = 17.sp,
        fontWeight = FontWeight.Bold,
        color = CampusNavy
      )
    },
    text = {
      if (isSubmitted) {
        Column(
          horizontalAlignment = Alignment.CenterHorizontally,
          modifier = Modifier.fillMaxWidth().padding(16.dp)
        ) {
          Text(
            text = "Report Received",
            fontWeight = FontWeight.Bold,
            color = CampusTeal
          )
          Spacer(modifier = Modifier.height(4.dp))
          Text(
            text = "Thank you for keeping our college campus safe and trusted. Moderators will review within 24 hours.",
            fontSize = 12.sp,
            color = CampusTextSecondary
          )
        }
      } else {
        Column(
          modifier = Modifier
            .fillMaxWidth()
            .verticalScroll(rememberScrollState()),
          verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
          Text(
            text = "Select violation reason:",
            fontSize = 13.sp,
            fontWeight = FontWeight.SemiBold,
            color = CampusNavy
          )

          ReportReasons.ALL.forEach { reason ->
            Row(
              verticalAlignment = Alignment.CenterVertically,
              modifier = Modifier
                .fillMaxWidth()
                .clickable { selectedReason = reason }
                .padding(vertical = 4.dp)
            ) {
              RadioButton(
                selected = selectedReason == reason,
                onClick = { selectedReason = reason },
                colors = RadioButtonDefaults.colors(selectedColor = CampusRose)
              )
              Spacer(modifier = Modifier.width(6.dp))
              Text(
                text = reason,
                fontSize = 12.sp,
                color = CampusTextPrimary
              )
            }
          }

          OutlinedTextField(
            value = description,
            onValueChange = { description = it },
            label = { Text("Additional notes") },
            placeholder = { Text("Provide details...") },
            minLines = 2,
            modifier = Modifier.fillMaxWidth()
          )
        }
      }
    },
    confirmButton = {
      if (isSubmitted) {
        Button(
          onClick = {
            onReportSubmitted()
            onDismiss()
          },
          colors = ButtonDefaults.buttonColors(containerColor = CampusBlue)
        ) {
          Text("Done")
        }
      } else {
        Button(
          onClick = {
            MarketplaceRepository.submitReport(
              listingId = listing.listingId,
              reason = selectedReason,
              description = description
            )
            isSubmitted = true
          },
          colors = ButtonDefaults.buttonColors(containerColor = CampusRose),
          modifier = Modifier.testTag("submit_report_confirm_button")
        ) {
          Text("Submit Report", fontWeight = FontWeight.Bold)
        }
      }
    },
    dismissButton = {
      if (!isSubmitted) {
        TextButton(onClick = onDismiss) {
          Text("Cancel", color = CampusTextSecondary)
        }
      }
    },
    shape = RoundedCornerShape(16.dp),
    containerColor = CampusSurface
  )
}
