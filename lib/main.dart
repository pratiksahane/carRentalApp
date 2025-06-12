import 'package:carrentalapp/firebase_options.dart';
import 'package:carrentalapp/mainlayout.dart';
import 'package:carrentalapp/splashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zymo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.cyanAccent,
          surface: const Color(0xFF121212),
          background: const Color(0xFF121212),
        ),
        brightness: Brightness.dark,
      ),
      home:FirebaseAuth.instance.currentUser!=null?MainLayout():Splashscreen(),
    );
  }
}
