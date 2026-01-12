import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import '../model/odometer.model.dart';

part 'odometer_list.vm.g.dart';

// Add a provider to manage the selected month state
@riverpod
class SelectedOdometerMonth extends _$SelectedOdometerMonth {
  @override
  DateTime build() => DateTime.now();

  void updateMonth(DateTime newMonth) => state = newMonth;
}

@riverpod
class OdometerListSearchQuery extends _$OdometerListSearchQuery {
  @override
  String build() => "";

  void updateQuery(String query) => state = query;
}

@riverpod
class OdometerListViewModel extends _$OdometerListViewModel {
  @override
  Future<List<OdometerListItem>> build() async {
    final selectedMonth = ref.watch(selectedOdometerMonthProvider);
    return _fetchMonthlyReport(selectedMonth);
  }

  /// Fetch monthly odometer report from API
  Future<List<OdometerListItem>> _fetchMonthlyReport(DateTime month) async {
    try {
      AppLogger.i('📋 Fetching odometer monthly report for ${DateFormat('MMMM yyyy').format(month)}...');

      final dio = ref.read(dioClientProvider);
      final response = await dio.get(
        '/api/v1/odometer/my-monthly-report',
        queryParameters: {
          'month': month.month,
          'year': month.year,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final odometerMap = data['odometer'] as Map<String, dynamic>;

        // Convert the odometer map to list of OdometerListItem
        final items = <OdometerListItem>[];

        odometerMap.forEach((dayKey, dayData) {
          if (dayData is! Map<String, dynamic>) return;

          final entry = DailyOdometerEntry.fromJson(dayData);

          // Only include completed readings
          if (entry.status == 'completed' &&
              entry.startReading != null &&
              entry.stopReading != null) {
            final day = int.parse(dayKey);

            // Create the date from the selected month and day
            final date = DateTime(month.year, month.month, day);

            // Use the MongoDB ID if available, otherwise fall back to constructed ID
            // Note: Backend should include '_id' in monthly report for details to work
            final itemId = entry.id ?? 'odometer_${month.year}_${month.month}_$day';

            items.add(OdometerListItem(
              id: itemId,
              date: date,
              startReading: entry.startReading!,
              endReading: entry.stopReading!,
              totalDistance: entry.distance ?? (entry.stopReading! - entry.startReading!),
            ));
          }
        });

        // Sort by date descending
        items.sort((a, b) => b.date.compareTo(a.date));

        AppLogger.i('✅ Loaded ${items.length} odometer readings');
        return items;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.e('❌ Failed to fetch monthly report: $e');
      return [];
    } catch (e) {
      AppLogger.e('❌ Unexpected error: $e');
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidateSelf();
  }
}

@riverpod
Future<List<OdometerListItem>> searchedOdometerReadings(Ref ref) async {
  // Watch the current search text
  final query = ref.watch(odometerListSearchQueryProvider).toLowerCase();

  // Watch the currently selected month from the selector
  final selectedMonth = ref.watch(selectedOdometerMonthProvider);

  // Get the full data list
  final allReadings = await ref.watch(odometerListViewModelProvider.future);

  // 1. Filter by the selected Month/Year first
  final filteredByMonth = allReadings
      .where(
        (item) =>
            item.date.year == selectedMonth.year &&
            item.date.month == selectedMonth.month,
      )
      .toList();

  // 2. Apply search filter on top of the month filter
  if (query.isEmpty) return filteredByMonth;

  return filteredByMonth.where((item) {
    // You can search by start meter, end meter, or formatted date string
    final String dateStr = DateFormat(
      'MMM dd, yyyy',
    ).format(item.date).toLowerCase();
    final String startMeter = item.startReading.toString();
    final String endMeter = item.endReading.toString();

    return dateStr.contains(query) ||
        startMeter.contains(query) ||
        endMeter.contains(query);
  }).toList();
}
