import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class CrudService {
  final String baseUrl;

  CrudService({required this.baseUrl});

  // GET genérico
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.get(url, headers: _defaultHeaders());
  }

  // POST genérico
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.post(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(data),
    );
  }

  // PUT genérico
  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.put(
      url,
      headers: _defaultHeaders(),
      body: jsonEncode(data),
    );
  }

  // DELETE genérico
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.delete(url, headers: _defaultHeaders());
  }

  Map<String, String> _defaultHeaders() {
    return {"Content-Type": "application/json"};
  }
}
