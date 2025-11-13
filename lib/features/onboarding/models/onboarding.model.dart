import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding.model.freezed.dart';

@freezed
abstract class OnboardingModel with _$OnboardingModel {
  const factory OnboardingModel({
    /// The path to the SVG asset (e.g., 'assets/images/onboarding_welcome.svg')
    required String imagePath,

    /// The main headline text (e.g., 'Welcome to SalesSphere!')
    required String title,

    /// The body text description
    required String description,
  }) = _OnboardingModel;
}