import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PedidoPage extends StatefulWidget {
  const PedidoPage({super.key});

  @override
  _PedidoPageState createState() => _PedidoPageState();
}

class _PedidoPageState extends State<PedidoPage> {
  Map<String, int> cantidades = {};
  String _busqueda = '';

  // Agrupa productos por categoría
  Future<Map<String, List<DocumentSnapshot>>> getProductosAgrupados() async {
    final snapshot = await FirebaseFirestore.instance.collection('productos').get();
    final productos = snapshot.docs;

    final Map<String, List<DocumentSnapshot>> agrupado = {};

    for (var producto in productos) {
      final categoria = producto['categoria'] ?? 'Sin categoría';
      agrupado.putIfAbsent(categoria, () => []).add(producto);
      cantidades[producto.id] = 1;
    }

    return agrupado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hacer Pedido"),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar producto',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _busqueda = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, List<DocumentSnapshot>>>(
              future: getProductosAgrupados(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar los productos'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay productos disponibles'));
                }

                final categorias = snapshot.data!;

                return ListView(
                  children: categorias.entries.map((entry) {
                    final categoria = entry.key;
                    final productos = entry.value.where((producto) {
                      final nombre = (producto['nombre'] ?? '').toString().toLowerCase();
                      return _busqueda.isEmpty || nombre.contains(_busqueda);
                    }).toList();

                    if (productos.isEmpty) return const SizedBox.shrink();

                    return ExpansionTile(
                      initiallyExpanded: _busqueda.isNotEmpty,
                      title: Text(categoria, style: const TextStyle(fontWeight: FontWeight.bold)),
                      children: productos.map((producto) {
                        final id = producto.id;
                        final nombre = producto['nombre'];
                        final precio = producto['precio'];

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('Precio: \$${precio}'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          if (cantidades[id]! > 1) cantidades[id] = cantidades[id]! - 1;
                                        });
                                      },
                                    ),
                                    Text('${cantidades[id]}', style: const TextStyle(fontSize: 20)),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          cantidades[id] = cantidades[id]! + 1;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Producto: $nombre x${cantidades[id]} agregado al pedido'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text("Agregar al Pedido"),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
