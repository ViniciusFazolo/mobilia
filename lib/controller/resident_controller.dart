import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobilia/domain/property.dart';
import 'package:mobilia/domain/unit.dart';
import 'package:mobilia/service/property_service.dart';
import 'package:mobilia/service/resident_service.dart';
import 'package:mobilia/service/unit_service.dart';
import 'package:mobilia/domain/resident.dart';
import 'package:mobilia/utils/textInputFormatter.dart';
import 'package:mobilia/utils/utils.dart';

class ResidentController {
  final formKey = GlobalKey<FormState>();
  List<Property> properties = [];
  List<Unit> units = [];
  bool isLoading = false;
  int? editingId; // ID do item sendo editado

  // ---- inicio campos do formulário ---
  // campos booleanos
  bool ativo = true;

  // campos texto
  final cpfController = TextEditingController();
  final emailController = TextEditingController();
  final nomeController = TextEditingController();
  final rgController = TextEditingController();
  final telefoneController = TextEditingController();
  
  // campos endereço
  final ruaController = TextEditingController();
  final bairroController = TextEditingController();
  final cepController = TextEditingController();
  final cidadeController = TextEditingController();
  String? estadoSelecionado;

  // campos chave estrangeira
  int? imovelSelecionado;
  int? unidadeSelecionado;
  // ---- fim campos do formulário ---

  Future<bool> submitForm(BuildContext context, VoidCallback refresh) async {
    if (!formKey.currentState!.validate()) return false;

    final service = ResidentService(baseUrl: apiBaseUrl);

    _setLoading(refresh, true);

    // Remove máscaras dos campos antes de enviar
    final telefoneDigits = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    final cpfDigits = cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
    
    final data = {
      'ativo': ativo,
      'nome': nomeController.text,
      'email': emailController.text,
      'telefone': telefoneDigits,
      'cpf': cpfDigits,
      'rg': rgController.text,
      'rua': ruaController.text.isNotEmpty ? ruaController.text : null,
      'bairro': bairroController.text.isNotEmpty ? bairroController.text : null,
      'cep': cepController.text.isNotEmpty ? cepController.text.replaceAll(RegExp(r'[^\d]'), '') : null,
      'cidade': cidadeController.text.isNotEmpty ? cidadeController.text : null,
      'estado': estadoSelecionado,
      'unidade': unidadeSelecionado,
    };
    
    debugPrint('=== Resident Submit ===');
    debugPrint('editingId: $editingId');
    debugPrint('isEdit: ${editingId != null}');
    debugPrint('Enviando dados para ${editingId != null ? "PUT" : "POST"}: $data');
    debugPrint('URL: ${editingId != null ? "morador/$editingId" : "morador"}');

    final response = editingId != null
        ? await service.put('morador/$editingId', data)
        : await service.post('morador', data);

    _setLoading(refresh, false);

    debugPrint('Resposta do servidor: ${response.statusCode}');
    debugPrint('Body da resposta: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(editingId != null
              ? "Morador atualizado com sucesso!"
              : "Morador cadastrado com sucesso!"),
        ),
      );
      // Não reseta mais o formulário, pois vamos voltar para a listagem
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(editingId != null
              ? "Erro ao atualizar morador (${response.statusCode})"
              : "Erro ao cadastrar morador (${response.statusCode})"),
        ),
      );
      return false;
    }
  }

  void loadForEdit(Morador morador) {
    editingId = morador.id;
    debugPrint('Carregando morador para edição - ID: $editingId');
    ativo = morador.ativo;
    nomeController.text = morador.nome;
    emailController.text = morador.email;
    
    // Aplica a máscara de telefone se o valor vier sem máscara
    final telefoneValue = morador.telefone;
    if (telefoneValue.isNotEmpty) {
      // Remove caracteres não numéricos para aplicar a máscara
      final telefoneDigits = telefoneValue.replaceAll(RegExp(r'[^\d]'), '');
      telefoneController.text = applyTelefoneMask(telefoneDigits);
    } else {
      telefoneController.text = '';
    }
    
    // Aplica a máscara de CPF se o valor vier sem máscara
    final cpfValue = morador.cpf;
    if (cpfValue.isNotEmpty) {
      // Remove caracteres não numéricos para aplicar a máscara
      final cpfDigits = cpfValue.replaceAll(RegExp(r'[^\d]'), '');
      cpfController.text = applyCpfMask(cpfDigits);
    } else {
      cpfController.text = '';
    }
    
    rgController.text = morador.rg;
    ruaController.text = morador.rua ?? '';
    bairroController.text = morador.bairro ?? '';
    cepController.text = morador.cep ?? '';
    cidadeController.text = morador.cidade ?? '';
    estadoSelecionado = morador.estado;
    unidadeSelecionado = morador.unidade?.id ?? morador.unidadeId;
  }

  Future<void> fetchProperty(BuildContext context, VoidCallback refresh) async {
    final propertyService = PropertyService(baseUrl: apiBaseUrl);
    final response = await propertyService.get("imovel");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      properties = data.map((e) => Property.fromJson(e)).toList();
    } else {
      properties = [];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao buscar imóveis (${response.statusCode})"),
        ),
      );
    }

    refresh();
  }

  Future<void> fetchUnit(BuildContext context, VoidCallback refresh) async {
    final unitService = UnitService(baseUrl: apiBaseUrl);
    final response = await unitService.get("unidade");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      units = data.map((e) => Unit.fromJson(e)).toList();
    } else {
      units = [];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao buscar unidades (${response.statusCode})"),
        ),
      );
    }

    refresh();
  }

  void _setLoading(VoidCallback refresh, bool value) {
    isLoading = value;
    refresh();
  }

}
