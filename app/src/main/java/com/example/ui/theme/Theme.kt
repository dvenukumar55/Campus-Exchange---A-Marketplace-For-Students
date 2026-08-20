package com.example.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext

private val DarkColorScheme =
  darkColorScheme(
    primary = CampusBlueLight,
    onPrimary = Color.White,
    primaryContainer = CampusBlue,
    onPrimaryContainer = Color.White,
    secondary = CampusTealLight,
    onSecondary = Color.White,
    secondaryContainer = CampusTeal,
    tertiary = CampusAmberLight,
    background = DarkBackground,
    onBackground = DarkTextPrimary,
    surface = DarkSurface,
    onSurface = DarkTextPrimary,
    surfaceVariant = DarkSurfaceVariant,
    onSurfaceVariant = DarkTextSecondary,
    outline = DarkBorder
  )

private val LightColorScheme =
  lightColorScheme(
    primary = CampusBlue,
    onPrimary = Color.White,
    primaryContainer = Color(0xFFDBEAFE),
    onPrimaryContainer = CampusNavy,
    secondary = CampusTeal,
    onSecondary = Color.White,
    secondaryContainer = Color(0xFFCCFBF1),
    onSecondaryContainer = Color(0xFF134E4A),
    tertiary = CampusAmber,
    onTertiary = Color.White,
    background = CampusBackground,
    onBackground = CampusTextPrimary,
    surface = CampusSurface,
    onSurface = CampusTextPrimary,
    surfaceVariant = CampusSurfaceVariant,
    onSurfaceVariant = CampusTextSecondary,
    outline = CampusBorder
  )

@Composable
fun CampusExchangeTheme(
  darkTheme: Boolean = isSystemInDarkTheme(),
  dynamicColor: Boolean = false,
  content: @Composable () -> Unit,
) {
  val colorScheme =
    when {
      dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
        val context = LocalContext.current
        if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
      }
      darkTheme -> DarkColorScheme
      else -> LightColorScheme
    }

  MaterialTheme(colorScheme = colorScheme, typography = Typography, content = content)
}

@Composable
fun MyApplicationTheme(
  darkTheme: Boolean = isSystemInDarkTheme(),
  dynamicColor: Boolean = false,
  content: @Composable () -> Unit,
) {
  CampusExchangeTheme(darkTheme = darkTheme, dynamicColor = dynamicColor, content = content)
}

