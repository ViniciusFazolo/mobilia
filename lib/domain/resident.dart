import 'package:mobilia/domain/property.dart';
import 'package:mobilia/domain/unit.dart';

class Morador {
  final int? id;
  final String nome;
  final String email;
  final String telefone;
  final String cpf;
  final String rg;
  final DateTime? dtNascimento;
  final bool ativo;
  final DateTime? dtVencimento;
  final DateTime? dtInicio;
  final DateTime? dtFim;

  // Relações
  final int? unidadeId;    // usado no request
  final Unit? unidade;  // usado no response

  final int? imovelId;     // usado no request
  final Property? imovel;    // usado no response

  Morador({
    this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cpf,
    required this.rg,
    this.dtNascimento,
    this.ativo = true,
    this.dtVencimento,
    this.dtInicio,
    this.dtFim,
    this.unidadeId,
    this.unidade,
    this.imovelId,
    this.imovel,
  });

  /// Construtor a partir de JSON (response)
  factory Morador.fromJson(Map<String, dynamic> json) {
    return Morador(
      id: json['id'],
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'] ?? '',
      cpf: json['cpf'] ?? '',
      rg: json['rg'] ?? '',
      dtNascimento: json['dtNascimento'] != null
          ? DateTime.parse(json['dtNascimento'])
          : null,
      ativo: json['ativo'] ?? true,
      dtVencimento: json['dtVencimento'] != null
          ? DateTime.parse(json['dtVencimento'])
          : null,
      dtInicio: json['dtInicio'] != null
          ? DateTime.parse(json['dtInicio'])
          : null,
      dtFim: json['dtFim'] != null
          ? DateTime.parse(json['dtFim'])
          : null,
      unidade: json['unidade'] != null ? Unit.fromJson(json['unidade']) : null,
      imovel: json['imovel'] != null ? Property.fromJson(json['imovel']) : null,
    );
  }

  /// Converter para JSON (request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cpf': cpf,
      'rg': rg,
      'dtNascimento': dtNascimento?.toIso8601String(),
      'ativo': ativo,
      'dtVencimento': dtVencimento?.toIso8601String(),
      'dtInicio': dtInicio?.toIso8601String(),
      'dtFim': dtFim?.toIso8601String(),
      'unidade': unidadeId ?? unidade?.id,
      'imovel': imovelId ?? imovel?.id,
    };
  }
}
