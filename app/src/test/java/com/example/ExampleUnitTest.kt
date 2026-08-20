package com.example

import com.example.data.MarketplaceRepository
import com.example.model.ListingStatus
import com.example.model.ReportStatus
import com.example.model.UserRole
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

class ExampleUnitTest {

  @Before
  fun setUp() {
    // Reset to default student
    MarketplaceRepository.switchStudent(MarketplaceRepository.defaultStudent)
  }

  @Test
  fun testStudentCannotPerformAdminActions() {
    // Current student is regular student (UserRole.STUDENT)
    assertEquals(UserRole.STUDENT, MarketplaceRepository.currentStudent.value?.role)

    val blockResult = MarketplaceRepository.adminBlockUser("s_jntuh_101", "Unauthorized test")
    assertTrue("Student must be blocked from admin action", blockResult.isFailure)
    assertTrue(blockResult.exceptionOrNull() is SecurityException)

    val deleteResult = MarketplaceRepository.adminDeleteListing("l_avih_1", "Unauthorized test")
    assertTrue("Student must be blocked from admin delete", deleteResult.isFailure)
  }

  @Test
  fun testAdminCanPerformOperationsAndCreatesAuditLog() {
    // Switch to Dr. Rajesh Sharma (ADMIN)
    MarketplaceRepository.switchStudent(MarketplaceRepository.adminUser)
    assertEquals(UserRole.ADMIN, MarketplaceRepository.currentStudent.value?.role)

    val initialLogCount = MarketplaceRepository.auditLogs.value.size

    // Perform soft deletion
    val deleteResult = MarketplaceRepository.adminDeleteListing("l_avih_1", "Violates compliance guidelines")
    assertTrue(deleteResult.isSuccess)

    val updatedListing = MarketplaceRepository.listings.value.find { it.listingId == "l_avih_1" }
    assertNotNull(updatedListing)
    assertTrue(updatedListing?.isSoftDeleted == true)
    assertEquals(ListingStatus.REMOVED, updatedListing?.status)

    // Verify audit log increment
    val newLogCount = MarketplaceRepository.auditLogs.value.size
    assertEquals(initialLogCount + 1, newLogCount)

    val latestLog = MarketplaceRepository.auditLogs.value.first()
    assertEquals("LISTING_DELETED", latestLog.actionType)
    assertEquals("l_avih_1", latestLog.targetId)

    // Restore listing
    val restoreResult = MarketplaceRepository.adminRestoreListing("l_avih_1")
    assertTrue(restoreResult.isSuccess)
    val restoredListing = MarketplaceRepository.listings.value.find { it.listingId == "l_avih_1" }
    assertFalse(restoredListing?.isSoftDeleted == true)
    assertEquals(ListingStatus.ACTIVE, restoredListing?.status)
  }

  @Test
  fun testReportResolutionWorkflow() {
    // Switch to Moderator Prof. Ananya Rao
    MarketplaceRepository.switchStudent(MarketplaceRepository.moderatorUser)
    assertEquals(UserRole.MODERATOR, MarketplaceRepository.currentStudent.value?.role)

    val reportResult = MarketplaceRepository.adminResolveReport(
      reportId = "rep_101",
      action = "Warning sent and description cleaned",
      moderatorNotes = "Verified listing compliant",
      takeDownListing = false,
      blockSeller = false
    )

    assertTrue(reportResult.isSuccess)
    val updatedReport = MarketplaceRepository.reports.value.find { it.reportId == "rep_101" }
    assertEquals(ReportStatus.RESOLVED, updatedReport?.status)
  }
}
