import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'models.dart';

class AuthProvider extends ChangeNotifier {
  User? user;
  bool loading = false;
  bool initialized = false;

  final _api = ApiService();

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('bc_token');
    final saved = prefs.getString('bc_user');
    if (token != null && saved != null) {
      _api.setToken(token);
      try {
        user = User.fromJson(jsonDecode(saved) as Map<String, dynamic>);
      } catch (_) {
        user = null;
      }
    }
    initialized = true;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    loading = true; notifyListeners();
    try {
      final data = await _api.post('/api/auth/login', {'email': email, 'password': password});
      await _saveSession(data);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      loading = false; notifyListeners();
    }
  }

  Future<String?> register(Map<String, dynamic> payload) async {
    loading = true; notifyListeners();
    try {
      final data = await _api.post('/api/auth/register', payload);
      await _saveSession(data);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      loading = false; notifyListeners();
    }
  }

  Future<void> _saveSession(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bc_token', data['token']);
    await prefs.setString('bc_user', jsonEncode(data['user']));
    _api.setToken(data['token']);
    user = User.fromJson(data['user']);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bc_token');
    await prefs.remove('bc_user');
    _api.setToken(null);
    user = null;
    notifyListeners();
  }

  bool get isAdmin => user?.role == 'admin' || user?.role == 'official';
}
