import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quantum/Components/my_textfield.dart';
import 'package:quantum/Components/my_text_box.dart';
import 'package:quantum/Helper/helper_function.dart'; // make sure path is correct



class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;

  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  @override
  void dispose() {
    // Always dispose controllers
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Validate password strength
  String? validatePasswordStrength(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null; // Password is strong
  }

  // Sign Up User
  Future<void> signUpUser() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Validate password strength
    String? passwordError = validatePasswordStrength(passwordController.text.trim());
    if (passwordError != null) {
      Navigator.pop(context);
      displayMessageToUser(passwordError, context);
      return;
    }

    if (!passwordConfirmed()) {
      Navigator.pop(context);
      displayMessageToUser('Passwords don\'t match', context);
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessageToUser(e.message ?? 'An error occurred', context);
    }
  }

  bool passwordConfirmed() {
    if (passwordController.text.trim() ==
        confirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Text(
                  'Fill your profiles',
                  style: TextStyle(
                      color: Colors.black12,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  'You can\'t change it once filled!!!',
                  style: TextStyle(color: Colors.grey[600], fontSize: 18),
                ),

                const SizedBox(height: 10),

                // Username TextField
                MyTextfield(
                  controller: userNameController,
                  hintText: 'User Name',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Email TextField
                MyTextfield(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Password TextField
                MyTextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // Confirm password TextField
                MyTextfield(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // forgot password button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Sign Up Button
                MyButton(
                  onTap: signUpUser,
                  text: 'Sign Up',
                ),

                const SizedBox(height: 35),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1.5,
                          color: Colors.lightGreen[700],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('Or continue with'),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1.5,
                          color: Colors.lightGreen[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SquareTitle(imagepath: 'lib/images/apple.png'),
                    // SizedBox(width: 30),
                    // SquareTitle(imagepath: 'lib/images/google.png'),
                  ],
                ),

                const SizedBox(height: 25),

                // Register Now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('I am a member!'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text(
                        'Login',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}