import 'package:flutter/material.dart';
import 'package:command_app_ft/screens/login_page.dart';
import 'package:command_app_ft/screens/register_page.dart';
import 'package:command_app_ft/screens/verification_mail_page.dart';


/* Importar librerias de firebase */
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/verifyEmail': (context) => const VerificationMailPage(),
      },
    );
  }
}