import 'dart:io';

import 'package:mobilia/domain/property.dart';

class Unit {
  final int? id;
  final bool ativo;
  final bool cozinha;
  final bool areaServico;
  final String valorAluguel;
  final String areaTotal;
  final String? bloco;
  final String? complemento;
  final String identificacao;
  final String? descricao;
  final String? qtdSala;
  final String? qtdQuarto;
  final String? qtdBanheiro;
  final String? qtdSuite;
  final String? qtdGaragem;
  final String? status;
  final List<File> imagens; // Para upload (Files locais)
  final List<String>? imagensUrls; // URLs das imagens do backend
  final Property? imovel;

  Unit({
    this.id,
    required this.ativo,
    required this.cozinha,
    required this.areaServico,
    required this.valorAluguel,
    required this.areaTotal,
    this.bloco,
    this.complemento,
    required this.identificacao,
    this.descricao,
    this.qtdSala,
    this.qtdQuarto,
    this.qtdBanheiro,
    this.qtdSuite,
    this.qtdGaragem,
    this.status,
    this.imagens = const [],
    this.imagensUrls,
    required this.imovel,
  });

  Map<String, String> toMap() {
    return {
      'ativo': ativo.toString(),
      'cozinha': cozinha.toString(),
      'areaServico': areaServico.toString(),
      'valorAluguel': valorAluguel,
      'areaTotal': areaTotal,
      if(id != null) 'id': id.toString(),
      if (bloco != null) 'bloco': bloco!,
      if (complemento != null) 'complemento': complemento!,
      'identificacao': identificacao,
      if (descricao != null) 'descricao': descricao!,
      if (qtdSala != null) 'qtdSala': qtdSala!,
      if (qtdQuarto != null) 'qtdQuarto': qtdQuarto!,
      if (qtdBanheiro != null) 'qtdBanheiro': qtdBanheiro!,
      if (qtdSuite != null) 'qtdSuite': qtdSuite!,
      if (qtdGaragem != null) 'qtdGaragem': qtdGaragem!,
    };
  }

  static List<String>? _parseImagensUrls(dynamic imagensValue) {
    print('DEBUG _parseImagensUrls - entrada: $imagensValue (tipo: ${imagensValue?.runtimeType})');
    
    if (imagensValue == null) {
      print('DEBUG _parseImagensUrls - imagensValue é null, retornando null');
      return null;
    }
    
    // Se é uma lista de strings (URLs)
    if (imagensValue is List) {
      print('DEBUG _parseImagensUrls - é List com ${imagensValue.length} itens');
      final urls = imagensValue
          .map((e) {
            final url = e.toString().trim();
            print('DEBUG _parseImagensUrls - processando item: "$url"');
            if (url.isEmpty || url.toLowerCase() == 'null') {
              print('DEBUG _parseImagensUrls - item vazio ou null, ignorando');
              return null;
            }
            // Se a URL não começa com http, adiciona o baseUrl
            if (!url.startsWith('http')) {
              final cleanUrl = url.startsWith('/') ? url.substring(1) : url;
              final baseUrl = Platform.isAndroid ? "http://10.0.2.2:8080" : 'http://localhost:8080';
              final finalUrl = '$baseUrl/$cleanUrl';
              print('DEBUG _parseImagensUrls - URL relativa convertida: "$finalUrl"');
              return finalUrl;
            }
            print('DEBUG _parseImagensUrls - URL absoluta mantida: "$url"');
            return url;
          })
          .where((url) => url != null)
          .cast<String>()
          .toList();
      
      print('DEBUG _parseImagensUrls - URLs finais: $urls');
      return urls.isNotEmpty ? urls : null;
    }
    
    // Se é uma string única, converte para lista
    if (imagensValue is String) {
      final url = imagensValue.trim();
      print('DEBUG _parseImagensUrls - é String: "$url"');
      if (url.isNotEmpty && url.toLowerCase() != 'null') {
        if (!url.startsWith('http')) {
          final cleanUrl = url.startsWith('/') ? url.substring(1) : url;
          final baseUrl = Platform.isAndroid ? "http://10.0.2.2:8080" : 'http://localhost:8080';
          final finalUrl = '$baseUrl/$cleanUrl';
          print('DEBUG _parseImagensUrls - String convertida para lista: [$finalUrl]');
          return [finalUrl];
        }
        print('DEBUG _parseImagensUrls - String absoluta convertida para lista: [$url]');
        return [url];
      }
    }
    
    print('DEBUG _parseImagensUrls - tipo não reconhecido, retornando null');
    return null;
  }

  static String? _parseStatus(dynamic statusValue) {
    print('DEBUG _parseStatus - entrada: $statusValue (tipo: ${statusValue?.runtimeType})');
    
    if (statusValue == null) {
      print('DEBUG _parseStatus - statusValue é null, retornando null');
      return null;
    }
    
    // Se já é uma string, retorna diretamente
    if (statusValue is String) {
      final result = statusValue.trim();
      print('DEBUG _parseStatus - é String, retornando: "$result"');
      return result;
    }
    
    // Se é um Map (objeto JSON), tenta extrair o valor
    if (statusValue is Map) {
      print('DEBUG _parseStatus - é Map, tentando extrair valor');
      // Pode vir como {"name": "OCUPADA"} ou similar
      if (statusValue.containsKey('name')) {
        final result = statusValue['name']?.toString().trim();
        print('DEBUG _parseStatus - encontrou "name", retornando: "$result"');
        return result;
      }
      if (statusValue.containsKey('value')) {
        final result = statusValue['value']?.toString().trim();
        print('DEBUG _parseStatus - encontrou "value", retornando: "$result"');
        return result;
      }
      // Se não tiver essas chaves, tenta pegar o primeiro valor string
      for (var value in statusValue.values) {
        if (value is String) {
          final result = value.trim();
          print('DEBUG _parseStatus - encontrou string no Map, retornando: "$result"');
          return result;
        }
      }
    }
    
    // Por último, tenta converter para string
    final result = statusValue.toString().trim();
    print('DEBUG _parseStatus - convertendo para string, retornando: "$result"');
    return result;
  }

  factory Unit.fromJson(Map<String, dynamic> json) {
    // Debug: verifica o que está vindo no JSON
    print('DEBUG Unit.fromJson - JSON completo: $json');
    print('DEBUG Unit.fromJson - Chaves do JSON: ${json.keys.toList()}');
    
    if (json.containsKey('status')) {
      print('DEBUG Unit.fromJson - status no JSON: ${json['status']} (tipo: ${json['status'].runtimeType})');
    } else {
      print('DEBUG Unit.fromJson - campo status NÃO existe no JSON');
    }
    
    if (json.containsKey('imagens')) {
      print('DEBUG Unit.fromJson - imagens no JSON: ${json['imagens']} (tipo: ${json['imagens'].runtimeType})');
      print('DEBUG Unit.fromJson - imagens é null? ${json['imagens'] == null}');
      if (json['imagens'] is List) {
        print('DEBUG Unit.fromJson - imagens é List com ${(json['imagens'] as List).length} itens');
      }
    } else {
      print('DEBUG Unit.fromJson - campo "imagens" NÃO existe no JSON');
    }
    
    return Unit(
      ativo: json['ativo'] == true || json['ativo'] == "true",
      cozinha: json['cozinha'] == true || json['cozinha'] == "true",
      areaServico: json['areaServico'] == true || json['areaServico'] == "true",
      valorAluguel: json['valorAluguel']?.toString() ?? '',
      areaTotal: json['areaTotal']?.toString() ?? '',
      bloco: json['bloco'],
      complemento: json['complemento'],
      identificacao: json['identificacao'] ?? '',
      id: json['id'],
      descricao: json['descricao'],
      qtdSala: json['qtdSala']?.toString(),
      qtdQuarto: json['qtdQuarto']?.toString(),
      qtdBanheiro: json['qtdBanheiro']?.toString(),
      qtdSuite: json['qtdSuite']?.toString(),
      qtdGaragem: json['qtdGaragem']?.toString(),
      status: _parseStatus(json['status']),
      imagens: [], // Files locais (vazio ao carregar do JSON)
      imagensUrls: _parseImagensUrls(json['imagens']), // Parse das URLs das imagens do JSON
      imovel: json['imovel'] != null ? Property.fromJson(json['imovel']) : null,
    );
  }
  
  @override
  String toString() {
    return 'Unit(id: $id, identificacao: $identificacao, imagensUrls: $imagensUrls)';
  }
}
