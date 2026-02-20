import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum/Intro_Screens/Intro1.dart';
import 'package:quantum/Intro_Screens/Intro2.dart';
import 'package:quantum/Intro_Screens/Intro3.dart';
import 'package:quantum/Pages/auth_page.dart'; // AuthPage manages login/register
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Provider for PageController
final pageControllerProvider = Provider.autoDispose<PageController>((ref) {
  final controller = PageController();
  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});

// StateProvider for tracking if we're on the last page
final onLastPageProvider = StateProvider.autoDispose<bool>((ref) => false);

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(pageControllerProvider);
    final onLastPage = ref.watch(onLastPageProvider);

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller,
            onPageChanged: (index) {
              ref.read(onLastPageProvider.notifier).state = (index == 2);
            },
            children: const [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Skip button
                TextButton(
                  onPressed: () {
                    controller.jumpToPage(2);
                  },
                  child: const Text('Skip'),
                ),

                // Dot indicator
                SmoothPageIndicator(
                  controller: controller,
                  count: 3,
                ),

                // Next or Done button
                onLastPage
                    ? TextButton(
                  onPressed: () {
                    // Navigate to AuthPage instead of HomeScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthPage(),
                      ),
                    );
                  },
                  child: const Text('Done'),
                )
                    : TextButton(
                  onPressed: () {
                    controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    );
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
