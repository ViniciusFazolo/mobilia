import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobilia/domain/property.dart';
import 'package:mobilia/domain/resident.dart';
import 'package:mobilia/domain/unit.dart';
import 'package:mobilia/domain/user.dart';
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
  final dtInicioController = TextEditingController();
  final dtFimController = TextEditingController();
  final dtVencimentoController = TextEditingController();
  final valorDepositoController = TextEditingController();
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
        'valorDeposito': double.tryParse(valorDepositoController.text),
        'objLocacao': tipoLocacaoSelecionado,
        'user': userId,
        'morador': residenteSelecionado,
      };

      final service = ContractService(baseUrl: apiBaseUrl);
      final res = await service.post("contrato", contrato);

      if (res.statusCode == 201 || res.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Contrato criado com sucesso")),
          );
          Navigator.pop(context, true); // Retorna para a página anterior
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
    dtInicioController.clear();
    dtFimController.clear();
    dtVencimentoController.clear();
    valorDepositoController.clear();
    tipoLocacaoSelecionado = null;
    imovelSelecionado = 0;
    unidadeSelecionado = 0;
    residenteSelecionado = 0;
  }

  fetchUsers() async {
    try {
      final service = UserService(baseUrl: apiBaseUrl);
      final res = await service.get("user");
      
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        users = data.map((e) => User.fromJson(e)).toList();
      } else {
        debugPrint("Erro ao buscar usuários: ${res.statusCode}");
        users = [];
      }
    } catch (e) {
      debugPrint("Erro ao buscar usuários: $e");
      users = [];
    }
  }

  fetchResident() async {
    try {
      final service = ResidentService(baseUrl: apiBaseUrl);
      final res = await service.get("morador");
      
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        residents = data.map((e) => Morador.fromJson(e)).toList();
        debugPrint("Moradores carregados: ${residents.length}");
      } else {
        debugPrint("Erro ao buscar moradores: ${res.statusCode}");
        residents = [];
      }
    } catch (e) {
      debugPrint("Erro ao buscar moradores: $e");
      residents = [];
    }
  }

  fetchUnit() async {
    try {
      final service = UnitService(baseUrl: apiBaseUrl);
      final res = await service.get("unidade");
      
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        units = data.map((e) => Unit.fromJson(e)).toList();
        debugPrint("Unidades carregadas: ${units.length}");
      } else {
        debugPrint("Erro ao buscar unidades: ${res.statusCode}");
        units = [];
      }
    } catch (e) {
      debugPrint("Erro ao buscar unidades: $e");
      units = [];
    }
  }

  fetchProperty() async {
    try {
      final service = PropertyService(baseUrl: apiBaseUrl);
      final res = await service.get("imovel");
      
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        properties = data.map((e) => Property.fromJson(e)).toList();
        debugPrint("Imóveis carregados: ${properties.length}");
      } else {
        debugPrint("Erro ao buscar imóveis: ${res.statusCode}");
        properties = [];
      }
    } catch (e) {
      debugPrint("Erro ao buscar imóveis: $e");
      properties = [];
    }
  }
}
