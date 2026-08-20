package com.example

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import com.example.data.MarketplaceRepository
import com.example.model.ListingStatus
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class ExampleRobolectricTest {

  @Test
  fun `read string from context`() {
    val context = ApplicationProvider.getApplicationContext<Context>()
    val appName = context.getString(R.string.app_name)
    assertEquals("Campus Exchange", appName)
  }

  @Test
  fun `create Java Programming Book listing successfully`() {
    val result = MarketplaceRepository.createListing(
      title = "Java Programming Book",
      price = 500.0,
      condition = "Good",
      category = "Academic/Books",
      description = "Java programming book in good condition"
    )

    assertTrue(result.isSuccess)
    val listing = result.getOrNull()
    assertNotNull(listing)
    assertEquals("Java Programming Book", listing?.title)
    assertEquals(500.0, listing?.price ?: 0.0, 0.01)
    assertEquals("Good", listing?.condition)
    assertEquals("Academic/Books", listing?.category)
    assertEquals(ListingStatus.ACTIVE, listing?.status)
  }

  @Test
  fun `send message and verify conversation creation`() {
    val msg = MarketplaceRepository.sendMessage(
      listingId = "list_java_001",
      recipientId = "std_seller_test",
      recipientName = "Test Seller",
      text = "Can we meet at Central Library?"
    )

    assertNotNull(msg)
    assertEquals("Can we meet at Central Library?", msg.content)
  }

  @Test
  fun `update listing status to sold`() {
    val res = MarketplaceRepository.updateListingStatus("list_coat_003", ListingStatus.SOLD)
    assertTrue(res.isSuccess)
    assertEquals(ListingStatus.SOLD, res.getOrNull()?.status)
  }
}
