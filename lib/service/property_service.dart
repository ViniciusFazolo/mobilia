// lib/services/property_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobilia/service/crud_service.dart';
import 'package:mobilia/utils/prefs.dart';

class PropertyService extends CrudService {
  PropertyService({required super.baseUrl});

  /// Cria um imóvel com suporte a multipart (imagens)
  Future<http.StreamedResponse> createProperty({
    required bool ativo,
    required String nome,
    required String cep,
    required String estado,
    required String cidade,
    required String bairro,
    required String rua,
    String? numero,
    String? complemento,
    List<File>? imagens,
  }) async {
    final uri = Uri.parse('$baseUrl/imovel');
    final request = http.MultipartRequest('POST', uri);

    // Adiciona token de autenticação
    final token = await Prefs.getString("token");
    if (token.isNotEmpty) {
      request.headers["Authorization"] = "Bearer $token";
    }

    // Campos do formulário
    request.fields['ativo'] = ativo.toString();
    request.fields['nome'] = nome;
    request.fields['cep'] = cep;
    request.fields['estado'] = estado;
    request.fields['cidade'] = cidade;
    request.fields['bairro'] = bairro;
    request.fields['rua'] = rua;
    if (numero != null) request.fields['numero'] = numero;
    if (complemento != null) request.fields['complemento'] = complemento;

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

  /// Atualiza um imóvel com suporte a multipart (imagens)
  Future<http.StreamedResponse> updateProperty({
    required int id,
    required bool ativo,
    required String nome,
    required String cep,
    required String estado,
    required String cidade,
    required String bairro,
    required String rua,
    String? numero,
    String? complemento,
    List<File>? imagens,
  }) async {
    final uri = Uri.parse('$baseUrl/imovel/$id');
    final request = http.MultipartRequest('PUT', uri);

    // Adiciona token de autenticação
    final token = await Prefs.getString("token");
    if (token.isNotEmpty) {
      request.headers["Authorization"] = "Bearer $token";
    }

    // Campos do formulário
    request.fields['ativo'] = ativo.toString();
    request.fields['nome'] = nome;
    request.fields['cep'] = cep;
    request.fields['estado'] = estado;
    request.fields['cidade'] = cidade;
    request.fields['bairro'] = bairro;
    request.fields['rua'] = rua;
    if (numero != null) request.fields['numero'] = numero;
    if (complemento != null) request.fields['complemento'] = complemento;

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
