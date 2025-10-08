class UserRole {
  final int? id;
  final String? descricao;
  final DateTime? dtCadastro;

  const UserRole({
    this.id,
    this.descricao,
    this.dtCadastro,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'],
      descricao: json['descricao'],
      dtCadastro: json['dtCadastro'] != null ? DateTime.parse(json['dtCadastro']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'dtCadastro': dtCadastro?.toIso8601String(),
    };
  }
}
