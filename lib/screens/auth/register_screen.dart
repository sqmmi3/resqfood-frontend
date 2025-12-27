import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/widgets/auth/auth_header.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_primary_button.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_text_field.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username is required.';
    if (value.length < 3 || value.length > 50) return 'Username must be 3-50 characters long.';
    final regex = RegExp(r'^\w+$');
    if (!regex.hasMatch(value)) return 'Username can only contain letters, numbers, and underscores.';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required.';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) return 'Invalid email format.';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Password must be at least 8 characters long.';
    final regex = RegExp(r'''^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*()_+\-=\[\]{};'"\\|,.<>\/?]).{8,}$''');
    if (!regex.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character.';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) return 'Passwords do not match.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logo/resqfood_logo.png",
                width: 200,
              ),

              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 8,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'RESCUE YOUR FOOD!',
                      speed: const Duration(milliseconds: 150),
                    ),
                  ],
                  pause: const Duration(milliseconds: 1000),
                  isRepeatingAnimation: true,
                  repeatForever: true,
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                )
              ),

              const SizedBox(height: 60),

              const AuthHeader(
                title: 'Welcome!',
                subtitle: 'Register'
              ),

              const SizedBox(height: 30),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    ResQFoodTextField(
                      label: 'Username',
                      controller: usernameController,
                      validator: validateUsername,
                      onChanged: (_) => auth.resetError(),
                    ),

                    const SizedBox(height: 10),

                    ResQFoodTextField(
                      label: 'Email',
                      controller: emailController,
                      validator: validateEmail,
                      onChanged: (_) => auth.resetError(),
                    ),

                    const SizedBox(height: 10),

                    ResQFoodTextField(
                      label: 'Password',
                      obscure: true,
                      showToggle: true,
                      obscureValue: !passwordVisible,
                      onToggle: () => setState(() => passwordVisible = !passwordVisible),
                      controller: passwordController,
                      validator: validatePassword,
                      onChanged: (_) => auth.resetError(),
                    ),

                    const SizedBox(height: 10),

                    ResQFoodTextField(
                      label: 'Confirm password',
                      obscure: true,
                      showToggle: true,
                      obscureValue: !confirmPasswordVisible,
                      onToggle: () => setState(() => confirmPasswordVisible = !confirmPasswordVisible),
                      controller: confirmPasswordController,
                      validator: validateConfirmPassword,
                      onChanged: (_) => auth.resetError(),
                    ),
                    
                    if (auth.status == AuthStatus.error)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          auth.errorMessage ?? "Registration failed",
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 15),
                        ),
                      ),
                    
                    const SizedBox(height: 30),
                    ResQFoodPrimaryButton(
                      text: auth.status == AuthStatus.loading? "Registering..." : "Register",
                      disabled: auth.status == AuthStatus.loading,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        try {
                          final registerResponse = await auth.register(
                            usernameController.text.trim(),
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );

                          if (!mounted) return;

                          if (registerResponse != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Registration successful!')),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$e')),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                            child: Text(
                              "Log in",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: Theme.of(context).colorScheme.primary,
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}