import 'package:flutter/material.dart';
import '../auth_provider.dart';
import 'home_screen.dart';
import 'requests_screen.dart';
import 'concerns_screen.dart';
import 'directory_screen.dart';
import 'profile_screen.dart';

class ResidentShell extends StatefulWidget {
  const ResidentShell({super.key, required this.auth});
  final AuthProvider auth;
  @override
  State<ResidentShell> createState() => _ResidentShellState();
}

class _ResidentShellState extends State<ResidentShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(auth: widget.auth),
      RequestsScreen(auth: widget.auth),
      ConcernsScreen(auth: widget.auth),
      DirectoryScreen(auth: widget.auth),
      ProfileScreen(auth: widget.auth),
    ];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.report_problem_outlined), selectedIcon: Icon(Icons.report_problem), label: 'Concerns'),
          NavigationDestination(icon: Icon(Icons.phone_in_talk_outlined), selectedIcon: Icon(Icons.phone_in_talk), label: 'Directory'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
