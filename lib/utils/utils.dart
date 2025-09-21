// lib/utils.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final String apiBaseUrl = "http://localhost:8080/api";

Future<Map<String, String>?> findCep(String cep) async {
  if (cep.isEmpty) return null;

  final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    debugPrint(response.body);
    final data = json.decode(response.body);
    return {
      'cidade': data['localidade'] ?? '',
      'bairro': data['bairro'] ?? '',
      'rua': data['logradouro'] ?? '',
      'estado': data['uf'] ?? '',
    };
  } else {
    return null;
  }
}
