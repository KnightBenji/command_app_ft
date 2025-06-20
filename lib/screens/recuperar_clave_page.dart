import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecuperarClavePage extends StatefulWidget {
  const RecuperarClavePage({super.key});

  @override
  State<RecuperarClavePage> createState() => _RecuperarClavePageState();
}

class _RecuperarClavePageState extends State<RecuperarClavePage> {
  final TextEditingController _emailController = TextEditingController();
  bool enviado = false;

  Future<void> enviarCorreoRecuperacion() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor ingresa tu correo"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        enviado = true;
      });
    } on FirebaseAuthException catch (e) {
      String msg = "Error al enviar el correo";

      if (e.code == 'user-not-found') {
        msg = "No se encontró un usuario con ese correo";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recuperar clave"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mail_outline, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                "Ingresa tu correo electrónico para recibir un enlace de recuperación",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Correo",
                  prefixIcon: const Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text("Enviar correo"),
                onPressed: enviado ? null : enviarCorreoRecuperacion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              if (enviado) ...[
                const SizedBox(height: 24),
                const Text(
                  "¡Correo enviado! Revisa tu bandeja de entrada o spam.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
