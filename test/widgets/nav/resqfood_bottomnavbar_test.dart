import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/widgets/nav/resqfood_bottomnavbar.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'resqfood_bottomnavbar_test.mocks.dart';

@GenerateMocks([AuthProvider])

void main() {
  late MockAuthProvider mockAuth;

  setUp(() {
    mockAuth = MockAuthProvider();
    when(mockAuth.highContrast).thenReturn(false);
  });

  Widget createWidgetUnderTest({
    required int currentIndex,
    required ValueChanged<int> onTap,
  }) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuth,
      child: MaterialApp(
        home: Scaffold(
          bottomNavigationBar: ResQFoodBottomNavBar(
            currentIndex: currentIndex,
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  group('ResQFoodBottomNavBar Widget Tests', () {
    testWidgets('Should display Home and Settings items', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        currentIndex: 0,
        onTap: (index) {},
      ));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('Should call onTap with correct index when an item is tapped', (WidgetTester tester) async {
      int capturedIndex = -1;

      await tester.pumpWidget(createWidgetUnderTest(
        currentIndex: 0,
        onTap: (index) => capturedIndex = index,
      ));

      await tester.tap(find.text('Settings'));
      await tester.pump();

      expect(capturedIndex, 1);
    });

    testWidgets('Should apply High Contrast colors when enabled', (WidgetTester tester) async {
      when(mockAuth.highContrast).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest(
        currentIndex: 0,
        onTap: (index) {},
      ));

      final BottomNavigationBar navBar = tester.widget(find.byType(BottomNavigationBar));
      
      expect(navBar.selectedItemColor, Colors.black);
    });
  });
}