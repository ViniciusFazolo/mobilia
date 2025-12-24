import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class RegisterController {
  Future<bool> register(
    BuildContext context, {
    required String login,
    required String email,
    required String nome,
    required String pw,
    String? cpf,
    String? rg,
    String? endereco,
    String? numero,
    String? bairro,
    String? cidade,
    String? estado,
    String? cep,
    String? telefone,
  }) async {
    Map<String, dynamic> data = {
      'login': login,
      'email': email,
      'nome': nome,
      'pw': pw,
      'userRole': 1, // Sempre role 1 (ADMIN)
      'ativo': true,
      if (cpf != null && cpf.isNotEmpty) 'cpf': cpf,
      if (rg != null && rg.isNotEmpty) 'rg': rg,
      if (endereco != null && endereco.isNotEmpty) 'endereco': endereco,
      if (numero != null && numero.isNotEmpty) 'numero': numero,
      if (bairro != null && bairro.isNotEmpty) 'bairro': bairro,
      if (cidade != null && cidade.isNotEmpty) 'cidade': cidade,
      if (estado != null && estado.isNotEmpty) 'estado': estado,
      if (cep != null && cep.isNotEmpty) 'cep': cep,
      if (telefone != null && telefone.isNotEmpty) 'telefone': telefone,
    };

    String body = json.encode(data);

    try {
      final url = Platform.isAndroid
          ? "http://10.0.2.2:8080/auth/register"
          : "https://aluguei-app-production.up.railway.app/auth/register";

      final response = await http.post(
        Uri.parse(url),
        body: body,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Usuário registrado com sucesso!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 
                            errorData['error'] ?? 
                            "Erro ao registrar usuário";
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao registrar usuário: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}

