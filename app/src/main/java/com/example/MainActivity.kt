package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.LocalActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.example.data.MarketplaceRepository
import com.example.model.Listing
import com.example.ui.screens.*
import com.example.ui.screens.admin.AdminDashboardScreen
import com.example.ui.theme.CampusExchangeTheme
import kotlinx.coroutines.launch

sealed class Screen {
  object Verification : Screen()
  object Marketplace : Screen()
  object CreateListing : Screen()
  data class ListingDetail(val listing: Listing) : Screen()
  data class Chat(val listing: Listing) : Screen()
  object ChatList : Screen()
  object MyListings : Screen()
  data class EditListing(val listing: Listing) : Screen()
  object MetricsDashboard : Screen()
  object Profile : Screen()
  object AdminDashboard : Screen()
}

class MainActivity : ComponentActivity() {

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    enableEdgeToEdge()

    setContent {
      CampusExchangeTheme {
        CampusExchangeApp()
      }
    }
  }
}

@Composable
fun CampusExchangeApp() {

  val activity = LocalActivity.current

  val currentStudent by MarketplaceRepository.currentStudent.collectAsState()
  val listings by MarketplaceRepository.listings.collectAsState()

  var currentScreen by remember {
    mutableStateOf<Screen>(
      if (currentStudent != null) {
        Screen.Marketplace
      } else {
        Screen.Verification
      }
    )
  }

  var reportingListing by remember {
    mutableStateOf<Listing?>(null)
  }

  val snackbarHostState = remember {
    SnackbarHostState()
  }

  val scope = rememberCoroutineScope()

  /*
   * Android system Back button handling.
   *
   * Create Listing -> Marketplace
   * Listing Detail -> Marketplace
   * Chat -> Listing Detail
   * Chat List -> Marketplace
   * My Listings -> Profile
   * Edit Listing -> Listing Detail
   * Metrics -> Marketplace
   * Profile -> Marketplace
   * Admin -> Marketplace
   *
   * If already on Marketplace, the app closes normally.
   */
  BackHandler {

    when (val screen = currentScreen) {

      is Screen.Marketplace -> {
        activity?.finish()
      }

      is Screen.Verification -> {
        activity?.finish()
      }

      is Screen.CreateListing -> {
        currentScreen = Screen.Marketplace
      }

      is Screen.ListingDetail -> {
        currentScreen = Screen.Marketplace
      }

      is Screen.Chat -> {
        currentScreen = Screen.ListingDetail(screen.listing)
      }

      is Screen.ChatList -> {
        currentScreen = Screen.Marketplace
      }

      is Screen.MyListings -> {
        currentScreen = Screen.Profile
      }

      is Screen.EditListing -> {
        currentScreen = Screen.ListingDetail(screen.listing)
      }

      is Screen.MetricsDashboard -> {
        currentScreen = Screen.Marketplace
      }

      is Screen.Profile -> {
        currentScreen = Screen.Marketplace
      }

      is Screen.AdminDashboard -> {
        currentScreen = Screen.Marketplace
      }
    }
  }

  Scaffold(
    snackbarHost = {
      SnackbarHost(snackbarHostState)
    },
    modifier = Modifier.fillMaxSize()
  ) { paddingValues ->

    AnimatedContent(
      targetState = currentScreen,
      label = "screen_transition",
      modifier = Modifier
        .fillMaxSize()
        .padding(paddingValues)
    ) { screen ->

      when (screen) {

        // -------------------------------------------------
        // VERIFICATION
        // -------------------------------------------------

        is Screen.Verification -> {

          VerificationScreen(
            onVerificationSuccess = { student ->

              currentScreen = Screen.Marketplace

              scope.launch {
                snackbarHostState.showSnackbar(
                  "Welcome to ${
                    student.collegeName
                      .substringBefore("(")
                      .trim()
                  } Exchange!"
                )
              }
            }
          )
        }

        // -------------------------------------------------
        // MARKETPLACE
        // -------------------------------------------------

        is Screen.Marketplace -> {

          val student =
            currentStudent
              ?: MarketplaceRepository.defaultStudent

          MarketplaceScreen(
            student = student,
            listings = listings,

            onListingClick = { listing ->

              MarketplaceRepository.incrementViewCount(
                listing.listingId
              )

              currentScreen =
                Screen.ListingDetail(listing)
            },

            onCreateClick = {
              currentScreen = Screen.CreateListing
            },

            onOpenMetrics = {
              currentScreen = Screen.MetricsDashboard
            },

            onOpenProfile = {
              currentScreen = Screen.Profile
            },

            onOpenChats = {
              currentScreen = Screen.ChatList
            },

            onOpenAdmin = {
              currentScreen = Screen.AdminDashboard
            }
          )
        }

        // -------------------------------------------------
        // CREATE LISTING
        // -------------------------------------------------

        is Screen.CreateListing -> {

          CreateListingScreen(

            onNavigateBack = {
              currentScreen = Screen.Marketplace
            },

            onListingCreated = {

              currentScreen = Screen.Marketplace

              scope.launch {
                snackbarHostState.showSnackbar(
                  "Listing published successfully to your campus!"
                )
              }
            }
          )
        }

        // -------------------------------------------------
        // LISTING DETAIL
        // -------------------------------------------------

        is Screen.ListingDetail -> {

          val student =
            currentStudent
              ?: MarketplaceRepository.defaultStudent

          val activeListing =
            listings.find {
              it.listingId == screen.listing.listingId
            } ?: screen.listing

          ListingDetailScreen(

            listing = activeListing,

            currentStudent = student,

            onNavigateBack = {
              currentScreen = Screen.Marketplace
            },

            onOpenChat = { listing ->
              currentScreen = Screen.Chat(listing)
            },

            onEditListing = { listing ->
              currentScreen = Screen.EditListing(listing)
            },

            onMarkSold = { listing ->

              MarketplaceRepository.updateListingStatus(
                listing.listingId,
                com.example.model.ListingStatus.SOLD
              )

              scope.launch {
                snackbarHostState.showSnackbar(
                  "Item marked as Sold!"
                )
              }
            },

            onCloseListing = { listing ->

              MarketplaceRepository.updateListingStatus(
                listing.listingId,
                com.example.model.ListingStatus.CLOSED
              )

              scope.launch {
                snackbarHostState.showSnackbar(
                  "Listing status updated."
                )
              }
            },

            onReportClick = { listing ->
              reportingListing = listing
            }
          )
        }

        // -------------------------------------------------
        // CHAT
        // -------------------------------------------------

        is Screen.Chat -> {

          val student =
            currentStudent
              ?: MarketplaceRepository.defaultStudent

          val activeListing =
            listings.find {
              it.listingId == screen.listing.listingId
            } ?: screen.listing

          ChatScreen(

            listing = activeListing,

            currentStudent = student,

            onNavigateBack = {
              currentScreen =
                Screen.ListingDetail(activeListing)
            }
          )
        }

        // -------------------------------------------------
        // CHAT LIST
        // -------------------------------------------------

        is Screen.ChatList -> {

          ChatListScreen(

            onNavigateBack = {
              currentScreen = Screen.Marketplace
            },

            onOpenConversation = { listing ->
              currentScreen = Screen.Chat(listing)
            }
          )
        }

        // -------------------------------------------------
        // MY LISTINGS
        // -------------------------------------------------

        is Screen.MyListings -> {

          val student =
            currentStudent
              ?: MarketplaceRepository.defaultStudent

          MyListingsScreen(

            currentStudent = student,

            onNavigateBack = {
              currentScreen = Screen.Profile
            },

            onEditListing = { listing ->
              currentScreen = Screen.EditListing(listing)
            },

            onOpenListing = { listing ->
              currentScreen = Screen.ListingDetail(listing)
            }
          )
        }

        // -------------------------------------------------
        // EDIT LISTING
        // -------------------------------------------------

        is Screen.EditListing -> {

          val activeListing =
            listings.find {
              it.listingId == screen.listing.listingId
            } ?: screen.listing

          EditListingScreen(

            listing = activeListing,

            onNavigateBack = {
              currentScreen =
                Screen.ListingDetail(activeListing)
            },

            onUpdated = {

              currentScreen =
                Screen.ListingDetail(activeListing)

              scope.launch {
                snackbarHostState.showSnackbar(
                  "Listing details updated."
                )
              }
            }
          )
        }

        // -------------------------------------------------
        // METRICS DASHBOARD
        // -------------------------------------------------

        is Screen.MetricsDashboard -> {

          val student =
            currentStudent
              ?: MarketplaceRepository.defaultStudent

          MetricsDashboardScreen(

            student = student,

            onNavigateBack = {
              currentScreen = Screen.Marketplace
            }
          )
        }

        // -------------------------------------------------
        // PROFILE
        // -------------------------------------------------

        is Screen.Profile -> {

          val student =
            currentStudent
              ?: MarketplaceRepository.defaultStudent

          ProfileScreen(

            student = student,

            onNavigateBack = {
              currentScreen = Screen.Marketplace
            },

            onOpenMyListings = {
              currentScreen = Screen.MyListings
            },

            onOpenMetrics = {
              currentScreen = Screen.MetricsDashboard
            },

            onOpenAdmin = {
              currentScreen = Screen.AdminDashboard
            },

            onSwitchStudent = { studentInfo ->

              currentScreen = Screen.Marketplace

              scope.launch {
                snackbarHostState.showSnackbar(
                  "Switched campus domain to ${
                    studentInfo.collegeName
                      .substringBefore("(")
                      .trim()
                  }"
                )
              }
            },

            onSignOut = {
              currentScreen = Screen.Verification
            }
          )
        }

        // -------------------------------------------------
        // ADMIN DASHBOARD
        // -------------------------------------------------

        is Screen.AdminDashboard -> {

          val student =
            currentStudent
              ?: MarketplaceRepository.defaultStudent

          AdminDashboardScreen(

            currentStudent = student,

            onNavigateBack = {
              currentScreen = Screen.Marketplace
            },

            onSwitchUser = { user ->

              scope.launch {
                snackbarHostState.showSnackbar(
                  "Active identity switched to ${user.fullName} (${user.role.label})"
                )
              }
            }
          )
        }
      }
    }

    // ---------------------------------------------------------
    // REPORT DIALOG
    // ---------------------------------------------------------

    reportingListing?.let { listing ->

      ReportDialog(

        listing = listing,

        onDismiss = {
          reportingListing = null
        },

        onReportSubmitted = {

          reportingListing = null

          scope.launch {
            snackbarHostState.showSnackbar(
              "Report submitted for college moderation."
            )
          }
        }
      )
    }
  }
}