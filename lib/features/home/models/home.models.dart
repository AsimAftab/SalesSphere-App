import 'package:freezed_annotation/freezed_annotation.dart';

part 'home.models.freezed.dart';
part 'home.models.g.dart';

@freezed
abstract class HomeModel with _$HomeModel {
  const factory HomeModel({
    required int totalSales,
    required double revenue,
    required int totalCustomers,
    required List<RecentSale> recentSales,
  }) = _HomeModel;

  factory HomeModel.fromJson(Map<String, dynamic> json) =>
      _$HomeModelFromJson(json);
}

@freezed
abstract class RecentSale with _$RecentSale {
  const factory RecentSale({
    required String id,
    required String productName,
    required double amount,
    required String date,
    required String customerName,
  }) = _RecentSale;

  factory RecentSale.fromJson(Map<String, dynamic> json) =>
      _$RecentSaleFromJson(json);
}