import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfirmacionPedidoPage extends StatelessWidget {
  final List<Map<String, dynamic>> pedido;
  final String nombreMesa;

  const ConfirmacionPedidoPage({
    super.key,
    required this.pedido,
    required this.nombreMesa,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Resumen del Pedido - $nombreMesa",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pedido.isEmpty
            ? const Center(child: Text("No hay productos en el pedido."))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tu pedido:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: pedido.length,
                      itemBuilder: (context, index) {
                        final item = pedido[index];
                        return ListTile(
                          title: Text("${item['cantidad']} x ${item['nombre']}"),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () async {
            try {
              await FirebaseFirestore.instance.collection('pedidos').add({
                'mesa': nombreMesa,
                'productos': pedido,
                'estado': 'pendiente',
                'timestamp': FieldValue.serverTimestamp(),
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pedido enviado a cocina con éxito.")),
              );

              Navigator.pop(context);
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error al guardar pedido: $e")),
              );
            }
          },
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text("Confirmar Pedido", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
