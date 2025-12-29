import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/screens/auth/register_screen.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/widgets/auth/auth_header.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_primary_button.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_text_field.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passwordVisible = true;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isHapticsEnabled = context.watch<AuthProvider>().hapticsEnabled;

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
                subtitle: 'Login'
              ),
            
              const SizedBox(height: 30),

              ResQFoodTextField(
                label: 'Username',
                controller: usernameController
              ),

              SizedBox(height: 20),

              ResQFoodTextField(
                label: 'Password',
                obscure: true,
                showToggle: true,
                obscureValue: passwordVisible,
                onToggle: () {
                  setState(() => passwordVisible = !passwordVisible);
                },
                controller: passwordController,
              ),

              if (auth.status == AuthStatus.error)
                Text(
                  auth.errorMessage ?? "Login failed",
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 15),
                ),

              const SizedBox(height: 30),

              ResQFoodPrimaryButton(
                text: auth.status == AuthStatus.loading ? "Loading..." : "Login",
                disabled: auth.status == AuthStatus.loading,
                onPressed: () async {
                  await auth.login(
                    usernameController.text.trim(),
                    passwordController.text.trim(),
                    onSuccess: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                      );
                    }
                  );

                  if (auth.status == AuthStatus.authenticated) {
                    debugPrint("Logged in successfully!");
                  }
                },
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account yet?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  InkWell(
                    onTap: () {
                      isHapticsEnabled ? HapticFeedback.lightImpact() : null;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                      child: Text(
                        "Sign up",
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
          ),
        ),
      ),
    );
  }
}