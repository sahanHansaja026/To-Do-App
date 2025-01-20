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
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // Handle Firebase initialization errors here
    // ignore: avoid_print
    print('Error initializing Firebase: $e');
  }

  final AuthService authService = AuthService();
  await authService
      .signOut(); // Ensure the user is signed out when the app starts

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(
            create: (context) =>
                TimeoutManager(timeoutDuration: 100)), // 1 minute timeout
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
          theme: themeProvider.themeData,
          home: const SplashScreen(),
        );
      },
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay to simulate loading and navigate to AuthGate
    Future.delayed(const Duration(seconds: 20), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              'assets/images/Schedule.gif', // Ensure your logo is in the assets folder
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 20),
            // App Name
            const Text(
              'EduOrganizer',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 8, 0, 255),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
