import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pedido_page.dart';

class MeseroPage extends StatelessWidget {
  const MeseroPage({super.key});

  void _seleccionarMesa(BuildContext context) {
    String? mesaSeleccionada;
    final List<String> mesas = ['Mesa 1', 'Mesa 2', 'Mesa 3', 'Mesa 4'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Selecciona una mesa'),
            content: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Mesa',
                border: OutlineInputBorder(),
              ),
              value: mesaSeleccionada,
              items: mesas.map((mesa) {
                return DropdownMenuItem(
                  value: mesa,
                  child: Text(mesa),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  mesaSeleccionada = value;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (mesaSeleccionada != null) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PedidoPage(
                          nombreMesa: mesaSeleccionada!,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C42), // Naranjo
                ),
                child: const Text("Continuar"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Gris claro
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Panel del Mesero", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFF8C42), // Naranjo
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
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .where('estado', isEqualTo: 'listo')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidosListos = snapshot.data?.docs ?? [];

          if (pedidosListos.isEmpty) {
            return const Center(
              child: Text(
                "No hay pedidos listos para entregar.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: pedidosListos.length,
            itemBuilder: (context, index) {
              final pedido = pedidosListos[index];
              final mesa = pedido['mesa'];
              final productos = List.from(pedido['productos']);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "PEDIDO LISTO PARA LLEVAR",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text("Mesa: $mesa", style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 6),
                      ...productos.map((p) => Text("${p['cantidad']} x ${p['nombre']}")),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          tooltip: "Marcar como entregado",
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("¿Marcar como entregado?"),
                                content: const Text("Esto eliminará el pedido de la vista del mesero."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await FirebaseFirestore.instance
                                          .collection('pedidos')
                                          .doc(pedido.id)
                                          .delete();
                                    },
                                    child: const Text("Confirmar"),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _seleccionarMesa(context),
        backgroundColor: const Color(0xFFFF8C42), // Naranjo
        child: const Icon(Icons.add),
      ),
    );
  }
}
