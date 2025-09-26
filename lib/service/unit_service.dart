import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobilia/service/crud_service.dart';
import 'package:http/http.dart' as http;

class UnitService extends CrudService {
  UnitService({required super.baseUrl});

  Future<http.StreamedResponse> createUnit({
    required bool ativo,
    required bool cozinha,
    required bool areaServico,
    required String valorAluguel,
    required String areaTotal,
    String? bloco,
    String? complemento,
    required String identificacao,
    String? descricao,
    String? qtdSala,
    String? qtdQuarto,
    String? qtdBanheiro,
    String? qtdSuite,
    String? qtdGaragem,
    List<File>? imagens,
    required int imovel,
    required String status,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/unidade',
    );
    final request = http.MultipartRequest('POST', uri);

    // Campos do formulário
    request.fields['ativo'] = ativo.toString();
    request.fields['cozinha'] = cozinha.toString();
    request.fields['areaServico'] = areaServico.toString();
    request.fields['valorAluguel'] = valorAluguel;
    request.fields['areaTotal'] = areaTotal;
    request.fields['imovel'] = imovel.toString();
    request.fields['status'] = status;
    if (bloco != null) request.fields['bloco'] = bloco;
    if (complemento != null) request.fields['complemento'] = complemento;
    request.fields['identificacao'] = identificacao;
    if (descricao != null) request.fields['descricao'] = descricao;
    if (qtdSala != null) request.fields['qtdSala'] = qtdSala;
    if (qtdQuarto != null) request.fields['qtdQuarto'] = qtdQuarto;
    if (qtdBanheiro != null) request.fields['qtdBanheiro'] = qtdBanheiro;
    if (qtdSuite != null) request.fields['qtdSuite'] = qtdSuite;
    if (qtdGaragem != null) request.fields['qtdGaragem'] = qtdGaragem;

    debugPrint(request.fields['status']);
    // Adiciona imagens, se houver
    if (imagens != null) {
      for (var i = 0; i < imagens.length; i++) {
        final file = imagens[i];
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();

        final multipartFile = http.MultipartFile(
          'imagens',
          stream,
          length,
          filename: file.path.split('/').last,
        );

        request.files.add(multipartFile);
      }
    }

    return await request.send();
  }
}
