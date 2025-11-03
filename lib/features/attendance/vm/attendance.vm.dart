import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import '../models/attendance.models.dart';

part 'attendance.vm.g.dart';

// ========================================
// TODAY'S ATTENDANCE PROVIDER
// ========================================
@riverpod
class TodayAttendanceViewModel extends _$TodayAttendanceViewModel {
  @override
  TodayAttendance build() {
    // Mock data - Today's attendance (not checked in yet)
    return const TodayAttendance(
      isCheckedIn: false,
      isCheckedOut: false,
    );
  }

  /// Check-in method
  Future<void> checkIn() async {
    AppLogger.i('📍 Checking in...');

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    state = TodayAttendance(
      checkInTime: DateTime.now(),
      isCheckedIn: true,
      isCheckedOut: false,
      location: 'Office - Main Branch',
      hoursWorked: 0,
    );

    AppLogger.i('✅ Checked in successfully');
  }

  /// Check-out method
  Future<void> checkOut() async {
    if (!state.isCheckedIn) {
      AppLogger.w('⚠️ Cannot check out without checking in first');
      return;
    }

    AppLogger.i('📍 Checking out...');

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Calculate hours worked
    final checkInTime = state.checkInTime;
    final checkOutTime = DateTime.now();
    final hoursWorked = checkInTime != null
        ? checkOutTime.difference(checkInTime).inHours
        : 0;

    state = state.copyWith(
      checkOutTime: checkOutTime,
      isCheckedOut: true,
      hoursWorked: hoursWorked,
    );

    AppLogger.i('✅ Checked out successfully. Hours worked: $hoursWorked');
  }
}

// ========================================
// ATTENDANCE HISTORY PROVIDER
// ========================================
@riverpod
class AttendanceHistoryViewModel extends _$AttendanceHistoryViewModel {
  @override
  List<AttendanceRecord> build() {
    // Generate mock attendance data for the past 30 days
    return _generateMockAttendanceHistory();
  }

  /// Generate mock attendance history
  List<AttendanceRecord> _generateMockAttendanceHistory() {
    final List<AttendanceRecord> records = [];
    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));

      // Random status for variety
      AttendanceStatus status;
      DateTime? checkInTime;
      DateTime? checkOutTime;
      int hoursWorked = 0;

      // Saturday is weekend
      final isSaturday = date.weekday == DateTime.saturday;

      // Skip Sundays entirely (working day but no attendance data)
      if (date.weekday == DateTime.sunday) {
        continue;
      }

      if (i == 0) {
        // Today - not checked in yet
        status = AttendanceStatus.present;
        checkInTime = null;
        checkOutTime = null;
      } else if (i % 13 == 0) {
        // Half-day every 13th day
        status = AttendanceStatus.halfDay;
        checkInTime = DateTime(date.year, date.month, date.day, 9, 0);
        checkOutTime = DateTime(date.year, date.month, date.day, 13, 30);
        hoursWorked = 4;
      } else if (i % 10 == 0) {
        // Absent every 10th day
        status = AttendanceStatus.absent;
      } else if (i % 7 == 0) {
        // On leave every 7th day
        status = AttendanceStatus.onLeave;
      } else if (i % 5 == 0) {
        // Was late every 5th day, now just present
        status = AttendanceStatus.present;
        checkInTime = DateTime(date.year, date.month, date.day, 9, 30);
        checkOutTime = DateTime(date.year, date.month, date.day, 18, 15);
        hoursWorked = 8;
      } else if (isSaturday) {
        // Saturday - sometimes worked, sometimes not
        if (i % 3 == 0) {
          status = AttendanceStatus.present;
          checkInTime = DateTime(date.year, date.month, date.day, 9, 0);
          checkOutTime = DateTime(date.year, date.month, date.day, 14, 0);
          hoursWorked = 5;
        } else {
          // Weekend - not worked
          continue;
        }
      } else {
        // Present
        status = AttendanceStatus.present;
        checkInTime = DateTime(date.year, date.month, date.day, 9, 0);
        checkOutTime = DateTime(date.year, date.month, date.day, 18, 0);
        hoursWorked = 9;
      }

      records.add(
        AttendanceRecord(
          id: 'ATT${date.millisecondsSinceEpoch}',
          date: date,
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
          status: status,
          location: status == AttendanceStatus.present ||
                  status == AttendanceStatus.late
              ? 'Office - Main Branch'
              : null,
          totalHoursWorked: hoursWorked,
          notes: status == AttendanceStatus.onLeave ? 'Sick Leave' : null,
        ),
      );
    }

    return records;
  }

  /// Get attendance for specific date
  AttendanceRecord? getAttendanceForDate(DateTime date) {
    try {
      return state.firstWhere(
        (record) =>
            record.date.year == date.year &&
            record.date.month == date.month &&
            record.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get attendance for specific month
  List<AttendanceRecord> getAttendanceForMonth(int year, int month) {
    return state
        .where((record) =>
            record.date.year == year && record.date.month == month)
        .toList();
  }
}

// ========================================
// ATTENDANCE SUMMARY PROVIDER
// ========================================
@riverpod
class AttendanceSummaryViewModel extends _$AttendanceSummaryViewModel {
  @override
  AttendanceSummary build() {
    // Calculate summary from attendance history
    final history = ref.watch(attendanceHistoryViewModelProvider);

    int totalDays = history.length;
    int presentDays = history
        .where((r) => r.status == AttendanceStatus.present || r.status == AttendanceStatus.late)
        .length;
    int absentDays = history
        .where((r) => r.status == AttendanceStatus.absent)
        .length;
    int lateDays = 0; // Late is now treated as present
    int leaveDays = history
        .where((r) => r.status == AttendanceStatus.onLeave)
        .length;

    double attendancePercentage = totalDays > 0
        ? (presentDays / totalDays * 100)
        : 0.0;

    int totalHoursWorked = history
        .map((r) => r.totalHoursWorked)
        .fold(0, (sum, hours) => sum + hours);

    return AttendanceSummary(
      totalDays: totalDays,
      presentDays: presentDays,
      absentDays: absentDays,
      lateDays: lateDays,
      leaveDays: leaveDays,
      attendancePercentage: attendancePercentage,
      totalHoursWorked: totalHoursWorked,
    );
  }

  /// Get summary for specific month
  AttendanceSummary getSummaryForMonth(int year, int month) {
    final history = ref.read(attendanceHistoryViewModelProvider);
    final monthRecords = history
        .where((record) =>
            record.date.year == year && record.date.month == month)
        .toList();

    int totalDays = monthRecords.length;
    int presentDays = monthRecords
        .where((r) => r.status == AttendanceStatus.present || r.status == AttendanceStatus.late)
        .length;
    int absentDays = monthRecords
        .where((r) => r.status == AttendanceStatus.absent)
        .length;
    int lateDays = 0; // Late is now treated as present
    int leaveDays = monthRecords
        .where((r) => r.status == AttendanceStatus.onLeave)
        .length;

    double attendancePercentage = totalDays > 0
        ? (presentDays / totalDays * 100)
        : 0.0;

    int totalHoursWorked = monthRecords
        .map((r) => r.totalHoursWorked)
        .fold(0, (sum, hours) => sum + hours);

    return AttendanceSummary(
      totalDays: totalDays,
      presentDays: presentDays,
      absentDays: absentDays,
      lateDays: lateDays,
      leaveDays: leaveDays,
      attendancePercentage: attendancePercentage,
      totalHoursWorked: totalHoursWorked,
    );
  }
}
