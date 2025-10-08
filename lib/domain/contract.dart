import 'package:flutter/foundation.dart';
import 'package:mobilia/domain/property.dart';
import 'package:mobilia/domain/resident.dart';
import 'package:mobilia/domain/unit.dart';
import 'package:mobilia/domain/user.dart';

enum ObjetoLocacao {
  CASA_RESIDENCIAL,
  APARTAMENTO_RESIDENCIAL,
  PONTO_COMERCIAL,
}

class Contrato {
  final int? id;

  // Dados do contrato
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final DateTime? dataVencimento;
  final double? valorAluguel;
  final double? valorDeposito;
  final bool? status;

  // Objeto da locação
  final ObjetoLocacao? objLocacao;
  final int? qtd;
  final String? endereco;
  final String? cidade;
  final String? estado;
  final String? cep;
  final String? bairro;
  final String? rua;
  final int? numero;

  // Relações
  final User? user;
  final Morador? morador;
  final Unit? unidade;
  final Property? imovel;

  // Controle
  final DateTime? dtCadastro;
  final String? pdfContrato;

  const Contrato({
    this.id,
    this.dataInicio,
    this.dataFim,
    this.dataVencimento,
    this.valorAluguel,
    this.valorDeposito,
    this.status,
    this.objLocacao,
    this.qtd,
    this.endereco,
    this.cidade,
    this.estado,
    this.cep,
    this.bairro,
    this.rua,
    this.numero,
    this.user,
    this.morador,
    this.unidade,
    this.imovel,
    this.dtCadastro,
    this.pdfContrato,
  });

  /// Factory para criar a partir de JSON
  factory Contrato.fromJson(Map<String, dynamic> json) {
    return Contrato(
      id: json['id'],
      dataInicio: json['dataInicio'] != null
          ? DateTime.parse(json['dataInicio'])
          : null,
      dataFim: json['dataFim'] != null ? DateTime.parse(json['dataFim']) : null,
      dataVencimento: json['dataVencimento'] != null
          ? DateTime.parse(json['dataVencimento'])
          : null,
      valorAluguel: (json['valorAluguel'] as num?)?.toDouble(),
      valorDeposito: (json['valorDeposito'] as num?)?.toDouble(),
      status: json['status'],
      objLocacao: json['objLocacao'] != null
          ? ObjetoLocacao.values.firstWhere(
              (e) => describeEnum(e) == json['objLocacao'],
              orElse: () => ObjetoLocacao.CASA_RESIDENCIAL,
            )
          : null,
      qtd: json['qtd'],
      endereco: json['endereco'],
      cidade: json['cidade'],
      estado: json['estado'],
      cep: json['cep'],
      bairro: json['bairro'],
      rua: json['rua'],
      numero: json['numero'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      morador: json['morador'] != null
          ? Morador.fromJson(json['morador'])
          : null,
      unidade: json['unidade'] != null ? Unit.fromJson(json['unidade']) : null,
      imovel: json['imovel'] != null ? Property.fromJson(json['imovel']) : null,
      dtCadastro: json['dtCadastro'] != null
          ? DateTime.parse(json['dtCadastro'])
          : null,
      pdfContrato: json['pdfContrato'],
    );
  }

  /// Converter para JSON (útil em POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dataInicio': dataInicio?.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'dataVencimento': dataVencimento?.toIso8601String(),
      'valorAluguel': valorAluguel,
      'valorDeposito': valorDeposito,
      'status': status,
      'objLocacao': objLocacao != null ? describeEnum(objLocacao!) : null,
      'qtd': qtd,
      'endereco': endereco,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'bairro': bairro,
      'rua': rua,
      'numero': numero,
      'user': user?.toJson(),
      'morador': morador?.toJson(),
      'unidade': unidade?.toMap(),
      'imovel': imovel?.toMap(),
      'dtCadastro': dtCadastro?.toIso8601String(),
      'pdfContrato': pdfContrato,
    };
  }
}
