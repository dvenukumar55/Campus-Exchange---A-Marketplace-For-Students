package com.example.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.model.ListingStatus
import com.example.model.Student
import com.example.ui.theme.*

@Composable
fun ConditionBadge(condition: String, modifier: Modifier = Modifier) {
  val (bgColor, textColor) = when (condition.lowercase()) {
    "brand new", "new" -> Pair(Color(0xFFDCFCE7), Color(0xFF15803D))
    "like new" -> Pair(Color(0xFFE0F2FE), Color(0xFF0369A1))
    "good" -> Pair(Color(0xFFFEF3C7), Color(0xFFB45309))
    else -> Pair(Color(0xFFF1F5F9), Color(0xFF475569))
  }

  Surface(
    color = bgColor,
    shape = RoundedCornerShape(6.dp),
    modifier = modifier
  ) {
    Text(
      text = condition,
      color = textColor,
      fontSize = 11.sp,
      fontWeight = FontWeight.SemiBold,
      modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
    )
  }
}

@Composable
fun StatusBadge(status: ListingStatus, modifier: Modifier = Modifier) {
  val (bgColor, textColor, label) = when (status) {
    ListingStatus.ACTIVE -> Triple(Color(0xFFDCFCE7), Color(0xFF166534), "ACTIVE")
    ListingStatus.SOLD -> Triple(Color(0xFFF3E8FF), Color(0xFF6B21A8), "SOLD")
    ListingStatus.CLOSED -> Triple(Color(0xFFF1F5F9), Color(0xFF475569), "CLOSED")
    ListingStatus.FLAGGED -> Triple(Color(0xFFFEF3C7), Color(0xFFB45309), "FLAGGED")
    ListingStatus.REMOVED -> Triple(Color(0xFFFFE4E6), Color(0xFFBE123C), "REMOVED")
  }

  Surface(
    color = bgColor,
    shape = RoundedCornerShape(6.dp),
    modifier = modifier
  ) {
    Text(
      text = label,
      color = textColor,
      fontSize = 10.sp,
      fontWeight = FontWeight.Bold,
      modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
    )
  }
}

@Composable
fun SafetyBanner(modifier: Modifier = Modifier) {
  var isExpanded by remember { mutableStateOf(false) }

  Card(
    shape = RoundedCornerShape(12.dp),
    colors = CardDefaults.cardColors(containerColor = Color(0xFFEFF6FF)),
    modifier = modifier.fillMaxWidth()
  ) {
    Column(modifier = Modifier.padding(12.dp)) {
      Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween,
        modifier = Modifier.fillMaxWidth()
      ) {
        Row(
          verticalAlignment = Alignment.CenterVertically,
          modifier = Modifier.weight(1f)
        ) {
          Icon(
            imageVector = Icons.Default.Shield,
            contentDescription = "Security Shield",
            tint = CampusBlue,
            modifier = Modifier.size(20.dp)
          )
          Spacer(modifier = Modifier.width(8.dp))
          Text(
            text = "Campus Safety Guarantee",
            fontSize = 13.sp,
            fontWeight = FontWeight.Bold,
            color = CampusNavy
          )
        }
        TextButton(
          onClick = { isExpanded = !isExpanded },
          contentPadding = PaddingValues(0.dp)
        ) {
          Text(
            text = if (isExpanded) "Hide" else "Rules",
            fontSize = 12.sp,
            color = CampusBlueLight
          )
        }
      }

      AnimatedVisibility(visible = isExpanded) {
        Column(modifier = Modifier.padding(top = 8.dp)) {
          Text(
            text = "• Meet only in daylight in high-footfall campus zones (Library, Canteen, Quadrangle).",
            fontSize = 12.sp,
            color = CampusTextSecondary
          )
          Spacer(modifier = Modifier.height(4.dp))
          Text(
            text = "• Inspect items physically before any payment.",
            fontSize = 12.sp,
            color = CampusTextSecondary
          )
          Spacer(modifier = Modifier.height(4.dp))
          Text(
            text = "• No advance money transfers or non-student exchanges permitted.",
            fontSize = 12.sp,
            color = CampusTextSecondary
          )
        }
      }
    }
  }
}

@Composable
fun CollegeVerificationHeader(
  student: Student,
  onSwitchCollege: () -> Unit,
  modifier: Modifier = Modifier
) {
  Surface(
    color = CampusNavy,
    modifier = modifier.fillMaxWidth()
  ) {
    Column(modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp)) {
      Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween,
        modifier = Modifier.fillMaxWidth()
      ) {
        Row(
          verticalAlignment = Alignment.CenterVertically,
          modifier = Modifier.weight(1f)
        ) {
          Box(
            modifier = Modifier
              .size(36.dp)
              .clip(CircleShape)
              .background(CampusBlueLight),
            contentAlignment = Alignment.Center
          ) {
            Icon(
              imageVector = Icons.Default.School,
              contentDescription = "College icon",
              tint = Color.White,
              modifier = Modifier.size(20.dp)
            )
          }
          Spacer(modifier = Modifier.width(10.dp))
          Column {
            Row(verticalAlignment = Alignment.CenterVertically) {
              Text(
                text = student.collegeName.substringBefore("(").trim(),
                color = Color.White,
                fontSize = 13.sp,
                fontWeight = FontWeight.Bold
              )
              Spacer(modifier = Modifier.width(4.dp))
              Icon(
                imageVector = Icons.Default.Verified,
                contentDescription = "Verified Campus",
                tint = CampusTealLight,
                modifier = Modifier.size(14.dp)
              )
            }
            Text(
              text = "Official Campus: ${student.collegeId}",
              color = CampusTextMuted,
              fontSize = 11.sp
            )
          }
        }

        IconButton(onClick = onSwitchCollege) {
          Icon(
            imageVector = Icons.Default.SwapHoriz,
            contentDescription = "Switch test student / college boundary",
            tint = Color.White
          )
        }
      }
    }
  }
}

@Composable
fun CategoryChipsRow(
  categories: List<String>,
  selectedCategory: String,
  onSelect: (String) -> Unit,
  modifier: Modifier = Modifier
) {
  Row(
    modifier = modifier
      .fillMaxWidth()
      .horizontalScroll(rememberScrollState())
      .padding(horizontal = 16.dp, vertical = 4.dp),
    horizontalArrangement = Arrangement.spacedBy(8.dp)
  ) {
    categories.forEach { category ->
      val isSelected = category == selectedCategory
      FilterChip(
        selected = isSelected,
        onClick = { onSelect(category) },
        label = {
          Text(
            text = category,
            fontSize = 12.sp,
            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
          )
        },
        colors = FilterChipDefaults.filterChipColors(
          selectedContainerColor = CampusBlue,
          selectedLabelColor = Color.White,
          containerColor = CampusSurfaceVariant,
          labelColor = CampusTextPrimary
        ),
        shape = RoundedCornerShape(20.dp)
      )
    }
  }
}
