import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PedidoPage extends StatefulWidget {
  const PedidoPage({super.key});

  @override
  _PedidoPageState createState() => _PedidoPageState();
}

class _PedidoPageState extends State<PedidoPage> {
  int cantidad = 1;

  // Recuperamos los productos de Firebase
  Future<QuerySnapshot> getProductos() {
    return FirebaseFirestore.instance.collection('productos').get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hacer Pedido"),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder(
        future: getProductos(),
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

          final productos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              var producto = productos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto['nombre'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Precio: \$${producto['precio']}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (cantidad > 1) {
                                setState(() {
                                  cantidad--;
                                });
                              }
                            },
                          ),
                          Text(
                            '$cantidad',
                            style: const TextStyle(fontSize: 20),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                cantidad++;
                              });
                            },
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Lógica para agregar al pedido (en Firestore o en el carrito)
                          // Aquí puedes agregar el producto y la cantidad seleccionada al pedido
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Producto: ${producto['nombre']} x$cantidad agregado al pedido'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom( backgroundColor: Colors.red,),
                        child: const Text("Agregar al Pedido"),
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
