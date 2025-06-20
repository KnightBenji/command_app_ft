import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GestionMenuPage extends StatefulWidget {
  const GestionMenuPage({super.key});

  @override
  State<GestionMenuPage> createState() => _GestionMenuPageState();
}

class _GestionMenuPageState extends State<GestionMenuPage> {
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  final List<String> categoriasDisponibles = [
    'Sandwiches',
    'Bebidas',
    'Postres',
    'Café',
    'Platos Principales',
  ];
  String? categoriaSeleccionada;

  Future<void> agregarProducto() async {
    final nombre = _nombreController.text.trim();
    final precio = int.tryParse(_precioController.text.trim());
    final categoria = categoriaSeleccionada?.trim() ?? '';
    final descripcion = _descripcionController.text.trim();

    if (nombre.isEmpty || precio == null || categoria.isEmpty || descripcion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Completa todos los campos correctamente"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nuevoDoc = _firestore.collection('productos').doc();

    await nuevoDoc.set({
      'nombre': nombre,
      'precio': precio,
      'categoria': categoria,
      'descripcion': descripcion,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Producto agregado con éxito")),
    );

    _nombreController.clear();
    _precioController.clear();
    _descripcionController.clear();
    setState(() {
      categoriaSeleccionada = null;
    });
  }

  Future<void> eliminarProducto(String docId, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar "$nombre" del menú?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('productos').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Producto eliminado")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión del Menú'),
      ),
      body: Column(
        children: [
          // Formulario de agregar producto
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre del producto'),
                ),
                TextField(
                  controller: _precioController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio'),
                ),
                DropdownButtonFormField<String>(
                  value: categoriaSeleccionada,
                  items: categoriasDisponibles.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      categoriaSeleccionada = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Categoría'),
                ),
                TextField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: agregarProducto,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Agregar producto'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Lista de productos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('productos').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final productos = snapshot.data!.docs;

                if (productos.isEmpty) {
                  return const Center(child: Text('No hay productos en el menú.'));
                }

                return ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final prod = productos[index];
                    final id = prod.id;
                    final nombre = prod['nombre'];
                    final precio = prod['precio'];
                    final categoria = prod['categoria'];

                    return ListTile(
                      title: Text(nombre),
                      subtitle: Text('Categoría: $categoria\n\$ $precio'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => eliminarProducto(id, nombre),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
