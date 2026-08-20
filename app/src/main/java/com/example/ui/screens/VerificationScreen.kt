package com.example.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.R
import com.example.data.MarketplaceRepository
import com.example.model.Student
import com.example.ui.theme.*

@Composable
fun VerificationScreen(
  onVerificationSuccess: (Student) -> Unit,
  modifier: Modifier = Modifier
) {
  var email by remember { mutableStateOf("venumadhav@avih.edu.in") }
  var fullName by remember { mutableStateOf("Venu Madhav") }
  var department by remember { mutableStateOf("Computer Science & Engineering") }
  var otp by remember { mutableStateOf("123456") }
  var isOtpSent by remember { mutableStateOf(false) }
  var errorMessage by remember { mutableStateOf<String?>(null) }
  var isLoading by remember { mutableStateOf(false) }

  Surface(
    color = CampusBackground,
    modifier = modifier.fillMaxSize()
  ) {
    Column(
      horizontalAlignment = Alignment.CenterHorizontally,
      modifier = Modifier
        .fillMaxSize()
        .verticalScroll(rememberScrollState())
        .padding(24.dp)
    ) {
      Spacer(modifier = Modifier.height(32.dp))

      // Logo icon
      Box(
        modifier = Modifier
          .size(80.dp)
          .clip(CircleShape)
          .background(CampusNavy),
        contentAlignment = Alignment.Center
      ) {
        Icon(
          imageVector = Icons.Default.School,
          contentDescription = "Campus Exchange Logo",
          tint = CampusTealLight,
          modifier = Modifier.size(44.dp)
        )
      }

      Spacer(modifier = Modifier.height(16.dp))

      Text(
        text = "Campus Exchange",
        fontSize = 24.sp,
        fontWeight = FontWeight.ExtraBold,
        color = CampusNavy
      )

      Text(
        text = "Exclusive College Marketplace",
        fontSize = 13.sp,
        fontWeight = FontWeight.SemiBold,
        color = CampusTeal
      )

      Spacer(modifier = Modifier.height(8.dp))

      Text(
        text = "Closed, verified peer-to-peer exchange for textbook reuse, academic calculators, and hostel essentials.",
        fontSize = 12.sp,
        color = CampusTextSecondary,
        textAlign = TextAlign.Center,
        modifier = Modifier.padding(horizontal = 16.dp)
      )

      Spacer(modifier = Modifier.height(28.dp))

      // Main Form Card
      Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = CampusSurface),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        modifier = Modifier.fillMaxWidth()
      ) {
        Column(
          modifier = Modifier.padding(20.dp),
          verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
          Text(
            text = if (!isOtpSent) "Official College Email Sign In" else "Enter 6-Digit OTP Code",
            fontWeight = FontWeight.Bold,
            fontSize = 16.sp,
            color = CampusNavy
          )

          if (!isOtpSent) {
            OutlinedTextField(
              value = email,
              onValueChange = { email = it },
              label = { Text("Official Student Email") },
              placeholder = { Text("username@avih.edu.in") },
              leadingIcon = { Icon(Icons.Default.Email, contentDescription = null, tint = CampusBlue) },
              singleLine = true,
              shape = RoundedCornerShape(10.dp),
              modifier = Modifier.fillMaxWidth().testTag("auth_email_input")
            )

            OutlinedTextField(
              value = fullName,
              onValueChange = { fullName = it },
              label = { Text("Full Name") },
              leadingIcon = { Icon(Icons.Default.Person, contentDescription = null, tint = CampusBlue) },
              singleLine = true,
              shape = RoundedCornerShape(10.dp),
              modifier = Modifier.fillMaxWidth().testTag("auth_name_input")
            )

            OutlinedTextField(
              value = department,
              onValueChange = { department = it },
              label = { Text("Department") },
              leadingIcon = { Icon(Icons.Default.AccountBalance, contentDescription = null, tint = CampusBlue) },
              singleLine = true,
              shape = RoundedCornerShape(10.dp),
              modifier = Modifier.fillMaxWidth().testTag("auth_dept_input")
            )
          } else {
            Text(
              text = "A 6-digit verification code was sent to $email",
              fontSize = 12.sp,
              color = CampusTextSecondary
            )

            OutlinedTextField(
              value = otp,
              onValueChange = { otp = it },
              label = { Text("6-Digit OTP") },
              leadingIcon = { Icon(Icons.Default.Key, contentDescription = null, tint = CampusTeal) },
              singleLine = true,
              shape = RoundedCornerShape(10.dp),
              modifier = Modifier.fillMaxWidth().testTag("auth_otp_input")
            )
          }

          if (errorMessage != null) {
            Text(
              text = errorMessage ?: "",
              color = CampusRose,
              fontSize = 12.sp,
              fontWeight = FontWeight.Medium
            )
          }

          Button(
            onClick = {
              errorMessage = null
              if (!isOtpSent) {
                if (!email.contains("@") || (!email.endsWith(".edu.in") && !email.endsWith(".ac.in"))) {
                  errorMessage = "Please enter an official college domain email (.edu.in or .ac.in)"
                  return@Button
                }
                isOtpSent = true
              } else {
                isLoading = true
                val result = MarketplaceRepository.loginWithCollegeEmail(email, fullName, department)
                if (result.isSuccess) {
                  onVerificationSuccess(result.getOrThrow())
                } else {
                  isLoading = false
                  errorMessage = result.exceptionOrNull()?.message
                }
              }
            },
            colors = ButtonDefaults.buttonColors(containerColor = CampusBlue),
            shape = RoundedCornerShape(10.dp),
            modifier = Modifier
              .fillMaxWidth()
              .height(48.dp)
              .testTag("auth_submit_button")
          ) {
            if (isLoading) {
              CircularProgressIndicator(color = Color.White, modifier = Modifier.size(20.dp))
            } else {
              Text(
                text = if (!isOtpSent) "Send Verification Code" else "Verify & Enter Marketplace",
                fontWeight = FontWeight.Bold
              )
            }
          }

          if (isOtpSent) {
            TextButton(
              onClick = { isOtpSent = false },
              modifier = Modifier.align(Alignment.CenterHorizontally)
            ) {
              Text("Change Email Address", fontSize = 12.sp, color = CampusBlueLight)
            }
          }
        }
      }

      Spacer(modifier = Modifier.height(24.dp))

      // College boundary note
      Surface(
        color = Color(0xFFEFF6FF),
        shape = RoundedCornerShape(10.dp),
        modifier = Modifier.fillMaxWidth()
      ) {
        Row(
          verticalAlignment = Alignment.CenterVertically,
          modifier = Modifier.padding(12.dp)
        ) {
          Icon(
            imageVector = Icons.Default.Lock,
            contentDescription = null,
            tint = CampusBlue,
            modifier = Modifier.size(16.dp)
          )
          Spacer(modifier = Modifier.width(8.dp))
          Text(
            text = "Strict College Isolation: You will only see and exchange items with students of your own college.",
            fontSize = 11.sp,
            color = CampusNavy
          )
        }
      }
    }
  }
}
