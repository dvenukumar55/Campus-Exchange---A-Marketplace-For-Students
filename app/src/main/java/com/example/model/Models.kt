package com.example.model

enum class UserRole(val label: String) {
  STUDENT("Student"),
  MODERATOR("Campus Moderator"),
  ADMIN("System Administrator")
}

enum class UserStatus(val label: String) {
  ACTIVE("Active"),
  BLOCKED("Blocked"),
  SUSPENDED("Suspended")
}

enum class ListingStatus(val label: String) {
  ACTIVE("Active"),
  SOLD("Sold"),
  CLOSED("Closed"),
  FLAGGED("Flagged for Review"),
  REMOVED("Removed by Admin")
}

enum class ReportStatus(val label: String) {
  PENDING("Pending Review"),
  REVIEWED("Under Review"),
  RESOLVED("Resolved - Action Taken"),
  DISMISSED("Dismissed")
}

enum class ItemCondition(val label: String) {
  NEW("Brand New"),
  LIKE_NEW("Like New"),
  GOOD("Good"),
  FAIR("Fair")
}

object Categories {
  val ALL = listOf(
    "All",
    "Academic/Books",
    "Electronics",
    "Stationery",
    "Uniforms/Lab Coats",
    "Hostel Essentials"
  )
}

object ReportReasons {
  val ALL = listOf(
    "Misleading Condition or Details",
    "Incorrect Price or Commercial Seller",
    "Prohibited or Ineligible Item",
    "Harassment or Inappropriate Behavior",
    "Suspected Counterfeit or Fraud"
  )
}

data class Student(
  val studentId: String,
  val collegeId: String,
  val collegeName: String,
  val officialEmail: String,
  val fullName: String,
  val department: String,
  val graduatingYear: Int,
  val isVerified: Boolean = true,
  val role: UserRole = UserRole.STUDENT,
  val status: UserStatus = UserStatus.ACTIVE,
  val isBlocked: Boolean = false,
  val blockReason: String? = null,
  val warningsCount: Int = 0,
  val trustScore: Int = 100,
  val phone: String = "+91 98765 43210",
  val joinedAt: Long = System.currentTimeMillis() - 1000L * 60 * 60 * 24 * 30,
  val lastActiveAt: Long = System.currentTimeMillis()
)

data class Listing(
  val listingId: String,
  val collegeId: String,
  val sellerId: String,
  val sellerName: String,
  val sellerEmail: String,
  val title: String,
  val description: String,
  val category: String,
  val price: Double,
  val condition: String,
  val photoRefs: List<String> = emptyList(),
  val drawableResId: Int? = null,
  val status: ListingStatus = ListingStatus.ACTIVE,
  val isSoftDeleted: Boolean = false,
  val deletedAt: Long? = null,
  val deletedBy: String? = null,
  val deletionReason: String? = null,
  val flagReason: String? = null,
  val moderationNotes: String? = null,
  val viewCount: Int = 0,
  val chatCount: Int = 0,
  val createdAt: Long = System.currentTimeMillis()
)

data class ChatMessage(
  val messageId: String,
  val conversationId: String,
  val senderId: String,
  val senderName: String,
  val recipientId: String,
  val content: String,
  val timestamp: Long = System.currentTimeMillis(),
  val isFromMe: Boolean = true
)

data class Conversation(
  val conversationId: String,
  val listingId: String,
  val listingTitle: String,
  val listingPrice: Double,
  val otherUserId: String,
  val otherUserName: String,
  val lastMessage: String,
  val lastMessageTime: Long = System.currentTimeMillis(),
  val unreadCount: Int = 0
)

data class ReportSubmission(
  val reportId: String,
  val listingId: String,
  val listingTitle: String = "Reported Item",
  val sellerName: String = "Seller",
  val sellerEmail: String = "seller@campus.edu.in",
  val reporterStudentId: String,
  val reporterName: String = "Student Reporter",
  val reporterEmail: String = "reporter@campus.edu.in",
  val collegeId: String,
  val reason: String,
  val description: String,
  val status: ReportStatus = ReportStatus.PENDING,
  val resolvedBy: String? = null,
  val resolvedAt: Long? = null,
  val resolutionAction: String? = null,
  val moderatorNotes: String? = null,
  val createdAt: Long = System.currentTimeMillis()
)

data class AuditLog(
  val logId: String,
  val adminId: String,
  val adminName: String,
  val adminEmail: String,
  val actionType: String,
  val targetId: String,
  val targetType: String,
  val details: String,
  val timestamp: Long = System.currentTimeMillis(),
  val ipAddress: String = "192.168.1.104"
)

data class SystemSettings(
  val maintenanceMode: Boolean = false,
  val registrationOpen: Boolean = true,
  val maxPriceLimit: Double = 50000.0,
  val autoFlagThreshold: Int = 3,
  val allowedEmailDomains: List<String> = listOf("@avih.edu.in", "@jntuh.ac.in", ".edu.in", ".ac.in"),
  val requireEmailOtp: Boolean = true,
  val peerToPeerEscrowNotice: Boolean = true
)

data class AdminOverviewStats(
  val totalUsers: Int,
  val activeUsers: Int,
  val blockedUsers: Int,
  val totalListings: Int,
  val activeListings: Int,
  val soldListings: Int,
  val removedListings: Int,
  val totalReports: Int,
  val pendingReports: Int,
  val resolvedReports: Int,
  val totalTransactionValue: Double,
  val collegeStats: Map<String, Int>
)

data class PilotMetrics(
  val totalActiveListings: Int,
  val totalViews: Int,
  val conversationsInitiated: Int,
  val itemsSold: Int,
  val listingToChatRate: Double,
  val listingToSaleRate: Double,
  val averageResponseMinutes: Int
)

