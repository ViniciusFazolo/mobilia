import 'dart:io';

class Property {
  final int? id;
  final String nome;
  final String cep;
  final String estado;
  final String cidade;
  final String bairro;
  final String rua;
  final int? numero;
  final String? complemento;
  final String? imagem;
  final List<String>? imagens; // Lista de imagens do backend
  final bool ativo;
  final DateTime? dtCadastro;

  Property({
    this.id,
    required this.nome,
    required this.cep,
    required this.estado,
    required this.cidade,
    required this.bairro,
    required this.rua,
    this.numero,
    this.complemento,
    this.imagem,
    this.imagens,
    required this.ativo,
    this.dtCadastro,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'cep': cep,
      'estado': estado,
      'cidade': cidade,
      'bairro': bairro,
      'rua': rua,
      if (numero != null) 'numero': numero,
      if (complemento != null) 'complemento': complemento,
      if (imagem != null) 'imagem': imagem,
      'ativo': ativo,
      if (dtCadastro != null) 'dtCadastro': dtCadastro!.toIso8601String(),
    };
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    // Debug: verifica o que está vindo no JSON
    print('DEBUG Property.fromJson - JSON completo: $json');
    print('DEBUG Property.fromJson - Chaves do JSON: ${json.keys.toList()}');
    
    if (json.containsKey('imagens')) {
      print('DEBUG Property.fromJson - imagens no JSON: ${json['imagens']} (tipo: ${json['imagens'].runtimeType})');
      print('DEBUG Property.fromJson - imagens é null? ${json['imagens'] == null}');
      print('DEBUG Property.fromJson - imagens é empty? ${json['imagens']?.toString().isEmpty}');
    } else {
      print('DEBUG Property.fromJson - campo "imagens" NÃO existe no JSON');
    }
    
    if (json.containsKey('imagem')) {
      print('DEBUG Property.fromJson - imagem no JSON: ${json['imagem']} (tipo: ${json['imagem'].runtimeType})');
    } else {
      print('DEBUG Property.fromJson - campo "imagem" NÃO existe no JSON');
    }
    
    // Processa as imagens (campo "imagens" é uma String única, não uma lista)
    String? imagemValue;
    List<String>? imagensList;
    
    // Tenta pegar do campo "imagens" primeiro (nome do campo no DTO)
    // Verifica se não é null e se não é a string "null"
    String? urlValue;
    if (json['imagens'] != null && 
        json['imagens'].toString().trim().isNotEmpty && 
        json['imagens'].toString().toLowerCase() != 'null') {
      urlValue = json['imagens'].toString().trim();
    } 
    // Fallback para o campo "imagem" (singular - nome do campo no banco)
    else if (json['imagem'] != null && 
             json['imagem'].toString().trim().isNotEmpty && 
             json['imagem'].toString().toLowerCase() != 'null') {
      urlValue = json['imagem'].toString().trim();
    }
    
    if (urlValue != null && urlValue.isNotEmpty) {
      // Se a URL não começa com http, adiciona o baseUrl
      if (!urlValue.startsWith('http')) {
        final cleanUrl = urlValue.startsWith('/') ? urlValue.substring(1) : urlValue;
        final baseUrl = Platform.isAndroid ? "http://10.0.2.2:8080" : 'http://localhost:8080';
        imagemValue = '$baseUrl/$cleanUrl';
      } else {
        imagemValue = urlValue;
      }
      imagensList = [imagemValue];
    }
    
    print('DEBUG Property.fromJson - imagemValue final: $imagemValue');
    print('DEBUG Property.fromJson - imagensList final: $imagensList');
    
    return Property(
      id: json['id'],
      nome: json['nome'] ?? '',
      cep: json['cep'] ?? '',
      estado: json['estado'] ?? '',
      cidade: json['cidade'] ?? '',
      bairro: json['bairro'] ?? '',
      rua: json['rua'] ?? '',
      numero: json['numero'],
      complemento: json['complemento'],
      imagem: imagemValue,
      imagens: imagensList,
      ativo: json['ativo'] == true || json['ativo'] == "true",
      dtCadastro: json['dtCadastro'] != null
          ? DateTime.tryParse(json['dtCadastro'])
          : null,
    );
  }
}
