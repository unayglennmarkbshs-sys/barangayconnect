import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../../models.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _api = ApiService();
  List<User> _items = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.get('/api/users${_search.isNotEmpty ? '?search=${Uri.encodeComponent(_search)}' : ''}');
      setState(() { _items = (data as List).map((e) => User.fromJson(e)).toList(); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _toggleStatus(User u) async {
    final next = u.status == 'active' ? 'inactive' : 'active';
    try {
      await _api.put('/api/users/${u.userId}/status', {'status': next});
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search name or email...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: (v) { setState(() => _search = v); _load(); },
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final u = _items[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text(u.fullName.isNotEmpty ? u.fullName[0] : '?')),
                        title: Text(u.fullName),
                        subtitle: Text('${u.email} | ${u.role}'),
                        trailing: Switch(
                          value: u.status == 'active',
                          activeColor: Colors.green,
                          onChanged: (_) => _toggleStatus(u),
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
