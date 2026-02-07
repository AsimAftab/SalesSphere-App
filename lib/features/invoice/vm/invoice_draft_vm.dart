import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/providers/order_controller.dart';
import 'package:sales_sphere/features/parties/models/parties.model.dart';

part 'invoice_draft_vm.freezed.dart';
part 'invoice_draft_vm.g.dart';

@freezed
abstract class InvoiceDraftState with _$InvoiceDraftState {
  const factory InvoiceDraftState({
    PartyDetails? selectedParty,
    DateTime? expectedDeliveryDate,
    @Default(0.0) double discountPercentage,
  }) = _InvoiceDraftState;
}

@Riverpod(keepAlive: true)
class InvoiceDraftController extends _$InvoiceDraftController {
  Timer? _timer;
  static const _timeout = Duration(minutes: 5);

  @override
  InvoiceDraftState build() => const InvoiceDraftState();

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(_timeout, () {
      // Clear draft
      state = const InvoiceDraftState();
      // Clear order items
      ref.read(orderControllerProvider.notifier).clearOrder();
    });
  }

  void updateParty(PartyDetails? party) {
    state = state.copyWith(selectedParty: party);
    _resetTimer();
  }

  void updateDate(DateTime? date) {
    state = state.copyWith(expectedDeliveryDate: date);
    _resetTimer();
  }

  void updateDiscount(double discount) {
    state = state.copyWith(discountPercentage: discount);
    _resetTimer();
  }

  /// Call this when the user interacts with the order (e.g. adds items)
  /// to prevent the session from expiring.
  void refreshSession() {
    _resetTimer();
  }

  void clear() {
    _timer?.cancel();
    state = const InvoiceDraftState();
  }
}
