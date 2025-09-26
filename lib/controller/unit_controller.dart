import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobilia/domain/property.dart';
import 'package:mobilia/service/property_service.dart';
import 'package:mobilia/service/unit_service.dart';
import 'package:mobilia/utils/utils.dart';

class UnitController {
  final formKey = GlobalKey<FormState>();
  List<Property> properties = [];
  final List<Map<String, String>> statusOptions = [
    {'value': 'OCUPADA', 'label': 'Ocupada'},
    {'value': 'VAZIA', 'label': 'Vazia'},
  ];

  // estados booleanos
  bool isActive = true;
  bool cozinha = true;
  bool areaServico = true;
  bool isLoading = false;

  // controllers
  final valorAluguelController = TextEditingController();
  final areaTotalController = TextEditingController();
  final blocoController = TextEditingController();
  final complementoController = TextEditingController();
  final identificacaoController = TextEditingController();
  final descricaoController = TextEditingController();
  final numeroController = TextEditingController();
  final qtdSalaController = TextEditingController();
  final qtdQuartoController = TextEditingController();
  final qtdBanheiroController = TextEditingController();
  final qtdGaragemController = TextEditingController();
  final qtdSuiteController = TextEditingController();
  String statusSelecionado = "";
  int imovelSelecionado = 0;
  List<File> imagens = [];

  Future<void> submitForm(BuildContext context, VoidCallback refresh) async {
    if (!formKey.currentState!.validate()) return;

    final service = UnitService(baseUrl: apiBaseUrl);

    _setLoading(refresh, true);

    final response = await service.createUnit(
      ativo: isActive,
      cozinha: cozinha,
      areaServico: areaServico,
      valorAluguel: valorAluguelController.text,
      areaTotal: areaTotalController.text,
      bloco: blocoController.text,
      complemento: complementoController.text,
      identificacao: identificacaoController.text,
      descricao: descricaoController.text,
      qtdSala: qtdSalaController.text,
      qtdQuarto: qtdQuartoController.text,
      qtdBanheiro: qtdBanheiroController.text,
      qtdSuite: qtdSuiteController.text,
      qtdGaragem: qtdGaragemController.text,
      imagens: imagens,
      imovel: imovelSelecionado,
      status: statusSelecionado,
    );

    _setLoading(refresh, false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unidade cadastrada com sucesso!")),
      );
      _resetForm(refresh);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao cadastrar unidade")),
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

  void _setLoading(VoidCallback refresh, bool value) {
    isLoading = value;
    refresh();
  }

  void _resetForm(VoidCallback refresh) {
    formKey.currentState?.reset();
    valorAluguelController.clear();
    areaTotalController.clear();
    blocoController.clear();
    complementoController.clear();
    identificacaoController.clear();
    descricaoController.clear();
    numeroController.clear();
    qtdSalaController.clear();
    qtdQuartoController.clear();
    qtdBanheiroController.clear();
    qtdSuiteController.clear();
    qtdGaragemController.clear();

    isActive = true;
    cozinha = true;
    areaServico = true;

    refresh();
  }
}
