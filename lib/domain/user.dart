import 'package:mobilia/domain/user_role.dart';

class User {
  final int? id;
  final String? login;
  final String? email;
  final String? nome;
  final String? cpf;
  final String? rg;
  final String? endereco;
  final String? numero;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final String? cep;
  final String? telefone;
  final String? pw;
  final bool? ativo;
  final DateTime? dtCadastro;
  final UserRole? userRole;

  const User({
    this.id,
    this.login,
    this.email,
    this.nome,
    this.cpf,
    this.rg,
    this.endereco,
    this.numero,
    this.bairro,
    this.cidade,
    this.estado,
    this.cep,
    this.telefone,
    this.pw,
    this.ativo,
    this.dtCadastro,
    this.userRole,
  });

  /// Cria um objeto `User` a partir de JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      login: json['login'],
      email: json['email'],
      nome: json['nome'],
      cpf: json['cpf'],
      rg: json['rg'],
      endereco: json['endereco'],
      numero: json['numero'],
      bairro: json['bairro'],
      cidade: json['cidade'],
      estado: json['estado'],
      cep: json['cep'],
      telefone: json['telefone'],
      pw: json['pw'],
      ativo: json['ativo'],
      dtCadastro: json['dtCadastro'] != null ? DateTime.parse(json['dtCadastro']) : null,
      userRole: json['userRole'] != null ? UserRole.fromJson(json['userRole']) : null,
    );
  }

  /// Converte o objeto `User` em JSON (para POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'email': email,
      'nome': nome,
      'cpf': cpf,
      'rg': rg,
      'endereco': endereco,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'telefone': telefone,
      'pw': pw,
      'ativo': ativo,
      'dtCadastro': dtCadastro?.toIso8601String(),
      'userRole': userRole?.toJson(),
    };
  }
}
