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
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        onPressed: () => _seleccionarMesa(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
}
