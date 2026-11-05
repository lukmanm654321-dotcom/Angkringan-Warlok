import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'views/get_started.dart';
import 'views/login.dart';
import 'views/register.dart';
import 'views/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? user = FirebaseAuth.instance.currentUser;

  runApp(MyApp(isLoggedIn: user != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CASHIER',
      theme: ThemeData(
        textTheme: GoogleFonts.aBeeZeeTextTheme(),
          appBarTheme: AppBarTheme(
              backgroundColor: Colors.black,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
              iconTheme: IconThemeData(color: Colors.white))),
      home: SplashScreen(isLoggedIn: isLoggedIn),
      routes: {
        '/get_started': (context) => const GetStartedPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  final bool isLoggedIn;
  const SplashScreen({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isLoggedIn) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pushReplacementNamed(context, '/get_started');
      }
    });

    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
