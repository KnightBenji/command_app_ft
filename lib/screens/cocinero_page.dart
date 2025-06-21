import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CocineroPage extends StatelessWidget {
  const CocineroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Panel del Cocinero",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD32F2F),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pedidos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidos = snapshot.data?.docs ?? [];

          if (pedidos.isEmpty) {
            return const Center(child: Text("No hay pedidos."));
          }

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              final mesa = pedido['mesa'];
              final productos = List.from(pedido['productos']);
              final estado = pedido['estado'];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Mesa: $mesa",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black87)),
                      const SizedBox(height: 10),
                      ...productos.map((p) => Text(
                            "${p['cantidad']} x ${p['nombre']}",
                            style: const TextStyle(fontSize: 16),
                          )),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Estado: ${estado.toUpperCase()}",
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          if (estado != 'listo')
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text("Marcar como listo"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("¿Marcar como listo?"),
                                    content: const Text(
                                        "¿Estás seguro de que quieres marcar este pedido como listo?"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Cancelar"),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: const Text("Sí, confirmar"),
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await FirebaseFirestore.instance
                                              .collection('pedidos')
                                              .doc(pedido.id)
                                              .update({'estado': 'listo'});
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
