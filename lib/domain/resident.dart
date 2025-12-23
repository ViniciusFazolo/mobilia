import 'package:mobilia/domain/property.dart';
import 'package:mobilia/domain/unit.dart';

class Morador {
  final int? id;
  final String nome;
  final String email;
  final String telefone;
  final String cpf;
  final String rg;
  final bool ativo;
  
  // Endereço
  final String? rua;
  final String? bairro;
  final String? cep;
  final String? cidade;
  final String? estado;

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
    this.ativo = true,
    this.rua,
    this.bairro,
    this.cep,
    this.cidade,
    this.estado,
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
      ativo: json['ativo'] ?? true,
      rua: json['rua'],
      bairro: json['bairro'],
      cep: json['cep'],
      cidade: json['cidade'],
      estado: json['estado'],
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
      'ativo': ativo,
      'rua': rua,
      'bairro': bairro,
      'cep': cep,
      'cidade': cidade,
      'estado': estado,
      'unidade': unidadeId ?? unidade?.id,
      'imovel': imovelId ?? imovel?.id,
    };
  }
}
