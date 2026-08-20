package com.example.ui.screens

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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.MarketplaceRepository
import com.example.model.Student
import com.example.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
  student: Student,
  onNavigateBack: () -> Unit,
  onOpenMyListings: () -> Unit,
  onOpenMetrics: () -> Unit,
  onOpenAdmin: () -> Unit,
  onSwitchStudent: (Student) -> Unit,
  onSignOut: () -> Unit,
  modifier: Modifier = Modifier
) {
  var showSwitchDialog by remember { mutableStateOf(false) }

  Scaffold(
    topBar = {
      TopAppBar(
        title = {
          Text(
            text = "User Profile",
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
        .verticalScroll(rememberScrollState())
        .padding(16.dp),
      verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
      // Profile Hero Card
      Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = CampusNavy),
        modifier = Modifier.fillMaxWidth()
      ) {
        Column(
          horizontalAlignment = Alignment.CenterHorizontally,
          modifier = Modifier
            .fillMaxWidth()
            .padding(20.dp)
        ) {
          Box(
            modifier = Modifier
              .size(64.dp)
              .clip(CircleShape)
              .background(if (student.role == com.example.model.UserRole.ADMIN) CampusAmber else CampusBlueLight),
            contentAlignment = Alignment.Center
          ) {
            Text(
              text = student.fullName.take(1).uppercase(),
              color = Color.White,
              fontWeight = FontWeight.ExtraBold,
              fontSize = 24.sp
            )
          }

          Spacer(modifier = Modifier.height(12.dp))

          Text(
            text = student.fullName,
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold,
            color = Color.White
          )

          Spacer(modifier = Modifier.height(4.dp))

          Text(
            text = student.officialEmail,
            fontSize = 13.sp,
            color = CampusTealLight
          )

          Spacer(modifier = Modifier.height(10.dp))

          Surface(
            color = if (student.role == com.example.model.UserRole.ADMIN) Color(0x33F59E0B) else Color(0x3314B8A6),
            shape = RoundedCornerShape(20.dp)
          ) {
            Row(
              verticalAlignment = Alignment.CenterVertically,
              modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
            ) {
              Icon(
                imageVector = if (student.role == com.example.model.UserRole.ADMIN) Icons.Default.AdminPanelSettings else Icons.Default.Verified,
                contentDescription = null,
                tint = if (student.role == com.example.model.UserRole.ADMIN) CampusAmberLight else CampusTealLight,
                modifier = Modifier.size(14.dp)
              )
              Spacer(modifier = Modifier.width(4.dp))
              Text(
                text = if (student.role == com.example.model.UserRole.ADMIN) "CHIEF ADMINISTRATOR" else if (student.role == com.example.model.UserRole.MODERATOR) "CAMPUS MODERATOR" else "VERIFIED CAMPUS STUDENT",
                color = if (student.role == com.example.model.UserRole.ADMIN) CampusAmberLight else CampusTealLight,
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold
              )
            }
          }
        }
      }

      // Academic Details Card
      Card(
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = CampusSurface),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        modifier = Modifier.fillMaxWidth()
      ) {
        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
          Text(
            text = "Affiliation & Role Permissions",
            fontWeight = FontWeight.Bold,
            fontSize = 14.sp,
            color = CampusNavy
          )

          ProfileInfoRow(label = "College", value = student.collegeName)
          ProfileInfoRow(label = "Department", value = student.department)
          ProfileInfoRow(label = "System Role", value = student.role.label)
          ProfileInfoRow(label = "Account Status", value = student.status.label)
          ProfileInfoRow(label = "Trust Rating", value = "${student.trustScore}/100")
          ProfileInfoRow(label = "Data Isolation Domain", value = student.collegeId)
        }
      }

      // Navigation Actions
      Text(
        text = "Management & Security Controls",
        fontWeight = FontWeight.Bold,
        fontSize = 15.sp,
        color = CampusNavy
      )

      ProfileNavigationButton(
        title = "Admin Dashboard / Panel",
        subtitle = "Manage users, soft-delete listings, moderate reports & view audit logs",
        icon = Icons.Outlined.AdminPanelSettings,
        onClick = onOpenAdmin
      )

      ProfileNavigationButton(
        title = "My Posted Items",
        subtitle = "Manage active listings and mark sold",
        icon = Icons.Outlined.Inventory2,
        onClick = onOpenMyListings
      )

      ProfileNavigationButton(
        title = "Pilot Metrics Dashboard",
        subtitle = "View conversion rates & SLA",
        icon = Icons.Outlined.Analytics,
        onClick = onOpenMetrics
      )

      ProfileNavigationButton(
        title = "Test Role & College Isolation",
        subtitle = "Switch between Admin, Moderator & Students",
        icon = Icons.Outlined.Security,
        onClick = { showSwitchDialog = true }
      )

      Spacer(modifier = Modifier.height(8.dp))

      OutlinedButton(
        onClick = onSignOut,
        colors = ButtonDefaults.outlinedButtonColors(contentColor = CampusRose),
        shape = RoundedCornerShape(10.dp),
        modifier = Modifier
          .fillMaxWidth()
          .height(48.dp)
          .testTag("sign_out_button")
      ) {
        Icon(Icons.Default.Logout, contentDescription = null, modifier = Modifier.size(16.dp))
        Spacer(modifier = Modifier.width(8.dp))
        Text("Sign Out / Switch College Account")
      }
    }
  }

  if (showSwitchDialog) {
    AlertDialog(
      onDismissRequest = { showSwitchDialog = false },
      title = { Text("Identity & RBAC Role Switcher") },
      text = {
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
          Text(
            text = "Switch active identity to test Admin panel enforcement, Moderator review, and Student isolation barriers:",
            fontSize = 12.sp,
            color = CampusTextSecondary
          )
          Spacer(modifier = Modifier.height(4.dp))

          Button(
            onClick = {
              MarketplaceRepository.switchStudent(MarketplaceRepository.adminUser)
              onSwitchStudent(MarketplaceRepository.adminUser)
              showSwitchDialog = false
            },
            colors = ButtonDefaults.buttonColors(containerColor = CampusNavy),
            modifier = Modifier.fillMaxWidth()
          ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
              Text("Switch to Dr. Rajesh Sharma (ADMIN)", fontSize = 12.sp, fontWeight = FontWeight.Bold)
              Text("Full Admin Console Access", fontSize = 10.sp, color = CampusTealLight)
            }
          }

          Button(
            onClick = {
              MarketplaceRepository.switchStudent(MarketplaceRepository.moderatorUser)
              onSwitchStudent(MarketplaceRepository.moderatorUser)
              showSwitchDialog = false
            },
            colors = ButtonDefaults.buttonColors(containerColor = CampusBlue),
            modifier = Modifier.fillMaxWidth()
          ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
              Text("Switch to Prof. Ananya Rao (MODERATOR)", fontSize = 12.sp, fontWeight = FontWeight.Bold)
              Text("Moderation & Reports Permissions", fontSize = 10.sp, color = Color(0xFFDBEAFE))
            }
          }

          OutlinedButton(
            onClick = {
              MarketplaceRepository.switchStudent(MarketplaceRepository.defaultStudent)
              onSwitchStudent(MarketplaceRepository.defaultStudent)
              showSwitchDialog = false
            },
            modifier = Modifier.fillMaxWidth()
          ) {
            Text("Switch to Venu Madhav (STUDENT - AVIH)", fontSize = 12.sp)
          }

          OutlinedButton(
            onClick = {
              MarketplaceRepository.switchStudent(MarketplaceRepository.otherCollegeStudent)
              onSwitchStudent(MarketplaceRepository.otherCollegeStudent)
              showSwitchDialog = false
            },
            modifier = Modifier.fillMaxWidth()
          ) {
            Text("Switch to Rahul Sharma (STUDENT - JNTUH)", fontSize = 12.sp)
          }
        }
      },
      confirmButton = {},
      dismissButton = {
        TextButton(onClick = { showSwitchDialog = false }) {
          Text("Close")
        }
      }
    )
  }
}

@Composable
fun ProfileInfoRow(label: String, value: String) {
  Row(
    horizontalArrangement = Arrangement.SpaceBetween,
    modifier = Modifier.fillMaxWidth()
  ) {
    Text(text = label, fontSize = 12.sp, color = CampusTextSecondary)
    Text(text = value, fontSize = 12.sp, fontWeight = FontWeight.SemiBold, color = CampusTextPrimary)
  }
}

@Composable
fun ProfileNavigationButton(
  title: String,
  subtitle: String,
  icon: ImageVector,
  onClick: () -> Unit
) {
  Card(
    shape = RoundedCornerShape(12.dp),
    colors = CardDefaults.cardColors(containerColor = CampusSurface),
    elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
    onClick = onClick,
    modifier = Modifier.fillMaxWidth()
  ) {
    Row(
      verticalAlignment = Alignment.CenterVertically,
      modifier = Modifier.padding(14.dp)
    ) {
      Box(
        modifier = Modifier
          .size(40.dp)
          .clip(CircleShape)
          .background(CampusSurfaceVariant),
        contentAlignment = Alignment.Center
      ) {
        Icon(imageVector = icon, contentDescription = null, tint = CampusBlue, modifier = Modifier.size(20.dp))
      }

      Spacer(modifier = Modifier.width(12.dp))

      Column(modifier = Modifier.weight(1f)) {
        Text(text = title, fontSize = 14.sp, fontWeight = FontWeight.Bold, color = CampusNavy)
        Text(text = subtitle, fontSize = 11.sp, color = CampusTextSecondary)
      }

      Icon(imageVector = Icons.Default.ChevronRight, contentDescription = null, tint = CampusTextMuted)
    }
  }
}
