import 'dart:convert';
import 'package:flutter/material.dart';
import '../auth_provider.dart';
import '../api_service.dart';
import '../models.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.auth});
  final AuthProvider auth;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  List<Announcement> _announcements = [];
  List<Map<String, dynamic>> _events = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final ann = await _api.get('/api/announcements');
      final ev = await _api.get('/api/events');
      setState(() {
        _announcements = (ann as List).map((e) => Announcement.fromJson(e)).toList();
        _events = (ev as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Could not load feed. Is the server running? ($e)'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BarangayConnect'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notifications',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NotificationsScreen(auth: widget.auth)),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _load, child: const Text('Retry')),
                ])))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      if (_events.isNotEmpty) ...[
                        const Text('Upcoming Events', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        ..._events.take(3).map((e) => Card(
                              child: ListTile(
                                leading: const Icon(Icons.event, color: Color(0xFF1565C0)),
                                title: Text(e['title'] ?? ''),
                                subtitle: Text('${e['event_date'] ?? ''}  |  ${e['location'] ?? ''}'),
                              ),
                            )),
                        const SizedBox(height: 12),
                      ],
                      const Text('Announcements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ..._announcements.map((a) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    if (a.category != null)
                                      Chip(label: Text(a.category!, style: const TextStyle(fontSize: 11)), visualDensity: VisualDensity.compact),
                                    const Spacer(),
                                    Text(a.datePosted.substring(0, a.datePosted.length >= 10 ? 10 : a.datePosted.length),
                                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ]),
                                  const SizedBox(height: 6),
                                  Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 6),
                                  Text(a.content),
                                ],
                              ),
                            ),
                          )),
                      if (_announcements.isEmpty)
                        const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No announcements yet.'))),
                    ],
                  ),
                ),
    );
  }
}
