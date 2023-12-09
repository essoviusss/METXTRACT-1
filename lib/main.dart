import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metxtract/screens/home_screen.dart';
import 'package:metxtract/screens/splash_screen.dart';
import 'package:metxtract/utils/color_utils.dart';
import 'config/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    final user = _auth.currentUser;
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme:
            GoogleFonts.latoTextTheme(Typography.blackCupertino).copyWith(
          bodySmall: GoogleFonts.poppins(),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          background: ColorUtils.background,
        ),
        useMaterial3: true,
      ),
      home: _user == null ? const SplashScreen() : const HomeScreen(),
    );
  }
}
