import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      title,
                      speed: const Duration(milliseconds: 150),
                    ),
                  ],
                  isRepeatingAnimation: false,
                )
              ),
        const SizedBox(height: 5),
        DefaultTextStyle(
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.black,
            letterSpacing: 2,
          ),
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                subtitle,
                speed: const Duration(milliseconds: 150),
              ),
            ],
            isRepeatingAnimation: false,
          )
        ),
      ],
    );
  }
}