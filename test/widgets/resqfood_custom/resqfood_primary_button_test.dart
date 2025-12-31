import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_primary_button.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'resqfood_primary_button_test.mocks.dart';

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
    bool disabled = false,
    VoidCallback? onPressed,
  }) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuth,
      child: MaterialApp(
        home: Scaffold(
          body: ResQFoodPrimaryButton(
            text: text,
            disabled: disabled,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  group('ResQFoodPrimaryButton Widget Tests', () {
    testWidgets('Should display the text in uppercase', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(text: 'login', onPressed: () {}));

      expect(find.text('LOGIN'), findsOneWidget);
    });

    testWidgets('Should call onPressed when clicked and not disabled', (WidgetTester tester) async {
      bool wasPressed = false;
      await tester.pumpWidget(createWidgetUnderTest(
        text: 'Test',
        onPressed: () => wasPressed = true,
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('Should NOT call onPressed when disabled', (WidgetTester tester) async {
      bool wasPressed = false;
      await tester.pumpWidget(createWidgetUnderTest(
        text: 'Test',
        disabled: true,
        onPressed: () => wasPressed = true,
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(wasPressed, isFalse);
    });

    testWidgets('Should show grey background when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        text: 'Test',
        disabled: true,
        onPressed: () {},
      ));

      final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
      final Color? bgColor = button.style?.backgroundColor?.resolve({});

      expect(bgColor, Colors.grey.shade400);
    });

    testWidgets('Should change style when High Contrast is enabled', (WidgetTester tester) async {
      when(mockAuth.highContrast).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest(
        text: 'Test',
        onPressed: () {},
      ));

      final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
      
      final RoundedRectangleBorder shape = button.style?.shape?.resolve({}) as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(8));
      
      expect(button.style?.side?.resolve({})?.width, 3);
    });
  });
}