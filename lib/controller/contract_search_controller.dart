import 'dart:convert';

import 'package:mobilia/domain/contract.dart';
import 'package:mobilia/domain/resident.dart';
import 'package:mobilia/service/contract_service.dart';
import 'package:mobilia/service/resident_service.dart';
import 'package:mobilia/utils/utils.dart';

class ContractSearchController {
  Future<List<Morador>> getResidents() async {
    final ResidentService service = ResidentService(baseUrl: apiBaseUrl);

    final res = await service.get("morador");

    if (res.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(res.body);
      return jsonList.map((e) => Morador.fromJson(e)).toList();
    }

    return [];
  }

  Future<List<Contrato>> getContractsByResidentId(int? id) async {
    final ContractService service = ContractService(baseUrl: apiBaseUrl);

    final res = await service.get("contrato/byMoradorId/$id");

    if (res.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(res.body);
      return jsonList.map((e) => Contrato.fromJson(e)).toList();
    }

    return [];
  }
}
