import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CocineroPage extends StatelessWidget {
  const CocineroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel del Cocinero"),
        backgroundColor: Colors.red,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) async {
              if (value == 'cerrar') {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              } else if (value == 'cambiar') {
                Navigator.pushNamed(context, '/cambiarClave');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'cambiar',
                child: Text('Cambiar clave'),
              ),
              const PopupMenuItem(
                value: 'cerrar',
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "¡Bienvenido, Cocinero!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
