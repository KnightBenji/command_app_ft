import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PedidoPage extends StatelessWidget {
  const PedidoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hacer Pedido"),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder(
        // Aquí estamos recuperando los productos desde Firestore
        future: FirebaseFirestore.instance.collection('productos').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los productos'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay productos disponibles'));
          }

          // Aquí se muestran los productos en una lista
          final productos = snapshot.data!.docs;
          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              var producto = productos[index];
              return ListTile(
                title: Text(producto['nombre']),
                subtitle: Text('Precio: \$${producto['precio']}'),
                onTap: () {
                  // Aquí puedes añadir lógica para seleccionar un producto y agregarlo al pedido
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(producto['nombre']),
                      content: Text(producto['descripcion']),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cerrar"),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
