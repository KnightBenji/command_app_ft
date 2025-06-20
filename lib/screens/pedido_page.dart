import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'confirmacionPedido_page.dart';


class PedidoPage extends StatefulWidget {
  const PedidoPage({super.key});

  @override
  State<PedidoPage> createState() => _PedidoPageState();
}

class _PedidoPageState extends State<PedidoPage> {
  String? categoriaSeleccionada;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Map<String, int> cantidades = {};
  List<Map<String, dynamic>> pedido = [];
  List<QueryDocumentSnapshot>? productosCargados;
  bool cargandoProductos = true;

  final PanelController _panelController = PanelController();

  @override
  void initState() {
    super.initState();
    obtenerProductos().then((datos) {
      setState(() {
        productosCargados = datos;
        cargandoProductos = false;
      });
    });
  }

  Future<List<QueryDocumentSnapshot>> obtenerProductos() async {
    final snapshot = await FirebaseFirestore.instance.collection('productos').get();
    return snapshot.docs;
  }

  List<String> extraerCategorias(List<QueryDocumentSnapshot> productos) {
    final categorias = productos.map((p) => p['categoria'].toString()).toSet().toList();
    categorias.sort();
    return categorias;
  }

  void actualizarPedido(String id, String nombre, int cantidad, int precio) {
    setState(() {
      pedido.removeWhere((item) => item['id'] == id);
      if (cantidad > 0) {
        pedido.add({
          'id': id,
          'nombre': nombre,
          'cantidad': cantidad,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cargandoProductos) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final productosFiltrados = productosCargados!.where((producto) {
      final nombre = producto['nombre'].toString().toLowerCase();
      final coincideBusqueda = nombre.contains(searchQuery.toLowerCase());
      final coincideCategoria = categoriaSeleccionada == null ||
          producto['categoria'] == categoriaSeleccionada;
      return coincideBusqueda && coincideCategoria;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hacer Pedido'),
        backgroundColor: Colors.red,
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("¿Deshacer pedido?"),
                  content: const Text("¿Estás seguro de que deseas volver y cancelar este pedido?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("Sí, volver"),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              "Atrás",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Text('Categorías', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            for (var cat in extraerCategorias(productosCargados!))
              ListTile(
                title: Text(cat),
                selected: categoriaSeleccionada == cat,
                onTap: () {
                  setState(() {
                    categoriaSeleccionada = cat;
                    Navigator.pop(context);
                  });
                },
              )
          ],
        ),
      ),
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 80,
        maxHeight: 250,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        panelBuilder: (sc) => _buildResumenPedido(sc),
        body: Padding(
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
                                      Text(nombre,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 20)),
                                      const SizedBox(height: 4),
                                      Text('Precio: \$${precio.toString()}'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: cantidades[id]! > 0
                                            ? () {
                                                setState(() {
                                                  cantidades[id] = cantidades[id]! - 1;
                                                });
                                                actualizarPedido(id, nombre, cantidades[id]!, precio);
                                              }
                                            : null,
                                      ),
                                      Text('${cantidades[id]}',
                                          style: const TextStyle(fontSize: 20)),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            cantidades[id] = cantidades[id]! + 1;
                                          });
                                          actualizarPedido(id, nombre, cantidades[id]!, precio);
                                        },
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
        ),
      ),
    );
  }

  Widget _buildResumenPedido(ScrollController sc) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${pedido.length} PRODUCTOS", style: const TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.limeAccent[400],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                    onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ConfirmacionPedidoPage(pedido: pedido),
                      ),
                    );
                  },

                child: const Text("CONTINUAR"),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: sc,
            itemCount: pedido.length,
            itemBuilder: (context, index) {
              final item = pedido[index];
              return ListTile(
                title: Text("${item['cantidad']} x ${item['nombre']}"),
              );
            },
          ),
        )
      ],
    );
  }
}
