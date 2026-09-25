import 'package:flutter/material.dart';
import '../../api_service.dart';

class AdminDirectoryScreen extends StatefulWidget {
  const AdminDirectoryScreen({super.key});
  @override
  State<AdminDirectoryScreen> createState() => _AdminDirectoryScreenState();
}

class _AdminDirectoryScreenState extends State<AdminDirectoryScreen> {
  final _api = ApiService();
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.get('/api/emergency-contacts');
      setState(() { _items = data as List; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _addContact() async {
    final nameC = TextEditingController();
    final categoryC = TextEditingController();
    final phoneC = TextEditingController();
    final addressC = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Add Emergency Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name / Office', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: categoryC, decoration: const InputDecoration(labelText: 'Category (Police, Fire, Health...)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: phoneC, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: addressC, decoration: const InputDecoration(labelText: 'Address (optional)', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SAVE')),
        ]),
      ),
    );
    if (ok != true) return;
    try {
      await _api.post('/api/emergency-contacts', {
        'name': nameC.text.trim(), 'category': categoryC.text.trim(),
        'phone_number': phoneC.text.trim(), 'address': addressC.text.trim(),
      });
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final c = _items[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.phone, color: Colors.redAccent),
                      title: Text(c['name'] ?? ''),
                      subtitle: Text('${c['category'] ?? ''} | ${c['phone_number'] ?? ''}'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
