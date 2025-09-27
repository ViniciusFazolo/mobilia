import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobilia/domain/property.dart';
import 'package:mobilia/domain/unit.dart';
import 'package:mobilia/service/property_service.dart';
import 'package:mobilia/service/resident_service.dart';
import 'package:mobilia/service/unit_service.dart';
import 'package:mobilia/utils/date_format.dart';
import 'package:mobilia/utils/utils.dart';

class ResidentController {
  final formKey = GlobalKey<FormState>();
  List<Property> properties = [];
  List<Unit> units = [];
  bool isLoading = false;

  // ---- inicio campos do formulário ---
  // campos booleanos
  bool ativo = true;

  // campos texto
  final cpfController = TextEditingController();
  final emailController = TextEditingController();
  final nomeController = TextEditingController();
  final rgController = TextEditingController();
  final telefoneController = TextEditingController();

  // campos data
  final dtFimController = TextEditingController();
  final dtInicioController = TextEditingController();
  final dtVencimentoController = TextEditingController();

  // campos chave estrangeira
  int? imovelSelecionado;
  int? unidadeSelecionado;
  // ---- fim campos do formulário ---

  Future<void> submitForm(BuildContext context, VoidCallback refresh) async {
    if (!formKey.currentState!.validate()) return;

    final service = ResidentService(baseUrl: apiBaseUrl);

    _setLoading(refresh, true);

    final response = await service.post('morador', {
      'ativo': ativo,
      'nome': nomeController.text,
      'email': emailController.text,
      'telefone': telefoneController.text,
      'cpf': cpfController.text,
      'rg': rgController.text,
      'dtVencimento': formatDateToIso(dtVencimentoController.text),
      'dtInicio': formatDateToIso(dtInicioController.text),
      'dtFim': formatDateToIso(dtFimController.text),
      'unidade': unidadeSelecionado,
      'imovel': imovelSelecionado,
    });

    _setLoading(refresh, false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Morador cadastrado com sucesso!")),
      );
      _resetForm(refresh);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao cadastrar morador")),
      );
    }
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

  void _resetForm(VoidCallback refresh) {
    formKey.currentState?.reset();
    cpfController.clear();
    emailController.clear();
    nomeController.clear();
    rgController.clear();
    telefoneController.clear();
    dtFimController.clear();
    dtInicioController.clear();
    dtVencimentoController.clear();
    ativo = true;

    refresh();
  }
}
