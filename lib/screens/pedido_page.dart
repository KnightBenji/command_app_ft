import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PedidoPage extends StatefulWidget {
  const PedidoPage({super.key});

  @override
  State<PedidoPage> createState() => _PedidoPageState();
}

class _PedidoPageState extends State<PedidoPage> {
  String? categoriaSeleccionada;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Map<String, int> cantidades = {}; // Almacena cantidades por producto

  Future<List<QueryDocumentSnapshot>> obtenerProductos() async {
    final snapshot = await FirebaseFirestore.instance.collection('productos').get();
    return snapshot.docs;
  }

  List<String> extraerCategorias(List<QueryDocumentSnapshot> productos) {
    final categorias = productos.map((p) => p['categoria'].toString()).toSet().toList();
    categorias.sort();
    return categorias;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hacer Pedido'),
        backgroundColor: Colors.red,
      ),
      drawer: Drawer(
        child: FutureBuilder(
          future: obtenerProductos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) return const Center(child: Text("Error al cargar categorías"));
            final productos = snapshot.data!;
            final categorias = extraerCategorias(productos);

            return ListView(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.red),
                  child: Text('Categorías', style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                for (var cat in categorias)
                  ListTile(
                    title: Text(cat),
                    selected: categoriaSeleccionada == cat,
                    onTap: () {
                      setState(() {
                        categoriaSeleccionada = cat;
                        Navigator.pop(context); // cerrar drawer
                      });
                    },
                  )
              ],
            );
          },
        ),
      ),
      body: FutureBuilder(
        future: obtenerProductos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return const Center(child: Text("Error al cargar productos"));
          final productos = snapshot.data!;
          final productosFiltrados = productos.where((producto) {
            final nombre = producto['nombre'].toString().toLowerCase();
            final coincideBusqueda = nombre.contains(searchQuery.toLowerCase());
            final coincideCategoria = categoriaSeleccionada == null ||
                producto['categoria'] == categoriaSeleccionada;
            return coincideBusqueda && coincideCategoria;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar producto',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: productosFiltrados.isEmpty
                      ? const Center(child: Text("No hay productos que coincidan"))
                      : ListView.builder(
                          itemCount: productosFiltrados.length,
                          itemBuilder: (context, index) {
                            final producto = productosFiltrados[index];
                            final id = producto.id;
                            final nombre = producto['nombre'];
                            final precio = producto['precio'];

                            cantidades[id] = cantidades[id] ?? 0;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                        const SizedBox(height: 4),
                                        Text('Precio: \$${precio.toString()}'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: cantidades[id]! > 0
                                              ? () => setState(() => cantidades[id] = cantidades[id]! - 1)
                                              : null,
                                        ),
                                        Text('${cantidades[id]}', style: const TextStyle(fontSize: 20)),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () => setState(() => cantidades[id] = cantidades[id]! + 1),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
