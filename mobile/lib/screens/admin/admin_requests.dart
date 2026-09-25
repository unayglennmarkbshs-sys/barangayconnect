import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../requests_screen.dart' show statusColor;

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});
  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  final _api = ApiService();
  List<dynamic> _items = [];
  bool _loading = true;
  String? _filter;

  static const statuses = ['pending', 'in review', 'approved', 'released', 'rejected'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final q = _filter != null ? '?status=${Uri.encodeComponent(_filter!)}' : '';
      final data = await _api.get('/api/requests$q');
      setState(() { _items = data as List; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _updateStatus(Map<String, dynamic> r) async {
    String chosen = r['status'] ?? 'pending';
    final remarksC = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text('Request #${r['request_id']}'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              value: chosen,
              decoration: const InputDecoration(labelText: 'New Status', border: OutlineInputBorder()),
              items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
              onChanged: (v) => setDialog(() => chosen = v!),
            ),
            const SizedBox(height: 12),
            TextField(controller: remarksC, decoration: const InputDecoration(labelText: 'Remarks (optional)', border: OutlineInputBorder())),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Update')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await _api.put('/api/requests/${r['request_id']}/status', {
        'status': chosen, 'remarks': remarksC.text.trim(),
      });
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
                      final r = _items[i];
                      return Card(
                        child: ListTile(
                          title: Text('#${r['request_id']} - ${(r['request_type'] ?? '').toString().toUpperCase()}'),
                          subtitle: Text('${r['resident_name'] ?? ''} | ${r['purpose'] ?? ''}'),
                          trailing: Chip(
                            label: Text(r['status'] ?? '', style: const TextStyle(fontSize: 12)),
                            backgroundColor: statusColor(r['status'] ?? '').withOpacity(0.2),
                          ),
                          onTap: () => _updateStatus(r),
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
