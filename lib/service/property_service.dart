// lib/services/property_service.dart
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
    List<Map<String, dynamic>>? imagensBytes,
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
    if (imagensBytes != null && imagensBytes.isNotEmpty) {
      for (var imageData in imagensBytes) {
        final bytes = imageData['bytes'] as List<int>;
        final fileName = imageData['fileName'] as String? ?? 'upload.jpg';
        
        // Determina o content type baseado na extensão do arquivo
        final contentType = _getContentType(fileName);
        
        final multipartFile = http.MultipartFile.fromBytes(
          'imagens',
          bytes,
          filename: fileName,
          contentType: contentType,
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
    List<Map<String, dynamic>>? imagensBytes,
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
    if (imagensBytes != null && imagensBytes.isNotEmpty) {
      for (var imageData in imagensBytes) {
        final bytes = imageData['bytes'] as List<int>;
        final fileName = imageData['fileName'] as String? ?? 'upload.jpg';
        
        // Determina o content type baseado na extensão do arquivo
        final contentType = _getContentType(fileName);
        
        final multipartFile = http.MultipartFile.fromBytes(
          'imagens',
          bytes,
          filename: fileName,
          contentType: contentType,
        );

        request.files.add(multipartFile);
      }
    }

    return await request.send();
  }

  /// Determina o content type baseado na extensão do arquivo
  MediaType _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }
}
