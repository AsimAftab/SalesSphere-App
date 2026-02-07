// Update theme.dart
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return FlexThemeData.light(
      colors: FlexSchemeColor.from(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
      ),
      scaffoldBackground: AppColors.background,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: FlexSubThemesData(
        blendOnLevel: 10,
        inputDecoratorRadius: AppSizes.radiusM,
        elevatedButtonRadius: AppSizes.radiusM,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      fontFamily: 'Poppins',
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      colors: FlexSchemeColor.from(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: FlexSubThemesData(
        blendOnLevel: 20,
        inputDecoratorRadius: AppSizes.radiusM,
        elevatedButtonRadius: AppSizes.radiusM,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      fontFamily: 'Poppins',
      useMaterial3: true,
    );
  }
}
