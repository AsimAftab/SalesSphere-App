import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/leave/models/leave.model.dart';
import 'dart:async';
import 'package:sales_sphere/core/utils/logger.dart';

part 'leave.vm.g.dart';

// Static storage to persist mock data during the app session
List<LeaveApiData> _mockDatabase = [
  const LeaveApiData(
      id: '1',
      leaveType: 'Sick Leave',
      startDate: '2024-12-28',
      endDate: '2024-12-30',
      status: 'Approved',
      reason: 'Medical checkup and recovery - Need time off for scheduled health appointment.'
  ),
  const LeaveApiData(
      id: '2',
      leaveType: 'Maternity Leave',
      startDate: '2024-12-27',
      endDate: '2025-03-27',
      status: 'Pending',
      reason: 'Personal errands - Family obligations require immediate attention.'
  ),
  const LeaveApiData(
      id: '3',
      leaveType: 'Family Responsibility Leave',
      startDate: '2024-12-26',
      endDate: '2025-01-02',
      status: 'Approved',
      reason: 'Year-end vacation - Planning a trip with family during holiday season.'
  ),
  const LeaveApiData(
      id: '4',
      leaveType: 'Miscellaneous/Others',
      startDate: '2024-12-26',
      endDate: '2024-12-26',
      status: 'Rejected',
      reason: 'Remote work request - Internet connectivity issues at home resolved.'
  ),
];

@Riverpod(keepAlive: true)
class LeaveViewModel extends _$LeaveViewModel {
  @override
  FutureOr<List<LeaveListItem>> build() async {
    return _fetchLeaves();
  }

  // Fetches from the persistent mock database
  Future<List<LeaveListItem>> _fetchLeaves() async {
    try {
      AppLogger.i('📝 Fetching leave requests from mock database');
      await Future.delayed(const Duration(milliseconds: 800));

      return _mockDatabase.map((e) => LeaveListItem.fromApiData(e)).toList();
    } catch (e) {
      AppLogger.e('❌ Error fetching leaves: $e');
      rethrow;
    }
  }

  // Helper method for the ApplyLeaveViewModel to "save" data
  void addMockLeave(LeaveApiData newLeave) {
    _mockDatabase.insert(0, newLeave); // Add to top of list for immediate feedback
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchLeaves);
  }
}

@riverpod
class LeaveSearchQuery extends _$LeaveSearchQuery {
  @override
  String build() => '';
  void updateQuery(String query) => state = query;
}

@riverpod
Future<List<LeaveListItem>> searchedLeaves(Ref ref) async {
  final query = ref.watch(leaveSearchQueryProvider).toLowerCase();
  final allLeaves = await ref.watch(leaveViewModelProvider.future);

  if (query.isEmpty) return allLeaves;

  return allLeaves.where((l) =>
  l.leaveType.toLowerCase().contains(query) ||
      (l.reason?.toLowerCase().contains(query) ?? false)
  ).toList();
}