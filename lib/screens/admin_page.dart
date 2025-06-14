import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> rolesDisponibles = ['admin', 'mesero', 'cocinero'];

  void actualizarRol(String uid, String nuevoRol) async {
    await _firestore.collection('usuarios').doc(uid).update({'rol': nuevoRol});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rol actualizado a $nuevoRol')),
    );
  }

  void cambiarEstadoUsuario(String uid, bool estadoActual) async {
    await _firestore.collection('usuarios').doc(uid).update({'activo': !estadoActual});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(estadoActual ? 'Usuario desactivado' : 'Usuario activado')),
    );
  }

  void eliminarUsuario(String uid, String nombre) async {
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

  void cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: cerrarSesion,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('usuarios').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final usuarios = snapshot.data!.docs;

          return ListView.builder(
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Email: $email'),
                      const SizedBox(height: 4),
                      Text('Rol actual: $rol'),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: rolesDisponibles.contains(rol) ? rol : null,
                        hint: const Text("Asignar rol"),
                        items: rolesDisponibles.map((r) {
                          return DropdownMenuItem(
                            value: r,
                            child: Text(r),
                          );
                        }).toList(),
                        onChanged: (nuevoRol) {
                          if (nuevoRol != null) {
                            actualizarRol(uid, nuevoRol);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => cambiarEstadoUsuario(uid, activo),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activo ? Colors.green : Colors.blue,
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child: Text(activo ? "Activo (Desactivar)" : "Activar"),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => eliminarUsuario(uid, nombre),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child: const Text("Eliminar usuario"),
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
