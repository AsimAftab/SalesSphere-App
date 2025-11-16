import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/onboarding/models/onboarding.model.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingModel pageModel;
  final int pageIndex;

  const OnboardingPageWidget({
    super.key,
    required this.pageModel,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        children: [
          SizedBox(height: 16.h),

          // Illustration
          Expanded(
            flex: 3,
            child: Center(
              child: SvgPicture.asset(
                pageModel.imagePath,
                fit: BoxFit.contain,
                width: 300.w,
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Title
          Text(
            pageModel.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21.sp,
              color: AppColors.textPrimary,
              fontFamily: 'Poppins',
              height: 1.2,
            ),
          ),

          SizedBox(height: 14.h),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              pageModel.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
              maxLines: 4,
            ),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}