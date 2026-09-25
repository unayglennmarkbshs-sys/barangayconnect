import 'package:flutter/material.dart';
import '../auth_provider.dart';
import '../api_service.dart';
import '../models.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.auth});
  final AuthProvider auth;
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _api = ApiService();
  List<AppNotification> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.get('/api/notifications');
      setState(() {
        _items = (data as List).map((e) => AppNotification.fromJson(e)).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _markRead(AppNotification n) async {
    if (n.isRead) return;
    try { await _api.put('/api/notifications/${n.notificationId}/read', {}); await _load(); } catch (_) {}
  }

  IconData _icon(String type) {
    switch (type) {
      case 'announcement': return Icons.campaign;
      case 'request_update': return Icons.description;
      case 'concern_update': return Icons.report_problem;
      case 'event': return Icons.event;
      default: return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No notifications yet.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final n = _items[i];
                      return Card(
                        color: n.isRead ? null : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                        child: ListTile(
                          leading: Icon(_icon(n.type), color: const Color(0xFF1565C0)),
                          title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                          subtitle: Text(n.message),
                          trailing: Text(n.dateSent.length >= 10 ? n.dateSent.substring(0, 10) : n.dateSent,
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          onTap: () => _markRead(n),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
