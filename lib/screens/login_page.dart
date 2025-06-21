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
      backgroundColor: const Color(0xFFF5F5F5), // fondo gris muy claro
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 72, color: Color(0xFFFF8C42)),
                const SizedBox(height: 16),
                const Text(
                  "ComandAPP",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),

                // Correo
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("Correo electrónico", Icons.email),
                ),
                const SizedBox(height: 16),

                // Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration("Contraseña", Icons.lock),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/recuperarClave'),
                    child: const Text(
                      "¿Olvidaste tu clave?",
                      style: TextStyle(color: Color(0xFFFF8C42)),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Botón login
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      fnIniciarSesion(_emailController.text, _passwordController.text);
                    },
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text("Iniciar sesión", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C42),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
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
                    style: TextStyle(color: Color(0xFFFF8C42)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[800]),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> fnIniciarSesion(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _showError("Por favor, completa todos los campos");
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();

      if (!userDoc.exists) {
        _showError("El perfil no existe en la base de datos");
        return;
      }

      final data = userDoc.data()!;
      final activo = data['activo'] ?? false;
      final rol = data['rol'] ?? '';

      if (!activo) {
        _showError("Tu cuenta aún no ha sido activada por un administrador.", orange: true);
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
        _showError("Tu cuenta no tiene un rol válido asignado.");
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = "Correo y/o contraseña incorrecta, intenta nuevamente";
      if (e.code == 'user-not-found') mensaje = 'Usuario no encontrado';
      if (e.code == 'wrong-password') mensaje = 'Contraseña incorrecta';
      _showError(mensaje);
    }
  }

  void _showError(String mensaje, {bool orange = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: orange ? Colors.orange : Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
  }
}
