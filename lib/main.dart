import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // When not running on web, load environment variables from .env file
  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      print('Warning: Could not load .env file: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const ResQFoodApp(),
    )  
  );
}

class ResQFoodApp extends StatelessWidget {
  const ResQFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ResQFood',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
