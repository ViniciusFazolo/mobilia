import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobilia/utils/prefs.dart';

abstract class CrudService {
  final String baseUrl;

  CrudService({required this.baseUrl});

  // GET genérico
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.get(url, headers: await _defaultHeaders());
  }

  // POST genérico
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.post(
      url,
      headers: await _defaultHeaders(),
      body: jsonEncode(data),
    );
  }

  // PUT genérico
  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.put(
      url,
      headers: await _defaultHeaders(),
      body: jsonEncode(data),
    );
  }

  // DELETE genérico
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.delete(url, headers: await _defaultHeaders());
  }

  Future<Map<String, String>> _defaultHeaders() async {
    final token = await Prefs.getString("token");
    final headers = <String, String>{
      "Content-Type": "application/json",
    };
    
    if (token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }
    
    return headers;
  }
}
