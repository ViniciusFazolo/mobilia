import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobilia/service/property_service.dart';
import 'package:mobilia/utils/estados.dart';
import 'package:mobilia/utils/utils.dart';
import 'package:mobilia/widget/form_layout.dart';
import 'package:mobilia/widget/input.dart';
import 'package:mobilia/widget/input_image.dart';
import 'package:mobilia/widget/input_select.dart';
import 'package:mobilia/widget/input_switch.dart';

class Property extends StatefulWidget {
  const Property({super.key});

  @override
  State<Property> createState() => _PropertyState();
}

class _PropertyState extends State<Property> {
  final _formKey = GlobalKey<FormState>();
  bool isActive = true;
  String? estadoSelecionado;
  File? imagem;
  final nomeController = TextEditingController();
  final cepController = TextEditingController();
  final estadoController = TextEditingController();
  final cidadeController = TextEditingController();
  final bairroController = TextEditingController();
  final ruaController = TextEditingController();
  final numeroController = TextEditingController();
  final complementoController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FormLayout(title: "Cadastrar imóvel", child: content());
  }

  content() {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 10,
        children: [
          InputSwitch(
            label: "Ativo?",
            value: isActive,
            onChanged: (val) {
              setState(() {
                isActive = val;
              });
            },
          ),
          Input(label: "Nome", controller: nomeController),
          Input(
            label: "CEP",
            controller: cepController,
            onFocusChange: (focus) async {
              if (!focus) {
                if (cepController.text.isNotEmpty) {
                  final resultado = await findCep(cepController.text);
                  if (resultado != null) {
                    setState(() {
                      cidadeController.text = resultado['cidade']!;
                      bairroController.text = resultado['bairro']!;
                      ruaController.text = resultado['rua']!;
                      estadoSelecionado = resultado['estado']!;
                    });
                  }
                }
              }
            },
          ),
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
                // A validação automática do InputSelect vai remover a mensagem de erro
              });
            },
            validator: (val) {
              if (val == null) return "Campo obrigatório";
              return null;
            },
          ),
          Input(label: "Cidade", controller: cidadeController),
          Input(label: "Bairro", controller: bairroController),
          Input(label: "Rua", controller: ruaController),
          Input(
            label: "Número",
            controller: numeroController,
            requiredField: false,
          ),
          Input(
            label: "Complemento",
            controller: complementoController,
            requiredField: false,
          ),
          InputImage(
            label: "Imagem do imóvel",
            multiple: false,
            onChanged: (file) {
              setState(() {
                imagem = file;
              });
            },
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text("Salvar"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final service = PropertyService(baseUrl: apiBaseUrl);

    final imagens = imagem != null ? [imagem!] : <File>[];

    setState(() {
      isLoading = true;
    });

    final response = await service.createProperty(
      ativo: isActive,
      nome: nomeController.text,
      cep: cepController.text,
      estado: estadoSelecionado ?? '',
      cidade: cidadeController.text,
      bairro: bairroController.text,
      rua: ruaController.text,
      numero: numeroController.text,
      complemento: complementoController.text,
      imagens: imagens,
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Imóvel cadastrado com sucesso!")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erro ao cadastrar imóvel")));
    }
  }
}
