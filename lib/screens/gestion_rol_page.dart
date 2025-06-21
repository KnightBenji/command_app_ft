import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GestionRolPage extends StatefulWidget {
  const GestionRolPage({super.key});

  @override
  State<GestionRolPage> createState() => _GestionRolPageState();
}

class _GestionRolPageState extends State<GestionRolPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> rolesDisponibles = ['admin', 'mesero', 'cocinero'];

  void cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> actualizarRol(String uid, String nuevoRol, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar cambio de rol'),
        content: Text('¿Deseas cambiar el rol de $nombre a "$nuevoRol"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirm == true) {
      await _firestore.collection('usuarios').doc(uid).update({'rol': nuevoRol});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rol actualizado a $nuevoRol')),
      );
    }
  }

  Future<void> cambiarEstadoUsuario(String uid, bool estadoActual, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(estadoActual ? 'Confirmar desactivación' : 'Confirmar activación'),
        content: Text('¿Estás seguro que deseas ${estadoActual ? 'desactivar' : 'activar'} a $nombre?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirm == true) {
      await _firestore.collection('usuarios').doc(uid).update({'activo': !estadoActual});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(estadoActual ? 'Usuario desactivado' : 'Usuario activado')),
      );
    }
  }

  Future<void> eliminarUsuario(String uid, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Seguro que deseas eliminar a $nombre?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      await _firestore.collection('usuarios').doc(uid).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Fondo claro
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8C42), // Naranjo
        title: const Text(
          'Gestión de Roles',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: cerrarSesion),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('usuarios').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final usuarios = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final user = usuarios[index];
              final uid = user.id;
              final nombre = user['nombre'];
              final email = user['email'];
              final rol = user['rol'];
              final activo = user['activo'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text('Email: $email'),
                      const SizedBox(height: 4),
                      Text('Rol actual: $rol'),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: rolesDisponibles.contains(rol) ? rol : null,
                        decoration: InputDecoration(
                          labelText: "Asignar rol",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: rolesDisponibles.map((r) {
                          return DropdownMenuItem(value: r, child: Text(r));
                        }).toList(),
                        onChanged: (nuevoRol) {
                          if (nuevoRol != null && nuevoRol != rol) {
                            actualizarRol(uid, nuevoRol, nombre);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => cambiarEstadoUsuario(uid, activo, nombre),
                              icon: Icon(activo ? Icons.visibility_off : Icons.check),
                              label: Text(activo ? "Activo (Desactivar)" : "Activar"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: activo ? Colors.green : Colors.blue,
                                minimumSize: const Size.fromHeight(45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => eliminarUsuario(uid, nombre),
                              icon: const Icon(Icons.delete_forever),
                              label: const Text("Eliminar"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size.fromHeight(45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ],
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
