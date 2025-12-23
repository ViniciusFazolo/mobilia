import 'package:flutter/material.dart';
import 'package:mobilia/controller/profile_controller.dart';
import 'package:mobilia/utils/estados.dart';
import 'package:mobilia/utils/utils.dart';
import 'package:mobilia/utils/widget/button.dart';
import 'package:mobilia/utils/widget/input.dart';
import 'package:mobilia/utils/widget/input_select.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ProfileController profileController = ProfileController();
  
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
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await profileController.loadUserData();
    setState(() {});
  }

  @override
  void dispose() {
    profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meu Perfil"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: profileController.isLoading && profileController.loginController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: profileController.formKey,
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
                      controller: profileController.loginController,
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
                      controller: profileController.emailController,
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
                      controller: profileController.nomeController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Nome obrigatório";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Input(
                      label: "Senha (deixe em branco para não alterar)",
                      controller: profileController.pwController,
                      obscureText: true,
                      requiredField: false,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length < 6) {
                          return "Senha deve ter no mínimo 6 caracteres";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Input(
                      label: "Confirmar Senha",
                      controller: profileController.confirmPwController,
                      obscureText: true,
                      requiredField: false,
                      validator: (value) {
                        if (profileController.pwController.text.isNotEmpty) {
                          if (value == null || value.isEmpty) {
                            return "Confirmação de senha obrigatória";
                          }
                          if (value != profileController.pwController.text) {
                            return "Senhas não coincidem";
                          }
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
                      controller: profileController.cpfController,
                      inputFormatters: [cpfMask],
                      requiredField: false,
                    ),
                    const SizedBox(height: 16),
                    Input(
                      label: "RG",
                      controller: profileController.rgController,
                      requiredField: false,
                    ),
                    const SizedBox(height: 16),
                    Input(
                      label: "Telefone",
                      controller: profileController.telefoneController,
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
                      controller: profileController.cepController,
                      inputFormatters: [cepMask],
                      onFocusChange: (focus) async {
                        if (!focus) {
                          if (profileController.cepController.text.isNotEmpty) {
                            final resultado = await findCep(
                              profileController.cepController.text.replaceAll(RegExp(r'[^\d]'), ''),
                            );
                            if (resultado != null) {
                              setState(() {
                                profileController.cidadeController.text = resultado['cidade'] ?? '';
                                profileController.bairroController.text = resultado['bairro'] ?? '';
                                profileController.enderecoController.text = resultado['rua'] ?? '';
                                profileController.estadoSelecionado = resultado['estado'];
                              });
                            }
                          }
                        }
                      },
                      requiredField: false,
                    ),
                    const SizedBox(height: 16),
                    InputSelect<String>(
                      key: ValueKey('estado_${profileController.estadoSelecionado}'),
                      label: "Estado",
                      value: profileController.estadoSelecionado,
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
                          profileController.estadoSelecionado = val;
                        });
                      },
                      validator: null,
                    ),
                    const SizedBox(height: 16),
                    Input(
                      label: "Cidade",
                      controller: profileController.cidadeController,
                      requiredField: false,
                    ),
                    const SizedBox(height: 16),
                    Input(
                      label: "Bairro",
                      controller: profileController.bairroController,
                      requiredField: false,
                    ),
                    const SizedBox(height: 16),
                    Input(
                      label: "Rua/Logradouro",
                      controller: profileController.enderecoController,
                      requiredField: false,
                    ),
                    const SizedBox(height: 16),
                    Input(
                      label: "Número",
                      controller: profileController.numeroController,
                      requiredField: false,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 56,
                      child: Button(
                        label: profileController.isLoading ? "Salvando..." : "Salvar Alterações",
                        onPressed: profileController.isLoading
                            ? null
                            : () async {
                                final success = await profileController.updateProfile(context);
                                if (success && context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}

