import 'package:mobilia/domain/contract.dart';

class Parcela {
  final int? id;
  final Contrato? contrato;
  final int? numeroParcela;
  final DateTime? dataVencimento;
  final double? valor;
  final DateTime? dataPagamento;
  final StatusParcela? status;

  Parcela({
    this.id,
    this.contrato,
    this.numeroParcela,
    this.dataVencimento,
    this.valor,
    this.dataPagamento,
    this.status,
  });

  factory Parcela.fromJson(Map<String, dynamic> json) {
    return Parcela(
      id: json['id'],
      contrato: json['contrato'] != null ? Contrato.fromJson(json['contrato']) : null,
      numeroParcela: json['numeroParcela'],
      dataVencimento: json['dataVencimento'] != null
          ? DateTime.parse(json['dataVencimento'])
          : null,
      valor: (json['valor'] as num?)?.toDouble(),
      dataPagamento: json['dataPagamento'] != null
          ? DateTime.parse(json['dataPagamento'])
          : null,
      status: json['status'] != null
          ? StatusParcela.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => StatusParcela.PENDENTE,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contrato': contrato?.toJson(),
      'numeroParcela': numeroParcela,
      'dataVencimento': dataVencimento?.toIso8601String(),
      'valor': valor,
      'dataPagamento': dataPagamento?.toIso8601String(),
      'status': status?.name,
    };
  }
}

enum StatusParcela {
  PENDENTE,
  PAGO,
}
