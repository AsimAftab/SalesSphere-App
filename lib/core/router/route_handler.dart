import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/features/Detail-Added/view/detail_added.dart';

import '../../features/auth/views/login_screen.dart';


final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/detail-added',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        // Define the root path as the starting screen (Login)
        path: '/',
        name: 'login',
        // Using the placeholder, replace with your actual LoginScreen
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        // 2. Define a separate, named path for the DetailAdded screen
        path: '/detail-added',
        name: 'detail-added',
        builder: (context, state) => const DetailAdded(),
      ),

    ],

    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
});

// Placeholder Home Page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Sphere'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Sales Sphere! 🚀',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}


// Error Page
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
