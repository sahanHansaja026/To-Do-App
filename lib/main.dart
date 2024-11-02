import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:taskmanagerr/firebase_options.dart';
import 'package:taskmanagerr/services/auth/auth_gate.dart';
import 'package:taskmanagerr/services/auth/auth_service.dart';
import 'package:taskmanagerr/services/auth/timeout_manager.dart';
import 'package:taskmanagerr/themes/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // Handle Firebase initialization errors here
    // ignore: avoid_print
    print('Error initializing Firebase: $e');
  }

  final AuthService authService = AuthService();
  await authService.signOut(); // Ensure the user is signed out when the app starts

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => TimeoutManager(timeoutDuration: 100)), // 1 minute timeout
        Provider<AuthService>(create: (_) => authService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const AuthGate(),
          theme: themeProvider.themeData,
        );
      },
    );
  }
}
