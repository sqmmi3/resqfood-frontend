import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_text_field.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'resqfood_text_field_test.mocks.dart';

@GenerateMocks([AuthProvider])
void main() {
  late MockAuthProvider mockAuth;

  setUp(() {
    mockAuth = MockAuthProvider();
    when(mockAuth.highContrast).thenReturn(false);
    when(mockAuth.hapticsEnabled).thenReturn(false);
  });

  Widget createWidgetUnderTest({
    required String label,
    TextEditingController? controller,
    bool obscure = false,
    bool showToggle = false,
    bool obscureValue = false,
    VoidCallback? onToggle,
    String? Function(String?)? validator,
  }) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuth,
      child: MaterialApp(
        home: Scaffold(
          body: Form(
            child: ResQFoodTextField(
              label: label,
              controller: controller,
              obscure: obscure,
              showToggle: showToggle,
              obscureValue: obscureValue,
              onToggle: onToggle,
              validator: validator,
            ),
          ),
        ),
      ),
    );
  }

  group('ResQFoodTextField Widget Tests', () {
    testWidgets('Should allow text entry and update controller', (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(createWidgetUnderTest(label: 'Email', controller: controller));

      await tester.enterText(find.byType(TextFormField), 'test@resqfood.com');
      expect(controller.text, 'test@resqfood.com');
    });

    testWidgets('Should show visibility icon and trigger onToggle when pressed', (WidgetTester tester) async {
      bool toggleCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        label: 'Password',
        showToggle: true,
        obscure: true,
        obscureValue: true,
        onToggle: () => toggleCalled = true,
      ));

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(toggleCalled, isTrue);
    });

    testWidgets('Should display error border/style when validation fails', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        label: 'Required',
        validator: (value) => value == null || value.isEmpty ? 'Error Message' : null,
      ));

      final formState = tester.state<FormState>(find.byType(Form));
      formState.validate();
      await tester.pump();

      expect(find.text('Error Message'), findsOneWidget);
    });

    testWidgets('Should apply high-contrast border thickness', (WidgetTester tester) async {
      when(mockAuth.highContrast).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest(label: 'Contrast Test'));

      final InputDecorator decorator = tester.widget(find.byType(InputDecorator));
      
      final decoration = decorator.decoration;
      
      expect(decoration.enabledBorder is OutlineInputBorder, isTrue);
      final border = decoration.enabledBorder as OutlineInputBorder;
      expect(border.borderSide.width, 2.0);
    });
  });
}