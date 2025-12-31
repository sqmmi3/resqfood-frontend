import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/auth/auth_header.dart';

void main() {
  group('AuthHeader Widget Tests', () {
    
    // helper to ensure the animation is finished
    Future<void> driveTypewriter(WidgetTester tester) async {
      // Advance by 5 seconds (more than enough for the typewriter to finish)
      await tester.pump(const Duration(seconds: 5));
      // Settle any remaining microtasks
      await tester.pumpAndSettle();
    }

    testWidgets('Should display title and subtitle correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthHeader(
              title: 'Welcome',
              subtitle: 'Subtitle',
            ),
          ),
        ),
      );

      await driveTypewriter(tester);

      // Search for text across all widget types (Text, RichText, etc.)
      expect(find.byElementPredicate((element) {
        final widget = element.widget;
        if (widget is RichText) {
          return widget.text.toPlainText().contains('Welcome');
        }
        if (widget is Text) {
          return widget.data?.contains('Welcome') ?? false;
        }
        return false;
      }), findsOneWidget);

      expect(find.byElementPredicate((element) {
        final widget = element.widget;
        if (widget is RichText) {
          return widget.text.toPlainText().contains('Subtitle');
        }
        return false;
      }), findsOneWidget);
    });

    testWidgets('Should apply correct styles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthHeader(title: 'Title', subtitle: 'Subtitle'),
          ),
        ),
      );
      
      await driveTypewriter(tester);

      // Find the RichText widget specifically
      final finder = find.byElementPredicate((element) {
        final widget = element.widget;
        return widget is RichText && widget.text.toPlainText().contains('Title');
      });

      expect(finder, findsOneWidget);

      final RichText richText = tester.widget<RichText>(finder);
      final TextStyle? style = richText.text.style;
      
      expect(style?.fontSize, 28);
      expect(style?.fontWeight, FontWeight.w500);
    });
  });
}