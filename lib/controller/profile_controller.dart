import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mobilia/domain/user.dart';
import 'package:mobilia/utils/prefs.dart';

class ProfileController {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  
  // Controllers
  final loginController = TextEditingController();
  final emailController = TextEditingController();
  final nomeController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();
  final cpfController = TextEditingController();
  final rgController = TextEditingController();
  final enderecoController = TextEditingController();
  final numeroController = TextEditingController();
  final bairroController = TextEditingController();
  final cidadeController = TextEditingController();
  final cepController = TextEditingController();
  final telefoneController = TextEditingController();
  
  String? estadoSelecionado;
  int? userId;

  Future<void> loadUserData() async {
    try {
      isLoading = true;
      userId = await Prefs.getInt("id");
      
      if (userId == null) {
        debugPrint("ID do usuário não encontrado");
        return;
      }

      final url = Platform.isAndroid
          ? "http://10.0.2.2:8080/api/user/$userId"
          : "https://aluguei-app-production.up.railway.app/api/user/$userId";
      
      final token = await Prefs.getString("token");
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
        
        // Preenche os controllers com os dados do usuário
        loginController.text = user.login ?? '';
        emailController.text = user.email ?? '';
        nomeController.text = user.nome ?? '';
        cpfController.text = user.cpf ?? '';
        rgController.text = user.rg ?? '';
        enderecoController.text = user.endereco ?? '';
        numeroController.text = user.numero ?? '';
        bairroController.text = user.bairro ?? '';
        cidadeController.text = user.cidade ?? '';
        cepController.text = user.cep ?? '';
        telefoneController.text = user.telefone ?? '';
        estadoSelecionado = user.estado;
        
        // Senha não é carregada por segurança
        pwController.clear();
        confirmPwController.clear();
      } else {
        debugPrint("Erro ao carregar dados do usuário: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados do usuário: $e");
    } finally {
      isLoading = false;
    }
  }

  Future<bool> updateProfile(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    try {
      isLoading = true;
      userId = await Prefs.getInt("id");
      
      if (userId == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("ID do usuário não encontrado"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }

      final cpfDigits = cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
      final telefoneDigits = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      final cepDigits = cepController.text.replaceAll(RegExp(r'[^\d]'), '');

      Map<String, dynamic> data = {
        'id': userId, // Adiciona o ID no body
        'login': loginController.text,
        'email': emailController.text,
        'nome': nomeController.text,
        'ativo': true, // Adiciona o campo ativo
        if (cpfDigits.isNotEmpty) 'cpf': cpfDigits,
        if (rgController.text.isNotEmpty) 'rg': rgController.text,
        if (enderecoController.text.isNotEmpty) 'endereco': enderecoController.text,
        if (numeroController.text.isNotEmpty) 'numero': numeroController.text,
        if (bairroController.text.isNotEmpty) 'bairro': bairroController.text,
        if (cidadeController.text.isNotEmpty) 'cidade': cidadeController.text,
        if (estadoSelecionado != null && estadoSelecionado!.isNotEmpty) 'estado': estadoSelecionado,
        if (cepDigits.isNotEmpty) 'cep': cepDigits,
        if (telefoneDigits.isNotEmpty) 'telefone': telefoneDigits,
      };

      // Se a senha foi preenchida, adiciona ao payload
      if (pwController.text.isNotEmpty) {
        data['pw'] = pwController.text;
      }

      String body = json.encode(data);

      // CORREÇÃO: URL correta para atualizar usuário
      final url = Platform.isAndroid
          ? "http://10.0.2.2:8080/api/user/$userId"
          : "https://aluguei-app-production.up.railway.app/api/user/$userId";

      final token = await Prefs.getString("token");
      final response = await http.put(
        Uri.parse(url),
        body: body,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Perfil atualizado com sucesso!"),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } else {
        String errorMessage = "Erro ao atualizar perfil";
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 
                        errorData['error'] ?? 
                        "Erro ao atualizar perfil";
        } catch (e) {
          errorMessage = "Erro ${response.statusCode}: ${response.body}";
        }
        
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
            content: Text("Erro ao atualizar perfil: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      isLoading = false;
    }
  }

  void dispose() {
    loginController.dispose();
    emailController.dispose();
    nomeController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    cpfController.dispose();
    rgController.dispose();
    enderecoController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    cepController.dispose();
    telefoneController.dispose();
  }
}

