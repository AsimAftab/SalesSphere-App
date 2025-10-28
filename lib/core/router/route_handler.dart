import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/widget/main_shell.dart';
import 'package:sales_sphere/features/auth/views/login_screen.dart';
import 'package:sales_sphere/features/home/views/home_screen.dart';
import 'package:sales_sphere/features/catalog/views/catalog_screen.dart';
import 'package:sales_sphere/features/invoice/views/invoice_screen.dart';
import 'package:sales_sphere/features/parties/views/parties_screen.dart';
import 'package:sales_sphere/features/settings/views/settings_screen.dart';
import 'package:sales_sphere/features/Detail-Added/view/detail_added.dart';
import 'package:sales_sphere/features/auth/models/login.models.dart';

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
      final isGoingToLogin = state.matchedLocation == '/';
      final isGoingToDetailAdded = state.matchedLocation == '/detail-added';

      // If user is not logged in and trying to access protected routes, redirect to login
      if (!isLoggedIn && !isGoingToLogin && !isGoingToDetailAdded) {
        return '/';
      }

      // If user is already logged in and trying to go to login, redirect to home
      if (isLoggedIn && isGoingToLogin) {
        return '/home';
      }

      // Allow navigation
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
        path: '/detail-added',
        name: 'detail-added',
        builder: (context, state) => const DetailAdded(),
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
          } else if (location.startsWith('/parties')) {
            currentIndex = 3;
          } else if (location.startsWith('/settings')) {
            currentIndex = 4;
          }

          return MainShell(
            currentIndex: currentIndex,
            child: child,
          );
        },
        routes: [
          // Home Tab
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),

          // Catalog Tab
          GoRoute(
            path: '/catalog',
            name: 'catalog',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CatalogScreen(),
            ),
          ),

          // Invoice Tab
          GoRoute(
            path: '/invoice',
            name: 'invoice',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InvoiceScreen(),
            ),
          ),

          // Parties Tab
          GoRoute(
            path: '/parties',
            name: 'parties',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PartiesScreen(),
            ),
          ),

          // Settings Tab
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
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
    _ref.listen<User?>(
      userControllerProvider,
      (previous, next) {
        // Notify GoRouter to refresh when user state changes
        notifyListeners();
      },
    );
  }
}