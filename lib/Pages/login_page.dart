import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum/Components/my_textfield.dart';
import 'package:quantum/Components/my_text_box.dart';
import 'package:quantum/Features/auth/Controller/auth_controller.dart';



class LoginPage extends ConsumerStatefulWidget {
  final VoidCallback showRegisterPage;

  const LoginPage({super.key, required this.showRegisterPage});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (next.error != null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(next.error!),
          ),
        );
      }
    });


    return Scaffold(
      backgroundColor: Colors.blue[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Icon(Icons.home, size: 250,),
                const SizedBox(height: 25),

                Text(
                  'Login to your account',
                  style: TextStyle(color: Colors.grey[600], fontSize: 30),
                ),
                const SizedBox(height: 25),

                // Email field
                MyTextfield(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 25),

                // Password field
                MyTextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                // Sign In Button
                MyButton(
                  onTap: authState.isLoading
                      ? null
                      : () {
                    ref.read(authControllerProvider.notifier).signIn(
                      emailController.text,
                      passwordController.text,
                    );
                  },
                  text: authState.isLoading ? 'Loading...' : 'Sign In',
                ),

                const SizedBox(height: 20),

                // Navigate to Register
                TextButton(
                  onPressed: widget.showRegisterPage,
                  child: const Text("Don't have an account? Register here"),
                ),

                // Error message
                if (authState.error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    authState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],

                const SizedBox(height: 20),

                // Optional: forgot password
                GestureDetector(
                  onTap: () {
                    // Navigate to ForgotPasswordPage if you have it
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordPage()));
                  },
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),

                const SizedBox(height: 50),

                // Optional: social login buttons
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: const [
                //     // Replace with your social buttons
                //     // SquareTitle(imagepath: 'lib/images/apple.png'),
                //     // SizedBox(width: 30),
                //     // SquareTitle(imagepath: 'lib/images/google.png'),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}