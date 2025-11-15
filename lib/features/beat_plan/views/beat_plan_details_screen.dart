import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/beat_plan/models/beat_plan.models.dart';
import 'package:sales_sphere/features/beat_plan/vm/beat_plan.vm.dart';
import 'package:sales_sphere/features/beat_plan/widgets/route_progress_card.dart';
import 'package:sales_sphere/features/beat_plan/widgets/party_visit_card.dart';
import 'package:sales_sphere/features/beat_plan/widgets/tracking_status_card.dart';
import 'package:sales_sphere/features/beat_plan/widgets/tracking_controls_widget.dart';
import 'package:sales_sphere/features/beat_plan/widgets/tracking_indicator_widget.dart';

/// Beat Plan Details Screen
/// Shows detailed beat plan with route progress, filter tabs, and party visit cards
class BeatPlanDetailsScreen extends ConsumerStatefulWidget {
  final String beatPlanId;

  const BeatPlanDetailsScreen({
    super.key,
    required this.beatPlanId,
  });

  @override
  ConsumerState<BeatPlanDetailsScreen> createState() => _BeatPlanDetailsScreenState();
}

class _BeatPlanDetailsScreenState extends ConsumerState<BeatPlanDetailsScreen> {
  // Filter state: 'all', 'pending', 'visited'
  String _selectedFilter = 'all';
  String? _loadingVisitId;

  @override
  Widget build(BuildContext context) {
    final beatPlanAsync = ref.watch(beatPlanDetailViewModelProvider(widget.beatPlanId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Beat Plan Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: TrackingIndicatorWidget(),
          ),
        ],
      ),
      body: beatPlanAsync.when(
        data: (beatPlan) {
          if (beatPlan == null) {
            return _buildEmptyState();
          }

          return _buildContent(beatPlan);
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildContent(BeatPlanDetail beatPlan) {
    // Filter parties based on selected tab
    final filteredParties = _getFilteredParties(beatPlan.parties);

    // Calculate counts for tabs
    final allCount = beatPlan.parties.length;
    final pendingCount = beatPlan.parties
        .where((p) => p.visitStatus.status.toLowerCase() == 'pending')
        .length;
    final visitedCount = beatPlan.parties
        .where((p) => p.visitStatus.status.toLowerCase() == 'visited')
        .length;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(beatPlanDetailViewModelProvider(widget.beatPlanId).notifier).refresh(widget.beatPlanId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Beat Plan Name
            Text(
              beatPlan.name,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 8.h),

            // Status badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(beatPlan.status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                _getStatusText(beatPlan.status),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(beatPlan.status),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Route Progress Card
            RouteProgressCard(
              totalParties: beatPlan.progress.totalDirectories,
              visitedParties: beatPlan.progress.visitedDirectories,
              pendingParties: beatPlan.progress.totalDirectories - beatPlan.progress.visitedDirectories,
              progressPercentage: beatPlan.progress.percentage,
            ),

            SizedBox(height: 16.h),

            // Tracking Status Card
            const TrackingStatusCard(),

            // Tracking Controls
            TrackingControlsWidget(
              onTrackingStopped: () {
                // Refresh beat plan data when tracking stops
                ref.invalidate(beatPlanDetailViewModelProvider(widget.beatPlanId));
              },
            ),

            SizedBox(height: 24.h),

            // Filter Tabs
            Row(
              children: [
                _buildFilterTab(
                  label: 'All',
                  count: allCount,
                  isSelected: _selectedFilter == 'all',
                  onTap: () => setState(() => _selectedFilter = 'all'),
                ),
                SizedBox(width: 10.w),
                _buildFilterTab(
                  label: 'Pending',
                  count: pendingCount,
                  isSelected: _selectedFilter == 'pending',
                  onTap: () => setState(() => _selectedFilter = 'pending'),
                ),
                SizedBox(width: 10.w),
                _buildFilterTab(
                  label: 'Visited',
                  count: visitedCount,
                  isSelected: _selectedFilter == 'visited',
                  onTap: () => setState(() => _selectedFilter = 'visited'),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Party Visit Cards
            if (filteredParties.isEmpty)
              _buildEmptyFilterState()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredParties.length,
                itemBuilder: (context, index) {
                  final party = filteredParties[index];
                  final isLoading = _loadingVisitId == party.id;

                  return PartyVisitCard(
                    party: party,
                    isLoading: isLoading,
                    onMarkComplete: () => _handleMarkVisitComplete(
                      beatPlan.id,
                      party.id,
                    ),
                    onMarkPending: () => _handleMarkVisitPending(
                      beatPlan.id,
                      party.id,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    Color getColor() {
      if (label == 'All') return AppColors.primary;
      if (label == 'Pending') return AppColors.secondary;
      return AppColors.success;
    }

    final color = getColor();

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      color,
                      color.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? color : AppColors.greyLight,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<BeatDirectory> _getFilteredParties(List<BeatDirectory> parties) {
    if (_selectedFilter == 'all') {
      return parties;
    } else if (_selectedFilter == 'pending') {
      return parties.where((p) => p.visitStatus.status.toLowerCase() == 'pending').toList();
    } else {
      return parties.where((p) => p.visitStatus.status.toLowerCase() == 'visited').toList();
    }
  }

  Future<void> _handleMarkVisitComplete(String beatPlanId, String visitId) async {
    setState(() => _loadingVisitId = visitId);
    try {
      final success = await ref.read(beatPlanDetailViewModelProvider(beatPlanId).notifier).markVisitComplete(beatPlanId, visitId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Visit marked as completed'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark visit: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingVisitId = null);
      }
    }
  }

  Future<void> _handleMarkVisitPending(String beatPlanId, String visitId) async {
    setState(() => _loadingVisitId = visitId);
    try {
      final success = await ref.read(beatPlanDetailViewModelProvider(beatPlanId).notifier).markVisitPending(beatPlanId, visitId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Visit marked as pending'),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark visit: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingVisitId = null);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'in-progress':
        return AppColors.secondary;
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.greyMedium;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'in-progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(
              Icons.filter_list_off,
              size: 48.sp,
              color: AppColors.greyMedium,
            ),
            SizedBox(height: 12.h),
            Text(
              'No parties in this filter',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route_outlined,
            size: 64.sp,
            color: AppColors.greyMedium,
          ),
          SizedBox(height: 16.h),
          Text(
            'Beat Plan Not Found',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading beat plan details...',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load beat plan',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(beatPlanDetailViewModelProvider(widget.beatPlanId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
