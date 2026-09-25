import 'package:flutter/material.dart';
import '../../auth_provider.dart';
import '../../api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, required this.auth});
  final AuthProvider auth;
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _summary;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final s = await _api.get('/api/reports/summary');
      setState(() { _summary = s; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final s = _summary ?? {};
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _statCard('Residents', s['total_residents'], Icons.people, Colors.blue),
              _statCard('Pending Requests', s['pending_requests'], Icons.description, Colors.orange),
              _statCard('Open Concerns', s['open_concerns'], Icons.report_problem, Colors.red),
              _statCard('Announcements', s['announcements'], Icons.campaign, Colors.green),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Requests by Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ...((s['requests_by_status'] as List?) ?? []).map((row) => ListTile(
                title: Text((row['status'] ?? '').toString().toUpperCase()),
                trailing: Text('${row['count']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
          const Divider(height: 32),
          const Text('Concerns by Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ...((s['concerns_by_status'] as List?) ?? []).map((row) => ListTile(
                title: Text((row['status'] ?? '').toString().toUpperCase()),
                trailing: Text('${row['count']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
        ],
      ),
    );
  }

  Widget _statCard(String label, dynamic value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color),
          const Spacer(),
          Text('$value', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
      ),
    );
  }
}
