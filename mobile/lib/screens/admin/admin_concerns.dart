import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../requests_screen.dart' show statusColor;

class AdminConcernsScreen extends StatefulWidget {
  const AdminConcernsScreen({super.key});
  @override
  State<AdminConcernsScreen> createState() => _AdminConcernsScreenState();
}

class _AdminConcernsScreenState extends State<AdminConcernsScreen> {
  final _api = ApiService();
  List<dynamic> _items = [];
  bool _loading = true;
  String? _filter;

  static const statuses = ['pending', 'reviewed', 'resolved', 'dismissed'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final q = _filter != null ? '?status=${Uri.encodeComponent(_filter!)}' : '';
      final data = await _api.get('/api/concerns$q');
      setState(() { _items = data as List; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _updateStatus(Map<String, dynamic> c) async {
    String chosen = c['status'] ?? 'pending';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(c['title'] ?? ''),
          content: DropdownButtonFormField<String>(
            value: chosen,
            decoration: const InputDecoration(labelText: 'New Status', border: OutlineInputBorder()),
            items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
            onChanged: (v) => setDialog(() => chosen = v!),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Update')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await _api.put('/api/concerns/${c['concern_id']}/status', {'status': chosen});
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(10),
            children: [
              ChoiceChip(label: const Text('All'), selected: _filter == null, onSelected: (_) { setState(() => _filter = null); _load(); }),
              const SizedBox(width: 6),
              ...statuses.map((s) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(label: Text(s.toUpperCase()), selected: _filter == s, onSelected: (_) { setState(() => _filter = s); _load(); }),
              )),
            ],
          ),
        ),
        Expanded(
          child: _loading
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
                          title: Text(c['title'] ?? ''),
                          subtitle: Text('${c['resident_name'] ?? ''} | ${c['category'] ?? ''}'),
                          trailing: Chip(
                            label: Text(c['status'] ?? '', style: const TextStyle(fontSize: 12)),
                            backgroundColor: statusColor(c['status'] ?? '').withOpacity(0.2),
                          ),
                          onTap: () => _updateStatus(c),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
