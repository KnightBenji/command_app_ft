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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7043),
        title: const Text("Cambiar Clave", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
                decoration: InputDecoration(
                  labelText: 'Clave actual',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nuevaClaveController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Nueva clave',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) =>
                    value!.length < 6 ? 'Debe tener al menos 6 caracteres' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmarClaveController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar nueva clave',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) =>
                    value != _nuevaClaveController.text ? 'Las claves no coinciden' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: cargando ? null : cambiarClave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: cargando
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Actualizar clave',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
