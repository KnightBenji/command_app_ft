import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add_alt_1, size: 72, color: Color(0xFFFF8C42)),
                const SizedBox(height: 16),
                const Text(
                  'Registrar Usuario',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 32),
                _buildTextField(_nombreController, "Nombre completo", Icons.person),
                const SizedBox(height: 16),
                _buildTextField(_emailController, "Correo electrónico", Icons.email),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, "Contraseña", Icons.lock, obscure: true),
                const SizedBox(height: 16),
                _buildTextField(_confirmPasswordController, "Confirmar contraseña", Icons.lock_outline, obscure: true),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      fnRegistrarUsuario(
                        _nombreController.text.trim(),
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                    },
                    icon: const Icon(Icons.login, color: Colors.black),
                    label: const Text("Registrar", style: TextStyle(color: Colors.black)),
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
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "¿Ya tienes cuenta? Inicia sesión",
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1B263B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> fnRegistrarUsuario(String nombre, String email, String password) async {
    if (nombre.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      _showSnackbar("Por favor, completa todos los campos", color: Colors.red);
      return;
    }
    if (password != _confirmPasswordController.text.trim()) {
      _showSnackbar("Las contraseñas no coinciden", color: Colors.red);
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      final String uid = credential.user!.uid;
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': nombre,
        'email': email,
        'rol': 'pendiente',
        'activo': false,
      });
      await credential.user?.sendEmailVerification();
      _showSnackbar("Registro exitoso. Revisa tu correo para verificar tu cuenta.", color: Colors.green);
      Navigator.pushReplacementNamed(context, '/verifyEmail');
    } on FirebaseAuthException catch (e) {
      _showSnackbar(e.message ?? "Error al registrar usuario", color: Colors.red);
    } catch (e) {
      _showSnackbar("Ocurrió un error inesperado", color: Colors.red);
    }
  }

  void _showSnackbar(String message, {required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
  }
}