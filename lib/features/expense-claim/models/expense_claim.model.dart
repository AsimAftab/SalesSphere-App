import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_claim.model.freezed.dart';
part 'expense_claim.model.g.dart';

// ============================================================================
// API Response Models
// ============================================================================

/// API Response wrapper for expense claims list endpoint
@freezed
abstract class ExpenseClaimsApiResponse with _$ExpenseClaimsApiResponse {
  const factory ExpenseClaimsApiResponse({
    required bool success,
    required int count,
    required List<ExpenseClaimApiData> data,
  }) = _ExpenseClaimsApiResponse;

  factory ExpenseClaimsApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ExpenseClaimsApiResponseFromJson(json);
}

/// Individual expense claim data from API (list view)
@freezed
abstract class ExpenseClaimApiData with _$ExpenseClaimApiData {
  const factory ExpenseClaimApiData({
    @JsonKey(name: '_id') required String id,
    required String claimType,
    required double amount,
    required String date,
    required String status,
    String? description,
    String? receiptUrl,
  }) = _ExpenseClaimApiData;

  factory ExpenseClaimApiData.fromJson(Map<String, dynamic> json) =>
      _$ExpenseClaimApiDataFromJson(json);
}

/// API Response wrapper for single expense claim details endpoint
@freezed
abstract class ExpenseClaimDetailApiResponse
    with _$ExpenseClaimDetailApiResponse {
  const factory ExpenseClaimDetailApiResponse({
    required bool success,
    required ExpenseClaimDetailApiData data,
  }) = _ExpenseClaimDetailApiResponse;

  factory ExpenseClaimDetailApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ExpenseClaimDetailApiResponseFromJson(json);
}

/// Full expense claim data from API (details view)
@freezed
abstract class ExpenseClaimDetailApiData with _$ExpenseClaimDetailApiData {
  const factory ExpenseClaimDetailApiData({
    @JsonKey(name: '_id') required String id,
    required String claimType,
    required double amount,
    required String date,
    required String status,
    String? description,
    String? receiptUrl,
    String? organizationId,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
    String? approvedBy,
    String? approvedAt,
    String? rejectedReason,
  }) = _ExpenseClaimDetailApiData;

  factory ExpenseClaimDetailApiData.fromJson(Map<String, dynamic> json) =>
      _$ExpenseClaimDetailApiDataFromJson(json);
}

// ============================================================================
// Create Request Models
// ============================================================================

/// Create expense claim request model for POST /api/v1/expense-claims
@freezed
abstract class CreateExpenseClaimRequest with _$CreateExpenseClaimRequest {
  const factory CreateExpenseClaimRequest({
    required String claimType,
    required double amount,
    required String date,
    String? description,
    String? receiptUrl,
  }) = _CreateExpenseClaimRequest;

  factory CreateExpenseClaimRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateExpenseClaimRequestFromJson(json);
}

/// API Response wrapper for create expense claim endpoint
@freezed
abstract class CreateExpenseClaimApiResponse
    with _$CreateExpenseClaimApiResponse {
  const factory CreateExpenseClaimApiResponse({
    required bool success,
    required ExpenseClaimDetailApiData data,
  }) = _CreateExpenseClaimApiResponse;

  factory CreateExpenseClaimApiResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateExpenseClaimApiResponseFromJson(json);
}

// ============================================================================
// Update Request Models
// ============================================================================

/// Update expense claim request model for PUT /api/v1/expense-claims/:id
@freezed
abstract class UpdateExpenseClaimRequest with _$UpdateExpenseClaimRequest {
  const factory UpdateExpenseClaimRequest({
    required String claimType,
    required double amount,
    required String date,
    String? description,
    String? receiptUrl,
  }) = _UpdateExpenseClaimRequest;

  factory UpdateExpenseClaimRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateExpenseClaimRequestFromJson(json);

  factory UpdateExpenseClaimRequest.fromExpenseClaimDetails(
      ExpenseClaimDetails claim) {
    return UpdateExpenseClaimRequest(
      claimType: claim.claimType,
      amount: claim.amount,
      date: claim.date,
      description: claim.description,
      receiptUrl: claim.receiptUrl,
    );
  }
}

// ============================================================================
// App Models
// ============================================================================

/// Lightweight model for expense claim list display
@freezed
abstract class ExpenseClaimListItem with _$ExpenseClaimListItem {
  const factory ExpenseClaimListItem({
    required String id,
    required String claimType,
    required double amount,
    required String date,
    required String status,
    String? description,
  }) = _ExpenseClaimListItem;

  factory ExpenseClaimListItem.fromJson(Map<String, dynamic> json) =>
      _$ExpenseClaimListItemFromJson(json);

  factory ExpenseClaimListItem.fromApiData(ExpenseClaimApiData apiData) {
    return ExpenseClaimListItem(
      id: apiData.id,
      claimType: apiData.claimType,
      amount: apiData.amount,
      date: apiData.date,
      status: apiData.status,
      description: apiData.description,
    );
  }

  factory ExpenseClaimListItem.fromExpenseClaimDetails(
      ExpenseClaimDetails claim) {
    return ExpenseClaimListItem(
      id: claim.id,
      claimType: claim.claimType,
      amount: claim.amount,
      date: claim.date,
      status: claim.status,
      description: claim.description,
    );
  }
}

/// Full expense claim details model (for edit/view screens)
@freezed
abstract class ExpenseClaimDetails with _$ExpenseClaimDetails {
  const ExpenseClaimDetails._();

  const factory ExpenseClaimDetails({
    required String id,
    required String claimType,
    required double amount,
    required String date,
    required String status,
    String? description,
    String? receiptUrl,
    String? approvedBy,
    String? approvedAt,
    String? rejectedReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ExpenseClaimDetails;

  factory ExpenseClaimDetails.fromJson(Map<String, dynamic> json) =>
      _$ExpenseClaimDetailsFromJson(json);

  factory ExpenseClaimDetails.fromApiDetail(
      ExpenseClaimDetailApiData apiData) {
    return ExpenseClaimDetails(
      id: apiData.id,
      claimType: apiData.claimType,
      amount: apiData.amount,
      date: apiData.date,
      status: apiData.status,
      description: apiData.description,
      receiptUrl: apiData.receiptUrl,
      approvedBy: apiData.approvedBy,
      approvedAt: apiData.approvedAt,
      rejectedReason: apiData.rejectedReason,
      createdAt: apiData.createdAt != null
          ? DateTime.tryParse(apiData.createdAt!)
          : null,
      updatedAt: apiData.updatedAt != null
          ? DateTime.tryParse(apiData.updatedAt!)
          : null,
    );
  }
}
