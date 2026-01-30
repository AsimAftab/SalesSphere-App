import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/exceptions/offline_exception.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/providers/connectivity_provider.dart';
import 'package:sales_sphere/core/services/geofencing_service.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import '../models/attendance.models.dart';

part 'attendance.vm.g.dart';

// ========================================
// TODAY'S ATTENDANCE PROVIDER
// ========================================
@riverpod
class TodayAttendanceViewModel extends _$TodayAttendanceViewModel {
  @override
  Future<TodayAttendanceStatusResponse?> build() async {
    // Fetch today's attendance status from API
    // ConnectivityInterceptor will throw OfflineException if offline
    return _fetchTodayStatus();
  }

  /// Fetch today's attendance status
  Future<TodayAttendanceStatusResponse?> _fetchTodayStatus() async {
    try {
      AppLogger.i('📅 Fetching today\'s attendance status...');

      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiEndpoints.attendanceTodayStatus);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final statusResponse = TodayAttendanceStatusResponse.fromJson(response.data);

        if (statusResponse.data == null) {
          AppLogger.i('ℹ️ Not marked today: ${statusResponse.message}');
          AppLogger.i('🕐 Org Check-In Time: ${statusResponse.organizationCheckInTime}');
        } else {
          AppLogger.i('✅ Today\'s attendance status fetched');
        }

        return statusResponse;
      }

      return null;
    } on DioException catch (e) {
      AppLogger.e('❌ Failed to fetch today\'s status: $e');
      return null;
    } catch (e) {
      AppLogger.e('❌ Unexpected error: $e');
      return null;
    }
  }

  /// Check if check-in is allowed (within 2 hours before scheduled check-in time)
  bool isCheckInAllowed(TodayAttendanceStatusResponse? statusResponse) {
    if (statusResponse == null) return false;

    // If already checked in, don't allow check-in again
    if (statusResponse.data?.checkInTime != null) return false;

    final orgCheckInTime = statusResponse.organizationCheckInTime;
    if (orgCheckInTime == null) return true; // Allow if no restriction

    try {
      // Parse organization check-in time (format: "HH:mm")
      final timeParts = orgCheckInTime.split(':');
      if (timeParts.length != 2) return true;

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final now = DateTime.now();
      final scheduledCheckIn = DateTime(now.year, now.month, now.day, hour, minute);
      final twoHoursBefore = scheduledCheckIn.subtract(const Duration(hours: 2));

      // Allow check-in if current time is within 2 hours before scheduled time
      final isAllowed = now.isAfter(twoHoursBefore) || now.isAtSameMomentAs(twoHoursBefore);

      if (!isAllowed) {
        AppLogger.i('⏰ Check-in not allowed yet. Earliest: ${DateFormat('HH:mm').format(twoHoursBefore)}');
      }

      return isAllowed;
    } catch (e) {
      AppLogger.e('❌ Error checking check-in time: $e');
      return true; // Allow on error to not block user
    }
  }

  /// Check if geofencing is enabled for attendance
  bool isGeofencingEnabled(TodayAttendanceStatusResponse? statusResponse) {
    if (statusResponse == null) return false;
    final orgLocation = statusResponse.organizationLocation;
    return statusResponse.enableGeoFencingAttendance &&
        orgLocation != null &&
        orgLocation.latitude != null &&
        orgLocation.longitude != null;
  }

  /// Validate user location against geofence before check-in
  /// Throws GeofenceViolationException if outside radius
  Future<void> validateGeofenceForCheckIn(
    TodayAttendanceStatusResponse statusResponse,
    double userLat,
    double userLng,
  ) async {
    if (!isGeofencingEnabled(statusResponse)) {
      AppLogger.i('ℹ️ Geofencing not enabled, skipping validation');
      return;
    }

    final orgLocation = statusResponse.organizationLocation!;
    AppLogger.i('📍 Validating geofence for check-in...');
    AppLogger.d('   Organization: ${orgLocation.latitude}, ${orgLocation.longitude}');
    AppLogger.d('   User: $userLat, $userLng');

    final result = GeofencingService.instance.validateGeofence(
      userLat: userLat,
      userLng: userLng,
      targetLat: orgLocation.latitude!,
      targetLng: orgLocation.longitude!,
      radius: GeofencingService.attendanceGeofenceRadius,
    );

    if (!result.isWithinGeofence) {
      final distanceFormatted = GeofencingService.instance.formatDistance(result.distanceOutside);
      final radiusFormatted = GeofencingService.instance.formatDistance(result.radius);
      AppLogger.w('⚠️ Geofence violation: ${distanceFormatted} outside (allowed: ${radiusFormatted})');
      throw GeofenceViolationException(
        'You are outside the attendance geofence. '
        'Please move within ${radiusFormatted} of ${orgLocation.address}. '
        '(Current distance: ${distanceFormatted} away)',
      );
    }

    AppLogger.i('✅ Geofence validation passed for check-in');
  }

  /// Validate user location against geofence before check-out
  /// Throws GeofenceViolationException if outside radius
  Future<void> validateGeofenceForCheckOut(
    TodayAttendanceStatusResponse statusResponse,
    double userLat,
    double userLng,
  ) async {
    if (!isGeofencingEnabled(statusResponse)) {
      AppLogger.i('ℹ️ Geofencing not enabled, skipping validation');
      return;
    }

    final orgLocation = statusResponse.organizationLocation!;
    AppLogger.i('📍 Validating geofence for check-out...');
    AppLogger.d('   Organization: ${orgLocation.latitude}, ${orgLocation.longitude}');
    AppLogger.d('   User: $userLat, $userLng');

    final result = GeofencingService.instance.validateGeofence(
      userLat: userLat,
      userLng: userLng,
      targetLat: orgLocation.latitude!,
      targetLng: orgLocation.longitude!,
      radius: GeofencingService.attendanceGeofenceRadius,
    );

    if (!result.isWithinGeofence) {
      final distanceFormatted = GeofencingService.instance.formatDistance(result.distanceOutside);
      final radiusFormatted = GeofencingService.instance.formatDistance(result.radius);
      AppLogger.w('⚠️ Geofence violation: ${distanceFormatted} outside (allowed: ${radiusFormatted})');
      throw GeofenceViolationException(
        'You are outside the attendance geofence. '
        'Please move within ${radiusFormatted} of ${orgLocation.address}. '
        '(Current distance: ${distanceFormatted} away)',
      );
    }

    AppLogger.i('✅ Geofence validation passed for check-out');
  }

  /// Check-in method
  Future<void> checkIn({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    // Save the current state to restore if check-in validation fails
    final previousState = state;

    state = const AsyncLoading();

    try {
      AppLogger.i('📍 Checking in at: $address');

      // Validate geofence before API call
      final currentStatus = previousState.value;
      if (currentStatus != null) {
        await validateGeofenceForCheckIn(currentStatus, latitude, longitude);
      }

      final dio = ref.read(dioClientProvider);
      final response = await dio.post(
        ApiEndpoints.attendanceCheckIn,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
        },
      );

      // Check if response indicates success
      if (response.data['success'] == true) {
        final checkInResponse = CheckInOutResponse.fromJson(response.data);

        AppLogger.i('✅ Checked in successfully');
        if (checkInResponse.isLate == true) {
          AppLogger.w('⚠️ Late check-in! Expected: ${checkInResponse.expectedCheckInTime}');
        }

        // Refresh the status to get updated data with organization info
        await refresh();
      }
      // Check if response is an error with detailed check-in time info
      else if (response.data != null &&
          response.data is Map<String, dynamic> &&
          response.data['success'] == false) {
        try {
          final checkInError = CheckInError.fromJson(response.data);
          AppLogger.w('⏰ Check-in time window error: ${checkInError.message}');

          // Restore previous state (don't set to error for validation failures)
          state = previousState;

          throw CheckInErrorException(checkInError);
        } catch (parseError) {
          if (parseError is! CheckInErrorException) {
            AppLogger.e('Failed to parse check-in error: $parseError');
            state = AsyncError(parseError, StackTrace.current);
            throw Exception(response.data['message'] ?? 'Check-in failed');
          }
          rethrow;
        }
      } else {
        state = AsyncError(Exception('Check-in failed'), StackTrace.current);
        throw Exception('Check-in failed');
      }
    } on GeofenceViolationException {
      // Geofence violation - restore state and rethrow
      state = previousState;
      rethrow;
    } on DioException catch (e) {
      AppLogger.e('❌ Check-in failed: ${e.response?.statusCode} - ${e.response?.data}');

      // Check if response contains check-in time window error
      if (e.response?.data != null &&
          e.response?.data is Map<String, dynamic> &&
          e.response?.data['success'] == false) {
        try {
          final checkInError = CheckInError.fromJson(e.response!.data);
          AppLogger.w('⏰ Check-in time window error: ${checkInError.message}');

          // Restore previous state (don't set to error for validation failures)
          state = previousState;

          throw CheckInErrorException(checkInError);
        } catch (parseError) {
          // If parsing failed for a reason other than type issues, log it
          if (parseError is! CheckInErrorException) {
            AppLogger.e('Failed to parse check-in error: $parseError');
            state = AsyncError(parseError, StackTrace.current);
          }
          // Always rethrow to preserve the error
          rethrow;
        }
      }

      state = AsyncError(e, StackTrace.current);
      rethrow;
    } catch (e) {
      if (e is CheckInErrorException) {
        // Validation errors should not change the provider state
        rethrow;
      }
      AppLogger.e('❌ Unexpected error during check-in: $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Check-out method
  Future<void> checkOut({
    required double latitude,
    required double longitude,
    required String address,
    bool isHalfDay = false,
  }) async {
    // Save the current state to restore if check-out validation fails
    final previousState = state;

    state = const AsyncLoading();

    try {
      AppLogger.i('📍 Checking out at: $address${isHalfDay ? ' (Half-day)' : ''}');

      // Validate geofence before API call
      final currentStatus = previousState.value;
      if (currentStatus != null) {
        await validateGeofenceForCheckOut(currentStatus, latitude, longitude);
      }

      final dio = ref.read(dioClientProvider);
      final response = await dio.put(
        ApiEndpoints.attendanceCheckOut,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          if (isHalfDay) 'isHalfDay': true,
        },
      );

      // Check for success response
      if (response.data['success'] == true) {
        final checkOutResponse = CheckInOutResponse.fromJson(response.data);

        AppLogger.i('✅ Checked out successfully${isHalfDay ? ' (Half-day)' : ''}');

        // Refresh the status to get updated data with organization info
        await refresh();
      }
      // Handle error responses (400 status with success: false)
      else if (response.data != null &&
          response.data is Map<String, dynamic> &&
          response.data['success'] == false) {
        try {
          final restriction = CheckoutRestriction.fromJson(response.data);

          // Restore previous state (don't set to error for validation failures)
          state = previousState;

          // Check if half-day window has closed
          if (isHalfDay && restriction.halfDayCheckoutClosedAt != null) {
            AppLogger.w('Half-day checkout window closed: ${restriction.message}');
            throw HalfDayWindowClosedException(restriction);
          }

          // Check if half-day fallback is available (too early for full-day)
          if (restriction.canUseHalfDayFallback) {
            AppLogger.w('Checkout restricted, half-day option available');
            throw CheckoutRestrictionException(restriction);
          }

          // Generic checkout error with time info
          AppLogger.w('Checkout time restriction: ${restriction.message}');
          throw CheckoutRestrictionException(restriction);
        } catch (parseError) {
          if (parseError is CheckoutRestrictionException ||
              parseError is HalfDayWindowClosedException) {
            rethrow;
          }
          AppLogger.e('Failed to parse checkout restriction: $parseError');
          state = AsyncError(parseError, StackTrace.current);
          throw Exception('Check-out failed: ${response.data['message'] ?? 'Unknown error'}');
        }
      }
      // Generic failure
      else {
        AppLogger.e('Check-out failed with status: ${response.statusCode}');
        state = AsyncError(Exception('Check-out failed'), StackTrace.current);
        throw Exception('Check-out failed');
      }
    } on GeofenceViolationException {
      // Geofence violation - restore state and rethrow
      state = previousState;
      rethrow;
    } on CheckoutRestrictionException {
      // Validation errors - state already restored, just re-throw
      rethrow;
    } on HalfDayWindowClosedException {
      // Validation errors - state already restored, just re-throw
      rethrow;
    } on DioException catch (e) {
      AppLogger.e('❌ Check-out failed: ${e.response?.data}');

      // Parse error response
      if (e.response?.data != null &&
          e.response?.data is Map<String, dynamic> &&
          e.response?.data['success'] == false) {
        try {
          final restriction = CheckoutRestriction.fromJson(e.response!.data);

          // Restore previous state (don't set to error for validation failures)
          state = previousState;

          // Check if half-day window has closed
          if (isHalfDay && restriction.halfDayCheckoutClosedAt != null) {
            AppLogger.w('Half-day checkout window closed: ${restriction.message}');
            throw HalfDayWindowClosedException(restriction);
          }

          // Check if half-day fallback is available (too early for full-day)
          if (restriction.canUseHalfDayFallback) {
            AppLogger.w('Checkout restricted, half-day option available');
            throw CheckoutRestrictionException(restriction);
          }

          // Generic checkout error with time info
          AppLogger.w('Checkout time restriction: ${restriction.message}');
          throw CheckoutRestrictionException(restriction);
        } catch (parseError) {
          if (parseError is CheckoutRestrictionException ||
              parseError is HalfDayWindowClosedException) {
            rethrow;
          }
          AppLogger.e('Failed to parse checkout restriction: $parseError');
          state = AsyncError(parseError, StackTrace.current);
        }
      }

      state = AsyncError(e, StackTrace.current);
      rethrow;
    } catch (e) {
      if (e is CheckoutRestrictionException || e is HalfDayWindowClosedException) {
        // Validation errors should not change the provider state
        rethrow;
      }
      AppLogger.e('❌ Unexpected error during check-out: $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Refresh today's status
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchTodayStatus);
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
        // Present with full hours
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
                  status == AttendanceStatus.halfDay
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
        .where((r) => r.status == AttendanceStatus.present)
        .length;
    int absentDays = history
        .where((r) => r.status == AttendanceStatus.absent)
        .length;
    int halfDays = history
        .where((r) => r.status == AttendanceStatus.halfDay)
        .length;
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
      halfDays: halfDays,
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
        .where((r) => r.status == AttendanceStatus.present)
        .length;
    int absentDays = monthRecords
        .where((r) => r.status == AttendanceStatus.absent)
        .length;
    int halfDays = monthRecords
        .where((r) => r.status == AttendanceStatus.halfDay)
        .length;
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
      halfDays: halfDays,
      leaveDays: leaveDays,
      attendancePercentage: attendancePercentage,
      totalHoursWorked: totalHoursWorked,
    );
  }
}

// ========================================
// MONTHLY ATTENDANCE REPORT PROVIDER
// ========================================
@riverpod
class MonthlyAttendanceReportViewModel
    extends _$MonthlyAttendanceReportViewModel {
  @override
  Future<MonthlyAttendanceReport> build(int month, int year) async {
    // Fetch monthly attendance report from API
    // ConnectivityInterceptor will throw OfflineException if offline
    return _fetchMonthlyReport(month, year);
  }

  /// Fetch monthly attendance report from API
  Future<MonthlyAttendanceReport> _fetchMonthlyReport(
      int month, int year) async {
    try {
      AppLogger.i('📅 Fetching monthly attendance report for $month/$year');

      final dio = ref.read(dioClientProvider);
      final endpoint =
          ApiEndpoints.monthlyAttendanceReport(month: month, year: year);

      AppLogger.d('Endpoint: $endpoint');

      final response = await dio.get(endpoint);

      AppLogger.i('✅ Monthly attendance report fetched successfully');
      AppLogger.d('Status code: ${response.statusCode}');
      AppLogger.d('Response type: ${response.data.runtimeType}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        AppLogger.d('Response data keys: ${response.data.keys.toList()}');

        final reportData = response.data['data'] as Map<String, dynamic>;
        final report = MonthlyAttendanceReport.fromJson(reportData);

        AppLogger.i('✅ Successfully parsed monthly attendance report');
        return report;
      } else {
        AppLogger.e('❌ API returned unsuccessful response');
        throw Exception('API returned success: false');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Failed to fetch monthly attendance report: $e');
      AppLogger.e('Response data: ${e.response?.data}');
      AppLogger.e('Status code: ${e.response?.statusCode}');
      AppLogger.e('Request URL: ${e.requestOptions.uri}');
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.e('❌ Unexpected error fetching attendance report: $e');
      AppLogger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Refresh the monthly report
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

// ========================================
// ATTENDANCE SEARCH PROVIDER
// ========================================
@riverpod
class AttendanceSearchViewModel extends _$AttendanceSearchViewModel {
  @override
  Future<AttendanceSearchResponse> build({
    List<String>? status,
    int? month,
    int? year,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    // Fetch attendance search results
    // ConnectivityInterceptor will handle offline state
    return _searchAttendance(
      status: status,
      month: month,
      year: year,
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );
  }

  /// Search attendance records with filters
  Future<AttendanceSearchResponse> _searchAttendance({
    List<String>? status,
    int? month,
    int? year,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      AppLogger.i('🔍 Searching attendance records...');
      AppLogger.d('Filters: status=$status, month=$month, year=$year, page=$page');

      final dio = ref.read(dioClientProvider);
      final endpoint = ApiEndpoints.attendanceSearch(
        status: status,
        month: month,
        year: year,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );

      AppLogger.d('Endpoint: $endpoint');

      final response = await dio.get(endpoint);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final searchResponse = AttendanceSearchResponse.fromJson(response.data);
        AppLogger.i('✅ Found ${searchResponse.data.length} attendance records');
        return searchResponse;
      } else {
        AppLogger.e('❌ API returned unsuccessful response');
        throw Exception('API returned success: false');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Failed to search attendance: $e');
      AppLogger.e('Response data: ${e.response?.data}');
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.e('❌ Unexpected error searching attendance: $e');
      AppLogger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Load utilities results (pagination)
  Future<void> loadMore() async {
    final current = state.value;

    // Guard: Don't load if no current data or no next page
    if (current == null) {
      AppLogger.w('⚠️ Cannot load utilities: No current state');
      return;
    }

    if (!current.pagination.hasNextPage) {
      AppLogger.i('ℹ️ No utilities pages to load (total: ${current.pagination.total})');
      return;
    }

    // Guard: Don't load if already loading
    if (state.isLoading) {
      AppLogger.w('⚠️ Already loading, skipping loadMore');
      return;
    }

    try {
      AppLogger.i('📄 Loading utilities attendance records (page ${current.pagination.page + 1})');

      state = const AsyncLoading();

      final nextPage = await _searchAttendance(
        status: current.filters.status,
        month: current.filters.dateRange != null
            ? DateTime.parse(current.filters.dateRange!.start).month
            : null,
        year: current.filters.dateRange != null
            ? DateTime.parse(current.filters.dateRange!.start).year
            : null,
        page: current.pagination.page + 1,
        limit: current.pagination.limit,
      );

      // Append new data to existing data
      final combinedData = [...current.data, ...nextPage.data];
      final updatedResponse = nextPage.copyWith(data: combinedData);

      state = AsyncData(updatedResponse);
      AppLogger.i('✅ Loaded ${nextPage.data.length} utilities records (total: ${combinedData.length})');
    } catch (e) {
      AppLogger.e('❌ Failed to load utilities: $e');
      state = AsyncError(e, StackTrace.current);
    }
  }

  /// Refresh search results
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
