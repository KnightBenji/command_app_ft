import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pedido_page.dart';  // Importa PedidoPage

class MeseroPage extends StatelessWidget {
  const MeseroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel del Mesero"),
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
          "¡Bienvenido, Mesero!",
          style: TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la página de crear pedido
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PedidoPage()),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
}
