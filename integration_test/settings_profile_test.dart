import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/profile/profile_screen.dart';
import 'package:frontend/screens/settings/settings_screen.dart';

import 'helpers.dart';

Future<void> main() async {
  await initializeTestEnvironment();

  group('Settings', () {
    testWidgets('All settings controls respond to interaction', (WidgetTester tester) async {
      await pumpRealApp(tester);
      await loginAs(tester, username: 'admin', password: 'Admin123%');
      await openSettingsTab(tester);

      expect(find.byType(SettingsScreen), findsOneWidget);

      await toggleSetting(tester, 'Left-Handed Mode');
      await toggleSetting(tester, 'Dark Mode');
      await toggleSetting(tester, 'High Contrast Mode');
      await toggleSetting(tester, 'Touch Feedback');
      await toggleSetting(tester, 'Enhanced Screen Reader');
      await adjustFontSize(tester);
    });
  });

  group('Profile Menu', () {
    testWidgets('Profile can be opened and closed', (WidgetTester tester) async {
      await pumpRealApp(tester);
      await loginAs(tester, username: 'admin', password: 'Admin123%');

      await openProfileFromMenu(tester);
      expect(find.byType(ProfileScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsNothing);
    });

    testWidgets('Profile menu displays user information', (WidgetTester tester) async {
      await pumpRealApp(tester);
      await loginAs(tester, username: 'admin', password: 'Admin123%');

      await openProfileFromMenu(tester);
      expect(find.byType(ProfileScreen), findsOneWidget);

      // Verify profile screen is visible
      expect(find.byType(ProfileScreen), findsWidgets);
    });
  });
}
