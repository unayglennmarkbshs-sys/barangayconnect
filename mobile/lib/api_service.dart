import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ApiService {
  static const String base = kBaseUrl;
  String? _token;
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  void setToken(String? token) => _token = token;
  String? get token => _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String path) async {
    return _handle(await http.get(Uri.parse('$base$path'), headers: _headers));
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    return _handle(await http.post(Uri.parse('$base$path'),
        headers: _headers, body: jsonEncode(body)));
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    return _handle(await http.put(Uri.parse('$base$path'),
        headers: _headers, body: jsonEncode(body)));
  }

  Future<dynamic> delete(String path) async {
    return _handle(await http.delete(Uri.parse('$base$path'), headers: _headers));
  }

  Future<dynamic> uploadFile(String path, File file) async {
    final req = http.MultipartRequest('POST', Uri.parse('$base$path'))
      ..headers['Authorization'] = 'Bearer $_token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    final data = res.body.isEmpty ? {} : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw ApiException(
        data['message'] ?? 'Request failed (${res.statusCode})', res.statusCode);
  }
}
