/// Asset paths constants
class AppAssets {
  AppAssets._();

  // Base Paths
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _animations = 'assets/animations';
  static const String _fonts = 'assets/fonts';

  // Images
  static const String logo = '$_images/logo.png';
  static const String logoWhite = '$_images/logo_white.png';
  static const String splash = '$_images/splash.png';
  static const String placeholder = '$_images/placeholder.png';
  static const String noImage = '$_images/no_image.png';
  static const String emptyState = '$_images/empty_state.png';
  static const String errorState = '$_images/error_state.png';
  static const String onboarding1 = '$_images/onboarding_1.png';
  static const String onboarding2 = '$_images/onboarding_2.png';
  static const String onboarding3 = '$_images/onboarding_3.png';

  // Icons
  static const String iconHome = '$_icons/home.svg';
  static const String iconProfile = '$_icons/profile.svg';
  static const String iconSettings = '$_icons/settings.svg';
  static const String iconNotification = '$_icons/notification.svg';

  // Animations (Lottie)
  static const String loadingAnimation = '$_animations/loading.json';
  static const String successAnimation = '$_animations/success.json';
  static const String errorAnimation = '$_animations/error.json';
  static const String emptyAnimation = '$_animations/empty.json';
}