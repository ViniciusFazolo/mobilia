import 'dart:io';

import 'package:mobilia/pages/property.dart';

class Unit {
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
  final List<File> imagens;
  final Property imovel;

  Unit({
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
    this.imagens = const [],
    required this.imovel,
  });

  Map<String, String> toMap() {
    return {
      'ativo': ativo.toString(),
      'cozinha': cozinha.toString(),
      'areaServico': areaServico.toString(),
      'valorAluguel': valorAluguel,
      'areaTotal': areaTotal,
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

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      ativo: json['ativo'] == true || json['ativo'] == "true",
      cozinha: json['cozinha'] == true || json['cozinha'] == "true",
      areaServico: json['areaServico'] == true || json['areaServico'] == "true",
      valorAluguel: json['valorAluguel']?.toString() ?? '',
      areaTotal: json['areaTotal']?.toString() ?? '',
      bloco: json['bloco'],
      complemento: json['complemento'],
      identificacao: json['identificacao'] ?? '',
      descricao: json['descricao'],
      qtdSala: json['qtdSala']?.toString(),
      qtdQuarto: json['qtdQuarto']?.toString(),
      qtdBanheiro: json['qtdBanheiro']?.toString(),
      qtdSuite: json['qtdSuite']?.toString(),
      qtdGaragem: json['qtdGaragem']?.toString(),
      imagens: [], // imagens não vêm direto do JSON
      imovel: json['imovel'],
    );
  }
}
