import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerificationMailPage extends StatefulWidget {
  const VerificationMailPage({super.key});

  @override
  State<VerificationMailPage> createState() => _VerificationMailPageState();
}

class _VerificationMailPageState extends State<VerificationMailPage> {
  bool _isEmailVerified = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    checkEmailVerified();
  }

  Future<void> checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isEmailVerified = user?.emailVerified ?? false;
    });
    if (_isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Correo verificado correctamente!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> resendVerificationEmail() async {
    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Correo de verificación reenviado. Revisa también la carpeta SPAM."),
            backgroundColor: Colors.green,
          ),
        );
        print("Correo de verificación enviado a: ${user.email}");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se encontró el usuario actual. Inicia sesión nuevamente."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error al reenviar correo de verificación: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ocurrió un error al reenviar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail, size: 64, color: Colors.red),
                SizedBox(height: 24),
                Text(
                  'Verifica tu correo electrónico',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Hemos enviado un correo de verificación a tu dirección. '
                  'Por favor, revisa tu bandeja de entrada (y la carpeta SPAM) y haz click en el enlace para verificar tu cuenta.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton.icon(
                        icon: Icon(Icons.refresh),
                        label: Text('Reenviar correo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: resendVerificationEmail,
                      ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.check),
                  label: Text('Ya verifiqué mi correo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: checkEmailVerified,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
