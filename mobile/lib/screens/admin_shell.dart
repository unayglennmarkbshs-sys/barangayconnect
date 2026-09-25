import 'package:flutter/material.dart';
import '../auth_provider.dart';
import 'admin/admin_dashboard.dart';
import 'admin/admin_users.dart';
import 'admin/admin_announcements.dart';
import 'admin/admin_requests.dart';
import 'admin/admin_concerns.dart';
import 'admin/admin_directory.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.auth});
  final AuthProvider auth;
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      AdminDashboardScreen(auth: widget.auth),
      AdminUsersScreen(),
      AdminAnnouncementsScreen(),
      AdminRequestsScreen(),
      AdminConcernsScreen(),
      AdminDirectoryScreen(),
    ];
    final titles = ['Dashboard', 'Users', 'Announcements', 'Requests', 'Concerns', 'Directory'];
    return Scaffold(
      appBar: AppBar(title: Text('Admin - ${titles[_index]}')),
      drawer: Drawer(
        child: ListView(children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1565C0)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
              const SizedBox(height: 8),
              Text(widget.auth.user?.fullName ?? 'Admin',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ]),
          ),
          ...List.generate(6, (i) => ListTile(
                title: Text(titles[i]),
                selected: _index == i,
                onTap: () => setState(() { _index = i; Navigator.pop(context); }),
              )),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await widget.auth.logout();
            },
          ),
        ]),
      ),
      body: pages[_index],
    );
  }
}
