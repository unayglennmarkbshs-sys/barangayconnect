import 'package:flutter/material.dart';
import '../auth_provider.dart';
import '../api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.auth});
  final AuthProvider auth;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _me;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.text = widget.auth.user?.fullName ?? '';
    _phone.text = widget.auth.user?.phoneNumber ?? '';
    _address.text = widget.auth.user?.address ?? '';
    _load();
  }

  Future<void> _load() async {
    try {
      final me = await _api.get('/api/users/me');
      setState(() => _me = me);
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      await _api.put('/api/users/me', {
        'full_name': _name.text.trim(),
        'phone_number': _phone.text.trim(),
        'address': _address.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
        widget.auth.restoreSession();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    }
  }

  Future<void> _logout() async {
    await widget.auth.logout();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen(auth: widget.auth)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.auth.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 44)),
          const SizedBox(height: 8),
          Center(child: Text(u?.fullName ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          Center(child: Text(u?.email ?? '', style: const TextStyle(color: Colors.grey))),
          Center(child: Chip(label: Text((u?.role ?? '').toUpperCase()))),
          const SizedBox(height: 16),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address / Purok', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('SAVE CHANGES')),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
