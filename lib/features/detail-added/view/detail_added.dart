import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/widget/custom_button.dart';

class DetailAdded extends ConsumerWidget {
  const DetailAdded({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // FIX: SvgPicture.asset is the icon widget itself
          icon: SvgPicture.asset(
            'assets/icons/arrow_left.svg', // <-- Make sure this path is correct
            height: 24.h,
            width: 24.w,
            colorFilter: ColorFilter.mode(
              // This gets the default color for icons in the AppBar
              Theme.of(context).appBarTheme.iconTheme?.color ?? Colors.black,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            // Go back to the login/home screen
            context.goNamed('login');
          },
        ),

      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TODO: Replace with your success image/animation
            SvgPicture.asset(
              'assets/images/detail_added_success.svg', // Placeholder path
              height: 250.h,
            ),
            SizedBox(height: 40.h),
            Text(
              'Details Added Successfully',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 40.h),
            PrimaryButton(
              label: 'Go to Home Page',
              onPressed: () {
                context.goNamed('login');
              },
              size: ButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}
