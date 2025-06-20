import 'package:cloud_firestore/cloud_firestore.dart';
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Mesa: $mesa", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                ...productos.map((p) => Text("${p['cantidad']} x ${p['nombre']}")).toList(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Estado: ${estado.toUpperCase()}"),
                    if (estado != 'listo')
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        tooltip: "Marcar como listo",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("¿Marcar como listo?"),
                              content: const Text("¿Estás seguro de que quieres marcar este pedido como listo?"),
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
                )
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
