package com.example.data

import com.example.R
import com.example.model.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.util.UUID

object MarketplaceRepository {
  val defaultStudent = Student(
    studentId = "std_avih_2026_01",
    collegeId = "avih-gunthapalli",
    collegeName = "Avanthi Institute of Engineering and Technology (AVIH)",
    officialEmail = "venumadhav@avih.edu.in",
    fullName = "Venu Madhav",
    department = "Computer Science and Engineering",
    graduatingYear = 2026,
    isVerified = true,
    role = UserRole.STUDENT,
    status = UserStatus.ACTIVE,
    isBlocked = false,
    phone = "+91 98765 11223",
    trustScore = 98
  )

  val otherCollegeStudent = Student(
    studentId = "std_jntuh_2026_09",
    collegeId = "jntuh-hyderabad",
    collegeName = "Jawaharlal Nehru Technological University (JNTUH)",
    officialEmail = "student@jntuh.ac.in",
    fullName = "Rahul Sharma",
    department = "Electronics & Communication",
    graduatingYear = 2025,
    isVerified = true,
    role = UserRole.STUDENT,
    status = UserStatus.ACTIVE,
    isBlocked = false,
    phone = "+91 98480 33445",
    trustScore = 95
  )

  val moderatorUser = Student(
    studentId = "mod_avih_2026_01",
    collegeId = "avih-gunthapalli",
    collegeName = "Avanthi Institute of Engineering and Technology (AVIH)",
    officialEmail = "moderator@avih.edu.in",
    fullName = "Prof. Ananya Rao",
    department = "Campus Safety & Student Affairs",
    graduatingYear = 2024,
    isVerified = true,
    role = UserRole.MODERATOR,
    status = UserStatus.ACTIVE,
    isBlocked = false,
    phone = "+91 98490 88776",
    trustScore = 100
  )

  val adminUser = Student(
    studentId = "admin_super_001",
    collegeId = "avih-gunthapalli",
    collegeName = "Campus Central Administration",
    officialEmail = "admin@campus.edu.in",
    fullName = "Dr. Rajesh Sharma",
    department = "Chief Information Security & Campus Administration",
    graduatingYear = 2020,
    isVerified = true,
    role = UserRole.ADMIN,
    status = UserStatus.ACTIVE,
    isBlocked = false,
    phone = "+91 98000 99999",
    trustScore = 100
  )

  private val _currentStudent = MutableStateFlow<Student?>(defaultStudent)
  val currentStudent: StateFlow<Student?> = _currentStudent.asStateFlow()

  private val _allUsers = MutableStateFlow<List<Student>>(emptyList())
  val allUsers: StateFlow<List<Student>> = _allUsers.asStateFlow()

  private val _listings = MutableStateFlow<List<Listing>>(emptyList())
  val listings: StateFlow<List<Listing>> = _listings.asStateFlow()

  private val _conversations = MutableStateFlow<List<Conversation>>(emptyList())
  val conversations: StateFlow<List<Conversation>> = _conversations.asStateFlow()

  private val _messages = MutableStateFlow<Map<String, List<ChatMessage>>>(emptyMap())
  val messages: StateFlow<Map<String, List<ChatMessage>>> = _messages.asStateFlow()

  private val _reports = MutableStateFlow<List<ReportSubmission>>(emptyList())
  val reports: StateFlow<List<ReportSubmission>> = _reports.asStateFlow()

  private val _auditLogs = MutableStateFlow<List<AuditLog>>(emptyList())
  val auditLogs: StateFlow<List<AuditLog>> = _auditLogs.asStateFlow()

  private val _systemSettings = MutableStateFlow(SystemSettings())
  val systemSettings: StateFlow<SystemSettings> = _systemSettings.asStateFlow()

  init {
    seedInitialData()
  }

  private fun seedInitialData() {
    val sampleUsers = listOf(
      adminUser,
      moderatorUser,
      defaultStudent,
      otherCollegeStudent,
      Student(
        studentId = "std_avih_2026_02",
        collegeId = "avih-gunthapalli",
        collegeName = "Avanthi Institute of Engineering and Technology (AVIH)",
        officialEmail = "karthik.r@avih.edu.in",
        fullName = "Karthik Reddy",
        department = "Computer Science and Engineering",
        graduatingYear = 2026,
        isVerified = true,
        role = UserRole.STUDENT,
        status = UserStatus.ACTIVE,
        phone = "+91 91234 56789",
        trustScore = 92
      ),
      Student(
        studentId = "std_avih_2026_03",
        collegeId = "avih-gunthapalli",
        collegeName = "Avanthi Institute of Engineering and Technology (AVIH)",
        officialEmail = "pooja.v@avih.edu.in",
        fullName = "Pooja Verma",
        department = "Mechanical Engineering",
        graduatingYear = 2025,
        isVerified = true,
        role = UserRole.STUDENT,
        status = UserStatus.ACTIVE,
        phone = "+91 99887 66554",
        trustScore = 99
      ),
      Student(
        studentId = "std_avih_2026_04",
        collegeId = "avih-gunthapalli",
        collegeName = "Avanthi Institute of Engineering and Technology (AVIH)",
        officialEmail = "anil.k@avih.edu.in",
        fullName = "Anil Kumar",
        department = "Civil Engineering",
        graduatingYear = 2026,
        isVerified = true,
        role = UserRole.STUDENT,
        status = UserStatus.ACTIVE,
        phone = "+91 94401 22334",
        trustScore = 88
      ),
      Student(
        studentId = "std_avih_2026_05",
        collegeId = "avih-gunthapalli",
        collegeName = "Avanthi Institute of Engineering and Technology (AVIH)",
        officialEmail = "sneha.p@avih.edu.in",
        fullName = "Sneha Patel",
        department = "Information Technology",
        graduatingYear = 2027,
        isVerified = true,
        role = UserRole.STUDENT,
        status = UserStatus.ACTIVE,
        phone = "+91 97765 44332",
        trustScore = 96
      ),
      Student(
        studentId = "std_bad_user_99",
        collegeId = "avih-gunthapalli",
        collegeName = "Avanthi Institute of Engineering and Technology (AVIH)",
        officialEmail = "spammer@avih.edu.in",
        fullName = "Suspected Spammer Account",
        department = "External",
        graduatingYear = 2024,
        isVerified = true,
        role = UserRole.STUDENT,
        status = UserStatus.BLOCKED,
        isBlocked = true,
        blockReason = "Repeated commercial advertisements & prohibited external promotional links",
        warningsCount = 3,
        trustScore = 20,
        phone = "+91 90000 00000"
      )
    )
    _allUsers.value = sampleUsers

    val sampleListings = listOf(
      Listing(
        listingId = "list_java_001",
        collegeId = "avih-gunthapalli",
        sellerId = "std_avih_2026_02",
        sellerName = "Karthik Reddy",
        sellerEmail = "karthik.r@avih.edu.in",
        title = "Java Programming Book",
        description = "Java programming book in good condition. Standard textbook covering Core Java, Collections framework, Multi-threading, and JVM fundamentals with solved university question papers.",
        category = "Academic/Books",
        price = 500.0,
        condition = "Good",
        photoRefs = listOf("photo_java_prog_1.jpg"),
        drawableResId = R.drawable.img_java_book_1787076327185,
        status = ListingStatus.ACTIVE,
        viewCount = 42,
        chatCount = 3,
        createdAt = System.currentTimeMillis() - 1000 * 60 * 120
      ),
      Listing(
        listingId = "list_calc_002",
        collegeId = "avih-gunthapalli",
        sellerId = "std_avih_2026_03",
        sellerName = "Pooja Verma",
        sellerEmail = "pooja.v@avih.edu.in",
        title = "Casio FX-991EX Scientific Calculator",
        description = "Authentic Casio ClassWiz fx-991EX in like-new condition. Essential for engineering mathematics, circuit analysis, and semester exams.",
        category = "Electronics",
        price = 850.0,
        condition = "Like New",
        photoRefs = listOf("photo_calc_1.jpg"),
        drawableResId = null,
        status = ListingStatus.ACTIVE,
        viewCount = 68,
        chatCount = 5,
        createdAt = System.currentTimeMillis() - 1000 * 60 * 360
      ),
      Listing(
        listingId = "list_coat_003",
        collegeId = "avih-gunthapalli",
        sellerId = "std_avih_2026_01",
        sellerName = "Venu Madhav",
        sellerEmail = "venumadhav@avih.edu.in",
        title = "Official Chemistry & Physics Lab Coat (Size M)",
        description = "Standard 100% white cotton lab coat with embroidered college crest. Used for 1 semester, freshly laundered and in good condition.",
        category = "Uniforms/Lab Coats",
        price = 250.0,
        condition = "Good",
        photoRefs = listOf("photo_coat_1.jpg"),
        drawableResId = null,
        status = ListingStatus.ACTIVE,
        viewCount = 29,
        chatCount = 2,
        createdAt = System.currentTimeMillis() - 1000 * 60 * 720
      ),
      Listing(
        listingId = "list_drafter_004",
        collegeId = "avih-gunthapalli",
        sellerId = "std_avih_2026_04",
        sellerName = "Anil Kumar",
        sellerEmail = "anil.k@avih.edu.in",
        title = "Engineering Drawing Mini Drafter with Sheet Holder",
        description = "Omega mini drafter with clamp and heavy duty drawing board clips. No cracks, calibration scale is intact.",
        category = "Stationery",
        price = 380.0,
        condition = "Good",
        photoRefs = listOf("photo_drafter_1.jpg"),
        drawableResId = null,
        status = ListingStatus.ACTIVE,
        viewCount = 18,
        chatCount = 1,
        createdAt = System.currentTimeMillis() - 1000 * 60 * 1440
      ),
      Listing(
        listingId = "list_lamp_005",
        collegeId = "avih-gunthapalli",
        sellerId = "std_avih_2026_05",
        sellerName = "Sneha Patel",
        sellerEmail = "sneha.p@avih.edu.in",
        title = "Rechargeable LED Hostel Desk Lamp",
        description = "Flexible neck LED lamp with 3 brightness modes and built-in pen organizer. Ideal for night-time study in hostel rooms.",
        category = "Hostel Essentials",
        price = 450.0,
        condition = "Like New",
        photoRefs = listOf("photo_lamp_1.jpg"),
        drawableResId = null,
        status = ListingStatus.ACTIVE,
        viewCount = 53,
        chatCount = 4,
        createdAt = System.currentTimeMillis() - 1000 * 60 * 2000
      ),
      Listing(
        listingId = "list_prohibited_006",
        collegeId = "avih-gunthapalli",
        sellerId = "std_bad_user_99",
        sellerName = "Suspected Spammer Account",
        sellerEmail = "spammer@avih.edu.in",
        title = "Commercial Coaching Notes Bundle [Suspicious]",
        description = "External coaching institute bulk materials printed commercially.",
        category = "Academic/Books",
        price = 2999.0,
        condition = "Good",
        status = ListingStatus.FLAGGED,
        flagReason = "Reported by multiple students as unauthorized commercial sale",
        viewCount = 14,
        chatCount = 0,
        createdAt = System.currentTimeMillis() - 1000 * 60 * 3000
      )
    )

    _listings.value = sampleListings

    val sampleConvo = Conversation(
      conversationId = "conv_java_001",
      listingId = "list_java_001",
      listingTitle = "Java Programming Book",
      listingPrice = 500.0,
      otherUserId = "std_avih_2026_02",
      otherUserName = "Karthik Reddy",
      lastMessage = "Hi! Is the Java book still available? Can we meet at the Central Library?",
      lastMessageTime = System.currentTimeMillis() - 1000 * 60 * 15,
      unreadCount = 1
    )

    _conversations.value = listOf(sampleConvo)

    _messages.value = mapOf(
      "conv_java_001" to listOf(
        ChatMessage(
          messageId = "msg_1",
          conversationId = "conv_java_001",
          senderId = "std_avih_2026_01",
          senderName = "Venu Madhav",
          recipientId = "std_avih_2026_02",
          content = "Hi Karthik! I saw your listing for the Java Programming textbook.",
          timestamp = System.currentTimeMillis() - 1000 * 60 * 30,
          isFromMe = true
        ),
        ChatMessage(
          messageId = "msg_2",
          conversationId = "conv_java_001",
          senderId = "std_avih_2026_02",
          senderName = "Karthik Reddy",
          recipientId = "std_avih_2026_01",
          content = "Hey Venu! Yes, it is still available. All pages are clean with no highlights.",
          timestamp = System.currentTimeMillis() - 1000 * 60 * 25,
          isFromMe = false
        ),
        ChatMessage(
          messageId = "msg_3",
          conversationId = "conv_java_001",
          senderId = "std_avih_2026_01",
          senderName = "Venu Madhav",
          recipientId = "std_avih_2026_02",
          content = "Awesome! Can we meet at the Central Library around 4:30 PM today?",
          timestamp = System.currentTimeMillis() - 1000 * 60 * 15,
          isFromMe = true
        )
      )
    )

    val sampleReports = listOf(
      ReportSubmission(
        reportId = "rep_init_001",
        listingId = "list_prohibited_006",
        listingTitle = "Commercial Coaching Notes Bundle [Suspicious]",
        sellerName = "Suspected Spammer Account",
        sellerEmail = "spammer@avih.edu.in",
        reporterStudentId = "std_avih_2026_01",
        reporterName = "Venu Madhav",
        reporterEmail = "venumadhav@avih.edu.in",
        collegeId = "avih-gunthapalli",
        reason = "Incorrect Price or Commercial Seller",
        description = "This user is selling commercial coaching materials which violates peer-to-peer student policy.",
        status = ReportStatus.PENDING,
        createdAt = System.currentTimeMillis() - 1000 * 60 * 90
      ),
      ReportSubmission(
        reportId = "rep_init_002",
        listingId = "list_calc_002",
        listingTitle = "Casio FX-991EX Scientific Calculator",
        sellerName = "Pooja Verma",
        sellerEmail = "pooja.v@avih.edu.in",
        reporterStudentId = "std_avih_2026_04",
        reporterName = "Anil Kumar",
        reporterEmail = "anil.k@avih.edu.in",
        collegeId = "avih-gunthapalli",
        reason = "Misleading Condition or Details",
        description = "Just asking if warranty is included, checked condition verified fine.",
        status = ReportStatus.RESOLVED,
        resolvedBy = "admin@campus.edu.in",
        resolvedAt = System.currentTimeMillis() - 1000 * 60 * 30,
        resolutionAction = "Listing verified authentic, seller warned to clarify warranty note.",
        moderatorNotes = "Verified legitimate student seller. Closed report.",
        createdAt = System.currentTimeMillis() - 1000 * 60 * 300
      )
    )
    _reports.value = sampleReports

    val sampleAudit = listOf(
      AuditLog(
        logId = "log_001",
        adminId = adminUser.studentId,
        adminName = adminUser.fullName,
        adminEmail = adminUser.officialEmail,
        actionType = "SYSTEM_INITIALIZED",
        targetId = "SYS_CAMPUS_EXCHANGE",
        targetType = "SYSTEM",
        details = "Campus Exchange RBAC security layer and database partition initialized.",
        timestamp = System.currentTimeMillis() - 1000 * 60 * 60 * 24
      ),
      AuditLog(
        logId = "log_002",
        adminId = adminUser.studentId,
        adminName = adminUser.fullName,
        adminEmail = adminUser.officialEmail,
        actionType = "USER_BLOCKED",
        targetId = "std_bad_user_99",
        targetType = "USER",
        details = "Blocked user for unauthorized commercial advertisements & suspicious spam.",
        timestamp = System.currentTimeMillis() - 1000 * 60 * 60 * 12
      ),
      AuditLog(
        logId = "log_003",
        adminId = adminUser.studentId,
        adminName = adminUser.fullName,
        adminEmail = adminUser.officialEmail,
        actionType = "LISTING_FLAGGED",
        targetId = "list_prohibited_006",
        targetType = "LISTING",
        details = "Flagged listing for administrative review following student report.",
        timestamp = System.currentTimeMillis() - 1000 * 60 * 60 * 2
      )
    )
    _auditLogs.value = sampleAudit
  }

  // --- Security Check Helper ---
  fun requireAdminAuthorization(): Result<Student> {
    val student = _currentStudent.value
      ?: return Result.failure(SecurityException("Unauthorized: No authenticated session found."))

    if (student.role != UserRole.ADMIN && student.role != UserRole.MODERATOR) {
      logAudit(
        actionType = "UNAUTHORIZED_ADMIN_ACCESS_ATTEMPT",
        targetId = student.studentId,
        targetType = "SECURITY_BREACH_ATTEMPT",
        details = "User ${student.fullName} (${student.officialEmail}) attempted to access admin privileges without valid role."
      )
      return Result.failure(SecurityException("Unauthorized: User ${student.fullName} is not an authorized Administrator."))
    }
    return Result.success(student)
  }

  fun requireStrictAdmin(): Result<Student> {
    val student = _currentStudent.value
      ?: return Result.failure(SecurityException("Unauthorized: No authenticated session found."))

    if (student.role != UserRole.ADMIN) {
      return Result.failure(SecurityException("Unauthorized: This action requires Chief Administrator authorization."))
    }
    return Result.success(student)
  }

  private fun logAudit(
    actionType: String,
    targetId: String,
    targetType: String,
    details: String
  ) {
    val current = _currentStudent.value ?: adminUser
    val log = AuditLog(
      logId = "log_${UUID.randomUUID().toString().substring(0, 8)}",
      adminId = current.studentId,
      adminName = current.fullName,
      adminEmail = current.officialEmail,
      actionType = actionType,
      targetId = targetId,
      targetType = targetType,
      details = details,
      timestamp = System.currentTimeMillis()
    )
    _auditLogs.value = listOf(log) + _auditLogs.value
  }

  // --- Admin User Management Methods ---
  fun adminGetUsers(): Result<List<Student>> {
    val auth = requireAdminAuthorization()
    if (auth.isFailure) return Result.failure(auth.exceptionOrNull()!!)
    return Result.success(_allUsers.value)
  }

  fun adminBlockUser(studentId: String, reason: String): Result<Student> {
    val auth = requireAdminAuthorization()
    if (auth.isFailure) return Result.failure(auth.exceptionOrNull()!!)

    val user = _allUsers.value.find { it.studentId == studentId }
      ?: return Result.failure(NoSuchElementException("User not found"))

    val updated = user.copy(
      status = UserStatus.BLOCKED,
      isBlocked = true,
      blockReason = reason.ifBlank { "Account blocked by administrator for policy violation." }
    )

    _allUsers.value = _allUsers.value.map { if (it.studentId == studentId) updated else it }

    // If active user is blocked, update currentStudent if it matches
    if (_currentStudent.value?.studentId == studentId) {
      _currentStudent.value = updated
    }

    logAudit(
      actionType = "USER_BLOCKED",
      targetId = studentId,
      targetType = "USER",
      details = "Blocked user ${user.fullName} (${user.officialEmail}). Reason: $reason"
    )

    return Result.success(updated)
  }

  fun adminUnblockUser(studentId: String): Result<Student> {
    val auth = requireAdminAuthorization()
    if (auth.isFailure) return Result.failure(auth.exceptionOrNull()!!)

    val user = _allUsers.value.find { it.studentId == studentId }
      ?: return Result.failure(NoSuchElementException("User not found"))

    val updated = user.copy(
      status = UserStatus.ACTIVE,
      isBlocked = false,
      blockReason = null
    )

    _allUsers.value = _allUsers.value.map { if (it.studentId == studentId) updated else it }

    if (_currentStudent.value?.studentId == studentId) {
      _currentStudent.value = updated
    }

    logAudit(
      actionType = "USER_UNBLOCKED",
      targetId = studentId,
      targetType = "USER",
      details = "Restored user ${user.fullName} (${user.officialEmail}) to active status."
    )

    return Result.success(updated)
  }

  fun adminSetUserRole(studentId: String, newRole: UserRole): Result<Student> {
    val auth = requireStrictAdmin()
    if (auth.isFailure) return Result.failure(auth.exceptionOrNull()!!)

    val user = _allUsers.value.find { it.studentId == studentId }
      ?: return Result.failure(NoSuchElementException("User not found"))

    val updated = user.copy(role = newRole)
    _allUsers.value = _allUsers.value.map { if (it.studentId == studentId) updated else it }

    if (_currentStudent.value?.studentId == studentId) {
      _currentStudent.value = updated
    }

    logAudit(
      actionType = "USER_ROLE_CHANGED",
      targetId = studentId,
      targetType = "USER",
      details = "Changed role of ${user.fullName} to ${newRole.label}."
    )

    return Result.success(updated)
  }

  fun adminWarnUser(studentId: String, warningMessage: String): Result<Student> {
    val auth = requireAdminAuthorization()
    if (auth.isFailure) return Result.failure(auth.exceptionOrNull()!!)

    val user = _allUsers.value.find { it.studentId == studentId }
      ?: return Result.failure(NoSuchElementException("User not found"))

    val newWarnings = user.warningsCount + 1
    val newScore = (user.trustScore - 15).coerceAtLeast(0)
    val updated = user.copy(
      warningsCount = newWarnings,
      trustScore = newScore,
      status = if (newWarnings >= 3) UserStatus.SUSPENDED else user.status
    )

    _allUsers.value = _allUsers.value.map { if (it.studentId == studentId) updated else it }

    logAudit(
      actionType = "USER_WARNED",
      targetId = studentId,
      targetType = "USER",
      details = "Issued warning #$newWarnings to ${user.fullName}. Trust score reduced to $newScore. Note: $warningMessage"
    )

    return Result.success(updated)
  }

  // --- Admin Listing Management Methods ---
  fun adminGetAllListings(): Result<List<Listing>> {
    val auth = requireAdminAuthorization()
    if (auth.isFailure) return Result.failure(auth.exceptionOrNull()!!)
    return Result.success(_listings.value)
  }

  fun adminDeleteListing(listingId: String, reason: String): Result<Listing> {
    val auth = requireAdminAuthorization()
    if (auth.isFailure) return Result.failure(auth.exceptionOrNull()!!)

    val listing = _listings.value.find { it.listingId == listingId }
      ?: return Result.failure(NoSuchElementException("Listing not found"))

    val current = auth.getOrNull() ?: adminUser
    val updated = listing.copy(
      status = ListingStatus.REMOVED,
      isSoftDeleted = true,
      deletedAt = System.currentTimeMillis(),
      deletedBy = current.officialEmail,
      deletionReason = reason.ifBlank { "Removed by admin for terms violation." }
    )

    _listings.value = _listings.value.map { if (it.listingId == listingId) updated else it }

    logAudit(
      actionType = "LISTING_SOFT_DELETED",
      targetId = listingId,
      targetType = "LISTING",
      details = "Soft-deleted listing '${listing.title}' (Seller: ${listing.sellerEmail}). Reason: $reason"
    )

    return Result.success(updated)
  }

  fun adminRestoreListing(listingId: String): Result<Listing> {
    val auth = requireAdminAuthorization()
    if (auth.isFailure) return Result.failure(auth.exceptionOrNull()!!)

    val listing = _listings.value.find { it.listingId == listingId }
      ?: return Result.failure(NoSuchElementException("Listing not found"))

    val updated = listing.copy(
      status = ListingStatus.ACTIVE,
      isSoftDeleted = false,
      deletedAt = null,
      deletedBy = null,
      deletionReason = null,
      flagReason = null
    )

    _listings.value = _listings.value.map { if (it.listingId == listingId) updated else it }

    logAudit(
      actionType = "LISTING_RESTORED",
      targetId = listingId,
      targetType = "LISTING",
      details = "Restored listing '${listing.title}' to ACTIVE marketplace state."
    )

    return Result.success(updated)
  }

  fun adminFlagListing(listingId: String, reason: String): Result<Listing> {
    val auth = requireAdminAuthorization()
    if (auth.isFailure) return Result.failure(auth.exceptionOrNull()!!)

    val listing = _listings.value.find { it.listingId == listingId }
      ?: return Result.failure(NoSuchElementException("Listing not found"))

    val updated = listing.copy(
      status = ListingStatus.FLAGGED,
      flagReason = reason
    )

    _listings.value = _listings.value.map { if (it.listingId == listingId) updated else it }

    logAudit(
      actionType = "LISTING_FLAGGED",
      targetId = listingId,
      targetType = "LISTING",
      details = "Flagged listing '${listing.title}'. Reason: $reason"
    )

    return Result.success(updated)
  }

  // --- Admin Moderation & Reports Methods ---
  fun adminGetReports(): Result<List<ReportSubmission>> {
    val auth = requireAdminAuthorization()
    if (auth.isFailure) return Result.failure(auth.exceptionOrNull()!!)
    return Result.success(_reports.value)
  }

  fun adminResolveReport(
    reportId: String,
    action: String,
    moderatorNotes: String,
    takeDownListing: Boolean = false,
    blockSeller: Boolean = false
  ): Result<ReportSubmission> {
    val auth = requireAdminAuthorization()
    if (auth.isFailure) return Result.failure(auth.exceptionOrNull()!!)

    val report = _reports.value.find { it.reportId == reportId }
      ?: return Result.failure(NoSuchElementException("Report not found"))

    val current = auth.getOrNull() ?: adminUser
    val updated = report.copy(
      status = ReportStatus.RESOLVED,
      resolvedBy = current.officialEmail,
      resolvedAt = System.currentTimeMillis(),
      resolutionAction = action,
      moderatorNotes = moderatorNotes
    )

    _reports.value = _reports.value.map { if (it.reportId == reportId) updated else it }

    if (takeDownListing) {
      adminDeleteListing(report.listingId, "Removed via resolution of report #$reportId")
    }

    if (blockSeller) {
      val listing = _listings.value.find { it.listingId == report.listingId }
      if (listing != null) {
        adminBlockUser(listing.sellerId, "Account blocked during report #$reportId moderation.")
      }
    }

    logAudit(
      actionType = "REPORT_RESOLVED",
      targetId = reportId,
      targetType = "REPORT",
      details = "Resolved report against '${report.listingTitle}'. Action: $action. Takedown: $takeDownListing, Block Seller: $blockSeller"
    )

    return Result.success(updated)
  }

  fun adminDismissReport(reportId: String, reason: String): Result<ReportSubmission> {
    val auth = requireAdminAuthorization()
    if (auth.isFailure) return Result.failure(auth.exceptionOrNull()!!)

    val report = _reports.value.find { it.reportId == reportId }
      ?: return Result.failure(NoSuchElementException("Report not found"))

    val current = auth.getOrNull() ?: adminUser
    val updated = report.copy(
      status = ReportStatus.DISMISSED,
      resolvedBy = current.officialEmail,
      resolvedAt = System.currentTimeMillis(),
      resolutionAction = "Dismissed - No Violation Found",
      moderatorNotes = reason
    )

    _reports.value = _reports.value.map { if (it.reportId == reportId) updated else it }

    logAudit(
      actionType = "REPORT_DISMISSED",
      targetId = reportId,
      targetType = "REPORT",
      details = "Dismissed report #$reportId for '${report.listingTitle}'. Reason: $reason"
    )

    return Result.success(updated)
  }

  // --- Admin Security & System Settings ---
  fun adminGetAuditLogs(): Result<List<AuditLog>> {
    val auth = requireAdminAuthorization()
    if (auth.isFailure) return Result.failure(auth.exceptionOrNull()!!)
    return Result.success(_auditLogs.value)
  }

  fun adminUpdateSystemSettings(settings: SystemSettings): Result<SystemSettings> {
    val auth = requireStrictAdmin()
    if (auth.isFailure) return Result.failure(auth.exceptionOrNull()!!)

    _systemSettings.value = settings

    logAudit(
      actionType = "SYSTEM_SETTINGS_UPDATED",
      targetId = "SYS_CONFIG",
      targetType = "SYSTEM",
      details = "Updated system security configuration. Maintenance: ${settings.maintenanceMode}, Max Price: ₹${settings.maxPriceLimit}"
    )

    return Result.success(settings)
  }

  fun adminGetOverviewStats(): Result<AdminOverviewStats> {
    val auth = requireAdminAuthorization()
    if (auth.isFailure) return Result.failure(auth.exceptionOrNull()!!)

    val allU = _allUsers.value
    val allL = _listings.value
    val allR = _reports.value

    val collegeCount = allL.groupBy { it.collegeId }.mapValues { it.value.size }

    return Result.success(
      AdminOverviewStats(
        totalUsers = allU.size,
        activeUsers = allU.count { it.status == UserStatus.ACTIVE },
        blockedUsers = allU.count { it.isBlocked || it.status == UserStatus.BLOCKED },
        totalListings = allL.size,
        activeListings = allL.count { it.status == ListingStatus.ACTIVE },
        soldListings = allL.count { it.status == ListingStatus.SOLD },
        removedListings = allL.count { it.status == ListingStatus.REMOVED || it.isSoftDeleted },
        totalReports = allR.size,
        pendingReports = allR.count { it.status == ReportStatus.PENDING || it.status == ReportStatus.REVIEWED },
        resolvedReports = allR.count { it.status == ReportStatus.RESOLVED },
        totalTransactionValue = allL.filter { it.status == ListingStatus.SOLD }.sumOf { it.price },
        collegeStats = collegeCount
      )
    )
  }

  // --- Standard User Operations ---
  fun createListing(
    title: String,
    price: Double,
    condition: String,
    category: String,
    description: String,
    photoRefs: List<String> = emptyList(),
    drawableResId: Int? = null
  ): Result<Listing> {
    val student = _currentStudent.value
      ?: return Result.failure(IllegalStateException("Must be signed in with verified student email"))

    if (student.isBlocked || student.status == UserStatus.BLOCKED) {
      return Result.failure(IllegalStateException("Your account is currently blocked by administration. Posting listings is disabled."))
    }

    if (title.trim().length < 3) {
      return Result.failure(IllegalArgumentException("Title must be at least 3 characters"))
    }
    if (price <= 0 || price > _systemSettings.value.maxPriceLimit) {
      return Result.failure(IllegalArgumentException("Price must be between ₹1 and ₹${_systemSettings.value.maxPriceLimit.toInt()}"))
    }
    if (description.trim().length < 5) {
      return Result.failure(IllegalArgumentException("Description must be at least 5 characters"))
    }

    val newListing = Listing(
      listingId = "list_${UUID.randomUUID().toString().substring(0, 8)}",
      collegeId = student.collegeId,
      sellerId = student.studentId,
      sellerName = student.fullName,
      sellerEmail = student.officialEmail,
      title = title.trim(),
      description = description.trim(),
      category = category,
      price = price,
      condition = condition,
      photoRefs = if (photoRefs.isEmpty()) listOf("photo_user_upload_${System.currentTimeMillis()}.jpg") else photoRefs,
      drawableResId = drawableResId ?: if (title.contains("Java", ignoreCase = true)) R.drawable.img_java_book_1787076327185 else null,
      status = ListingStatus.ACTIVE,
      viewCount = 1,
      chatCount = 0,
      createdAt = System.currentTimeMillis()
    )

    _listings.value = listOf(newListing) + _listings.value
    return Result.success(newListing)
  }

  fun updateListing(
    listingId: String,
    title: String,
    price: Double,
    condition: String,
    category: String,
    description: String
  ): Result<Listing> {
    val current = _listings.value.find { it.listingId == listingId }
      ?: return Result.failure(NoSuchElementException("Listing not found"))

    val updated = current.copy(
      title = title.trim(),
      price = price,
      condition = condition,
      category = category,
      description = description.trim()
    )

    _listings.value = _listings.value.map { if (it.listingId == listingId) updated else it }
    return Result.success(updated)
  }

  fun updateListingStatus(listingId: String, newStatus: ListingStatus): Result<Listing> {
    val current = _listings.value.find { it.listingId == listingId }
      ?: return Result.failure(NoSuchElementException("Listing not found"))

    val updated = current.copy(status = newStatus)
    _listings.value = _listings.value.map { if (it.listingId == listingId) updated else it }
    return Result.success(updated)
  }

  fun incrementViewCount(listingId: String) {
    _listings.value = _listings.value.map {
      if (it.listingId == listingId) it.copy(viewCount = it.viewCount + 1) else it
    }
  }

  fun sendMessage(listingId: String, recipientId: String, recipientName: String, text: String): ChatMessage {
    val student = _currentStudent.value ?: defaultStudent
    val listing = _listings.value.find { it.listingId == listingId }

    val convId = "conv_${listingId}_${student.studentId}"
    val newMsg = ChatMessage(
      messageId = "msg_${UUID.randomUUID().toString().substring(0, 8)}",
      conversationId = convId,
      senderId = student.studentId,
      senderName = student.fullName,
      recipientId = recipientId,
      content = text,
      timestamp = System.currentTimeMillis(),
      isFromMe = true
    )

    val currentMsgList = _messages.value[convId] ?: emptyList()
    val updatedMap = _messages.value.toMutableMap()
    updatedMap[convId] = currentMsgList + newMsg
    _messages.value = updatedMap

    val existingConv = _conversations.value.find { it.conversationId == convId }
    val updatedConv = existingConv?.copy(
      lastMessage = text,
      lastMessageTime = System.currentTimeMillis()
    ) ?: Conversation(
      conversationId = convId,
      listingId = listingId,
      listingTitle = listing?.title ?: "Listing #$listingId",
      listingPrice = listing?.price ?: 0.0,
      otherUserId = recipientId,
      otherUserName = recipientName,
      lastMessage = text,
      lastMessageTime = System.currentTimeMillis(),
      unreadCount = 0
    )

    _conversations.value = listOf(updatedConv) + _conversations.value.filter { it.conversationId != convId }

    _listings.value = _listings.value.map {
      if (it.listingId == listingId) it.copy(chatCount = it.chatCount + 1) else it
    }

    return newMsg
  }

  fun submitReport(listingId: String, reason: String, description: String): Result<ReportSubmission> {
    val student = _currentStudent.value ?: defaultStudent
    val listing = _listings.value.find { it.listingId == listingId }

    val report = ReportSubmission(
      reportId = "rep_${UUID.randomUUID().toString().substring(0, 8)}",
      listingId = listingId,
      listingTitle = listing?.title ?: "Listing #$listingId",
      sellerName = listing?.sellerName ?: "Seller",
      sellerEmail = listing?.sellerEmail ?: "seller@campus.edu.in",
      reporterStudentId = student.studentId,
      reporterName = student.fullName,
      reporterEmail = student.officialEmail,
      collegeId = student.collegeId,
      reason = reason,
      description = description,
      status = ReportStatus.PENDING
    )
    _reports.value = listOf(report) + _reports.value
    return Result.success(report)
  }

  fun switchStudent(student: Student) {
    _currentStudent.value = student
    // Ensure student is registered in allUsers
    if (_allUsers.value.none { it.studentId == student.studentId }) {
      _allUsers.value = _allUsers.value + student
    }
  }

  fun loginWithCollegeEmail(email: String, fullName: String, department: String): Result<Student> {
    val trimmed = email.trim().lowercase()
    val allowed = _systemSettings.value.allowedEmailDomains
    val isDomainAllowed = allowed.any { trimmed.endsWith(it) }

    if (!isDomainAllowed) {
      return Result.failure(IllegalArgumentException("Must be an official college email domain (.edu.in / .ac.in)"))
    }

    val collegeId = if (trimmed.contains("avih")) "avih-gunthapalli" else "jntuh-hyderabad"
    val collegeName = if (trimmed.contains("avih")) {
      "Avanthi Institute of Engineering and Technology (AVIH)"
    } else {
      "Jawaharlal Nehru Technological University (JNTUH)"
    }

    val isAdm = trimmed.startsWith("admin")
    val role = if (isAdm) UserRole.ADMIN else UserRole.STUDENT

    val student = Student(
      studentId = "std_${trimmed.substringBefore("@")}",
      collegeId = collegeId,
      collegeName = collegeName,
      officialEmail = trimmed,
      fullName = fullName.ifBlank { if (isAdm) "Campus Administrator" else "Verified Student" },
      department = department.ifBlank { "Computer Science and Engineering" },
      graduatingYear = 2026,
      isVerified = true,
      role = role,
      status = UserStatus.ACTIVE,
      phone = "+91 98765 00000"
    )

    switchStudent(student)
    return Result.success(student)
  }

  fun getMetrics(): PilotMetrics {
    val student = _currentStudent.value ?: defaultStudent
    val collegeListings = _listings.value.filter { it.collegeId == student.collegeId && !it.isSoftDeleted }
    val totalActive = collegeListings.count { it.status == ListingStatus.ACTIVE }
    val totalSold = collegeListings.count { it.status == ListingStatus.SOLD }
    val totalViews = collegeListings.sumOf { it.viewCount }
    val totalChats = collegeListings.sumOf { it.chatCount }

    val listingToChatRate = if (collegeListings.isNotEmpty()) {
      (collegeListings.count { it.chatCount > 0 }.toDouble() / collegeListings.size.toDouble()) * 100.0
    } else 0.0

    val listingToSaleRate = if (collegeListings.isNotEmpty()) {
      (totalSold.toDouble() / collegeListings.size.toDouble()) * 100.0
    } else 0.0

    return PilotMetrics(
      totalActiveListings = totalActive,
      totalViews = totalViews,
      conversationsInitiated = totalChats,
      itemsSold = totalSold,
      listingToChatRate = (listingToChatRate * 10).toInt() / 10.0,
      listingToSaleRate = (listingToSaleRate * 10).toInt() / 10.0,
      averageResponseMinutes = 18
    )
  }
}

