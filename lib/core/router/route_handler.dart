import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/features/collection/views/add_collection_screen.dart';
import 'package:sales_sphere/features/collection/views/collection_screen.dart';
import 'package:sales_sphere/features/collection/views/edit_collection_screen.dart';
import 'package:sales_sphere/features/leave/views/apply_leave_screen.dart';
import 'package:sales_sphere/features/leave/views/leave_screen.dart';
import 'package:sales_sphere/features/leave/views/edit_leave_screen.dart';
import 'package:sales_sphere/features/notes/views/add_notes_screen.dart';
import 'package:sales_sphere/features/notes/views/edit_notes_screen.dart';
import 'package:sales_sphere/features/notes/views/notes_screen.dart';
import 'package:sales_sphere/features/odometer/views/odometer_details_screen.dart';
import 'package:sales_sphere/features/odometer/views/odometer_list_screen.dart';
import 'package:sales_sphere/features/odometer/views/odometer_screen.dart';
import 'package:sales_sphere/features/tour_plan/views/add_tour_screen.dart';
import 'package:sales_sphere/features/tour_plan/views/edit_tour_details_screen.dart';
import 'package:sales_sphere/features/tour_plan/views/tour_plan_screen.dart';
import 'package:sales_sphere/widget/main_shell.dart';
import 'package:sales_sphere/features/auth/views/login_screen.dart';
import 'package:sales_sphere/features/auth/views/forgot_password_screen.dart';
import 'package:sales_sphere/features/home/views/home_screen.dart';
import 'package:sales_sphere/features/catalog/views/catalog_screen.dart';
import 'package:sales_sphere/features/catalog/views/category_selection_screen.dart';
import 'package:sales_sphere/features/invoice/views/invoice_screen.dart';
import 'package:sales_sphere/features/parties/views/parties_screen.dart';
import 'package:sales_sphere/features/parties/views/edit_party_details_screen.dart';
import 'package:sales_sphere/features/parties/views/add_party_screen.dart';
import 'package:sales_sphere/features/profile/view/profile_screen.dart';
import 'package:sales_sphere/features/attendance/views/attendance_screen.dart';
import 'package:sales_sphere/features/attendance/views/attendance_monthly_details_screen.dart';
import 'package:sales_sphere/features/prospects/views/prospects_screen.dart';
import 'package:sales_sphere/features/prospects/views/add_prospect_screen.dart';
import 'package:sales_sphere/features/prospects/views/edit_prospect_details_screen.dart';
import 'package:sales_sphere/features/sites/views/sites_screen.dart';
import 'package:sales_sphere/features/sites/views/add_sites_screen.dart';
import 'package:sales_sphere/features/sites/views/edit_site_details_screen.dart';
import 'package:sales_sphere/features/sites/views/sites_images_screen.dart';
import 'package:sales_sphere/features/settings/views/settings_screen.dart';
import 'package:sales_sphere/features/settings/views/about_screen.dart';
import 'package:sales_sphere/features/settings/views/terms_and_conditions_screen.dart';
import 'package:sales_sphere/features/settings/views/change_password_screen.dart';
import 'package:sales_sphere/features/utilities/views/utilities_screen.dart';
import 'package:sales_sphere/features/beat_plan/views/beat_plan_details_screen.dart';
import 'package:sales_sphere/features/miscellaneous/views/miscellaneous_list_screen.dart';
import 'package:sales_sphere/features/miscellaneous/views/add_miscellaneous_work_screen.dart';
import 'package:sales_sphere/features/miscellaneous/views/edit_miscellaneous_work_screen.dart';
import 'package:sales_sphere/features/miscellaneous/models/miscellaneous.model.dart';
import 'package:sales_sphere/features/expense-claim/views/expense_claims_screen.dart';
import 'package:sales_sphere/features/expense-claim/views/add_expense_claim_screen.dart';
import 'package:sales_sphere/features/expense-claim/views/edit_expense_claim_screen.dart';
import 'package:sales_sphere/features/auth/models/login.models.dart';
import 'package:sales_sphere/features/splash/views/splash_screen.dart';
import 'package:sales_sphere/features/onboarding/views/onboarding_screen.dart';
import '../../features/invoice/views/history_screen.dart';
import '../../features/invoice/views/invoice_details_screen.dart';
import '../../features/invoice/views/estimate_details_screen.dart';
import '../providers/user_controller.dart';
import '../providers/app_startup.dart';
import '../providers/permission_controller.dart';
import '../constants/module_config.dart';

// ========================================
// HELPER FUNCTIONS
// ========================================

/// Calculate the correct tab index based on route and enabled modules
/// This ensures the correct tab is highlighted when modules are hidden
int _calculateCurrentTabIndex(Ref ref, BuildContext context, String path) {
  final permissionState = ref.read(permissionControllerProvider);

  // Get module for current path
  final moduleId = ModuleConfig.getModuleForRoute(path);

  // If no module found or it's a standalone route (not in bottom nav), default to home
  if (moduleId == null) return 0;

  // Use centralized helper from ModuleConfig for consistency
  final visualIndex = ModuleConfig.getVisualTabIndex(
    moduleId,
    permissionState.isModuleEnabled,
  );

  return visualIndex ?? 0;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  // Watch app startup state - this returns User? when complete
  final appStartup = ref.watch(appStartupProvider);

  // DON'T watch user here - it rebuilds router!
  // Use refreshListenable instead to trigger redirects without rebuilding

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    // Refresh router when user auth state changes
    refreshListenable: _UserAuthNotifier(ref),
    redirect: (context, state) {
      final requestedPath = state.uri.path;

      // Read user state for redirect logic (doesn't trigger rebuild)
      final user = ref.read(userControllerProvider);
      final isLoggedIn = user != null;

      // IMPORTANT: Always allow splash/onboarding to show
      // Splash has critical token validation logic that runs in background
      // Don't interfere with splash navigation - it handles its own routing
      if (requestedPath == '/splash' || requestedPath == '/onboarding') {
        return null; // Allow navigation - splash decides where to go next
      }

      // Check if route is always accessible (no auth required for these)
      final isAlwaysAccessible = ModuleConfig.isAlwaysAccessibleRoute(requestedPath);
      if (isAlwaysAccessible) {
        return null; // Allow navigation to public routes
      }

      // ===== AUTH CHECK =====
      // If user is not logged in, redirect to login
      if (!isLoggedIn) {
        return '/';
      }

      // If user is logged in and trying to go to login page, redirect to home
      if (isLoggedIn && requestedPath == '/') {
        return '/home';
      }

      // ===== MODULE-BASED ACCESS CONTROL (only for logged-in users) =====
      // Check if this route requires module access
      final moduleId = ModuleConfig.getModuleForRoute(requestedPath);

      if (moduleId != null) {
        final permissionState = ref.read(permissionControllerProvider);

        // If subscription data hasn't loaded yet, redirect to home
        // This prevents race condition where disabled features might be briefly exposed
        if (permissionState.subscription == null) {
          return '/home';
        }

        // Check if module is enabled in subscription
        if (!permissionState.isModuleEnabled(moduleId)) {
          // Module not enabled - redirect to home with flag for snackbar
          return '/home?module_disabled=$moduleId';
        }
      }

      // Otherwise, allow navigation
      return null;
    },
    routes: [
      // ========================================
      // SPLASH ROUTE (Initial loading)
      // ========================================
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ========================================
      // ONBOARDING ROUTE (First-time user flow)
      // ========================================
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ========================================
      // AUTH ROUTES (No Bottom Navigation)
      // ========================================
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/edit_party_details_screen/:partyId',
        name: 'edit_party_details_screen',
        builder: (context, state) {
          final partyId = state.pathParameters['partyId'] ?? '1';
          return EditPartyDetailsScreen(partyId: partyId);
        },
      ),
      // ========================================
      // STANDALONE ROUTES (No Bottom Navigation)
      // ========================================
      GoRoute(
        path: '/add-party',
        name: 'add-party',
        builder: (context, state) => const AddPartyScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // ========================================
      // SETTINGS ROUTES (No Bottom Navigation)
      // ========================================
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // ========================================
      // ATTENDANCE ROUTES (No Bottom Navigation)
      // ========================================
      GoRoute(
        path: '/attendance',
        name: 'attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/attendance/monthly-details',
        name: 'attendance-monthly-details',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          final month = extras?['month'] as DateTime?;
          final filter = extras?['filter'];
          return AttendanceMonthlyDetailsScreen(
            initialMonth: month,
            filter: filter,
          );
        },
      ),

      // ========================================
      // BEAT PLAN ROUTES (No Bottom Navigation)
      // ========================================
      GoRoute(
        path: '/beat-plan/:beatPlanId',
        name: 'beat-plan-details',
        builder: (context, state) {
          final beatPlanId = state.pathParameters['beatPlanId'] ?? '';
          return BeatPlanDetailsScreen(beatPlanId: beatPlanId);
        },
      ),

      // ========================================
      // PROSPECTS ROUTES (No Bottom Navigation)
      // ========================================
      GoRoute(
        path: '/prospects',
        name: 'prospects',
        builder: (context, state) => const ProspectsScreen(),
      ),
      GoRoute(
        path: '/add-prospect',
        name: 'add-prospect',
        builder: (context, state) => const AddProspectScreen(),
      ),
      GoRoute(
        path: '/edit-prospect/:prospectId',
        name: 'edit-prospect',
        builder: (context, state) {
          final prospectId = state.pathParameters['prospectId'] ?? '1';
          return EditProspectDetailsScreen(prospectId: prospectId);
        },
      ),
      GoRoute(
        path: '/edit_prospect_details_screen/:prospectId',
        name: 'edit_prospect_details_screen',
        builder: (context, state) {
          final prospectId = state.pathParameters['prospectId'] ?? '1';
          return EditProspectDetailsScreen(prospectId: prospectId);
        },
      ),

      // ========================================
      // SITES ROUTES (No Bottom Navigation)
      // ========================================
      GoRoute(
        path: '/sites',
        name: 'sites',
        builder: (context, state) => const SitesScreen(),
      ),
      GoRoute(
        path: '/add-site',
        name: 'add-site',
        builder: (context, state) => const AddSitesScreen(),
      ),
      GoRoute(
        path: '/edit-site/:siteId',
        name: 'edit-site',
        builder: (context, state) {
          final siteId = state.pathParameters['siteId'] ?? '1';
          return EditSiteDetailsScreen(siteId: siteId);
        },
      ),
      GoRoute(
        path: '/edit_site_details_screen/:siteId',
        name: 'edit_site_details_screen',
        builder: (context, state) {
          final siteId = state.pathParameters['siteId'] ?? '1';
          return EditSiteDetailsScreen(siteId: siteId);
        },
      ),
      GoRoute(
        path: '/sites/:siteId/images',
        name: 'site-images',
        builder: (context, state) {
          final siteId = state.pathParameters['siteId'] ?? '';
          // Handle both String and Map types for siteName
          String siteName = 'Site';
          if (state.extra is String) {
            siteName = state.extra as String;
          } else if (state.extra is Map<String, dynamic>) {
            final extras = state.extra as Map<String, dynamic>;
            siteName = extras['siteName'] as String? ?? 'Site';
          }
          return SitesImagesScreen(siteId: siteId, siteName: siteName);
        },
      ),
      GoRoute(
        path: '/sites_images_screen/:siteId',
        name: 'sites_images_screen',
        builder: (context, state) {
          final siteId = state.pathParameters['siteId'] ?? '';
          // Handle both String and Map types for siteName
          String siteName = 'Site';
          if (state.extra is String) {
            siteName = state.extra as String;
          } else if (state.extra is Map<String, dynamic>) {
            final extras = state.extra as Map<String, dynamic>;
            siteName = extras['siteName'] as String? ?? 'Site';
          }
          return SitesImagesScreen(siteId: siteId, siteName: siteName);
        },
      ),

      // ========================================
      // TOUR PLAN ROUTES
      // ========================================
      GoRoute(
        path: '/tour-plans',
        name: 'tour-plans',
        builder: (context, state) => const TourPlanScreen(),
      ),
      GoRoute(
        path: '/add-tour',
        name: 'add-tour',
        builder: (context, state) => const AddTourPlanScreen(),
      ),
      GoRoute(
        path: '/edit-tour/:tourId',
        name: 'edit-tour',
        builder: (context, state) {
          final tourId = state.pathParameters['tourId'] ?? '';
          return EditTourDetailsScreen(tourId: tourId);
        },
      ),
      // ========================================
      // NOTES ROUTES (No Bottom Navigation)
      // ========================================
      GoRoute(
        path: '/notes',
        name: 'notes',
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: '/add-notes',
        name: 'add-notes',
        builder: (context, state) => const AddNotesScreen(),
      ),
      GoRoute(
        path: '/edit-notes/:noteId',
        name: 'edit-notes',
        builder: (context, state) {
          final noteId = state.pathParameters['noteId'] ?? '';
          return EditNoteScreen(noteId: noteId);
        },
      ),

      // ========================================
      // COLLECTION ROUTES (No Bottom Navigation)
      // ========================================
      GoRoute(
        path: '/collections',
        name: 'collections',
        builder: (context, state) => const CollectionScreen(),
      ),
      GoRoute(
        path: '/add-collection',
        name: 'add-collection',
        builder: (context, state) => const AddCollectionScreen(),
      ),
      GoRoute(
        path: '/edit-collection/:collectionId',
        name: 'edit-collection',
        builder: (context, state) {
          final collectionId = state.pathParameters['collectionId']!;
          return EditCollectionScreen(collectionId: collectionId);
        },
      ),

      // ========================================
      // LEAVE REQUEST ROUTES (No Bottom Navigation)
      // ========================================
      GoRoute(
        path: '/leave-requests',
        name: 'leave-requests',
        builder: (context, state) => const LeaveScreen(),
      ),
      GoRoute(
        path: '/apply-leave',
        name: 'apply-leave',
        builder: (context, state) => const ApplyLeaveRequestScreen(),
      ),
      GoRoute(
        path: '/edit-leave/:leaveId',
        name: 'edit-leave',
        builder: (context, state) {
          final leaveId = state.pathParameters['leaveId']!;
          return EditLeaveScreen(leaveId: leaveId);
        },
      ),

      // ========================================
      // ODOMETER ROUTES (No Bottom Navigation)
      // ========================================
      GoRoute(
        path: '/odometer',
        name: 'odometer',
        builder: (context, state) => const OdometerScreen(),
      ),
      GoRoute(
        path: '/odometer-list',
        name: 'odometer-list',
        builder: (context, state) {
          // Extract the extra map
          final extras = state.extra as Map<String, dynamic>?;
          final month = extras?['month'] as DateTime?;
          return const OdometerListScreen();
        },
      ),
      GoRoute(
        path: '/odometer-details/:id', // Define the ID parameter
        name: 'odometer-details',
        builder: (context, state) {
          // Extract the ID from path parameters
          final id = state.pathParameters['id'] ?? '';
          return OdometerDetailsScreen(id: id);
        },
      ),


      // ========================================
      // SETTINGS ROUTES (No Bottom Navigation)
      // ========================================
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/terms-and-conditions',
        name: 'terms-and-conditions',
        builder: (context, state) => const TermsAndConditionsScreen(),
      ),
      GoRoute(
        path: '/settings/change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // ========================================
      // DIRECTORY ROUTES (No Bottom Navigation)
      // ========================================
      GoRoute(
        path: '/directory/party-list',
        name: 'party-list',
        builder: (context, state) => const PartiesScreen(),
      ),
      GoRoute(
        path: '/directory/prospects-list',
        name: 'prospects-list',
        builder: (context, state) => const ProspectsScreen(),
      ),
      GoRoute(
        path: '/directory/sites-list',
        name: 'sites-list',
        builder: (context, state) => const SitesScreen(),
      ),

      // ========================================
      // MISCELLANEOUS ROUTES (No Bottom Navigation)
      // ========================================
      GoRoute(
        path: '/miscellaneous-work',
        name: 'miscellaneous-work',
        builder: (context, state) => const MiscellaneousListScreen(),
      ),
      GoRoute(
        path: '/add-miscellaneous-work',
        name: 'add-miscellaneous-work',
        builder: (context, state) => const AddMiscellaneousWorkScreen(),
      ),
      GoRoute(
        path: '/edit-miscellaneous-work',
        name: 'edit-miscellaneous-work',
        builder: (context, state) {
          final workData = state.extra as MiscWorkData;
          return EditMiscellaneousWorkScreen(workData: workData);
        },
      ),

      // ========================================
      // EXPENSE CLAIMS ROUTES (No Bottom Navigation)
      // ========================================
      GoRoute(
        path: '/expense-claims',
        name: 'expense-claims',
        builder: (context, state) => const ExpenseClaimsScreen(),
      ),
      GoRoute(
        path: '/add-expense-claim',
        name: 'add-expense-claim',
        builder: (context, state) => const AddExpenseClaimScreen(),
      ),
      GoRoute(
        path: '/expense-claim/:claimId',
        name: 'expense_claim_details',
        builder: (context, state) {
          final claimId = state.pathParameters['claimId'] ?? '';
          return EditExpenseClaimScreen(claimId: claimId);
        },
      ),

      // ========================================
      // MAIN APP ROUTES (With Bottom Navigation)
      // ========================================

      ShellRoute(
        builder: (context, state, child) {
          // Check if user was redirected due to disabled module
          _showModuleDisabledSnackbarIfNeeded(context);

          // Calculate current index dynamically based on enabled modules
          final currentIndex = _calculateCurrentTabIndex(ref, context, state.uri.path);

          return MainShell(currentIndex: currentIndex, child: child);
        },
        routes: [
          // Home Tab
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),

          // Catalog Tab
          GoRoute(
            path: '/catalog',
            name: 'catalog',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CatalogScreen()),
            routes: [
              GoRoute(
                path: 'select-category',
                name: 'category_selection',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CategorySelectionScreen()),
              ),
            ],
          ),
          // Invoice Tab
          GoRoute(
            path: '/invoice',
            name: 'invoice',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InvoiceScreen()),
          ),
          GoRoute(
            path: '/invoice/history',
            name: 'invoice_history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/invoice/details/:id',
            name: 'invoice_details',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return InvoiceDetailsScreen(invoiceId: id);
            },
          ),
          GoRoute(
            path: '/estimate/details/:id',
            name: 'estimate_details',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EstimateDetailsScreen(estimateId: id);
            },
          ),

          // Parties Tab (Keep for backwards compatibility)
          GoRoute(
            path: '/parties',
            name: 'parties',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PartiesScreen()),
          ),

          // Utilities Tab
          GoRoute(
            path: '/utilities',
            name: 'utilities',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: UtilitiesScreen()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
});

// ========================================
// MODULE DISABLED SNACKBAR HELPER
// ========================================
/// Shows a snackbar when user tries to access a disabled module.
/// Called from ShellRoute builder to check query params.
void _showModuleDisabledSnackbarIfNeeded(BuildContext context) {
  final GoRouterState state = GoRouterState.of(context);
  final disabledModule = state.uri.queryParameters['module_disabled'];

  if (disabledModule != null) {
    // Get display name for the module
    final displayName = ModuleConfig.getDisplayName(disabledModule);

    // Show snackbar once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$displayName is not available in your current plan'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        );

        // Clear the query param by navigating to clean home URL
        final cleanPath = state.uri.path;
        if (cleanPath == '/home') {
          context.go(cleanPath);
        }
      }
    });
  }
}

// ========================================
// ERROR PAGE
// ========================================
class ErrorPage extends StatelessWidget {
  final Object? error;

  const ErrorPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error: ${error ?? "Unknown error"}',
            style: const TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ========================================
// USER AUTH NOTIFIER
// ========================================
/// Notifier that listens to user auth state changes and refreshes GoRouter
class _UserAuthNotifier extends ChangeNotifier {
  final Ref _ref;

  _UserAuthNotifier(this._ref) {
    // Listen to user controller changes
    _ref.listen<User?>(userControllerProvider, (previous, next) {
      // Notify GoRouter to refresh when user state changes
      notifyListeners();
    });
  }
}
