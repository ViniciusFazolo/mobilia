import 'package:flutter/material.dart';
import 'package:mobilia/controller/resident_controller.dart';
import 'package:mobilia/domain/resident.dart';
import 'package:mobilia/utils/estados.dart';
import 'package:mobilia/utils/textInputFormatter.dart';
import 'package:mobilia/utils/utils.dart';
import 'package:mobilia/utils/widget/form_layout.dart';
import 'package:mobilia/utils/widget/input.dart';
import 'package:mobilia/utils/widget/input_select.dart';
import 'package:mobilia/utils/widget/input_switch.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Resident extends StatefulWidget {
  final Morador? residentToEdit;
  
  const Resident({super.key, this.residentToEdit});

  @override
  State<Resident> createState() => _ResidentState();
}

class _ResidentState extends State<Resident> {
  ResidentController residentController = ResidentController();
  
  final cepMask = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    residentController.fetchUnit(context, () {
      if (widget.residentToEdit != null) {
        residentController.loadForEdit(widget.residentToEdit!);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.residentToEdit != null ? "Editar morador" : "Cadastrar morador";
    return FormLayout(title: title, child: _content());
  }

  _content() {
    return Form(
      key: residentController.formKey,
      child: Column(
        spacing: 10,
        children: [
          Input(label: "Nome", controller: residentController.nomeController),
          Input(
            label: "E-mail",
            controller: residentController.emailController,
          ),
          Input(
            label: "Telefone",
            controller: residentController.telefoneController,
            inputFormatters: [telefoneMask],
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Telefone obrigatório";
              }
              // Remove caracteres não numéricos para verificar se tem 10 ou 11 dígitos
              final digits = value.replaceAll(RegExp(r'[^\d]'), '');
              if (digits.length < 10 || digits.length > 11) {
                return "Telefone incompleto";
              }
              return null;
            },
          ),
          Input(label: "RG", controller: residentController.rgController),
          Input(
            label: "CPF",
            controller: residentController.cpfController,
            inputFormatters: [cpfMask],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "CPF obrigatório";
              }
              // Remove caracteres não numéricos para verificar se tem 11 dígitos
              final digits = value.replaceAll(RegExp(r'[^\d]'), '');
              if (digits.length != 11) {
                return "CPF incompleto";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text(
            "Endereço",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Input(
            label: "CEP",
            controller: residentController.cepController,
            inputFormatters: [cepMask],
            onFocusChange: (focus) async {
              if (!focus) {
                if (residentController.cepController.text.isNotEmpty) {
                  final resultado = await findCep(
                    residentController.cepController.text.replaceAll(RegExp(r'[^\d]'), ''),
                  );
                  if (resultado != null) {
                    setState(() {
                      residentController.cidadeController.text = resultado['cidade'] ?? '';
                      residentController.bairroController.text = resultado['bairro'] ?? '';
                      residentController.ruaController.text = resultado['rua'] ?? '';
                      residentController.estadoSelecionado = resultado['estado'];
                    });
                  }
                }
              }
            },
            requiredField: false,
          ),
          InputSelect<String>(
            key: ValueKey('estado_${residentController.estadoSelecionado}_${residentController.editingId}'),
            label: "Estado",
            value: residentController.estadoSelecionado,
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
                residentController.estadoSelecionado = val;
              });
            },
            validator: null,
          ),
          Input(
            label: "Cidade",
            controller: residentController.cidadeController,
            requiredField: false,
          ),
          Input(
            label: "Bairro",
            controller: residentController.bairroController,
            requiredField: false,
          ),
          Input(
            label: "Rua",
            controller: residentController.ruaController,
            requiredField: false,
          ),
          InputSelect<int>(
            key: ValueKey('unidade_${residentController.unidadeSelecionado}_${residentController.editingId}'),
            value: residentController.unidadeSelecionado != null && residentController.unidadeSelecionado != 0
                ? residentController.unidadeSelecionado
                : null,
            items: residentController.units
                .map(
                  (e) => DropdownMenuItem<int>(
                    value: e.id,
                    child: Text(e.identificacao),
                  ),
                )
                .toList(),
            label: "Responsável por qual unidade?",
            onChanged: (value) {
              setState(() {
                residentController.unidadeSelecionado = value;
              });
            },
          ),
          InputSwitch(
            label: "Ativo?",
            value: residentController.ativo,
            onChanged: (val) {
              setState(() {
                residentController.ativo = val;
              });
            },
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: residentController.isLoading
                  ? null
                  : () async {
                      final success = await residentController.submitForm(
                        context,
                        () => setState(() {}),
                      );
                      // Volta para a listagem após salvar (tanto para cadastro quanto edição)
                      if (success && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: residentController.isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Salvar"),
            ),
          ),
        ],
      ),
    );
  }
}
