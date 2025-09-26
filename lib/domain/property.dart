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
      imagem: json['imagem'],
      ativo: json['ativo'] == true || json['ativo'] == "true",
      dtCadastro: json['dtCadastro'] != null
          ? DateTime.tryParse(json['dtCadastro'])
          : null,
    );
  }
}
