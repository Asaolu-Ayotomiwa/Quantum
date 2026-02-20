import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Features/auth/auth_providers.dart';
import 'firebase_options.dart';
import 'package:quantum/Core/app_theme.dart';
import 'package:quantum/Screens/onboarding_screen.dart';
import 'package:quantum/Screens/home_screen.dart';
import 'package:quantum/test_firestore_connection.dart'; // Add this import


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      // Add routes here
      routes: {
        '/test_firestore': (context) => const TestFirestoreConnection(),
      },
    );
  }
}

// Auth Wrapper - Put this INSIDE main.dart
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeScreen();
        }
        return const OnboardingScreen();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.green,
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Auth Error: $error'),
            ],
          ),
        ),
      ),
    );
  }
}