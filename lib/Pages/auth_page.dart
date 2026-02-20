import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum/Screens/home_screen.dart';
import 'package:quantum/Features/auth/auth_providers.dart';
import 'login_page.dart';
import 'register_page.dart';

class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final showLogin = ref.watch(showLoginProvider);

    return Scaffold(
      body: authState.when(
        data: (user) {
          // If user is logged in, navigate to home screen
          if (user != null) {
            return const HomeScreen();
          }

          // If user is not logged in, show login or register
          return showLogin
              ? LoginPage(
            showRegisterPage: () =>
            ref.read(showLoginProvider.notifier).state = false,
          )
              : RegisterPage(
            showLoginPage: () =>
            ref.read(showLoginProvider.notifier).state = true,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
