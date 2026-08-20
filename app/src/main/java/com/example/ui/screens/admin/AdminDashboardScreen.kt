package com.example.ui.screens.admin

import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.MarketplaceRepository
import com.example.model.*
import com.example.ui.screens.ProfileInfoRow
import com.example.ui.theme.*
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

enum class AdminTab(val title: String, val icon: ImageVector) {
  DASHBOARD("Overview", Icons.Outlined.Dashboard),
  USERS("Users", Icons.Outlined.People),
  LISTINGS("Listings", Icons.Outlined.Inventory2),
  REPORTS("Reports", Icons.Outlined.ReportProblem),
  BLOCKED("Blocked", Icons.Outlined.Block),
  LOGS("Audit Logs", Icons.Outlined.History),
  SETTINGS("Settings", Icons.Outlined.AdminPanelSettings)
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdminDashboardScreen(
  currentStudent: Student,
  onNavigateBack: () -> Unit,
  onSwitchUser: (Student) -> Unit,
  modifier: Modifier = Modifier
) {
  var selectedTab by remember { mutableStateOf(AdminTab.DASHBOARD) }
  var showRoleSwitcherDialog by remember { mutableStateOf(false) }

  val users by MarketplaceRepository.allUsers.collectAsState()
  val listings by MarketplaceRepository.listings.collectAsState()
  val reports by MarketplaceRepository.reports.collectAsState()
  val auditLogs by MarketplaceRepository.auditLogs.collectAsState()
  val settings by MarketplaceRepository.systemSettings.collectAsState()

  val isAuthorized = currentStudent.role == UserRole.ADMIN || currentStudent.role == UserRole.MODERATOR

  if (!isAuthorized) {
    // Unauthorized Security Block Screen
    Scaffold(
      topBar = {
        TopAppBar(
          title = { Text("Security Access Control", fontWeight = FontWeight.Bold) },
          navigationIcon = {
            IconButton(onClick = onNavigateBack) {
              Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
            }
          }
        )
      }
    ) { innerPadding ->
      Box(
        modifier = Modifier
          .fillMaxSize()
          .padding(innerPadding)
          .padding(24.dp),
        contentAlignment = Alignment.Center
      ) {
        Card(
          shape = RoundedCornerShape(16.dp),
          colors = CardDefaults.cardColors(containerColor = CampusSurface),
          elevation = CardDefaults.cardElevation(defaultElevation = 3.dp),
          modifier = Modifier.fillMaxWidth()
        ) {
          Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(24.dp)
          ) {
            Box(
              modifier = Modifier
                .size(64.dp)
                .clip(CircleShape)
                .background(Color(0xFFFFE4E6)),
              contentAlignment = Alignment.Center
            ) {
              Icon(
                imageVector = Icons.Default.Lock,
                contentDescription = null,
                tint = CampusRose,
                modifier = Modifier.size(32.dp)
              )
            }

            Spacer(modifier = Modifier.height(16.dp))

            Text(
              text = "403 Forbidden: Administrator Only",
              fontSize = 18.sp,
              fontWeight = FontWeight.Bold,
              color = CampusNavy
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
              text = "Your current account (${currentStudent.fullName} - ${currentStudent.role.label}) does not have administrative permissions to view or execute moderation actions.",
              fontSize = 13.sp,
              color = CampusTextSecondary,
              lineHeight = 18.sp
            )

            Spacer(modifier = Modifier.height(20.dp))

            Button(
              onClick = { showRoleSwitcherDialog = true },
              colors = ButtonDefaults.buttonColors(containerColor = CampusNavy),
              modifier = Modifier.fillMaxWidth()
            ) {
              Icon(Icons.Default.VpnKey, contentDescription = null, modifier = Modifier.size(16.dp))
              Spacer(modifier = Modifier.width(8.dp))
              Text("Switch to Authorized Administrator")
            }

            Spacer(modifier = Modifier.height(8.dp))

            OutlinedButton(
              onClick = onNavigateBack,
              modifier = Modifier.fillMaxWidth()
            ) {
              Text("Return to Marketplace")
            }
          }
        }
      }
    }
  } else {
    // Authorized Admin Dashboard
    Scaffold(
      topBar = {
        TopAppBar(
          title = {
            Column {
              Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                  text = "Campus Admin Console",
                  fontSize = 17.sp,
                  fontWeight = FontWeight.Bold,
                  color = CampusNavy
                )
                Spacer(modifier = Modifier.width(6.dp))
                Surface(
                  color = if (currentStudent.role == UserRole.ADMIN) Color(0xFFDCFCE7) else Color(0xFFE0F2FE),
                  shape = RoundedCornerShape(4.dp)
                ) {
                  Text(
                    text = currentStudent.role.name,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    color = if (currentStudent.role == UserRole.ADMIN) Color(0xFF166534) else Color(0xFF0369A1),
                    modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                  )
                }
              }
              Text(
                text = "${currentStudent.fullName} • ${currentStudent.officialEmail}",
                fontSize = 11.sp,
                color = CampusTextSecondary
              )
            }
          },
          navigationIcon = {
            IconButton(onClick = onNavigateBack) {
              Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = CampusNavy)
            }
          },
          actions = {
            IconButton(
              onClick = { showRoleSwitcherDialog = true },
              modifier = Modifier.testTag("admin_role_switcher_button")
            ) {
              Icon(
                imageVector = Icons.Default.SwitchAccount,
                contentDescription = "Switch Admin Role",
                tint = CampusBlue
              )
            }
          },
          colors = TopAppBarDefaults.topAppBarColors(containerColor = CampusSurface)
        )
      },
      bottomBar = {
        NavigationBar(
          containerColor = CampusSurface,
          tonalElevation = 8.dp,
          windowInsets = WindowInsets.navigationBars
        ) {
          AdminTab.values().forEach { tab ->
            val isSelected = selectedTab == tab
            val badgeCount = when (tab) {
              AdminTab.REPORTS -> reports.count { it.status == ReportStatus.PENDING }
              AdminTab.BLOCKED -> users.count { it.isBlocked || it.status == UserStatus.BLOCKED }
              else -> 0
            }

            NavigationBarItem(
              selected = isSelected,
              onClick = { selectedTab = tab },
              icon = {
                BadgedBox(
                  badge = {
                    if (badgeCount > 0) {
                      Badge(containerColor = CampusRose) {
                        Text(badgeCount.toString())
                      }
                    }
                  }
                ) {
                  Icon(tab.icon, contentDescription = tab.title)
                }
              },
              label = {
                Text(
                  text = tab.title,
                  fontSize = 10.sp,
                  fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                  maxLines = 1,
                  overflow = TextOverflow.Ellipsis
                )
              },
              colors = NavigationBarItemDefaults.colors(
                selectedIconColor = CampusBlue,
                selectedTextColor = CampusNavy,
                indicatorColor = CampusSurfaceVariant,
                unselectedIconColor = CampusTextMuted,
                unselectedTextColor = CampusTextMuted
              )
            )
          }
        }
      },
      modifier = modifier
    ) { innerPadding ->
      Box(
        modifier = Modifier
          .fillMaxSize()
          .padding(innerPadding)
      ) {
        when (selectedTab) {
          AdminTab.DASHBOARD -> AdminOverviewView(
            users = users,
            listings = listings,
            reports = reports,
            auditLogs = auditLogs,
            onSelectTab = { selectedTab = it }
          )
          AdminTab.USERS -> AdminUsersView(
            users = users,
            currentAdmin = currentStudent
          )
          AdminTab.LISTINGS -> AdminListingsView(
            listings = listings
          )
          AdminTab.REPORTS -> AdminReportsView(
            reports = reports
          )
          AdminTab.BLOCKED -> AdminBlockedUsersView(
            users = users
          )
          AdminTab.LOGS -> AdminAuditLogsView(
            logs = auditLogs
          )
          AdminTab.SETTINGS -> AdminSettingsView(
            settings = settings,
            currentAdmin = currentStudent
          )
        }
      }
    }
  }

  // Admin / Identity Switcher Dialog
  if (showRoleSwitcherDialog) {
    AdminRoleSwitcherDialog(
      currentStudent = currentStudent,
      onDismiss = { showRoleSwitcherDialog = false },
      onSelectUser = {
        MarketplaceRepository.switchStudent(it)
        onSwitchUser(it)
        showRoleSwitcherDialog = false
      }
    )
  }
}

// ----------------------------------------------------
// 1. OVERVIEW DASHBOARD VIEW
// ----------------------------------------------------
@Composable
fun AdminOverviewView(
  users: List<Student>,
  listings: List<Listing>,
  reports: List<ReportSubmission>,
  auditLogs: List<AuditLog>,
  onSelectTab: (AdminTab) -> Unit
) {
  val pendingReports = reports.count { it.status == ReportStatus.PENDING }
  val activeListings = listings.count { it.status == ListingStatus.ACTIVE }
  val soldListings = listings.count { it.status == ListingStatus.SOLD }
  val blockedUsers = users.count { it.isBlocked || it.status == UserStatus.BLOCKED }
  val totalSalesVal = listings.filter { it.status == ListingStatus.SOLD }.sumOf { it.price }

  Column(
    modifier = Modifier
      .fillMaxSize()
      .verticalScroll(rememberScrollState())
      .padding(16.dp),
    verticalArrangement = Arrangement.spacedBy(16.dp)
  ) {
    // Top KPI Metric Cards Grid
    Row(horizontalArrangement = Arrangement.spacedBy(12.dp), modifier = Modifier.fillMaxWidth()) {
      KpiCard(
        title = "Total Users",
        value = "${users.size}",
        subtitle = "${users.count { it.status == UserStatus.ACTIVE }} Active",
        icon = Icons.Default.People,
        accentColor = CampusBlue,
        modifier = Modifier.weight(1f),
        onClick = { onSelectTab(AdminTab.USERS) }
      )
      KpiCard(
        title = "Active Items",
        value = "$activeListings",
        subtitle = "$soldListings Sold",
        icon = Icons.Default.Storefront,
        accentColor = CampusTeal,
        modifier = Modifier.weight(1f),
        onClick = { onSelectTab(AdminTab.LISTINGS) }
      )
    }

    Row(horizontalArrangement = Arrangement.spacedBy(12.dp), modifier = Modifier.fillMaxWidth()) {
      KpiCard(
        title = "Pending Reports",
        value = "$pendingReports",
        subtitle = if (pendingReports > 0) "Requires Action" else "All Clear",
        icon = Icons.Default.Warning,
        accentColor = if (pendingReports > 0) CampusRose else CampusTeal,
        modifier = Modifier.weight(1f),
        onClick = { onSelectTab(AdminTab.REPORTS) }
      )
      KpiCard(
        title = "Blocked Accounts",
        value = "$blockedUsers",
        subtitle = "Zero-tolerance rules",
        icon = Icons.Default.Block,
        accentColor = CampusAmber,
        modifier = Modifier.weight(1f),
        onClick = { onSelectTab(AdminTab.BLOCKED) }
      )
    }

    // Secondary KPI banner
    Card(
      shape = RoundedCornerShape(12.dp),
      colors = CardDefaults.cardColors(containerColor = CampusNavy),
      modifier = Modifier.fillMaxWidth()
    ) {
      Row(
        modifier = Modifier.padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
      ) {
        Column {
          Text(
            text = "Total Campus Marketplace Volume",
            fontSize = 12.sp,
            color = CampusTealLight
          )
          Text(
            text = "₹${totalSalesVal.toInt()}",
            fontSize = 22.sp,
            fontWeight = FontWeight.ExtraBold,
            color = Color.White
          )
          Text(
            text = "Peer-to-peer completed campus transactions",
            fontSize = 11.sp,
            color = Color(0xFF94A3B8)
          )
        }
        Icon(
          imageVector = Icons.Default.CurrencyRupee,
          contentDescription = null,
          tint = CampusAmber,
          modifier = Modifier.size(36.dp)
        )
      }
    }

    // College Partition Breakdown
    Card(
      shape = RoundedCornerShape(12.dp),
      colors = CardDefaults.cardColors(containerColor = CampusSurface),
      elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
      modifier = Modifier.fillMaxWidth()
    ) {
      Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(
          text = "Campus Partition Distribution",
          fontWeight = FontWeight.Bold,
          fontSize = 14.sp,
          color = CampusNavy
        )

        val avihListings = listings.count { it.collegeId.contains("avih") }
        val jntuhListings = listings.count { it.collegeId.contains("jntuh") }

        CollegeStatProgress(
          collegeName = "Avanthi Institute of Tech (AVIH)",
          count = avihListings,
          total = listings.size,
          color = CampusBlue
        )

        CollegeStatProgress(
          collegeName = "Jawaharlal Nehru Tech Univ (JNTUH)",
          count = jntuhListings,
          total = listings.size,
          color = CampusTeal
        )
      }
    }

    // Recent Audit Actions
    Card(
      shape = RoundedCornerShape(12.dp),
      colors = CardDefaults.cardColors(containerColor = CampusSurface),
      elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
      modifier = Modifier.fillMaxWidth()
    ) {
      Column(modifier = Modifier.padding(16.dp)) {
        Row(
          modifier = Modifier.fillMaxWidth(),
          horizontalArrangement = Arrangement.SpaceBetween,
          verticalAlignment = Alignment.CenterVertically
        ) {
          Text(
            text = "Recent Audit Actions",
            fontWeight = FontWeight.Bold,
            fontSize = 14.sp,
            color = CampusNavy
          )
          TextButton(onClick = { onSelectTab(AdminTab.LOGS) }) {
            Text("View All (${auditLogs.size})", fontSize = 12.sp)
          }
        }

        Spacer(modifier = Modifier.height(8.dp))

        if (auditLogs.isEmpty()) {
          Text("No logs recorded yet.", fontSize = 12.sp, color = CampusTextMuted)
        } else {
          auditLogs.take(4).forEach { log ->
            AuditLogMiniItem(log = log)
            HorizontalDivider(color = CampusBorder.copy(alpha = 0.5f), modifier = Modifier.padding(vertical = 6.dp))
          }
        }
      }
    }
  }
}

@Composable
fun KpiCard(
  title: String,
  value: String,
  subtitle: String,
  icon: ImageVector,
  accentColor: Color,
  modifier: Modifier = Modifier,
  onClick: () -> Unit
) {
  Card(
    shape = RoundedCornerShape(12.dp),
    colors = CardDefaults.cardColors(containerColor = CampusSurface),
    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    onClick = onClick,
    modifier = modifier
  ) {
    Column(modifier = Modifier.padding(14.dp)) {
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
      ) {
        Text(text = title, fontSize = 12.sp, color = CampusTextSecondary, fontWeight = FontWeight.Medium)
        Box(
          modifier = Modifier
            .size(28.dp)
            .clip(CircleShape)
            .background(accentColor.copy(alpha = 0.15f)),
          contentAlignment = Alignment.Center
        ) {
          Icon(icon, contentDescription = null, tint = accentColor, modifier = Modifier.size(16.dp))
        }
      }

      Spacer(modifier = Modifier.height(8.dp))

      Text(text = value, fontSize = 20.sp, fontWeight = FontWeight.ExtraBold, color = CampusNavy)
      Spacer(modifier = Modifier.height(2.dp))
      Text(text = subtitle, fontSize = 11.sp, color = accentColor, fontWeight = FontWeight.SemiBold)
    }
  }
}

@Composable
fun CollegeStatProgress(collegeName: String, count: Int, total: Int, color: Color) {
  val pct = if (total > 0) count.toFloat() / total.toFloat() else 0f
  Column {
    Row(
      modifier = Modifier.fillMaxWidth(),
      horizontalArrangement = Arrangement.SpaceBetween
    ) {
      Text(text = collegeName, fontSize = 12.sp, color = CampusTextPrimary)
      Text(text = "$count items (${(pct * 100).toInt()}%)", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = CampusNavy)
    }
    Spacer(modifier = Modifier.height(4.dp))
    LinearProgressIndicator(
      progress = { pct },
      color = color,
      trackColor = CampusSurfaceVariant,
      modifier = Modifier
        .fillMaxWidth()
        .height(6.dp)
        .clip(RoundedCornerShape(3.dp))
    )
  }
}

@Composable
fun AuditLogMiniItem(log: AuditLog) {
  val dateFormat = SimpleDateFormat("dd MMM, HH:mm", Locale.getDefault())
  Row(
    verticalAlignment = Alignment.CenterVertically,
    modifier = Modifier.fillMaxWidth()
  ) {
    Box(
      modifier = Modifier
        .size(8.dp)
        .clip(CircleShape)
        .background(CampusBlue)
    )
    Spacer(modifier = Modifier.width(10.dp))
    Column(modifier = Modifier.weight(1f)) {
      Text(
        text = "${log.actionType} • ${log.targetId}",
        fontSize = 12.sp,
        fontWeight = FontWeight.Bold,
        color = CampusNavy
      )
      Text(
        text = log.details,
        fontSize = 11.sp,
        color = CampusTextSecondary,
        maxLines = 1,
        overflow = TextOverflow.Ellipsis
      )
    }
    Text(
      text = dateFormat.format(Date(log.timestamp)),
      fontSize = 10.sp,
      color = CampusTextMuted
    )
  }
}

// ----------------------------------------------------
// 2. USER MANAGEMENT VIEW
// ----------------------------------------------------
@Composable
fun AdminUsersView(
  users: List<Student>,
  currentAdmin: Student
) {
  var searchQuery by remember { mutableStateOf("") }
  var selectedRoleFilter by remember { mutableStateOf<UserRole?>(null) }
  var selectedStatusFilter by remember { mutableStateOf<UserStatus?>(null) }
  var selectedUserForDetails by remember { mutableStateOf<Student?>(null) }
  var userToBlock by remember { mutableStateOf<Student?>(null) }
  var blockReasonInput by remember { mutableStateOf("") }
  var userToWarn by remember { mutableStateOf<Student?>(null) }
  var warnMessageInput by remember { mutableStateOf("") }

  val filteredUsers = remember(users, searchQuery, selectedRoleFilter, selectedStatusFilter) {
    users.filter { user ->
      val matchesSearch = searchQuery.isBlank() ||
          user.fullName.contains(searchQuery, ignoreCase = true) ||
          user.officialEmail.contains(searchQuery, ignoreCase = true) ||
          user.studentId.contains(searchQuery, ignoreCase = true) ||
          user.department.contains(searchQuery, ignoreCase = true)

      val matchesRole = selectedRoleFilter == null || user.role == selectedRoleFilter
      val matchesStatus = selectedStatusFilter == null || user.status == selectedStatusFilter

      matchesSearch && matchesRole && matchesStatus
    }
  }

  Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
    // Search input
    OutlinedTextField(
      value = searchQuery,
      onValueChange = { searchQuery = it },
      placeholder = { Text("Search users by name, email, student ID...", fontSize = 12.sp) },
      leadingIcon = { Icon(Icons.Default.Search, contentDescription = null, tint = CampusTextSecondary) },
      trailingIcon = {
        if (searchQuery.isNotEmpty()) {
          IconButton(onClick = { searchQuery = "" }) {
            Icon(Icons.Default.Clear, contentDescription = "Clear")
          }
        }
      },
      singleLine = true,
      shape = RoundedCornerShape(10.dp),
      modifier = Modifier.fillMaxWidth()
    )

    Spacer(modifier = Modifier.height(8.dp))

    // Filter Chips Row
    Row(
      modifier = Modifier
        .fillMaxWidth()
        .horizontalScroll(rememberScrollState()),
      horizontalArrangement = Arrangement.spacedBy(6.dp)
    ) {
      FilterChip(
        selected = selectedRoleFilter == null && selectedStatusFilter == null,
        onClick = {
          selectedRoleFilter = null
          selectedStatusFilter = null
        },
        label = { Text("All (${users.size})", fontSize = 11.sp) }
      )
      FilterChip(
        selected = selectedRoleFilter == UserRole.STUDENT,
        onClick = { selectedRoleFilter = if (selectedRoleFilter == UserRole.STUDENT) null else UserRole.STUDENT },
        label = { Text("Students", fontSize = 11.sp) }
      )
      FilterChip(
        selected = selectedRoleFilter == UserRole.MODERATOR,
        onClick = { selectedRoleFilter = if (selectedRoleFilter == UserRole.MODERATOR) null else UserRole.MODERATOR },
        label = { Text("Moderators", fontSize = 11.sp) }
      )
      FilterChip(
        selected = selectedRoleFilter == UserRole.ADMIN,
        onClick = { selectedRoleFilter = if (selectedRoleFilter == UserRole.ADMIN) null else UserRole.ADMIN },
        label = { Text("Admins", fontSize = 11.sp) }
      )
      FilterChip(
        selected = selectedStatusFilter == UserStatus.BLOCKED,
        onClick = { selectedStatusFilter = if (selectedStatusFilter == UserStatus.BLOCKED) null else UserStatus.BLOCKED },
        label = { Text("Blocked (${users.count { it.isBlocked }})", fontSize = 11.sp) },
        colors = FilterChipDefaults.filterChipColors(selectedContainerColor = CampusRose, selectedLabelColor = Color.White)
      )
    }

    Spacer(modifier = Modifier.height(10.dp))

    Text(
      text = "Showing ${filteredUsers.size} Users",
      fontSize = 12.sp,
      fontWeight = FontWeight.Bold,
      color = CampusTextSecondary
    )

    Spacer(modifier = Modifier.height(6.dp))

    LazyColumn(
      verticalArrangement = Arrangement.spacedBy(8.dp),
      modifier = Modifier.fillMaxSize()
    ) {
      items(filteredUsers, key = { it.studentId }) { user ->
        UserAdminItemCard(
          user = user,
          onViewDetails = { selectedUserForDetails = user },
          onBlockClick = { userToBlock = user },
          onUnblockClick = { MarketplaceRepository.adminUnblockUser(user.studentId) },
          onWarnClick = { userToWarn = user },
          onPromoteRole = { newRole -> MarketplaceRepository.adminSetUserRole(user.studentId, newRole) }
        )
      }
    }
  }

  // Block Dialog
  userToBlock?.let { user ->
    AlertDialog(
      onDismissRequest = { userToBlock = null },
      icon = { Icon(Icons.Default.Block, contentDescription = null, tint = CampusRose) },
      title = { Text("Block Campus Account") },
      text = {
        Column {
          Text("Are you sure you want to block ${user.fullName} (${user.officialEmail})? They will not be able to list items or send messages.")
          Spacer(modifier = Modifier.height(12.dp))
          OutlinedTextField(
            value = blockReasonInput,
            onValueChange = { blockReasonInput = it },
            label = { Text("Violation / Block Reason") },
            placeholder = { Text("e.g. Repeated spam or abusive behavior") },
            modifier = Modifier.fillMaxWidth()
          )
        }
      },
      confirmButton = {
        Button(
          onClick = {
            MarketplaceRepository.adminBlockUser(user.studentId, blockReasonInput)
            blockReasonInput = ""
            userToBlock = null
          },
          colors = ButtonDefaults.buttonColors(containerColor = CampusRose)
        ) {
          Text("Block Account")
        }
      },
      dismissButton = {
        TextButton(onClick = { userToBlock = null }) {
          Text("Cancel")
        }
      }
    )
  }

  // Warn Dialog
  userToWarn?.let { user ->
    AlertDialog(
      onDismissRequest = { userToWarn = null },
      icon = { Icon(Icons.Default.Warning, contentDescription = null, tint = CampusAmber) },
      title = { Text("Issue Official Warning") },
      text = {
        Column {
          Text("Issue administrative warning to ${user.fullName}. Trust score will decrease by 15 points. At 3 warnings, the account will be auto-suspended.")
          Spacer(modifier = Modifier.height(12.dp))
          OutlinedTextField(
            value = warnMessageInput,
            onValueChange = { warnMessageInput = it },
            label = { Text("Warning Reason") },
            placeholder = { Text("e.g. Overpricing or inaccurate item condition") },
            modifier = Modifier.fillMaxWidth()
          )
        }
      },
      confirmButton = {
        Button(
          onClick = {
            MarketplaceRepository.adminWarnUser(user.studentId, warnMessageInput)
            warnMessageInput = ""
            userToWarn = null
          },
          colors = ButtonDefaults.buttonColors(containerColor = CampusAmber)
        ) {
          Text("Send Warning")
        }
      },
      dismissButton = {
        TextButton(onClick = { userToWarn = null }) {
          Text("Cancel")
        }
      }
    )
  }

  // User Details Modal Sheet / Dialog
  selectedUserForDetails?.let { user ->
    AlertDialog(
      onDismissRequest = { selectedUserForDetails = null },
      title = {
        Row(verticalAlignment = Alignment.CenterVertically) {
          Box(
            modifier = Modifier
              .size(36.dp)
              .clip(CircleShape)
              .background(CampusBlue),
            contentAlignment = Alignment.Center
          ) {
            Text(user.fullName.take(1), color = Color.White, fontWeight = FontWeight.Bold)
          }
          Spacer(modifier = Modifier.width(10.dp))
          Column {
            Text(user.fullName, fontSize = 16.sp, fontWeight = FontWeight.Bold)
            Text(user.officialEmail, fontSize = 12.sp, color = CampusTextSecondary)
          }
        }
      },
      text = {
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
          ProfileInfoRow(label = "Student ID", value = user.studentId)
          ProfileInfoRow(label = "College", value = user.collegeName.substringBefore("(").trim())
          ProfileInfoRow(label = "Department", value = user.department)
          ProfileInfoRow(label = "Graduation Year", value = user.graduatingYear.toString())
          ProfileInfoRow(label = "Role", value = user.role.label)
          ProfileInfoRow(label = "Status", value = user.status.label)
          ProfileInfoRow(label = "Trust Score", value = "${user.trustScore}/100")
          ProfileInfoRow(label = "Warnings Count", value = "${user.warningsCount}")
          if (user.blockReason != null) {
            ProfileInfoRow(label = "Block Reason", value = user.blockReason)
          }
        }
      },
      confirmButton = {
        TextButton(onClick = { selectedUserForDetails = null }) {
          Text("Close")
        }
      }
    )
  }
}

@Composable
fun UserAdminItemCard(
  user: Student,
  onViewDetails: () -> Unit,
  onBlockClick: () -> Unit,
  onUnblockClick: () -> Unit,
  onWarnClick: () -> Unit,
  onPromoteRole: (UserRole) -> Unit
) {
  var showRoleMenu by remember { mutableStateOf(false) }

  Card(
    shape = RoundedCornerShape(10.dp),
    colors = CardDefaults.cardColors(
      containerColor = if (user.isBlocked) Color(0xFFFFF1F2) else CampusSurface
    ),
    elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
    modifier = Modifier.fillMaxWidth()
  ) {
    Column(modifier = Modifier.padding(12.dp)) {
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
      ) {
        Row(
          verticalAlignment = Alignment.CenterVertically,
          modifier = Modifier.weight(1f)
        ) {
          Box(
            modifier = Modifier
              .size(36.dp)
              .clip(CircleShape)
              .background(if (user.isBlocked) CampusRose else CampusBlueLight),
            contentAlignment = Alignment.Center
          ) {
            Text(
              text = user.fullName.take(1).uppercase(),
              color = Color.White,
              fontWeight = FontWeight.Bold,
              fontSize = 14.sp
            )
          }
          Spacer(modifier = Modifier.width(10.dp))
          Column {
            Row(verticalAlignment = Alignment.CenterVertically) {
              Text(
                text = user.fullName,
                fontSize = 13.sp,
                fontWeight = FontWeight.Bold,
                color = CampusNavy
              )
              Spacer(modifier = Modifier.width(6.dp))
              Surface(
                color = when (user.role) {
                  UserRole.ADMIN -> Color(0xFFDCFCE7)
                  UserRole.MODERATOR -> Color(0xFFE0F2FE)
                  UserRole.STUDENT -> CampusSurfaceVariant
                },
                shape = RoundedCornerShape(4.dp)
              ) {
                Text(
                  text = user.role.name,
                  fontSize = 9.sp,
                  fontWeight = FontWeight.Bold,
                  color = when (user.role) {
                    UserRole.ADMIN -> Color(0xFF166534)
                    UserRole.MODERATOR -> Color(0xFF0369A1)
                    UserRole.STUDENT -> CampusTextSecondary
                  },
                  modifier = Modifier.padding(horizontal = 4.dp, vertical = 1.dp)
                )
              }
            }
            Text(
              text = "${user.officialEmail} • ${user.department}",
              fontSize = 11.sp,
              color = CampusTextSecondary,
              maxLines = 1,
              overflow = TextOverflow.Ellipsis
            )
          }
        }

        // Trust Score badge
        Surface(
          color = if (user.trustScore >= 80) Color(0xFFDCFCE7) else Color(0xFFFEF3C7),
          shape = RoundedCornerShape(4.dp)
        ) {
          Text(
            text = "Trust: ${user.trustScore}",
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold,
            color = if (user.trustScore >= 80) Color(0xFF166534) else Color(0xFFB45309),
            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
          )
        }
      }

      if (user.isBlocked && user.blockReason != null) {
        Spacer(modifier = Modifier.height(6.dp))
        Text(
          text = "Blocked: ${user.blockReason}",
          fontSize = 11.sp,
          color = CampusRose,
          fontWeight = FontWeight.Medium
        )
      }

      Spacer(modifier = Modifier.height(8.dp))
      HorizontalDivider(color = CampusBorder.copy(alpha = 0.5f))
      Spacer(modifier = Modifier.height(6.dp))

      // Action row
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.End,
        verticalAlignment = Alignment.CenterVertically
      ) {
        TextButton(
          onClick = onViewDetails,
          contentPadding = PaddingValues(horizontal = 8.dp, vertical = 4.dp)
        ) {
          Text("Details", fontSize = 11.sp)
        }

        TextButton(
          onClick = onWarnClick,
          contentPadding = PaddingValues(horizontal = 8.dp, vertical = 4.dp)
        ) {
          Text("Warn (${user.warningsCount})", fontSize = 11.sp, color = CampusAmber)
        }

        // Role menu
        Box {
          TextButton(
            onClick = { showRoleMenu = true },
            contentPadding = PaddingValues(horizontal = 8.dp, vertical = 4.dp)
          ) {
            Text("Role ▾", fontSize = 11.sp, color = CampusBlue)
          }
          DropdownMenu(
            expanded = showRoleMenu,
            onDismissRequest = { showRoleMenu = false }
          ) {
            DropdownMenuItem(
              text = { Text("Set as Student") },
              onClick = {
                onPromoteRole(UserRole.STUDENT)
                showRoleMenu = false
              }
            )
            DropdownMenuItem(
              text = { Text("Set as Moderator") },
              onClick = {
                onPromoteRole(UserRole.MODERATOR)
                showRoleMenu = false
              }
            )
            DropdownMenuItem(
              text = { Text("Set as Administrator") },
              onClick = {
                onPromoteRole(UserRole.ADMIN)
                showRoleMenu = false
              }
            )
          }
        }

        if (user.isBlocked) {
          Button(
            onClick = onUnblockClick,
            colors = ButtonDefaults.buttonColors(containerColor = CampusTeal),
            contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp),
            modifier = Modifier.height(30.dp)
          ) {
            Text("Unblock", fontSize = 11.sp)
          }
        } else {
          OutlinedButton(
            onClick = onBlockClick,
            colors = ButtonDefaults.outlinedButtonColors(contentColor = CampusRose),
            contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp),
            modifier = Modifier.height(30.dp)
          ) {
            Text("Block", fontSize = 11.sp)
          }
        }
      }
    }
  }
}

// ----------------------------------------------------
// 3. LISTING MANAGEMENT VIEW
// ----------------------------------------------------
@Composable
fun AdminListingsView(
  listings: List<Listing>
) {
  var searchQuery by remember { mutableStateOf("") }
  var selectedCollegeFilter by remember { mutableStateOf("All") }
  var selectedStatusFilter by remember { mutableStateOf<ListingStatus?>(null) }
  var listingToDelete by remember { mutableStateOf<Listing?>(null) }
  var deleteReasonInput by remember { mutableStateOf("") }

  val filteredListings = remember(listings, searchQuery, selectedCollegeFilter, selectedStatusFilter) {
    listings.filter { listing ->
      val matchesSearch = searchQuery.isBlank() ||
          listing.title.contains(searchQuery, ignoreCase = true) ||
          listing.sellerName.contains(searchQuery, ignoreCase = true) ||
          listing.sellerEmail.contains(searchQuery, ignoreCase = true) ||
          listing.category.contains(searchQuery, ignoreCase = true)

      val matchesCollege = selectedCollegeFilter == "All" || listing.collegeId.contains(selectedCollegeFilter, ignoreCase = true)
      val matchesStatus = selectedStatusFilter == null || listing.status == selectedStatusFilter

      matchesSearch && matchesCollege && matchesStatus
    }
  }

  Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
    OutlinedTextField(
      value = searchQuery,
      onValueChange = { searchQuery = it },
      placeholder = { Text("Search listings across all campuses...", fontSize = 12.sp) },
      leadingIcon = { Icon(Icons.Default.Search, contentDescription = null, tint = CampusTextSecondary) },
      trailingIcon = {
        if (searchQuery.isNotEmpty()) {
          IconButton(onClick = { searchQuery = "" }) {
            Icon(Icons.Default.Clear, contentDescription = "Clear")
          }
        }
      },
      singleLine = true,
      shape = RoundedCornerShape(10.dp),
      modifier = Modifier.fillMaxWidth()
    )

    Spacer(modifier = Modifier.height(8.dp))

    // Filter Chips
    Row(
      modifier = Modifier
        .fillMaxWidth()
        .horizontalScroll(rememberScrollState()),
      horizontalArrangement = Arrangement.spacedBy(6.dp)
    ) {
      FilterChip(
        selected = selectedCollegeFilter == "All" && selectedStatusFilter == null,
        onClick = {
          selectedCollegeFilter = "All"
          selectedStatusFilter = null
        },
        label = { Text("All (${listings.size})", fontSize = 11.sp) }
      )
      FilterChip(
        selected = selectedCollegeFilter == "avih",
        onClick = { selectedCollegeFilter = if (selectedCollegeFilter == "avih") "All" else "avih" },
        label = { Text("AVIH", fontSize = 11.sp) }
      )
      FilterChip(
        selected = selectedCollegeFilter == "jntuh",
        onClick = { selectedCollegeFilter = if (selectedCollegeFilter == "jntuh") "All" else "jntuh" },
        label = { Text("JNTUH", fontSize = 11.sp) }
      )
      FilterChip(
        selected = selectedStatusFilter == ListingStatus.FLAGGED,
        onClick = { selectedStatusFilter = if (selectedStatusFilter == ListingStatus.FLAGGED) null else ListingStatus.FLAGGED },
        label = { Text("Flagged", fontSize = 11.sp) },
        colors = FilterChipDefaults.filterChipColors(selectedContainerColor = CampusRose, selectedLabelColor = Color.White)
      )
      FilterChip(
        selected = selectedStatusFilter == ListingStatus.REMOVED,
        onClick = { selectedStatusFilter = if (selectedStatusFilter == ListingStatus.REMOVED) null else ListingStatus.REMOVED },
        label = { Text("Removed / Soft-Deleted", fontSize = 11.sp) }
      )
    }

    Spacer(modifier = Modifier.height(10.dp))

    Text(
      text = "Managing ${filteredListings.size} Listings Across Campuses",
      fontSize = 12.sp,
      fontWeight = FontWeight.Bold,
      color = CampusTextSecondary
    )

    Spacer(modifier = Modifier.height(6.dp))

    LazyColumn(
      verticalArrangement = Arrangement.spacedBy(8.dp),
      modifier = Modifier.fillMaxSize()
    ) {
      items(filteredListings, key = { it.listingId }) { listing ->
        AdminListingItemCard(
          listing = listing,
          onDeleteClick = { listingToDelete = listing },
          onRestoreClick = { MarketplaceRepository.adminRestoreListing(listing.listingId) },
          onFlagClick = { MarketplaceRepository.adminFlagListing(listing.listingId, "Admin flagged for compliance audit") },
          onMarkSoldClick = { MarketplaceRepository.updateListingStatus(listing.listingId, ListingStatus.SOLD) }
        )
      }
    }
  }

  // Delete Dialog
  listingToDelete?.let { listing ->
    AlertDialog(
      onDismissRequest = { listingToDelete = null },
      icon = { Icon(Icons.Default.DeleteForever, contentDescription = null, tint = CampusRose) },
      title = { Text("Soft-Delete Listing") },
      text = {
        Column {
          Text("Are you sure you want to take down '${listing.title}'? The listing will be removed from marketplace but preserved for audit records.")
          Spacer(modifier = Modifier.height(12.dp))
          OutlinedTextField(
            value = deleteReasonInput,
            onValueChange = { deleteReasonInput = it },
            label = { Text("Take Down Reason") },
            placeholder = { Text("e.g. Prohibited item or commercial solicitation") },
            modifier = Modifier.fillMaxWidth()
          )
        }
      },
      confirmButton = {
        Button(
          onClick = {
            MarketplaceRepository.adminDeleteListing(listing.listingId, deleteReasonInput)
            deleteReasonInput = ""
            listingToDelete = null
          },
          colors = ButtonDefaults.buttonColors(containerColor = CampusRose)
        ) {
          Text("Soft-Delete")
        }
      },
      dismissButton = {
        TextButton(onClick = { listingToDelete = null }) {
          Text("Cancel")
        }
      }
    )
  }
}

@Composable
fun AdminListingItemCard(
  listing: Listing,
  onDeleteClick: () -> Unit,
  onRestoreClick: () -> Unit,
  onFlagClick: () -> Unit,
  onMarkSoldClick: () -> Unit
) {
  val isRemoved = listing.status == ListingStatus.REMOVED || listing.isSoftDeleted

  Card(
    shape = RoundedCornerShape(10.dp),
    colors = CardDefaults.cardColors(
      containerColor = if (isRemoved) Color(0xFFF1F5F9) else CampusSurface
    ),
    elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
    modifier = Modifier.fillMaxWidth()
  ) {
    Column(modifier = Modifier.padding(12.dp)) {
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.Top
      ) {
        Column(modifier = Modifier.weight(1f)) {
          Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
              text = "₹${listing.price.toInt()}",
              fontSize = 15.sp,
              fontWeight = FontWeight.ExtraBold,
              color = CampusNavy
            )
            Spacer(modifier = Modifier.width(6.dp))
            Surface(
              color = when (listing.status) {
                ListingStatus.ACTIVE -> Color(0xFFDCFCE7)
                ListingStatus.SOLD -> Color(0xFFF3E8FF)
                ListingStatus.CLOSED -> Color(0xFFF1F5F9)
                ListingStatus.FLAGGED -> Color(0xFFFEF3C7)
                ListingStatus.REMOVED -> Color(0xFFFFE4E6)
              },
              shape = RoundedCornerShape(4.dp)
            ) {
              Text(
                text = listing.status.name,
                fontSize = 9.sp,
                fontWeight = FontWeight.Bold,
                color = when (listing.status) {
                  ListingStatus.ACTIVE -> Color(0xFF166534)
                  ListingStatus.SOLD -> Color(0xFF6B21A8)
                  ListingStatus.CLOSED -> Color(0xFF475569)
                  ListingStatus.FLAGGED -> Color(0xFFB45309)
                  ListingStatus.REMOVED -> Color(0xFFBE123C)
                },
                modifier = Modifier.padding(horizontal = 4.dp, vertical = 1.dp)
              )
            }
          }

          Text(
            text = listing.title,
            fontSize = 13.sp,
            fontWeight = FontWeight.SemiBold,
            color = CampusTextPrimary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
          )

          Text(
            text = "Seller: ${listing.sellerName} (${listing.sellerEmail}) • Campus: ${listing.collegeId}",
            fontSize = 11.sp,
            color = CampusTextSecondary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
          )
        }

        Column(horizontalAlignment = Alignment.End) {
          Text(
            text = "${listing.viewCount} views",
            fontSize = 10.sp,
            color = CampusTextMuted
          )
          Text(
            text = "${listing.chatCount} chats",
            fontSize = 10.sp,
            color = CampusTeal,
            fontWeight = FontWeight.Bold
          )
        }
      }

      if (listing.flagReason != null) {
        Spacer(modifier = Modifier.height(4.dp))
        Text(
          text = "Flag Note: ${listing.flagReason}",
          fontSize = 11.sp,
          color = CampusAmber,
          fontWeight = FontWeight.Medium
        )
      }

      if (listing.deletionReason != null) {
        Spacer(modifier = Modifier.height(4.dp))
        Text(
          text = "Deleted by: ${listing.deletedBy} - ${listing.deletionReason}",
          fontSize = 11.sp,
          color = CampusRose,
          fontWeight = FontWeight.Medium
        )
      }

      Spacer(modifier = Modifier.height(6.dp))
      HorizontalDivider(color = CampusBorder.copy(alpha = 0.5f))
      Spacer(modifier = Modifier.height(4.dp))

      // Action row
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.End,
        verticalAlignment = Alignment.CenterVertically
      ) {
        if (isRemoved) {
          Button(
            onClick = onRestoreClick,
            colors = ButtonDefaults.buttonColors(containerColor = CampusTeal),
            contentPadding = PaddingValues(horizontal = 10.dp, vertical = 2.dp),
            modifier = Modifier.height(28.dp)
          ) {
            Text("Restore Item", fontSize = 11.sp)
          }
        } else {
          TextButton(
            onClick = onMarkSoldClick,
            contentPadding = PaddingValues(horizontal = 8.dp, vertical = 2.dp)
          ) {
            Text("Mark Sold", fontSize = 11.sp)
          }

          if (listing.status != ListingStatus.FLAGGED) {
            TextButton(
              onClick = onFlagClick,
              contentPadding = PaddingValues(horizontal = 8.dp, vertical = 2.dp)
            ) {
              Text("Flag", fontSize = 11.sp, color = CampusAmber)
            }
          }

          OutlinedButton(
            onClick = onDeleteClick,
            colors = ButtonDefaults.outlinedButtonColors(contentColor = CampusRose),
            contentPadding = PaddingValues(horizontal = 8.dp, vertical = 2.dp),
            modifier = Modifier.height(28.dp)
          ) {
            Text("Take Down", fontSize = 11.sp)
          }
        }
      }
    }
  }
}

// ----------------------------------------------------
// 4. REPORTS & MODERATION VIEW
// ----------------------------------------------------
@Composable
fun AdminReportsView(
  reports: List<ReportSubmission>
) {
  var selectedReportForResolution by remember { mutableStateOf<ReportSubmission?>(null) }
  var resolutionActionInput by remember { mutableStateOf("") }
  var moderatorNotesInput by remember { mutableStateOf("") }
  var takeDownListingChecked by remember { mutableStateOf(false) }
  var blockSellerChecked by remember { mutableStateOf(false) }

  val pendingReports = reports.filter { it.status == ReportStatus.PENDING || it.status == ReportStatus.REVIEWED }
  val resolvedReports = reports.filter { it.status == ReportStatus.RESOLVED || it.status == ReportStatus.DISMISSED }

  Column(
    modifier = Modifier
      .fillMaxSize()
      .padding(16.dp)
  ) {
    Text(
      text = "Student Moderation Queue",
      fontSize = 16.sp,
      fontWeight = FontWeight.Bold,
      color = CampusNavy
    )
    Text(
      text = "${pendingReports.size} Pending Review • ${resolvedReports.size} Resolved",
      fontSize = 12.sp,
      color = CampusTextSecondary
    )

    Spacer(modifier = Modifier.height(12.dp))

    LazyColumn(
      verticalArrangement = Arrangement.spacedBy(10.dp),
      modifier = Modifier.fillMaxSize()
    ) {
      if (pendingReports.isNotEmpty()) {
        item {
          Text(
            text = "PENDING REPORTS (${pendingReports.size})",
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold,
            color = CampusRose
          )
        }
        items(pendingReports, key = { it.reportId }) { report ->
          ReportAdminCard(
            report = report,
            onResolveClick = {
              selectedReportForResolution = report
              resolutionActionInput = "Warning issued / Listing modified"
              moderatorNotesInput = "Investigated report; seller contacted."
              takeDownListingChecked = false
              blockSellerChecked = false
            },
            onDismissClick = {
              MarketplaceRepository.adminDismissReport(report.reportId, "No policy violation found.")
            }
          )
        }
      }

      if (resolvedReports.isNotEmpty()) {
        item {
          Spacer(modifier = Modifier.height(8.dp))
          Text(
            text = "RESOLVED & DISMISSED (${resolvedReports.size})",
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold,
            color = CampusTeal
          )
        }
        items(resolvedReports, key = { it.reportId }) { report ->
          ReportAdminCard(
            report = report,
            onResolveClick = {},
            onDismissClick = {}
          )
        }
      }
    }
  }

  // Resolve Report Dialog
  selectedReportForResolution?.let { report ->
    AlertDialog(
      onDismissRequest = { selectedReportForResolution = null },
      icon = { Icon(Icons.Default.Gavel, contentDescription = null, tint = CampusNavy) },
      title = { Text("Resolve Moderation Report") },
      text = {
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
          Text(
            text = "Target Listing: ${report.listingTitle}",
            fontWeight = FontWeight.Bold,
            fontSize = 13.sp
          )
          Text(
            text = "Reported Reason: ${report.reason}",
            fontSize = 12.sp,
            color = CampusRose
          )

          OutlinedTextField(
            value = resolutionActionInput,
            onValueChange = { resolutionActionInput = it },
            label = { Text("Resolution Action Description") },
            modifier = Modifier.fillMaxWidth()
          )

          OutlinedTextField(
            value = moderatorNotesInput,
            onValueChange = { moderatorNotesInput = it },
            label = { Text("Internal Moderator Audit Notes") },
            modifier = Modifier.fillMaxWidth()
          )

          Row(verticalAlignment = Alignment.CenterVertically) {
            Checkbox(
              checked = takeDownListingChecked,
              onCheckedChange = { takeDownListingChecked = it }
            )
            Text("Soft-delete reported listing immediately", fontSize = 12.sp)
          }

          Row(verticalAlignment = Alignment.CenterVertically) {
            Checkbox(
              checked = blockSellerChecked,
              onCheckedChange = { blockSellerChecked = it }
            )
            Text("Block seller campus account", fontSize = 12.sp, color = CampusRose)
          }
        }
      },
      confirmButton = {
        Button(
          onClick = {
            MarketplaceRepository.adminResolveReport(
              reportId = report.reportId,
              action = resolutionActionInput,
              moderatorNotes = moderatorNotesInput,
              takeDownListing = takeDownListingChecked,
              blockSeller = blockSellerChecked
            )
            selectedReportForResolution = null
          },
          colors = ButtonDefaults.buttonColors(containerColor = CampusNavy)
        ) {
          Text("Submit Resolution")
        }
      },
      dismissButton = {
        TextButton(onClick = { selectedReportForResolution = null }) {
          Text("Cancel")
        }
      }
    )
  }
}

@Composable
fun ReportAdminCard(
  report: ReportSubmission,
  onResolveClick: () -> Unit,
  onDismissClick: () -> Unit
) {
  val dateFormat = SimpleDateFormat("dd MMM, HH:mm", Locale.getDefault())
  val isPending = report.status == ReportStatus.PENDING

  Card(
    shape = RoundedCornerShape(12.dp),
    colors = CardDefaults.cardColors(
      containerColor = if (isPending) Color(0xFFFFFBEB) else CampusSurface
    ),
    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    modifier = Modifier.fillMaxWidth()
  ) {
    Column(modifier = Modifier.padding(14.dp)) {
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
      ) {
        Surface(
          color = if (isPending) Color(0xFFFEF3C7) else Color(0xFFDCFCE7),
          shape = RoundedCornerShape(4.dp)
        ) {
          Text(
            text = report.status.label.uppercase(),
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold,
            color = if (isPending) Color(0xFFB45309) else Color(0xFF166534),
            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
          )
        }

        Text(
          text = dateFormat.format(Date(report.createdAt)),
          fontSize = 10.sp,
          color = CampusTextMuted
        )
      }

      Spacer(modifier = Modifier.height(6.dp))

      Text(
        text = report.listingTitle,
        fontSize = 14.sp,
        fontWeight = FontWeight.Bold,
        color = CampusNavy
      )

      Text(
        text = "Reason: ${report.reason}",
        fontSize = 12.sp,
        fontWeight = FontWeight.SemiBold,
        color = CampusRose
      )

      Spacer(modifier = Modifier.height(4.dp))

      Text(
        text = "\"${report.description}\"",
        fontSize = 12.sp,
        color = CampusTextSecondary
      )

      Spacer(modifier = Modifier.height(6.dp))

      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween
      ) {
        Text(
          text = "Reporter: ${report.reporterName}",
          fontSize = 10.sp,
          color = CampusTextMuted
        )
        Text(
          text = "Seller: ${report.sellerName}",
          fontSize = 10.sp,
          color = CampusTextMuted
        )
      }

      if (report.resolutionAction != null) {
        Spacer(modifier = Modifier.height(6.dp))
        Surface(
          color = CampusSurfaceVariant,
          shape = RoundedCornerShape(6.dp),
          modifier = Modifier.fillMaxWidth()
        ) {
          Column(modifier = Modifier.padding(8.dp)) {
            Text(
              text = "Resolution: ${report.resolutionAction}",
              fontSize = 11.sp,
              fontWeight = FontWeight.Bold,
              color = CampusNavy
            )
            if (report.moderatorNotes != null) {
              Text(
                text = "Notes: ${report.moderatorNotes}",
                fontSize = 10.sp,
                color = CampusTextSecondary
              )
            }
          }
        }
      }

      if (isPending) {
        Spacer(modifier = Modifier.height(8.dp))
        HorizontalDivider(color = CampusBorder.copy(alpha = 0.5f))
        Spacer(modifier = Modifier.height(6.dp))

        Row(
          modifier = Modifier.fillMaxWidth(),
          horizontalArrangement = Arrangement.End,
          verticalAlignment = Alignment.CenterVertically
        ) {
          TextButton(
            onClick = onDismissClick,
            colors = ButtonDefaults.textButtonColors(contentColor = CampusTextSecondary)
          ) {
            Text("Dismiss Report", fontSize = 11.sp)
          }

          Spacer(modifier = Modifier.width(8.dp))

          Button(
            onClick = onResolveClick,
            colors = ButtonDefaults.buttonColors(containerColor = CampusNavy),
            contentPadding = PaddingValues(horizontal = 12.dp, vertical = 4.dp),
            modifier = Modifier.height(32.dp)
          ) {
            Icon(Icons.Default.Gavel, contentDescription = null, modifier = Modifier.size(14.dp))
            Spacer(modifier = Modifier.width(4.dp))
            Text("Resolve & Take Action", fontSize = 11.sp)
          }
        }
      }
    }
  }
}

// ----------------------------------------------------
// 5. BLOCKED USERS VIEW
// ----------------------------------------------------
@Composable
fun AdminBlockedUsersView(
  users: List<Student>
) {
  val blockedUsers = users.filter { it.isBlocked || it.status == UserStatus.BLOCKED }

  Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
    Text(
      text = "Blocked Accounts & Enforcement",
      fontSize = 16.sp,
      fontWeight = FontWeight.Bold,
      color = CampusNavy
    )
    Text(
      text = "${blockedUsers.size} restricted student identities under safety enforcement",
      fontSize = 12.sp,
      color = CampusTextSecondary
    )

    Spacer(modifier = Modifier.height(12.dp))

    if (blockedUsers.isEmpty()) {
      Box(
        modifier = Modifier.fillMaxSize().padding(32.dp),
        contentAlignment = Alignment.Center
      ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
          Icon(Icons.Outlined.CheckCircle, contentDescription = null, tint = CampusTeal, modifier = Modifier.size(56.dp))
          Spacer(modifier = Modifier.height(8.dp))
          Text("No Blocked Accounts", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = CampusNavy)
          Text("Campus safety enforcement is currently clean.", fontSize = 12.sp, color = CampusTextSecondary)
        }
      }
    } else {
      LazyColumn(
        verticalArrangement = Arrangement.spacedBy(10.dp),
        modifier = Modifier.fillMaxSize()
      ) {
        items(blockedUsers, key = { it.studentId }) { user ->
          Card(
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(containerColor = Color(0xFFFFF1F2)),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
            modifier = Modifier.fillMaxWidth()
          ) {
            Column(modifier = Modifier.padding(14.dp)) {
              Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
              ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                  Box(
                    modifier = Modifier
                      .size(36.dp)
                      .clip(CircleShape)
                      .background(CampusRose),
                    contentAlignment = Alignment.Center
                  ) {
                    Icon(Icons.Default.Block, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
                  }
                  Spacer(modifier = Modifier.width(10.dp))
                  Column {
                    Text(user.fullName, fontSize = 14.sp, fontWeight = FontWeight.Bold, color = CampusNavy)
                    Text(user.officialEmail, fontSize = 11.sp, color = CampusTextSecondary)
                  }
                }

                Surface(color = Color(0xFFFFE4E6), shape = RoundedCornerShape(4.dp)) {
                  Text(
                    text = "BLOCKED",
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    color = CampusRose,
                    modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                  )
                }
              }

              Spacer(modifier = Modifier.height(8.dp))

              Text(
                text = "Reason: ${user.blockReason ?: "Security policy violation"}",
                fontSize = 12.sp,
                color = CampusRose,
                fontWeight = FontWeight.Medium
              )

              Spacer(modifier = Modifier.height(4.dp))

              Text(
                text = "Campus: ${user.collegeName} • Trust Score: ${user.trustScore}",
                fontSize = 11.sp,
                color = CampusTextMuted
              )

              Spacer(modifier = Modifier.height(10.dp))

              Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                Button(
                  onClick = { MarketplaceRepository.adminUnblockUser(user.studentId) },
                  colors = ButtonDefaults.buttonColors(containerColor = CampusTeal),
                  contentPadding = PaddingValues(horizontal = 12.dp, vertical = 4.dp),
                  modifier = Modifier.height(32.dp)
                ) {
                  Icon(Icons.Default.LockOpen, contentDescription = null, modifier = Modifier.size(14.dp))
                  Spacer(modifier = Modifier.width(4.dp))
                  Text("Unblock & Restore Access", fontSize = 11.sp)
                }
              }
            }
          }
        }
      }
    }
  }
}

// ----------------------------------------------------
// 6. AUDIT LOGS VIEW
// ----------------------------------------------------
@Composable
fun AdminAuditLogsView(
  logs: List<AuditLog>
) {
  val dateFormat = SimpleDateFormat("dd MMM yyyy, HH:mm:ss", Locale.getDefault())

  Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
    Text(
      text = "Security Audit Trail",
      fontSize = 16.sp,
      fontWeight = FontWeight.Bold,
      color = CampusNavy
    )
    Text(
      text = "Immutable compliance record of administrative changes",
      fontSize = 12.sp,
      color = CampusTextSecondary
    )

    Spacer(modifier = Modifier.height(12.dp))

    LazyColumn(
      verticalArrangement = Arrangement.spacedBy(8.dp),
      modifier = Modifier.fillMaxSize()
    ) {
      items(logs, key = { it.logId }) { log ->
        Card(
          shape = RoundedCornerShape(10.dp),
          colors = CardDefaults.cardColors(containerColor = CampusSurface),
          elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
          modifier = Modifier.fillMaxWidth()
        ) {
          Column(modifier = Modifier.padding(12.dp)) {
            Row(
              modifier = Modifier.fillMaxWidth(),
              horizontalArrangement = Arrangement.SpaceBetween,
              verticalAlignment = Alignment.CenterVertically
            ) {
              Surface(
                color = when {
                  log.actionType.contains("BLOCKED") -> Color(0xFFFFE4E6)
                  log.actionType.contains("DELETED") -> Color(0xFFFEF3C7)
                  log.actionType.contains("ROLE") -> Color(0xFFE0F2FE)
                  else -> Color(0xFFDCFCE7)
                },
                shape = RoundedCornerShape(4.dp)
              ) {
                Text(
                  text = log.actionType,
                  fontSize = 10.sp,
                  fontWeight = FontWeight.Bold,
                  color = when {
                    log.actionType.contains("BLOCKED") -> CampusRose
                    log.actionType.contains("DELETED") -> Color(0xFFB45309)
                    log.actionType.contains("ROLE") -> Color(0xFF0369A1)
                    else -> Color(0xFF166534)
                  },
                  modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                )
              }

              Text(
                text = dateFormat.format(Date(log.timestamp)),
                fontSize = 10.sp,
                color = CampusTextMuted
              )
            }

            Spacer(modifier = Modifier.height(6.dp))

            Text(
              text = log.details,
              fontSize = 12.sp,
              color = CampusNavy,
              fontWeight = FontWeight.Medium
            )

            Spacer(modifier = Modifier.height(4.dp))

            Row(
              modifier = Modifier.fillMaxWidth(),
              horizontalArrangement = Arrangement.SpaceBetween
            ) {
              Text(
                text = "Actor: ${log.adminName} (${log.adminEmail})",
                fontSize = 10.sp,
                color = CampusTextSecondary
              )
              Text(
                text = "Target: ${log.targetId}",
                fontSize = 10.sp,
                color = CampusTextMuted
              )
            }
          }
        }
      }
    }
  }
}

// ----------------------------------------------------
// 7. SYSTEM SETTINGS VIEW
// ----------------------------------------------------
@Composable
fun AdminSettingsView(
  settings: SystemSettings,
  currentAdmin: Student
) {
  var maintenanceMode by remember { mutableStateOf(settings.maintenanceMode) }
  var maxPriceLimit by remember { mutableStateOf(settings.maxPriceLimit.toInt().toString()) }
  var autoFlagThreshold by remember { mutableStateOf(settings.autoFlagThreshold.toString()) }
  var saveSuccess by remember { mutableStateOf(false) }

  Column(
    modifier = Modifier
      .fillMaxSize()
      .verticalScroll(rememberScrollState())
      .padding(16.dp),
    verticalArrangement = Arrangement.spacedBy(16.dp)
  ) {
    Text(
      text = "System Security & Campus Policy",
      fontSize = 16.sp,
      fontWeight = FontWeight.Bold,
      color = CampusNavy
    )

    Card(
      shape = RoundedCornerShape(12.dp),
      colors = CardDefaults.cardColors(containerColor = CampusSurface),
      elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
      modifier = Modifier.fillMaxWidth()
    ) {
      Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("Marketplace Governance", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = CampusNavy)

        Row(
          modifier = Modifier.fillMaxWidth(),
          horizontalArrangement = Arrangement.SpaceBetween,
          verticalAlignment = Alignment.CenterVertically
        ) {
          Column(modifier = Modifier.weight(1f)) {
            Text("Emergency Maintenance Mode", fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
            Text("Temporarily halt all new listings and chat messaging across all college campuses", fontSize = 11.sp, color = CampusTextSecondary)
          }
          Switch(checked = maintenanceMode, onCheckedChange = { maintenanceMode = it })
        }

        HorizontalDivider(color = CampusBorder.copy(alpha = 0.5f))

        OutlinedTextField(
          value = maxPriceLimit,
          onValueChange = { maxPriceLimit = it },
          label = { Text("Maximum Item Listing Ceiling (₹)") },
          placeholder = { Text("50000") },
          modifier = Modifier.fillMaxWidth()
        )

        OutlinedTextField(
          value = autoFlagThreshold,
          onValueChange = { autoFlagThreshold = it },
          label = { Text("Auto-Flag Threshold (Report Count)") },
          placeholder = { Text("3") },
          modifier = Modifier.fillMaxWidth()
        )
      }
    }

    Card(
      shape = RoundedCornerShape(12.dp),
      colors = CardDefaults.cardColors(containerColor = CampusSurface),
      elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
      modifier = Modifier.fillMaxWidth()
    ) {
      Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text("Allowed Email Domain Whitelist", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = CampusNavy)
        Text("Only students and faculty with the following verified domains are permitted to authenticate:", fontSize = 12.sp, color = CampusTextSecondary)

        settings.allowedEmailDomains.forEach { domain ->
          Surface(
            color = CampusSurfaceVariant,
            shape = RoundedCornerShape(6.dp),
            modifier = Modifier.fillMaxWidth()
          ) {
            Row(
              modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
              verticalAlignment = Alignment.CenterVertically
            ) {
              Icon(Icons.Default.Check, contentDescription = null, tint = CampusTeal, modifier = Modifier.size(16.dp))
              Spacer(modifier = Modifier.width(8.dp))
              Text(domain, fontSize = 12.sp, fontWeight = FontWeight.Bold, color = CampusNavy)
            }
          }
        }
      }
    }

    Button(
      onClick = {
        val updated = settings.copy(
          maintenanceMode = maintenanceMode,
          maxPriceLimit = maxPriceLimit.toDoubleOrNull() ?: 50000.0,
          autoFlagThreshold = autoFlagThreshold.toIntOrNull() ?: 3
        )
        MarketplaceRepository.adminUpdateSystemSettings(updated)
        saveSuccess = true
      },
      colors = ButtonDefaults.buttonColors(containerColor = CampusNavy),
      shape = RoundedCornerShape(10.dp),
      modifier = Modifier
        .fillMaxWidth()
        .height(48.dp)
        .testTag("save_settings_button")
    ) {
      Icon(Icons.Default.Save, contentDescription = null, modifier = Modifier.size(16.dp))
      Spacer(modifier = Modifier.width(8.dp))
      Text("Save & Apply Security Policies")
    }

    if (saveSuccess) {
      Surface(
        color = Color(0xFFDCFCE7),
        shape = RoundedCornerShape(8.dp),
        modifier = Modifier.fillMaxWidth()
      ) {
        Row(
          modifier = Modifier.padding(12.dp),
          verticalAlignment = Alignment.CenterVertically
        ) {
          Icon(Icons.Default.CheckCircle, contentDescription = null, tint = Color(0xFF166534), modifier = Modifier.size(18.dp))
          Spacer(modifier = Modifier.width(8.dp))
          Text("Security policies successfully updated & broadcasted.", fontSize = 12.sp, color = Color(0xFF166534), fontWeight = FontWeight.Bold)
        }
      }
    }
  }
}

// ----------------------------------------------------
// Role Switcher / Demo Tester Dialog
// ----------------------------------------------------
@Composable
fun AdminRoleSwitcherDialog(
  currentStudent: Student,
  onDismiss: () -> Unit,
  onSelectUser: (Student) -> Unit
) {
  AlertDialog(
    onDismissRequest = onDismiss,
    title = {
      Row(verticalAlignment = Alignment.CenterVertically) {
        Icon(Icons.Default.SupervisorAccount, contentDescription = null, tint = CampusNavy)
        Spacer(modifier = Modifier.width(8.dp))
        Text("Account / Role Switcher", fontSize = 16.sp, fontWeight = FontWeight.Bold)
      }
    },
    text = {
      Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(
          text = "Switch active identity to test Admin panel, Moderator review, and Student isolation barriers:",
          fontSize = 12.sp,
          color = CampusTextSecondary
        )

        Spacer(modifier = Modifier.height(4.dp))

        // Super Admin option
        Button(
          onClick = { onSelectUser(MarketplaceRepository.adminUser) },
          colors = ButtonDefaults.buttonColors(containerColor = CampusNavy),
          modifier = Modifier.fillMaxWidth()
        ) {
          Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text("Dr. Rajesh Sharma (CHIEF ADMIN)", fontWeight = FontWeight.Bold, fontSize = 12.sp)
            Text("Full System Access • All Campuses", fontSize = 10.sp, color = CampusTealLight)
          }
        }

        // Moderator option
        Button(
          onClick = { onSelectUser(MarketplaceRepository.moderatorUser) },
          colors = ButtonDefaults.buttonColors(containerColor = CampusBlue),
          modifier = Modifier.fillMaxWidth()
        ) {
          Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text("Prof. Ananya Rao (CAMPUS MODERATOR)", fontWeight = FontWeight.Bold, fontSize = 12.sp)
            Text("Moderate Reports & Listings", fontSize = 10.sp, color = Color(0xFFDBEAFE))
          }
        }

        // Student option
        OutlinedButton(
          onClick = { onSelectUser(MarketplaceRepository.defaultStudent) },
          modifier = Modifier.fillMaxWidth()
        ) {
          Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text("Venu Madhav (STUDENT - AVIH)", fontWeight = FontWeight.Bold, fontSize = 12.sp)
            Text("Standard Student (Non-Admin)", fontSize = 10.sp, color = CampusTextMuted)
          }
        }
      }
    },
    confirmButton = {},
    dismissButton = {
      TextButton(onClick = onDismiss) {
        Text("Close")
      }
    }
  )
}
