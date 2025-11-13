import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:sales_sphere/features/auth/models/login.models.dart';
import '../../features/invoice/views/invoice_history_screen.dart';
import '../providers/user_controller.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // Watch the user controller to rebuild routes when auth state changes
  final user = ref.watch(userControllerProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    // Refresh router when user auth state changes
    refreshListenable: _UserAuthNotifier(ref),
    redirect: (context, state) {
      final isLoggedIn = user != null;

      // Get the path the user is trying to access
      final requestedPath = state.uri.path;

      // Check against your allowed routes
      final isGoingToLogin = requestedPath == '/';
      final isGoingToForgotPassword = requestedPath == '/forgot-password';
      final isGoingToCatalog = requestedPath.startsWith('/catalog');
      final isGoingToParties = requestedPath.startsWith('/parties');
      final isGoingToDirectory =
          requestedPath.startsWith('/directory') ||
          requestedPath.startsWith('/directory/prospects-list');
      final isGoingToEditParty = requestedPath.startsWith(
        '/edit_party_details_screen',
      );
      final isGoingToDetailAdded = requestedPath == '/detail-added';
      final isGoingToProfile = requestedPath == '/profile';
      final isGoingToAttendance = requestedPath.startsWith('/attendance');
      final isGoingToProspects =
          requestedPath.startsWith('/prospects') ||
          requestedPath.startsWith('/add-prospect') ||
          requestedPath.startsWith('/edit-prospect');
      final isGoingToSites =
          requestedPath.startsWith('/sites') ||
          requestedPath.startsWith('/add-site') ||
          requestedPath.startsWith('/edit-site');
      final isGoingToAbout = requestedPath == '/about';
      final isGoingToTerms = requestedPath == '/terms-and-conditions';
      final isGoingToChangePassword =
          requestedPath == '/settings/change-password';

      // If user is not logged in AND not going to one of the allowed pages...
      if (!isLoggedIn &&
          !isGoingToLogin &&
          !isGoingToForgotPassword &&
          !isGoingToCatalog &&
          !isGoingToParties &&
          !isGoingToDirectory &&
          !isGoingToEditParty &&
          !isGoingToDetailAdded &&
          !isGoingToProfile &&
          !isGoingToAttendance &&
          !isGoingToProspects &&
          !isGoingToSites &&
          !isGoingToAbout &&
          !isGoingToTerms &&
          !isGoingToChangePassword) {
        return '/';
      }

      // If user is logged in and trying to go to login, redirect to home
      if (isLoggedIn && isGoingToLogin) {
        return '/home';
      }

      // Otherwise, allow navigation
      return null;
    },
    routes: [
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
      // MAIN APP ROUTES (With Bottom Navigation)
      // ========================================
      ShellRoute(
        builder: (context, state, child) {
          // Determine current index based on location
          final location = state.uri.path;
          int currentIndex = 0;

          if (location.startsWith('/home')) {
            currentIndex = 0;
          } else if (location.startsWith('/catalog')) {
            currentIndex = 1;
          } else if (location.startsWith('/invoice')) {
            currentIndex = 2;
          } else if (location.startsWith('/parties') ||
              location.startsWith('/directory')) {
            currentIndex = 3;
          } else if (location.startsWith('/settings')) {
            currentIndex = 4;
          }

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
            builder: (context, state) => const InvoiceHistoryScreen(),
          ),

          // Parties Tab (Keep for backwards compatibility)
          GoRoute(
            path: '/parties',
            name: 'parties',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PartiesScreen()),
          ),

          // Settings Tab
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
});

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
