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

/// Category model for expense claim
@freezed
abstract class ExpenseCategory with _$ExpenseCategory {
  const factory ExpenseCategory({
    @JsonKey(name: '_id') required String id,
    required String name,
  }) = _ExpenseCategory;

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) =>
      _$ExpenseCategoryFromJson(json);
}

/// API Response wrapper for expense categories endpoint
@freezed
abstract class ExpenseCategoriesApiResponse with _$ExpenseCategoriesApiResponse {
  const factory ExpenseCategoriesApiResponse({
    required bool success,
    required int count,
    required List<ExpenseCategory> data,
  }) = _ExpenseCategoriesApiResponse;

  factory ExpenseCategoriesApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ExpenseCategoriesApiResponseFromJson(json);
}

/// Created by user model
@freezed
abstract class ExpenseCreatedBy with _$ExpenseCreatedBy {
  const factory ExpenseCreatedBy({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String email,
  }) = _ExpenseCreatedBy;

  factory ExpenseCreatedBy.fromJson(Map<String, dynamic> json) =>
      _$ExpenseCreatedByFromJson(json);
}

/// Party model for expense claim
@freezed
abstract class ExpenseParty with _$ExpenseParty {
  const factory ExpenseParty({
    @JsonKey(name: '_id') required String id,
    required String partyName,
    required String ownerName,
  }) = _ExpenseParty;

  factory ExpenseParty.fromJson(Map<String, dynamic> json) =>
      _$ExpensePartyFromJson(json);
}

/// Individual expense claim data from API (list view)
@freezed
abstract class ExpenseClaimApiData with _$ExpenseClaimApiData {
  const factory ExpenseClaimApiData({
    @JsonKey(name: '_id') required String id,
    required String title,
    required double amount,
    required String incurredDate,
    required ExpenseCategory category,
    required String status,
    String? description,
    ExpenseCreatedBy? createdBy,
    ExpenseParty? party,
    String? createdAt,
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
    required String title,
    @JsonKey(name: 'incurredDate') required String date,
    required double amount,
    ExpenseCategory? category, // Category object from API
    required String status,
    String? description,
    @JsonKey(name: 'receipt') String? receiptUrl,
    String? organizationId,
    dynamic createdBy, // Can be string or object
    String? createdAt,
    String? updatedAt,
    dynamic party, // Can be null, string, or object
    dynamic approvedBy, // Can be string or object
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
    required String title,
    required double amount,
    required String incurredDate,
    required String category,
    String? description,
    String? party,
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
    required CreateExpenseClaimData data,
  }) = _CreateExpenseClaimApiResponse;

  factory CreateExpenseClaimApiResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateExpenseClaimApiResponseFromJson(json);
}

/// Create expense claim response data
@freezed
abstract class CreateExpenseClaimData with _$CreateExpenseClaimData {
  const factory CreateExpenseClaimData({
    @JsonKey(name: '_id') required String id,
    required String title,
    required double amount,
    required String incurredDate,
    required ExpenseCategory category,
    required String status,
    String? description,
    ExpenseParty? party,
    String? organizationId,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
    @JsonKey(name: '__v') int? v,
  }) = _CreateExpenseClaimData;

  factory CreateExpenseClaimData.fromJson(Map<String, dynamic> json) =>
      _$CreateExpenseClaimDataFromJson(json);
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
    required String title,
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
      title: apiData.title,
      claimType: apiData.category.name,
      amount: apiData.amount,
      date: apiData.incurredDate,
      status: apiData.status,
      description: apiData.description,
    );
  }

  factory ExpenseClaimListItem.fromExpenseClaimDetails(
      ExpenseClaimDetails claim) {
    return ExpenseClaimListItem(
      id: claim.id,
      title: claim.title,
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
    required String title,
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
      title: apiData.title,
      claimType: apiData.category?.name ?? '', // Extract category name
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
