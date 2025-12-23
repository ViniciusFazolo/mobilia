import 'package:flutter/material.dart';
import 'package:mobilia/controller/register_controller.dart';
import 'package:mobilia/utils/estados.dart';
import 'package:mobilia/utils/utils.dart';
import 'package:mobilia/utils/widget/button.dart';
import 'package:mobilia/utils/widget/input.dart';
import 'package:mobilia/utils/widget/input_select.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final RegisterController registerController = RegisterController();
  
  final loginController = TextEditingController();
  final emailController = TextEditingController();
  final nomeController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();
  final cpfController = TextEditingController();
  final rgController = TextEditingController();
  final enderecoController = TextEditingController();
  final numeroController = TextEditingController();
  final bairroController = TextEditingController();
  final cidadeController = TextEditingController();
  final cepController = TextEditingController();
  final telefoneController = TextEditingController();
  
  String? estadoSelecionado;
  bool isLoading = false;

  final cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final cepMask = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    loginController.dispose();
    emailController.dispose();
    nomeController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    cpfController.dispose();
    rgController.dispose();
    enderecoController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    cepController.dispose();
    telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Usuário"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Dados de Acesso",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Input(
                label: "Login *",
                controller: loginController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Login obrigatório";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Input(
                label: "E-mail *",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "E-mail obrigatório";
                  }
                  if (!value.contains('@')) {
                    return "E-mail inválido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Input(
                label: "Nome *",
                controller: nomeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nome obrigatório";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Input(
                label: "Senha *",
                controller: pwController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Senha obrigatória";
                  }
                  if (value.length < 6) {
                    return "Senha deve ter no mínimo 6 caracteres";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Input(
                label: "Confirmar Senha *",
                controller: confirmPwController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Confirmação de senha obrigatória";
                  }
                  if (value != pwController.text) {
                    return "Senhas não coincidem";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              const Text(
                "Dados Pessoais (Opcional)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Input(
                label: "CPF",
                controller: cpfController,
                inputFormatters: [cpfMask],
                requiredField: false,
              ),
              const SizedBox(height: 16),
              Input(
                label: "RG",
                controller: rgController,
                requiredField: false,
              ),
              const SizedBox(height: 16),
              Input(
                label: "Telefone",
                controller: telefoneController,
                inputFormatters: [telefoneMask],
                keyboardType: TextInputType.phone,
                requiredField: false,
              ),
              const SizedBox(height: 32),
              const Text(
                "Endereço (Opcional)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Input(
                label: "CEP",
                controller: cepController,
                inputFormatters: [cepMask],
                onFocusChange: (focus) async {
                  if (!focus) {
                    if (cepController.text.isNotEmpty) {
                      final resultado = await findCep(
                        cepController.text.replaceAll(RegExp(r'[^\d]'), ''),
                      );
                      if (resultado != null) {
                        setState(() {
                          cidadeController.text = resultado['cidade'] ?? '';
                          bairroController.text = resultado['bairro'] ?? '';
                          enderecoController.text = resultado['rua'] ?? '';
                          estadoSelecionado = resultado['estado'];
                        });
                      }
                    }
                  }
                },
                requiredField: false,
              ),
              const SizedBox(height: 16),
              InputSelect<String>(
                label: "Estado",
                value: estadoSelecionado,
                items: estados
                    .map(
                      (e) => DropdownMenuItem(
                        value: e["sigla"],
                        child: Text(e["nome"]!),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    estadoSelecionado = val;
                  });
                },
                validator: null,
              ),
              const SizedBox(height: 16),
              Input(
                label: "Cidade",
                controller: cidadeController,
                requiredField: false,
              ),
              const SizedBox(height: 16),
              Input(
                label: "Bairro",
                controller: bairroController,
                requiredField: false,
              ),
              const SizedBox(height: 16),
              Input(
                label: "Rua/Logradouro",
                controller: enderecoController,
                requiredField: false,
              ),
              const SizedBox(height: 16),
              Input(
                label: "Número",
                controller: numeroController,
                requiredField: false,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: Button(
                  label: isLoading ? "Registrando..." : "Registrar",
                  onPressed: isLoading ? null : _onRegister,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final cpfDigits = cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
    final telefoneDigits = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    final cepDigits = cepController.text.replaceAll(RegExp(r'[^\d]'), '');

    await registerController.register(
      context,
      login: loginController.text,
      email: emailController.text,
      nome: nomeController.text,
      pw: pwController.text,
      cpf: cpfDigits.isNotEmpty ? cpfDigits : null,
      rg: rgController.text.isNotEmpty ? rgController.text : null,
      endereco: enderecoController.text.isNotEmpty ? enderecoController.text : null,
      numero: numeroController.text.isNotEmpty ? numeroController.text : null,
      bairro: bairroController.text.isNotEmpty ? bairroController.text : null,
      cidade: cidadeController.text.isNotEmpty ? cidadeController.text : null,
      estado: estadoSelecionado,
      cep: cepDigits.isNotEmpty ? cepDigits : null,
      telefone: telefoneDigits.isNotEmpty ? telefoneDigits : null,
    );

    setState(() {
      isLoading = false;
    });
  }
}

