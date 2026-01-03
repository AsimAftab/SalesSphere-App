// lib/features/leave/vm/apply_leave.vm.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/leave/models/leave.model.dart';
import 'package:sales_sphere/features/leave/vm/leave.vm.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'apply_leave.vm.g.dart';

@riverpod
class ApplyLeaveViewModel extends _$ApplyLeaveViewModel {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> submitLeave({required Map<String, dynamic> data}) async {
    state = const AsyncValue.loading();
    try {
      AppLogger.i('🚀 Submitting Leave Request: $data');

      // Simulating API latency
      await Future.delayed(const Duration(seconds: 1));

      // CRITICAL: Check if provider is still mounted after async delay
      if (!ref.mounted) return;

      final newLeave = LeaveApiData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        leaveType: data['leaveType'] ?? 'General Leave',
        startDate: data['startDate'] ?? '',
        endDate: data['endDate'] ?? '',
        status: 'Pending',
        reason: data['reason'],
        createdAt: DateTime.now().toIso8601String(),
      );

      // Save to mock database and trigger refresh
      ref.read(leaveViewModelProvider.notifier).addMockLeave(newLeave);
      ref.invalidate(leaveViewModelProvider);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      if (ref.mounted) {
        AppLogger.e('❌ Leave submission failed: $e');
        state = AsyncValue.error(e, stack);
      }
    }
  }
}