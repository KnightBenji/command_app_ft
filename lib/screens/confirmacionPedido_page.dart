import 'package:flutter/material.dart';

class ConfirmacionPedidoPage extends StatelessWidget {
  final List<Map<String, dynamic>> pedido;

  const ConfirmacionPedidoPage({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resumen del Pedido"),
        backgroundColor: Colors.green,
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
          onPressed: () {
            // Aquí puedes guardar en Firebase o ir a otra pantalla
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Pedido confirmado con éxito.")),
            );
            Navigator.pop(context); // Volver a pantalla anterior, si deseas
          },
          icon: const Icon(Icons.check),
          label: const Text("Confirmar Pedido"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
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
