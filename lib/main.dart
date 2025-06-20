import 'package:flutter/material.dart';
import 'package:command_app_ft/screens/login_page.dart';
import 'package:command_app_ft/screens/register_page.dart';
import 'package:command_app_ft/screens/cocinero.dart';
import 'package:command_app_ft/screens/admin_page.dart';
import 'package:command_app_ft/screens/verification_mail_page.dart';
import 'package:command_app_ft/screens/gestion_menu_page.dart';
import 'package:command_app_ft/screens/gestion_rol_page.dart';
import 'package:command_app_ft/screens/cambiar_clave_page.dart';
import 'package:command_app_ft/screens/recuperar_clave_page.dart';



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
      title: 'comandAPP',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/cocinero': (context) => const CocineroPage(), 
        '/admin': (context) => const AdminPage(),
        '/verifyEmail': (context) => const VerificationMailPage(),
        '/gestionMenu': (context) => const GestionMenuPage(),
        '/gestionRol': (context) => const GestionRolPage(),
        '/cambiarClave': (context) => const CambiarClavePage(),
        '/recuperarClave': (context) => const RecuperarClavePage(),
      },
    );
  }
}
  