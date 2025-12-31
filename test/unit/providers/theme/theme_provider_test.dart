import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/providers/theme/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThemeProvider themeProvider;

  setUp(() {
    themeProvider = ThemeProvider();
  });

  group('ThemeProvider - Manual Toggles', () {
    test('Initial theme should be Light', () {
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isDarkMode, isFalse);
    });

    test('toggleTheme should switch Light to Dark', () {
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.isDarkMode, isTrue);
    });
  });

  group('ThemeProvider - System Mode Logic', () {
    test('isDarkMode should return true when system is dark and mode is system', () {
      themeProvider.setThemeMode(ThemeMode.system);

      final dispatcher = TestWidgetsFlutterBinding.instance.platformDispatcher;
      dispatcher.platformBrightnessTestValue = Brightness.dark;

      expect(themeProvider.isDarkMode, isTrue);
      
      dispatcher.clearPlatformBrightnessTestValue();
    });

    test('isDarkMode should return false when system is light and mode is system', () {
      themeProvider.setThemeMode(ThemeMode.system);
      
      final dispatcher = TestWidgetsFlutterBinding.instance.platformDispatcher;
      dispatcher.platformBrightnessTestValue = Brightness.light;

      expect(themeProvider.isDarkMode, isFalse);
      
      dispatcher.clearPlatformBrightnessTestValue();
    });
  });
}