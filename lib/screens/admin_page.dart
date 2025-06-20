import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

<<<<<<< Updated upstream
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
=======
>>>>>>> Stashed changes
  void cerrarSesion(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => cerrarSesion(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.supervised_user_circle),
                label: const Text('Gestión de Roles'),
                onPressed: () => Navigator.pushNamed(context, '/gestionRol'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
<<<<<<< Updated upstream
              );
            },
          );
        },
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.supervised_user_circle),
                label: const Text('Gestión de Roles'),
                onPressed: () => Navigator.pushNamed(context, '/gestionRol'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
=======
>>>>>>> Stashed changes
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Gestión de Menú'),
                onPressed: () => Navigator.pushNamed(context, '/gestionMenu'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
