import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    await Future.delayed(const Duration(seconds: 1));

    return [
      OdometerListItem(id: '1', date: DateTime(2025, 12, 21), startReading: 45320, endReading: 45485, totalDistance: 165),
      OdometerListItem(id: '2', date: DateTime(2024, 12, 20), startReading: 45150, endReading: 45320, totalDistance: 170),
      OdometerListItem(id: '3', date: DateTime(2024, 12, 19), startReading: 45000, endReading: 45150, totalDistance: 150),
      OdometerListItem(id: '4', date: DateTime(2024, 12, 18), startReading: 44850, endReading: 45000, totalDistance: 150),
      OdometerListItem(id: '5', date: DateTime(2026, 01, 19), startReading: 45000, endReading: 45150, totalDistance: 150),
      OdometerListItem(id: '6', date: DateTime(2026, 01, 18), startReading: 44860, endReading: 45000, totalDistance: 150),
    ];
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
  final filteredByMonth = allReadings.where((item) =>
  item.date.year == selectedMonth.year &&
      item.date.month == selectedMonth.month
  ).toList();

  // 2. Apply search filter on top of the month filter
  if (query.isEmpty) return filteredByMonth;

  return filteredByMonth.where((item) {
    // You can search by start meter, end meter, or formatted date string
    final String dateStr = DateFormat('MMM dd, yyyy').format(item.date).toLowerCase();
    final String startMeter = item.startReading.toString();
    final String endMeter = item.endReading.toString();

    return dateStr.contains(query) ||
        startMeter.contains(query) ||
        endMeter.contains(query);
  }).toList();
}