import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobilia/domain/property.dart';
import 'package:mobilia/domain/resident.dart';
import 'package:mobilia/domain/unit.dart';
import 'package:mobilia/domain/user.dart';
import 'package:mobilia/pages/home.dart';
import 'package:mobilia/service/contract_service.dart';
import 'package:mobilia/service/property_service.dart';
import 'package:mobilia/service/resident_service.dart';
import 'package:mobilia/service/unit_service.dart';
import 'package:mobilia/service/user_service.dart';
import 'package:mobilia/utils/date_format.dart';
import 'package:mobilia/utils/prefs.dart';
import 'package:mobilia/utils/utils.dart';

class ContractController {
  final formKey = GlobalKey<FormState>();
  final cepController = TextEditingController();
  final ruaController = TextEditingController();
  final cidadeController = TextEditingController();
  final bairroController = TextEditingController();
  final numeroController = TextEditingController();
  final dtInicioController = TextEditingController();
  final dtFimController = TextEditingController();
  final dtVencimentoController = TextEditingController();
  final valorAluguelController = TextEditingController();
  final valorDepositoController = TextEditingController();
  String? estadoSelecionado;
  String? tipoLocacaoSelecionado;
  int imovelSelecionado = 0;
  int unidadeSelecionado = 0;
  int residenteSelecionado = 0;

  final List<Map<String, String>> tipoLocacao = [
    {'value': 'APARTAMENTO_RESIDENCIAL', 'label': 'Apartamento'},
    {'value': 'CASA_RESIDENCIAL', 'label': 'Casa'},
    {'value': 'PONTO_COMERCIAL', 'label': 'Ponto comercial'},
  ];
  bool isLoading = false;
  List<User> users = [];
  List<Morador> residents = [];
  List<Unit> units = [];
  List<Property> properties = [];

  submitForm(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading = true;

      final int userId = await Prefs.getInt("id");

      final contrato = {
        'dataInicio': dtInicioController.text.isNotEmpty
            ? formatDateToIso(dtInicioController.text)
            : null,
        'dataFim': dtFimController.text.isNotEmpty
            ? formatDateToIso(dtFimController.text)
            : null,
        'dataVencimento': dtVencimentoController.text.isNotEmpty
            ? formatDateToIso(dtVencimentoController.text)
            : null,
        'valorAluguel': double.tryParse(valorAluguelController.text),
        'valorDeposito': double.tryParse(valorDepositoController.text),
        'objLocacao': tipoLocacaoSelecionado,
        'endereco': ruaController.text,
        'cidade': cidadeController.text,
        'estado': estadoSelecionado,
        'cep': cepController.text,
        'bairro': bairroController.text,
        'rua': ruaController.text,
        'numero': int.tryParse(numeroController.text),
        'user': userId,
        'morador': residenteSelecionado,
        'unidade': unidadeSelecionado,
        'imovel': imovelSelecionado,
      };

      final service = ContractService(baseUrl: apiBaseUrl);
      final res = await service.post("contrato", contrato);

      if (res.statusCode == 201 || res.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Contrato criado com sucesso")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
        clearForm();
      } else {
        if(context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro ao criar contrato")),
          );
        }
      }
    } catch (e) {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao criar contrato")),
        );
      }
    } finally {
      isLoading = false;
    }
  }

  void clearForm() {
    cepController.clear();
    ruaController.clear();
    cidadeController.clear();
    bairroController.clear();
    numeroController.clear();
    dtInicioController.clear();
    dtFimController.clear();
    dtVencimentoController.clear();
    valorAluguelController.clear();
    valorDepositoController.clear();
    estadoSelecionado = null;
    tipoLocacaoSelecionado = null;
    imovelSelecionado = 0;
    unidadeSelecionado = 0;
    residenteSelecionado = 0;
  }

  fetchUsers() async {
    final service = UserService(baseUrl: apiBaseUrl);

    final res = await service.get("user");

    final List<dynamic> data = jsonDecode(res.body);
    users = data.map((e) => User.fromJson(e)).toList();
  }

  fetchResident() async {
    final service = ResidentService(baseUrl: apiBaseUrl);

    final res = await service.get("morador");
    final List<dynamic> data = jsonDecode(res.body);
    residents = data.map((e) => Morador.fromJson(e)).toList();
  }

  fetchUnit() async {
    final service = UnitService(baseUrl: apiBaseUrl);

    final res = await service.get("unidade");
    final List<dynamic> data = jsonDecode(res.body);
    units = data.map((e) => Unit.fromJson(e)).toList();
  }

  fetchProperty() async {
    final service = PropertyService(baseUrl: apiBaseUrl);

    final res = await service.get("imovel");
    final List<dynamic> data = jsonDecode(res.body);
    properties = data.map((e) => Property.fromJson(e)).toList();
  }
}
