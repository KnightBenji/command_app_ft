import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  "comandAPP",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 32),

                // Correo
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Correo electrónico",
                    prefixIcon: const Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: const Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                // ¿Olvidaste tu clave?
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/recuperarClave');
                    },
                    child: const Text(
                      "¿Olvidaste tu clave?",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Botón login
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      fnIniciarSesion(
                        _emailController.text,
                        _passwordController.text,
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text("Iniciar sesión"),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Link a registro
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    "¿No tienes cuenta?, Regístrate",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fnIniciarSesion(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, completa todos los campos"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
        ),
      );
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("El perfil no existe en la base de datos"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final data = userDoc.data()!;
      final activo = data['activo'] ?? false;
      final rol = data['rol'] ?? '';

      if (!activo) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Tu cuenta aún no ha sido activada por un administrador.",
            ),
            backgroundColor: Colors.orange,
          ),
        );
        await FirebaseAuth.instance.signOut();
        return;
      }

      if (rol == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else if (rol == 'cocinero') {
        Navigator.pushReplacementNamed(context, '/cocinero');
      } else if (rol == 'mesero') {
        Navigator.pushReplacementNamed(context, '/mesero');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tu cuenta no tiene un rol válido asignado."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = "Correo y/o contraseña incorrecta, intenta nuevamente";
      if (e.code == 'user-not-found') {
        mensaje = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        mensaje = 'Contraseña incorrecta';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
    }
  }
}
