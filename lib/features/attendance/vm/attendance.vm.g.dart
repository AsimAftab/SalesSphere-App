// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodayAttendanceViewModel)
const todayAttendanceViewModelProvider = TodayAttendanceViewModelProvider._();

final class TodayAttendanceViewModelProvider
    extends $NotifierProvider<TodayAttendanceViewModel, TodayAttendance> {
  const TodayAttendanceViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayAttendanceViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayAttendanceViewModelHash();

  @$internal
  @override
  TodayAttendanceViewModel create() => TodayAttendanceViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodayAttendance value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodayAttendance>(value),
    );
  }
}

String _$todayAttendanceViewModelHash() =>
    r'a004017c748700ee51c0633eff912c73b4e50d28';

abstract class _$TodayAttendanceViewModel extends $Notifier<TodayAttendance> {
  TodayAttendance build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TodayAttendance, TodayAttendance>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TodayAttendance, TodayAttendance>,
              TodayAttendance,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(AttendanceHistoryViewModel)
const attendanceHistoryViewModelProvider =
    AttendanceHistoryViewModelProvider._();

final class AttendanceHistoryViewModelProvider
    extends
        $NotifierProvider<AttendanceHistoryViewModel, List<AttendanceRecord>> {
  const AttendanceHistoryViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceHistoryViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceHistoryViewModelHash();

  @$internal
  @override
  AttendanceHistoryViewModel create() => AttendanceHistoryViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AttendanceRecord> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AttendanceRecord>>(value),
    );
  }
}

String _$attendanceHistoryViewModelHash() =>
    r'68095d06b8f4d03e72f05fd14de8b0f3fe2e470b';

abstract class _$AttendanceHistoryViewModel
    extends $Notifier<List<AttendanceRecord>> {
  List<AttendanceRecord> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<List<AttendanceRecord>, List<AttendanceRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<AttendanceRecord>, List<AttendanceRecord>>,
              List<AttendanceRecord>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(AttendanceSummaryViewModel)
const attendanceSummaryViewModelProvider =
    AttendanceSummaryViewModelProvider._();

final class AttendanceSummaryViewModelProvider
    extends $NotifierProvider<AttendanceSummaryViewModel, AttendanceSummary> {
  const AttendanceSummaryViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceSummaryViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceSummaryViewModelHash();

  @$internal
  @override
  AttendanceSummaryViewModel create() => AttendanceSummaryViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendanceSummary value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendanceSummary>(value),
    );
  }
}

String _$attendanceSummaryViewModelHash() =>
    r'c29c60d9324ec2e9cefe94dc70abb780cfef5bad';

abstract class _$AttendanceSummaryViewModel
    extends $Notifier<AttendanceSummary> {
  AttendanceSummary build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AttendanceSummary, AttendanceSummary>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AttendanceSummary, AttendanceSummary>,
              AttendanceSummary,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
