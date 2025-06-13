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

  void activarUsuario(String uid) async {
    await _firestore.collection('usuarios').doc(uid).update({'activo': true});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario activado')),
    );
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
                        onPressed: activo ? null : () => activarUsuario(uid),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activo ? Colors.green : Colors.blue,
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child: Text(activo ? "Activo" : "Activar"),
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
