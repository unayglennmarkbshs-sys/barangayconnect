import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../auth_provider.dart';
import '../api_service.dart';
import '../models.dart';
import 'requests_screen.dart' show statusColor;

const concernCategories = ['Noise', 'Sanitation', 'Peace & Order', 'Other'];

class ConcernsScreen extends StatefulWidget {
  const ConcernsScreen({super.key, required this.auth});
  final AuthProvider auth;
  @override
  State<ConcernsScreen> createState() => _ConcernsScreenState();
}

class _ConcernsScreenState extends State<ConcernsScreen> {
  final _api = ApiService();
  List<Concern> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.get('/api/concerns/mine');
      setState(() { _items = (data as List).map((e) => Concern.fromJson(e)).toList(); _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Concerns')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NewConcernScreen(onDone: _load)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Report Concern'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No concerns reported yet.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final c = _items[i];
                      return Card(
                        child: ListTile(
                          title: Text(c.title),
                          subtitle: Text(c.category ?? ''),
                          trailing: Chip(
                            label: Text(c.status, style: const TextStyle(fontSize: 12)),
                            backgroundColor: statusColor(c.status).withOpacity(0.2),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class NewConcernScreen extends StatefulWidget {
  const NewConcernScreen({super.key, required this.onDone});
  final VoidCallback onDone;
  @override
  State<NewConcernScreen> createState() => _NewConcernScreenState();
}

class _NewConcernScreenState extends State<NewConcernScreen> {
  final _api = ApiService();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  String _category = concernCategories.first;
  File? _photo;
  String? _error;
  bool _saving = false;

  @override
  void dispose() { _title.dispose(); _desc.dispose(); super.dispose(); }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty || _desc.text.trim().isEmpty) {
      setState(() => _error = 'Title and description are required.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      final created = await _api.post('/api/concerns', {
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'category': _category,
      });
      if (_photo != null) {
        await _api.uploadFile('/api/concerns/${created['concern_id']}/attachments', _photo!);
      }
      widget.onDone();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report a Concern')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
            items: concernCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _desc,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Row(children: [
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.photo_camera),
              label: Text(_photo == null ? 'Attach Photo' : 'Photo Attached'),
            ),
            const SizedBox(width: 8),
            if (_photo != null)
              TextButton(onPressed: () => setState(() => _photo = null), child: const Text('Remove')),
          ]),
          const SizedBox(height: 16),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          FilledButton(onPressed: _saving ? null : _submit, child: const Text('SUBMIT CONCERN')),
        ],
      ),
    );
  }
}
