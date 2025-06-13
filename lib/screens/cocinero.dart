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
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
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
