import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');

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
      home: LoginScreen(),
    );
  }
}
