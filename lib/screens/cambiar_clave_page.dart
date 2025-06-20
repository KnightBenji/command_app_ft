import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CambiarClavePage extends StatefulWidget {
  const CambiarClavePage({super.key});

  @override
  State<CambiarClavePage> createState() => _CambiarClavePageState();
}

class _CambiarClavePageState extends State<CambiarClavePage> {
  final _claveActualController = TextEditingController();
  final _nuevaClaveController = TextEditingController();
  final _confirmarClaveController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool cargando = false;

  Future<void> cambiarClave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => cargando = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _claveActualController.text,
      );

      await user.reauthenticateWithCredential(cred);

      if (_nuevaClaveController.text != _confirmarClaveController.text) {
        throw FirebaseAuthException(
          code: "clave-no-coincide",
          message: "La nueva clave no coincide",
        );
      }

      await user.updatePassword(_nuevaClaveController.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Clave actualizada correctamente"),
        backgroundColor: Colors.green,
      ));

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? "Error"),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  void dispose() {
    _claveActualController.dispose();
    _nuevaClaveController.dispose();
    _confirmarClaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cambiar Clave"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _claveActualController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Clave actual'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nuevaClaveController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nueva clave'),
                validator: (value) => value!.length < 6
                    ? 'Debe tener al menos 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmarClaveController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar nueva clave'),
                validator: (value) => value != _nuevaClaveController.text
                    ? 'Las claves no coinciden'
                    : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: cargando ? null : cambiarClave,
                child: cargando
                    ? const CircularProgressIndicator()
                    : const Text('Actualizar clave'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
