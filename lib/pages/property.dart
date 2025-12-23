import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobilia/domain/property.dart' as domain;
import 'package:mobilia/service/property_service.dart';
import 'package:mobilia/utils/estados.dart';
import 'package:mobilia/utils/utils.dart';
import 'package:mobilia/utils/widget/form_layout.dart';
import 'package:mobilia/utils/widget/input.dart';
import 'package:mobilia/utils/widget/input_image.dart';
import 'package:mobilia/utils/widget/input_select.dart';
import 'package:mobilia/utils/widget/input_switch.dart';

class Property extends StatefulWidget {
  final domain.Property? propertyToEdit;
  
  const Property({super.key, this.propertyToEdit});

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
  void initState() {
    super.initState();
    if (widget.propertyToEdit != null) {
      _loadForEdit(widget.propertyToEdit!);
    }
  }

  void _loadForEdit(domain.Property property) {
    isActive = property.ativo;
    nomeController.text = property.nome;
    cepController.text = property.cep;
    estadoSelecionado = property.estado;
    cidadeController.text = property.cidade;
    bairroController.text = property.bairro;
    ruaController.text = property.rua;
    numeroController.text = property.numero?.toString() ?? '';
    complementoController.text = property.complemento ?? '';
    
    // Debug: verifica se a imagem foi carregada
    print('DEBUG _loadForEdit - property.imagem: ${property.imagem}');
    print('DEBUG _loadForEdit - property.imagens: ${property.imagens}');
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.propertyToEdit != null ? "Editar imóvel" : "Cadastrar imóvel";
    return FormLayout(title: title, child: content());
  }

  content() {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 10,
        children: [
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
          Builder(
            builder: (context) {
              final imageUrl = widget.propertyToEdit?.imagem ?? 
                  (widget.propertyToEdit?.imagens != null && widget.propertyToEdit!.imagens!.isNotEmpty
                      ? widget.propertyToEdit!.imagens!.first
                      : null);
              print('DEBUG InputImage widget - imageUrl: $imageUrl');
              return InputImage(
                label: "Imagem do imóvel",
                multiple: false,
                initialImageUrl: imageUrl,
                onChanged: (file) {
                  setState(() {
                    imagem = file;
                  });
                },
              );
            },
          ),
          InputSwitch(
            label: "Ativo?",
            value: isActive,
            onChanged: (val) {
              setState(() {
                isActive = val;
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

    final response = widget.propertyToEdit != null && widget.propertyToEdit!.id != null
        ? await service.updateProperty(
            id: widget.propertyToEdit!.id!,
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
          )
        : await service.createProperty(
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
        SnackBar(
          content: Text(widget.propertyToEdit != null
              ? "Imóvel atualizado com sucesso!"
              : "Imóvel cadastrado com sucesso!"),
        ),
      );

      if (widget.propertyToEdit == null) {
        _formKey.currentState!.reset();

        nomeController.clear();
        cepController.clear();
        cidadeController.clear();
        bairroController.clear();
        ruaController.clear();
        numeroController.clear();
        complementoController.clear();

        setState(() {
          estadoSelecionado = null;
          imagem = null;
          isActive = true;
        });
      } else {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(widget.propertyToEdit != null
              ? "Erro ao atualizar imóvel"
              : "Erro ao cadastrar imóvel"),
        ),
      );
    }
  }
}
