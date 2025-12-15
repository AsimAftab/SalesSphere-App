import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/utilities/models/utilities.model.dart';

part 'utilities.vm.g.dart';

@riverpod
class UtilitiesViewModel extends _$UtilitiesViewModel {
  @override
  List<UtilityItem> build() {
    return _getUtilityItems();
  }

  List<UtilityItem> _getUtilityItems() {
    return [
      // 1. Odometer
      const UtilityItem(
        title: 'Odometer',
        subtitle: 'Track travel distance during field visits',
        icon: Icons.speed_rounded,
        color: Color(0xFF448AFF), // Blue
        backgroundColor: Color(0xFFE3F2FD),
        routePath: '/odometer',
      ),
      // 2. Expense Claims
      const UtilityItem(
        title: 'Expense Claims',
        subtitle: 'Submit and manage expense claims',
        icon: Icons.currency_rupee_rounded,
        color: Color(0xFF00C853), // Green
        backgroundColor: Color(0xFFE8F5E9),
        routePath: '/reimbursement',
      ),
      // 3. Notes & Complaints
      const UtilityItem(
        title: 'Notes & Complaints',
        subtitle: 'Log discussions, feedback & issues',
        icon: Icons.chat_bubble_outline_rounded,
        color: Color(0xFFFF5252), // Red
        backgroundColor: Color(0xFFFFEBEE),
        routePath: '/notes-complaints',
      ),
      // 4. Miscellaneous Work
      const UtilityItem(
        title: 'Miscellaneous Work',
        subtitle: 'Log unplanned field tasks and assignments',
        icon: Icons.work_outline_rounded,
        color: Color(0xFF7C4DFF), // Purple
        backgroundColor: Color(0xFFEDE7F6),
        routePath: '/miscellaneous-work',
      ),
      // 5. Tour Plan
      const UtilityItem(
        title: 'Tour Plan',
        subtitle: 'Plan and manage daily field visits',
        icon: Icons.navigation_outlined,
        color: Color(0xFFFF9100), // Orange
        backgroundColor: Color(0xFFFFF3E0),
        routePath: '/tour-plan',
      ),
      // 6. Attendance
      const UtilityItem(
        title: 'Attendance',
        subtitle: 'Mark and track daily attendance',
        icon: Icons.calendar_month_rounded,
        color: Color(0xFF00ACC1), // Cyan/Teal
        backgroundColor: Color(0xFFE0F7FA),
        routePath: '/attendance',
      ),
    ];
  }
}