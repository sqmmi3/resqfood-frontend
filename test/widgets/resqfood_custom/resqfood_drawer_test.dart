import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_drawer.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'resqfood_drawer_test.mocks.dart';

@GenerateMocks([
  AuthProvider,
], customMocks: [
  MockSpec<NavigatorObserver>(onMissingStub: OnMissingStub.returnDefault),
])
void main() {
  late MockAuthProvider mockAuth;
  late MockNavigatorObserver mockObserver;

  setUp(() async {
    await dotenv.load(fileName: '.env', isOptional: true);

    mockAuth = MockAuthProvider();
    mockObserver = MockNavigatorObserver();
    
    when(mockAuth.highContrast).thenReturn(false);
    when(mockAuth.hapticsEnabled).thenReturn(false);

    when(mockAuth.token).thenReturn('mock_token_123');
    
    when(mockObserver.navigator).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuth,
      child: MaterialApp(
        navigatorObservers: [mockObserver],
        home: const Scaffold(
          drawer: ResQFoodDrawer(),
        ),
      ),
    );
  }

  group('ResQFoodDrawer Widget Tests', () {
    testWidgets('Should display all menu items', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Household Hub'), findsOneWidget);
    });

    testWidgets('Should apply bold text when High Contrast is enabled', (WidgetTester tester) async {
      when(mockAuth.highContrast).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());
      
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      final Text homeText = tester.widget(find.text('Home'));
      expect(homeText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('Should navigate and close drawer when a tile is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Household Hub'));
      
      await tester.pump(); 
      await tester.pump(const Duration(milliseconds: 500));

      verify(mockObserver.didPush(any, any)).called(greaterThan(0));
      
      expect(find.byType(ResQFoodDrawer), findsNothing);
    });
  });
}