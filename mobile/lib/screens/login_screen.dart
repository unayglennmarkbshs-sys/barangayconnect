import 'package:flutter/material.dart';
import '../auth_provider.dart';
import 'admin_shell.dart';
import 'resident_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth});
  final AuthProvider auth;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _registerMode = false;
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    for (final c in [_email, _password, _fullName, _phone, _address, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    String? err;
    if (_registerMode) {
      if (_password.text != _confirm.text) {
        setState(() => _error = 'Passwords do not match');
        return;
      }
      err = await widget.auth.register({
        'full_name': _fullName.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text,
        'phone_number': _phone.text.trim(),
        'address': _address.text.trim(),
      });
    } else {
      err = await widget.auth.login(_email.text.trim(), _password.text);
    }
    if (!mounted) return;
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => widget.auth.isAdmin
          ? AdminShell(auth: widget.auth)
          : ResidentShell(auth: widget.auth),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_city, size: 72, color: Color(0xFF1565C0)),
                  const SizedBox(height: 8),
                  const Text('BarangayConnect',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text('Community Services and Information',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  if (_registerMode) ...[
                    TextFormField(
                      controller: _fullName,
                      decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _address,
                      decoration: const InputDecoration(labelText: 'Address / Purok', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                  ),
                  if (_registerMode) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirm,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: widget.auth.loading ? null : _submit,
                      child: Text(_registerMode ? 'REGISTER' : 'LOG IN'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _registerMode = !_registerMode;
                      _error = null;
                    }),
                    child: Text(_registerMode
                        ? 'Already have an account? Log in'
                        : 'Forgot password? Register as Resident'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Shells referenced from main.dart / login routing.
