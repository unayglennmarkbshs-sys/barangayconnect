import 'package:flutter/material.dart';
import '../../api_service.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});
  @override
  State<AdminAnnouncementsScreen> createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  final _api = ApiService();
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.get('/api/announcements/all');
      setState(() { _items = data as List; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _openForm([Map<String, dynamic>? existing]) async {
    final titleC = TextEditingController(text: existing?['title'] ?? '');
    final contentC = TextEditingController(text: existing?['content'] ?? '');
    final categoryC = TextEditingController(text: existing?['category'] ?? '');
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(existing == null ? 'New Announcement' : 'Edit Announcement',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: categoryC, decoration: const InputDecoration(labelText: 'Category (e.g. Health, Safety)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: contentC, maxLines: 6, decoration: const InputDecoration(labelText: 'Content', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SAVE')),
        ]),
      ),
    );
    if (ok != true) return;
    try {
      if (existing == null) {
        await _api.post('/api/announcements', {
          'title': titleC.text.trim(), 'content': contentC.text.trim(), 'category': categoryC.text.trim(),
        });
      } else {
        await _api.put('/api/announcements/${existing['announcement_id']}', {
          'title': titleC.text.trim(), 'content': contentC.text.trim(),
          'category': categoryC.text.trim(), 'status': existing['status'] ?? 'published',
        });
      }
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _archive(Map<String, dynamic> a) async {
    try { await _api.delete('/api/announcements/${a['announcement_id']}'); await _load(); } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
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
                  final a = _items[i];
                  return Card(
                    child: ListTile(
                      title: Text(a['title'] ?? ''),
                      subtitle: Text('${a['category'] ?? 'General'} | ${(a['date_posted'] ?? '').toString().substring(0, 10)} | ${a['status']}'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(a)),
                        IconButton(icon: const Icon(Icons.archive, color: Colors.red), onPressed: () => _archive(a)),
                      ]),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
