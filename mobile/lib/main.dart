import 'package:flutter/material.dart';
import 'auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/resident_shell.dart';
import 'screens/admin_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BarangayConnectApp());
}

class BarangayConnectApp extends StatelessWidget {
  const BarangayConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarangayConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const RootGate(),
    );
  }
}

class RootGate extends StatefulWidget {
  const RootGate({super.key});
  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  final _auth = AuthProvider();

  @override
  void initState() {
    super.initState();
    _auth.restoreSession().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => _auth.user == null
            ? LoginScreen(auth: _auth)
            : (_auth.isAdmin ? AdminShell(auth: _auth) : ResidentShell(auth: _auth)),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
