import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_secondary_button.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'resqfood_secondary_button_test.mocks.dart';

@GenerateMocks([AuthProvider])
void main() {
  late MockAuthProvider mockAuth;

  setUp(() {
    mockAuth = MockAuthProvider();
    when(mockAuth.highContrast).thenReturn(false);
    when(mockAuth.hapticsEnabled).thenReturn(false);
  });

  Widget createWidgetUnderTest({
    required String text,
    required VoidCallback onPressed,
  }) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuth,
      child: MaterialApp(
        home: Scaffold(
          body: ResQFoodSecondaryButton(
            text: text,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  group('ResQFoodSecondaryButton Widget Tests', () {
    testWidgets('Should display the text in uppercase', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(text: 'cancel', onPressed: () {}));
      expect(find.text('CANCEL'), findsOneWidget);
    });

    testWidgets('Should call onPressed and trigger haptics when clicked', (WidgetTester tester) async {
      bool wasPressed = false;
      when(mockAuth.hapticsEnabled).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest(
        text: 'Action',
        onPressed: () => wasPressed = true,
      ));

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('Should apply high-contrast styles (thicker border and sharper corners)', (WidgetTester tester) async {
      when(mockAuth.highContrast).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest(
        text: 'Contrast',
        onPressed: () {},
      ));

      final OutlinedButton button = tester.widget(find.byType(OutlinedButton));
      
      final BorderSide? side = button.style?.side?.resolve({});
      expect(side?.width, 3.0);

      final RoundedRectangleBorder shape = button.style?.shape?.resolve({}) as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(8));
    });

    testWidgets('Should use primary color when high-contrast is disabled', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        text: 'Normal',
        onPressed: () {},
      ));

      final OutlinedButton button = tester.widget(find.byType(OutlinedButton));
      final Color? textColor = button.style?.foregroundColor?.resolve({});
      
      expect(textColor, ThemeData.light().colorScheme.primary);
    });
  });
}