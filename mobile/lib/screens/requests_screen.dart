import 'package:flutter/material.dart';
import '../auth_provider.dart';
import '../api_service.dart';
import '../models.dart';

const requestTypes = ['clearance', 'certificate', 'residency', 'indigency', 'appointment', 'other'];
const requestStatuses = ['pending', 'in review', 'approved', 'released', 'rejected'];

Color statusColor(String s) {
  switch (s) {
    case 'pending': return Colors.orange;
    case 'in review': return Colors.blue;
    case 'approved': return Colors.green;
    case 'released': return Colors.teal;
    case 'rejected': return Colors.red;
    case 'resolved': return Colors.green;
    case 'dismissed': return Colors.grey;
    default: return Colors.grey;
  }
}

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key, required this.auth});
  final AuthProvider auth;
  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final _api = ApiService();
  List<ServiceRequest> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.get('/api/requests/mine');
      setState(() { _items = (data as List).map((e) => ServiceRequest.fromJson(e)).toList(); _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _openNewRequest() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NewRequestScreen(onDone: _load),
    ));
  }

  void _openDetail(ServiceRequest r) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RequestDetailScreen(requestId: r.requestId),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewRequest,
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No requests yet. Tap New Request to submit one.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final r = _items[i];
                      return Card(
                        child: ListTile(
                          title: Text('#${r.requestId} - ${_prettyType(r.requestType)}'),
                          subtitle: Text(r.purpose ?? ''),
                          trailing: Chip(
                            label: Text(r.status, style: const TextStyle(fontSize: 12)),
                            backgroundColor: statusColor(r.status).withOpacity(0.2),
                          ),
                          onTap: () => _openDetail(r),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _prettyType(String t) => t[0].toUpperCase() + t.substring(1);
}

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key, required this.onDone});
  final VoidCallback onDone;
  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _api = ApiService();
  final _purpose = TextEditingController();
  final _details = TextEditingController();
  String _type = requestTypes.first;
  String? _error;
  bool _saving = false;

  @override
  void dispose() { _purpose.dispose(); _details.dispose(); super.dispose(); }

  Future<void> _submit() async {
    setState(() { _saving = true; _error = null; });
    try {
      await _api.post('/api/requests', {
        'request_type': _type,
        'purpose': _purpose.text.trim(),
        'description': _details.text.trim(),
      });
      widget.onDone();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Service Request')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Request Type', border: OutlineInputBorder()),
            items: requestTypes.map((t) => DropdownMenuItem(value: t, child: Text(_pretty(t)))).toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _purpose,
            decoration: const InputDecoration(labelText: 'Purpose', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _details,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Additional Details', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: const Text('SUBMIT REQUEST'),
          ),
        ],
      ),
    );
  }

  String _pretty(String t) => t[0].toUpperCase() + t.substring(1);
}

class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({super.key, required this.requestId});
  final int requestId;
  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _api.get('/api/requests/${widget.requestId}');
      setState(() { _data = data; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _data;
    final history = (r?['history'] as List?) ?? [];
    return Scaffold(
      appBar: AppBar(title: Text('Request #${r?['request_id'] ?? ''}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Chip(
                      label: Text(r!['status'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: statusColor(r['status']),
                    ),
                    const SizedBox(height: 12),
                    ListTile(title: const Text('Type'), subtitle: Text(r['request_type'] ?? '')),
                    ListTile(title: const Text('Purpose'), subtitle: Text(r['purpose'] ?? '-')),
                    ListTile(title: const Text('Details'), subtitle: Text(r['description'] ?? '-')),
                    ListTile(title: const Text('Submitted'), subtitle: Text(r['date_submitted'] ?? '')),
                    const Divider(height: 32),
                    const Text('Status Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...history.map((h) => ListTile(
                          leading: Icon(Icons.check_circle,
                              color: statusColor(h['status'] ?? 'pending')),
                          title: Text((h['status'] ?? '').toString().toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${h['remarks'] ?? ''}\nby ${h['updated_by_name'] ?? ''} on ${h['date_updated']}'),
                          isThreeLine: true,
                        )),
                    if (history.isEmpty) const Text('No status history yet.'),
                  ],
                ),
    );
  }
}
