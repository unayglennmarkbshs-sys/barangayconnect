import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth_provider.dart';
import '../api_service.dart';
import '../models.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key, required this.auth});
  final AuthProvider auth;
  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final _api = ApiService();
  List<EmergencyContact> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.get('/api/emergency-contacts');
      setState(() { _items = (data as List).map((e) => EmergencyContact.fromJson(e)).toList(); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    // Group by category
    final Map<String, List<EmergencyContact>> grouped = {};
    for (final c in _items) {
      grouped.putIfAbsent(c.category, () => []).add(c);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Directory')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(8),
              children: grouped.entries.expand((entry) => [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                  child: Text(entry.key,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                ),
                ...entry.value.map((c) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.phone, color: Colors.redAccent),
                        title: Text(c.name),
                        subtitle: Text(c.address ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.call, color: Colors.green),
                          onPressed: () => _call(c.phoneNumber),
                        ),
                      ),
                    )),
              ]).toList(),
            ),
    );
  }
}
