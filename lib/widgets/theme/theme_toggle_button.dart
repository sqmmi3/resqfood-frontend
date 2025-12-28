import 'package:flutter/material.dart';
import 'package:frontend/providers/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topRight,
          child: FloatingActionButton.small(
            heroTag: 'theme_toggle',
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
            child: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
        ),
      ),
    );
  }
}
