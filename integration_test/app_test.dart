import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/models/auth/login_response.dart';
import 'package:frontend/models/auth/register_response.dart';
import 'package:frontend/models/grouped_user_item.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/providers/theme/theme_provider.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/auth/register_screen.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/items/manual_add_item_screen.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/services/notification/notification_service.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_primary_button.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_text_field.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

class FakeAuthProvider extends AuthProvider {
  AuthStatus _fakeStatus = AuthStatus.idle;
  LoginResponse? _fakeUser;
  RegisterResponse? _fakeNewUser;
  String? _fakeError;

  @override
  AuthStatus get status => _fakeStatus;

  @override
  LoginResponse? get user => _fakeUser;

  @override
  RegisterResponse? get newUser => _fakeNewUser;

  @override
  String? get errorMessage => _fakeError;

  @override
  Future<void> login(String username, String password, {VoidCallback? onSuccess}) async {
    _fakeStatus = AuthStatus.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 20));
    _fakeUser = LoginResponse(token: 'fake-token');
    _fakeStatus = AuthStatus.authenticated;
    notifyListeners();
    onSuccess?.call();
  }

  @override
  Future<RegisterResponse?> register(String username, String email, String password) async {
    _fakeStatus = AuthStatus.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 20));
    _fakeNewUser = RegisterResponse(id: 1, username: username, email: email);
    _fakeStatus = AuthStatus.idle;
    notifyListeners();
    return _fakeNewUser;
  }

  @override
  void logout() {
    _fakeUser = null;
    _fakeStatus = AuthStatus.idle;
    notifyListeners();
  }

  @override
  void resetError() {
    _fakeError = null;
    notifyListeners();
  }
}

class FakeUserItemProvider extends UserItemProvider {
  List<GroupedUserItem> _fakeItems = [];

  @override
  List<GroupedUserItem> get items => _fakeItems;

  @override
  Future<void> fetchItems() async {
    loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 10));
    _fakeItems = [];
    loading = false;
    notifyListeners();
  }
}

Widget buildApp(Widget home) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(create: (_) => FakeAuthProvider()),
      ChangeNotifierProvider<UserItemProvider>(create: (_) => FakeUserItemProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: MaterialApp(home: home),
  );
}

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();

  group('Auth Flow', () {
    testWidgets('Shows login screen on launch', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp(const LoginScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Login with correct credentials', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Username'), 'admin');
      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Password'), 'Admin123%');
      await tester.pump();

      await tester.tap(find.widgetWithText(ResQFoodPrimaryButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.byType(MainScreen), findsOneWidget);
    });

    testWidgets('Register with correct values', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsOneWidget);

      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Username'), 'newuser');
      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Email'), 'newuser@example.com');
      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Password'), 'Password123!');
      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Confirm password'), 'Password123!');
      await tester.pump();

      await tester.tap(find.widgetWithText(ResQFoodPrimaryButton, 'Register'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('Home Page', () {
    testWidgets('Shows empty state when no items exist', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp(const MainScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('No items found.'), findsOneWidget);
    });

    testWidgets('Opens expansion menu from FAB', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp(const MainScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add Manually'), findsOneWidget);
      expect(find.text('Barcode'), findsOneWidget);
    });

    testWidgets('Navigates to manual add item screen', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp(const MainScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Manually'));
      await tester.pumpAndSettle();

      expect(find.byType(ManualAddItemScreen), findsOneWidget);
    });
  });

  group('Additional Functionalities', () {
    testWidgets('Empty state remains when no items are present', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp(const MainScreen()));
      await tester.pumpAndSettle();
      expect(find.text('No items found.'), findsOneWidget);
    });
  });
}
