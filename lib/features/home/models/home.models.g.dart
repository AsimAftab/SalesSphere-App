// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home.models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeModel _$HomeModelFromJson(Map<String, dynamic> json) => _HomeModel(
  totalSales: (json['totalSales'] as num).toInt(),
  revenue: (json['revenue'] as num).toDouble(),
  totalCustomers: (json['totalCustomers'] as num).toInt(),
  recentSales: (json['recentSales'] as List<dynamic>)
      .map((e) => RecentSale.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HomeModelToJson(_HomeModel instance) =>
    <String, dynamic>{
      'totalSales': instance.totalSales,
      'revenue': instance.revenue,
      'totalCustomers': instance.totalCustomers,
      'recentSales': instance.recentSales,
    };

_RecentSale _$RecentSaleFromJson(Map<String, dynamic> json) => _RecentSale(
  id: json['id'] as String,
  productName: json['productName'] as String,
  amount: (json['amount'] as num).toDouble(),
  date: json['date'] as String,
  customerName: json['customerName'] as String,
);

Map<String, dynamic> _$RecentSaleToJson(_RecentSale instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productName': instance.productName,
      'amount': instance.amount,
      'date': instance.date,
      'customerName': instance.customerName,
    };
