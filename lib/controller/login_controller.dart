import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mobilia/pages/home.dart';
import 'package:mobilia/utils/prefs.dart';

class LoginController {
  Future login(
    BuildContext context, {
    required String login,
    required String pw,
  }) async {
    Map<String, String> data = {'login': login, 'senha': pw};

    String body = json.encode(data);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/auth/login'),
        body: body,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final id = data['id'];
        final usuario = data['usuario'];
        final userRole = data['UserRole'];
        final token = data['token'];

        Prefs.setInt("id", id);
        Prefs.setString("usuario", usuario);
        Prefs.setString("userRole", userRole.toString());
        Prefs.setString("token", token);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login efetuado com sucesso")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Usuário ou senha inválidos"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao efetuar login, tente novamente mais tarde"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
