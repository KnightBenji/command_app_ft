import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //Controladores de texto para los textfields
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
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
                  'Registrar Usuario',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 32),

                // Campo nombre
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo correo
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
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

                // Campo contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón register
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      fnRegistrarUsuario(
                        _nombreController.text.trim(),
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text("Registrar"),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void animacion() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Simular una espera de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Cerrar el diálogo
    });
  }

  Future<void> fnRegistrarUsuario(
    String nombre,
    String email,
    String password,
  ) async {
    if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, completa todos los campos"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Obtener UID del usuario recién creado
      final String uid = credential.user!.uid;

      // Crear el documento en Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': nombre,
        'email': email,
        'rol': 'pendiente', // rol por defecto
        'activo': false, // aún no verificado por el admin
      });
      
      // Enviar email de verificación
      await credential.user?.sendEmailVerification();

      // Mostrar mensaje y navegar a pantalla de verificación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Registro exitoso. Revisa tu correo para verificar tu cuenta.",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/verifyEmail');

      
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Error al registrar usuario"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ocurrió un error inesperado"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
